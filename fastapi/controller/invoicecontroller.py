from datetime import datetime
from fastapi import HTTPException
from sqlalchemy import extract
from sqlalchemy.orm import Session
from db.models.leases import Lease
from db.models.units import Unit
from db.models.properties import Property
from db.models.invoices import Invoice
from db.models.payments import Payment
from db.models.unit_utility import UnitUtility
from db.models.meter_readings import MeterReading
from db.models.renters import Renter
from db.models.user import User
from schemas.invoice import InvoiceCreate

def create_invoice(db: Session, data: InvoiceCreate, current_user):
    try:
        lease = (
            db.query(Lease)
            .join(Unit, Lease.unit_id == Unit.id)
            .join(Property, Unit.property_id == Property.id)
            .filter(Lease.id == int(data.lease_id))
            .filter(Property.owner_id == current_user.id)
            .first()
        )

        if not lease:
            raise HTTPException(status_code=404, detail="Lease not found or unauthorized.")
        
        date_obj = datetime.strptime(data.month, "%Y-%m-%d").date()
        duplicate_invoice = (
            db.query(Invoice)
            .filter(Payment.lease_id == data.lease_id)
            .filter(extract('month', Payment.payment_date) == date_obj.month)
            .filter(extract('year', Payment.payment_date) == date_obj.year)
            .first()
        )

        if duplicate_invoice:
            raise HTTPException(status_code=400, detail="An invoice already exists for this lease on the specified due date.")
        
        payment_exists = (
            db.query(Payment)
            .filter(Payment.lease_id == data.lease_id)
            .filter(extract('month', Payment.payment_date) == date_obj.month)
            .filter(extract('year', Payment.payment_date) == date_obj.year)
            .first()
        )

        lease_exists = (
            db.query(Lease)
            .filter(Lease.id == data.lease_id, Lease.status == 'active')
            .first()
        )

        if not lease_exists:
            raise HTTPException(status_code=400, detail="Lease not found or inactive.")
        
        unit_utilities = db.query(UnitUtility).filter(UnitUtility.unit_id == lease.unit_id).all()
        total_utility = 0.0

        for utility in unit_utilities:
            if utility.billing_type == 'fixed':
                total_utility += utility.fixed_rate or 0
            elif utility.billing_type == 'per_unit':
                meter_reading = (
                    db.query(MeterReading)
                    .filter(
                        MeterReading.unit_id == lease.unit_id,
                        MeterReading.utility_type_id == utility.utility_type_id,
                        extract('month', MeterReading.reading_date) == date_obj.month,
                        extract('year', MeterReading.reading_date) == date_obj.year
                    )
                    .order_by(MeterReading.reading_date.desc())
                    .first()
                )

                if meter_reading and utility.unit_rate:
                    usage = meter_reading.usage or (
                        (meter_reading.current_reading - meter_reading.previous_reading)
                        if meter_reading.current_reading is not None and meter_reading.previous_reading is not None
                        else 0
                    )
                    total_utility += usage * utility.unit_rate

        rent_amount = lease.rent_amount
        total_amount = float(rent_amount) + float(total_utility)

        new_invoice = Invoice(
            lease_id=data.lease_id,
            month=data.month,
            rent=payment_exists.amount_paid if payment_exists else lease_exists.rent_amount,
            utility=total_utility,
            total=total_amount,
            status='paid' if payment_exists else 'unpaid'
        )

        db.add(new_invoice)
        db.commit()
        db.refresh(new_invoice)

        return {
            "message": "Invoice created successfully",
            "invoice_id": new_invoice.id
        }

    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating invoice: {str(e)}")

def get_active_leases(db: Session, current_user):
    try:
        leases = (
            db.query(Lease, Unit, Property)
            .outerjoin(Unit, Lease.unit_id == Unit.id)
            .outerjoin(Property, Unit.property_id == Property.id)
            .filter((Lease.status == "active") & (Property.owner_id == current_user.id))
            .all()
        )

        return [
            {
                "lease_id": lease.id,
                "unit_id": lease.unit_id,
                "unit_number": unit.unit_number,
                "renter_id": lease.renter_id
            }
            for lease, unit, property in leases
        ]

    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating payment: {str(e)}")
    
def get_invoices(db: Session, current_user):
    try:
        invoices = (
            db.query(Invoice, Lease, Unit, Renter, User)
            .join(Lease, Invoice.lease_id == Lease.id)
            .join(Unit, Lease.unit_id == Unit.id)
            .join(Renter, Lease.renter_id == Renter.id)
            .join(User, Renter.user_id == User.id)
            .join(Property, Unit.property_id == Property.id)
            .filter(Property.owner_id == current_user.id)
            .order_by(Invoice.month.desc())
            .all()
        )

        result = []
        for invoice, lease, unit, renter, user in invoices:
            invoice_month = invoice.month

            # Calculate cost per utility type
            utilities = []
            unit_utils = (
                db.query(UnitUtility)
                .filter(UnitUtility.unit_id == lease.unit_id)
                .all()
            )

            for u in unit_utils:
                util_entry = {
                    "utility_type_id": u.utility_type_id,
                    "billing_type": u.billing_type,
                    "unit_rate": u.unit_rate,
                    "fixed_rate": u.fixed_rate,
                }

                if u.billing_type == "per_unit":
                    reading = (
                        db.query(MeterReading)
                        .filter(
                            MeterReading.unit_id == lease.unit_id,
                            MeterReading.utility_type_id == u.utility_type_id,
                            extract('month', MeterReading.reading_date) == invoice_month.month,
                            extract('year', MeterReading.reading_date) == invoice_month.year,
                        )
                        .order_by(MeterReading.reading_date.desc())
                        .first()
                    )
                    if reading:
                        usage = reading.usage or (
                            reading.current_reading - reading.previous_reading
                            if reading.current_reading and reading.previous_reading else 0
                        )
                        util_entry.update({
                            "previous_reading": reading.previous_reading,
                            "current_reading": reading.current_reading,
                            "usage": usage,
                            "cost": usage * u.unit_rate if u.unit_rate else None
                        })
                else:
                    util_entry["cost"] = u.fixed_rate

                utilities.append(util_entry)

            result.append({
                "id": invoice.id,
                "month": invoice.month,
                "rent": invoice.rent,
                "utility": invoice.utility,
                "total": invoice.total,
                "status": invoice.status,
                "unit_id": lease.unit_id,
                "unit_number": unit.unit_number,
                "renter_name": user.userName,
                "utilities": utilities
            })

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching invoices: {str(e)}")
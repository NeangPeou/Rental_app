from fastapi import HTTPException
from sqlalchemy.orm import Session, aliased
from sqlalchemy import desc
from schemas.payment import PaymentCreate, PaymentUpdate
from db.models.payments import Payment
from db.models.leases import Lease
from db.models.units import Unit
from db.models.user import User
from db.models.properties import Property

Owner = aliased(User)
Renter = aliased(User)

def create_payment(db: Session, data: PaymentCreate, current_user):
    try:
        lease = db.query(Lease).filter(Lease.id == data.lease_id).first()
        if not lease:
            raise HTTPException(status_code=400, detail="Invalid lease ID")

        payment = Payment(
            lease_id=data.lease_id,
            payment_date=data.payment_date,
            amount_paid=data.amount_paid,
            method=data.payment_method_id,
            receipt_url=data.receipt_url,
        )

        unit = db.query(Unit).filter(Unit.id == lease.unit_id).first()
        property = db.query(Property).filter(Property.id == unit.property_id).first() if unit else None
        renter = db.query(User).filter(User.id == lease.renter_id).first()
        owner = db.query(User).filter(User.id == property.owner_id).first() if property else None

        db.add(payment)
        db.commit()
        db.refresh(payment)

        return {
            'id': str(payment.id),
            'lease_id': payment.lease_id,
            'payment_date': payment.payment_date,
            'amount_paid': payment.amount_paid,
            'payment_method_id': payment.method,
            'receipt_url': payment.receipt_url,
            'property_name': property.name if property else '',
            'unit_number': unit.unit_number if unit else '',
            'renter_name': renter.userName if renter else '',
            'owner_name': owner.userName if owner else '',
        }
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating payment: {str(e)}")

def get_all_payments(db: Session, current_user):
    try:
        payments = (
            db.query(Payment, Lease, Unit, Renter, Property, Owner)
            .outerjoin(Lease, Payment.lease_id == Lease.id)
            .outerjoin(Unit, Lease.unit_id == Unit.id)
            .outerjoin(Renter, Lease.renter_id == Renter.id)
            .outerjoin(Property, Unit.property_id == Property.id)
            .outerjoin(Owner, Property.owner_id == Owner.id)
            .order_by(desc(Payment.id))
            .all()
        )

        return [{
            'id': str(payment.id),
            'lease_id': payment.lease_id,
            'payment_date': payment.payment_date,
            'amount_paid': payment.amount_paid,
            'payment_method_id': payment.method,
            'receipt_url': payment.receipt_url,
            'property_name': property.name,
            'unit_number': unit.unit_number,
            'renter_name': '' if user is None else user.userName,
            'owner_name': '' if owner is None else owner.userName
        } for payment, lease, unit, user, property, owner in payments]

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching payments: {str(e)}")

def update_payment(db: Session, payment_id: int, data: PaymentUpdate, current_user):
    try:
        payment = db.get(Payment, payment_id)
        if not payment:
            raise HTTPException(status_code=404, detail="Payment not found")

        if data.lease_id is not None:
            lease = db.query(Lease).filter(Lease.id == data.lease_id).first()
            if not lease:
                raise HTTPException(status_code=400, detail="Invalid lease ID")
            payment.lease_id = data.lease_id

        if data.payment_date is not None:
            payment.payment_date = data.payment_date

        if data.amount_paid is not None:
            payment.amount_paid = data.amount_paid

        if data.payment_method_id is not None:
            payment.method = data.payment_method_id

        if data.receipt_url is not None:
            payment.receipt_url = data.receipt_url

        lease = db.query(Lease).filter(Lease.id == payment.lease_id).first()
        unit = db.query(Unit).filter(Unit.id == lease.unit_id).first() if lease else None
        property = db.query(Property).filter(Property.id == unit.property_id).first() if unit else None
        renter = db.query(User).filter(User.id == lease.renter_id).first() if lease else None
        owner = db.query(User).filter(User.id == property.owner_id).first() if property else None

        db.commit()
        db.refresh(payment)

        return {
            'id': str(payment.id),
            'lease_id': payment.lease_id,
            'payment_date': payment.payment_date,
            'amount_paid': payment.amount_paid,
            'payment_method_id': payment.method,
            'receipt_url': payment.receipt_url,
            'property_name': property.name if property else '',
            'unit_number': unit.unit_number if unit else '',
            'renter_name': renter.userName if renter else '',
            'owner_name': owner.userName if owner else '',
        }

    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error updating payment: {str(e)}")

def delete_payment(db: Session, payment_id: int, current_user):
    try:
        payment = db.get(Payment, payment_id)
        if not payment:
            raise HTTPException(status_code=404, detail="Payment not found")

        return_data = {
            'id': str(payment.id),
            'lease_id': payment.lease_id,
            'payment_date': payment.payment_date,
            'amount_paid': payment.amount_paid,
            'payment_method_id': payment.method,
            'receipt_url': payment.receipt_url,
        }

        db.delete(payment)
        db.commit()

        return return_data

    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting payment: {str(e)}")

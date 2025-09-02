from fastapi import HTTPException
from sqlalchemy.orm import Session
from schemas.leases import LeaseCreate, LeaseUpdate, LeaseOut
from db.models.leases import Lease
from db.models.units import Unit
from db.models.renters import Renter
from db.models.user import User
from db.models.properties import Property

def create_lease(db: Session, data: LeaseCreate, current_user):
    try:
        unit = db.query(Unit).filter(Unit.id == data.unit_id).first()
        if not unit:
            raise HTTPException(status_code=404, detail="Unit not found")
        if not unit.is_available:
            raise HTTPException(status_code=400, detail="Unit is not available")

        renter = db.query(Renter).filter(Renter.id == data.renter_id).first()
        if not renter:
            raise HTTPException(status_code=404, detail="Renter not found")

        lease = Lease(
            unit_id=data.unit_id,
            renter_id=data.renter_id,
            start_date=data.start_date,
            end_date=data.end_date,
            rent_amount=data.rent_amount,
            deposit_amount=data.deposit_amount,
            status=data.status
        )

        # Update unit availability
        unit.is_available = False
        db.add(lease)
        db.commit()
        db.refresh(lease)

        # Fetch username
        user = db.query(User).filter(User.id == renter.user_id).first()
        return LeaseOut(
            id=lease.id,
            unit_id=lease.unit_id,
            renter_id=lease.renter_id,
            start_date=lease.start_date,
            end_date=lease.end_date,
            rent_amount=lease.rent_amount,
            deposit_amount=lease.deposit_amount,
            status=lease.status,
            username=user.userName if user else None
        )
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating lease: {str(e)}")

def get_all_leases(db: Session, current_user):
    try:
        query = (
            db.query(Lease, User.userName, Unit)
            .join(Renter, Renter.id == Lease.renter_id)
            .join(User, User.id == Renter.user_id)
            .join(Unit, Unit.id == Lease.unit_id)
            .join(Property, Property.id == Unit.property_id) 
        )

        query = query.filter(
            (User.id == current_user.id) | (Property.owner_id == current_user.id) 
        )

        leases = query.all()
        return [
            LeaseOut(
                id=lease.id,
                unit_id=lease.unit_id,
                renter_id=lease.renter_id,
                start_date=lease.start_date,
                end_date=lease.end_date,
                rent_amount=lease.rent_amount,
                deposit_amount=lease.deposit_amount,
                status=lease.status,
                username=username,
                unit_number=unit.unit_number
            ) for lease, username, unit in leases
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching leases: {str(e)}")

def update_lease(db: Session, lease_id: int, data: LeaseUpdate, current_user):
    try:
        lease = db.get(Lease, lease_id)
        if not lease:
            raise HTTPException(status_code=404, detail="Lease not found")

        if data.unit_id is not None:
            unit = db.query(Unit).filter(Unit.id == data.unit_id).first()
            if not unit:
                raise HTTPException(status_code=404, detail="Unit not found")
            lease.unit_id = data.unit_id
            unit.is_available = False  # Update unit availability
        if data.renter_id is not None:
            renter = db.query(Renter).filter(Renter.id == data.renter_id).first()
            if not renter:
                raise HTTPException(status_code=404, detail="Renter not found")
            lease.renter_id = data.renter_id
        if data.start_date is not None:
            lease.start_date = data.start_date
        if data.end_date is not None:
            lease.end_date = data.end_date
        if data.rent_amount is not None:
            lease.rent_amount = data.rent_amount
        if data.deposit_amount is not None:
            lease.deposit_amount = data.deposit_amount
        if data.status is not None:
            lease.status = data.status
            if data.status in ["terminated", "expired"]:
                unit = db.query(Unit).filter(Unit.id == lease.unit_id).first()
                if unit:
                    unit.is_available = True

        db.commit()
        db.refresh(lease)

        user = db.query(User).join(Renter, Renter.id == lease.renter_id).filter(User.id == Renter.user_id).first()
        return LeaseOut(
            id=lease.id,
            unit_id=lease.unit_id,
            renter_id=lease.renter_id,
            start_date=lease.start_date,
            end_date=lease.end_date,
            rent_amount=lease.rent_amount,
            deposit_amount=lease.deposit_amount,
            status=lease.status,
            username=user.userName if user else None
        )
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error updating lease: {str(e)}")

def delete_lease(db: Session, lease_id: int):
    try:
        lease = db.get(Lease, lease_id)
        if not lease:
            raise HTTPException(status_code=404, detail="Lease not found")

        unit = db.query(Unit).filter(Unit.id == lease.unit_id).first()
        if unit:
            unit.is_available = True

        db.delete(lease)
        db.commit()

        user = db.query(User).join(Renter, Renter.id == lease.renter_id).filter(User.id == Renter.user_id).first()
        return LeaseOut(
            id=lease.id,
            unit_id=lease.unit_id,
            renter_id=lease.renter_id,
            start_date=lease.start_date,
            end_date=lease.end_date,
            rent_amount=lease.rent_amount,
            deposit_amount=lease.deposit_amount,
            status=lease.status,
            username=user.userName if user else None
        )
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting lease: {str(e)}")
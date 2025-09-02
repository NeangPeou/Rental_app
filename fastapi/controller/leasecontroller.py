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
            status=data.status,
        )

        db.add(lease)
        db.commit()
        db.refresh(lease)

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
            username=user.userName if user else None,
            unit_number=unit.unit_number if unit else None,
        )
    except HTTPException as http_exc:
        db.rollback()
        raise http_exc
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating lease: {str(e)}")


def get_all_leases(db: Session, current_user):
    try:
        leases = db.query(Lease, User.userName, Unit.unit_number).\
            join(Renter, Renter.id == Lease.renter_id).\
            join(User, User.id == Renter.user_id).\
            join(Unit, Unit.id == Lease.unit_id).all()
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
                unit_number=unit_number  # Include unit_number
            ) for lease, username, unit_number in leases
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching leases: {str(e)}")

def update_lease(db: Session, lease_id: int, data: LeaseUpdate, current_user):
    try:
        lease = db.get(Lease, lease_id)
        if not lease:
            raise HTTPException(status_code=404, detail="Lease not found")

        # Handle unit update
        if data.unit_id is not None and data.unit_id != lease.unit_id:
            new_unit = db.query(Unit).filter(Unit.id == data.unit_id).first()
            if not new_unit:
                raise HTTPException(status_code=404, detail="Unit not found")
            lease.unit_id = data.unit_id

        # Handle renter update
        if data.renter_id is not None:
            renter = db.query(Renter).filter(Renter.id == data.renter_id).first()
            if not renter:
                raise HTTPException(status_code=404, detail="Renter not found")
            lease.renter_id = data.renter_id

        # Other fields
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

        db.commit()
        db.refresh(lease)

        # Query related data for response
        renter = db.query(Renter).filter(Renter.id == lease.renter_id).first()
        user = db.query(User).filter(User.id == renter.user_id).first() if renter else None
        unit = db.query(Unit).filter(Unit.id == lease.unit_id).first()

        return LeaseOut(
            id=lease.id,
            unit_id=lease.unit_id,
            renter_id=lease.renter_id,
            start_date=lease.start_date,
            end_date=lease.end_date,
            rent_amount=lease.rent_amount,
            deposit_amount=lease.deposit_amount,
            status=lease.status,
            username=user.userName if user else None,
            unit_number=unit.unit_number if unit else None
        )

    except HTTPException as http_exc:
        db.rollback()
        raise http_exc
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating lease: {str(e)}")


def delete_lease(db: Session, lease_id: int):
    try:
        lease = db.get(Lease, lease_id)
        if not lease:
            raise HTTPException(status_code=404, detail="Lease not found")

        unit = db.query(Unit).filter(Unit.id == lease.unit_id).with_for_update().first()
        if unit:
            unit.is_available = True

        db.delete(lease)
        db.commit()

        user = db.query(User).join(Renter, Renter.id == lease.renter_id).filter(User.id == Renter.user_id).first()
        unit = db.query(Unit).filter(Unit.id == lease.unit_id).first()
        return LeaseOut(
            id=lease.id,
            unit_id=lease.unit_id,
            renter_id=lease.renter_id,
            start_date=lease.start_date,
            end_date=lease.end_date,
            rent_amount=lease.rent_amount,
            deposit_amount=lease.deposit_amount,
            status=lease.status,
            username=user.userName if user else None,
            unit_number=unit.unit_number if unit else None  # Include unit_number
        )
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error deleting lease: {str(e)}")
from fastapi import HTTPException
from sqlalchemy import desc
from sqlalchemy.orm import Session
from schemas.units import PropertyUnitCreate, PropertyUnitUpdate
from db.models.units import Unit
from db.models.properties import Property

def create_property_unit(db: Session, data: PropertyUnitCreate, current_user):
    try:
        property = db.query(Property).filter(Property.id == data.property_id).first()
        if not property:
            raise HTTPException(status_code=400, detail="Invalid property")
        
        duplicate = db.query(Unit).filter(
            Unit.property_id == data.property_id,
            Unit.unit_number == data.unit_number,
            Unit.floor == data.floor
        ).first()

        if duplicate:
            raise HTTPException(status_code=400, detail="A unit with the same property ID, unit number, and floor already exists.")
        
        unit = Unit(
            property_id=data.property_id,
            unit_number=data.unit_number,
            floor=None if data.floor == "" else data.floor,
            bedrooms=None if data.bedrooms == "" else data.bedrooms,
            bathrooms=None if data.bathrooms == "" else data.bathrooms,
            size_sqm=None if data.size == "" else data.size,
            rent_price=None if data.rent == "" else data.rent,
            is_available=data.is_available,
        )

        db.add(unit)
        db.commit()
        db.refresh(unit)

        return {
            'id': str(unit.id),
            'unit_number': unit.unit_number,
            'floor': unit.floor,
            'bedrooms': unit.bedrooms,
            'bathrooms': unit.bathrooms,
            'size': unit.size_sqm,
            'rent': unit.rent_price,
            'is_available': unit.is_available,
            'property_id': unit.property_id,
            'property_name': property.name
        }
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating unit: {str(e)}")

def get_all_units(db: Session, current_user):
    try:
        units = (
            db.query(Property, Unit)
            .outerjoin(Property, Property.id == Unit.property_id)
            .order_by(desc(Unit.id)).all()
        )

        return [{
            'id': str(u.id),
            'unit_number': u.unit_number,
            'floor': u.floor,
            'bedrooms': u.bedrooms,
            'bathrooms': u.bathrooms,
            'size': u.size_sqm,
            'rent': u.rent_price,
            'is_available': u.is_available,
            'property_id': u.property_id,
            'property_name': p.name
        } for p, u in units]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching units: {str(e)}")

def update_property_unit(db: Session, unit_id: int, data: PropertyUnitUpdate, current_user):
    try:
        unit = db.get(Unit, unit_id)
        if not unit:
            raise HTTPException(status_code=404, detail="Unit not found")

        if data.unit_number is not None:
            unit.unit_number = data.unit_number
        if data.floor is not None:
            unit.floor = data.floor or None
        if data.bedrooms is not None:
            unit.bedrooms = data.bedrooms or None
        if data.bathrooms is not None:
            unit.bathrooms = data.bathrooms or None
        if data.size is not None:
            unit.size_sqm = data.size or None
        if data.rent is not None:
            unit.rent_price = data.rent or None
        if data.is_available is not None:
            unit.is_available = data.is_available
        if data.property_id is not None:
            unit.property_id = data.property_id

        if data.property_id is not None:
            property = db.query(Property).filter(Property.id == unit.property_id).first()
            if not property:
                raise HTTPException(status_code=404, detail="Property not found")

        db.commit()
        db.refresh(unit)

        return {
            'id': str(unit.id),
            'unit_number': unit.unit_number,
            'floor': unit.floor,
            'bedrooms': unit.bedrooms,
            'bathrooms': unit.bathrooms,
            'size': unit.size_sqm,
            'rent': unit.rent_price,
            'is_available': unit.is_available,
            'property_id': unit.property_id,
            'property_name': property.name
        }
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error updating unit: {str(e)}")

def delete_property_unit(db: Session, unit_id: int, current_user):
    try:
        unit = db.get(Unit, unit_id)
        if not unit:
            raise HTTPException(status_code=404, detail="Unit not found")

        return_data = {
            'id': str(unit.id),
            'unit_number': unit.unit_number,
            'floor': unit.floor,
            'bedrooms': unit.bedrooms,
            'bathrooms': unit.bathrooms,
            'size': unit.size_sqm,
            'rent': unit.rent_price,
            'is_available': unit.is_available,
            'property_id': unit.property_id,
        }

        db.delete(unit)
        db.commit()

        return return_data
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting unit: {str(e)}")

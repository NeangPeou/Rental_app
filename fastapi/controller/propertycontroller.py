from sqlalchemy import desc
from sqlalchemy.orm import Session
from fastapi import HTTPException
from db.models import properties as Property, property_types, user
from schemas.property import PropertyCreate, PropertyUpdate
from sqlalchemy.exc import SQLAlchemyError

def create_property(db: Session, data: PropertyCreate, current_user):
    try:
        type_exists = db.query(property_types.PropertyType).filter(property_types.PropertyType.id == data.type_id).first()
        if not type_exists:
            raise HTTPException(status_code=400, detail="Invalid type_id")
        
        owner_exists = db.query(user.User).filter(user.User.id == data.owner_id).first()
        if not owner_exists:
            raise HTTPException(status_code=400, detail="Invalid owner_id")
        
        new_property = Property.Property(
            name = data.name,
            address = data.address,
            city = data.city,
            district = data.district,
            province = data.province,
            postal_code = data.postal_code,
            latitude = data.latitude,
            longitude = data.longitude,
            description = data.description,
            type_id = data.type_id,
            owner_id = data.owner_id
        )
        db.add(new_property)
        db.commit()
        db.refresh(new_property)

        return {
            "id": new_property.id,
            "name": new_property.name,
            "address": new_property.address,
            "city": new_property.city,
            "district": new_property.district,
            "province": new_property.province,
            "postal_code": new_property.postal_code,
            "latitude": new_property.latitude,
            "longitude": new_property.longitude,
            "description": new_property.description,
            "type_id": new_property.type_id,
            "owner_id": new_property.owner_id
        }
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating property: {str(e)}")

def get_all_properties(db: Session, user):
    try:
        properties = db.query(Property.Property).order_by(desc(Property.Property.id)).all()
        
        return [
            {
                "id": p.id,
                "name": p.name,
                "address": p.address,
                "city": p.city,
                "district": p.district,
                "province": p.province,
                "postal_code": p.postal_code,
                "latitude": p.latitude,
                "longitude": p.longitude,
                "description": p.description,
                "type_id": p.type_id,
                "owner_id": p.owner_id
            }
            for p in properties
        ]
    except SQLAlchemyError as e:
        raise HTTPException(status_code=500, detail=f"Error fetching properties: {str(e)}")

def update_property(db: Session, property_id: int, data: PropertyUpdate, user):
    try:
        prop = db.query(Property.Property).filter(Property.Property.id == property_id).first()
        if not prop:
            raise HTTPException(status_code=404, detail="Property not found")
        for key, value in data.dict(exclude_unset=True).items():
            setattr(prop, key, value)
        db.commit()
        db.refresh(prop)

        return {
            "id": prop.id,
            "name": prop.name,
            "address": prop.address,
            "city": prop.city,
            "district": prop.district,
            "province": prop.province,
            "postal_code": prop.postal_code,
            "latitude": prop.latitude,
            "longitude": prop.longitude,
            "description": prop.description,
            "type_id": prop.type_id,
            "owner_id": prop.owner_id
        }
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating property: {str(e)}")

def delete_property(db: Session, property_id: int, user):
    try:
        prop = db.query(Property.Property).filter(Property.Property.id == property_id).first()
        if not prop:
            raise HTTPException(status_code=404, detail="Property not found")
        db.delete(prop)
        db.commit()
        return {"detail": "Property deleted"}
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error deleting property: {str(e)}")

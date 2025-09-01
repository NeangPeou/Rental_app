from pydantic import BaseModel
from typing import Optional

class PropertyUnitBase(BaseModel):
    unit_number: str
    floor: Optional[str] = None
    bedrooms: Optional[str] = None
    bathrooms: Optional[str] = None
    size: Optional[str] = None
    rent: Optional[str] = None
    is_available: bool
    property_id: str

class PropertyUnitCreate(PropertyUnitBase):
    pass

class PropertyUnitUpdate(PropertyUnitBase):
    pass

class PropertyUnitOut(PropertyUnitBase):
    id: int

    class Config:
        orm_mode = True

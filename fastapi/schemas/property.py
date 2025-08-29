from pydantic import BaseModel
from typing import Optional

class PropertyBase(BaseModel):
    name: str
    address: str
    city: str
    district: Optional[str] = None
    province: Optional[str] = None
    postal_code: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    description: Optional[str] = None
    type_id: str
    owner_id: str

class PropertyCreate(PropertyBase):
    pass

class PropertyUpdate(PropertyBase):
    pass

class PropertyOut(PropertyBase):
    id: int

    class Config:
        orm_mode = True

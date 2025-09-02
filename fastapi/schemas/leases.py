from pydantic import BaseModel
from typing import Optional
from datetime import date

class LeaseBase(BaseModel):
    unit_id: int
    renter_id: int
    start_date: date
    end_date: date
    rent_amount: float
    deposit_amount: Optional[float] = None
    status: str

class LeaseCreate(LeaseBase):
    pass

class LeaseUpdate(LeaseBase):
    unit_id: Optional[int] = None
    renter_id: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    rent_amount: Optional[float] = None
    status: Optional[str] = None

class LeaseOut(LeaseBase):
    id: int
    username: Optional[str] = None
    unit_number: Optional[str] = None

    class Config:
        orm_mode = True
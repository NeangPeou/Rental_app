from pydantic import BaseModel
from typing import Optional

class RenterBase(BaseModel):
    user_id: int
    id_document: Optional[str] = None

class RenterCreate(RenterBase):
    pass

class RenterOut(RenterBase):
    id: int
    username: Optional[str] = None

    class Config:
        orm_mode = True
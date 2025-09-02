from pydantic import BaseModel

class PaymentCreate(BaseModel):
    lease_id: int
    payment_date: str
    amount_paid: float
    payment_method_id: str
    receipt_url: str

class PaymentUpdate(PaymentCreate):
    pass

class PaymentOut(PaymentCreate):
    id: int
    created_by: int

    class Config:
        orm_mode = True

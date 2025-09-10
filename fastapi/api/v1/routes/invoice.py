from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from db.session import get_db
from controller import usercontroller, invoicecontroller
from schemas.invoice import InvoiceCreate

router = APIRouter()

@router.post("/create-invoice")
def create_invoice(data: InvoiceCreate, db: Session = Depends(get_db), current_user = Depends(usercontroller.get_current_user)):
    return invoicecontroller.create_invoice(db, data, current_user)

@router.get("/get_active_leases")
def get_active_leases(db: Session = Depends(get_db), current_user = Depends(usercontroller.get_current_user)):
    return invoicecontroller.get_active_leases(db, current_user)

@router.get("/get-invoices")
def get_invoices(db: Session = Depends(get_db), current_user = Depends(usercontroller.get_current_user)):
    return invoicecontroller.get_invoices(db, current_user)

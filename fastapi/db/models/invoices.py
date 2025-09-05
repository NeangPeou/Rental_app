from sqlalchemy import Column, Integer, Float, String, Date, ForeignKey
from db.session import Base

class Invoice(Base):
    __tablename__ = "t_invoices"
    id = Column(Integer, primary_key=True, index=True)
    lease_id = Column(Integer, ForeignKey("t_leases.id"), nullable=False)
    month = Column(Date, nullable=False)
    rent = Column(Float, nullable=False)
    utility = Column(Float, nullable=False)
    total = Column(Float, nullable=False)
    status = Column(String(50), nullable=False)  # e.g. 'paid', 'unpaid', 'partial'

# តាមដានការបង់ប្រាក់ជួលពីអ្នកជួល។
from sqlalchemy import DECIMAL, Column, Date, ForeignKey, Integer, String, Text
from db.session import Base

class Payment(Base):
    __tablename__ = "t_payments"
    id = Column(Integer, primary_key=True, index=True)
    lease_id = Column(Integer, ForeignKey("t_leases.id"), nullable=False) #លេខសម្គាល់កិច្ចសន្យាដែលបានបង់ប្រាក់
    payment_date = Column(Date, nullable=False)
    amount_paid = Column(DECIMAL(12, 2), nullable=False) #ចំនួនប្រាក់បានបង់
    method = Column(String(50), nullable=True) #របៀបបង់ប្រាក់ (បើកដូចជា cash, bank_transfer, card)
    receipt_url = Column(Text, nullable=True) #តំណភ្ជាប់ទៅបង្កាន់ដៃបង់ប្រាក់ (ប្រសិនបើមាន)
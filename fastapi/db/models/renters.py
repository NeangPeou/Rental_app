# រក្សាទុកព័ត៌មានបន្ថែមសម្រាប់អ្នកជួល។
from sqlalchemy import Column, ForeignKey, Integer, String
from db.session import Base

class Renter(Base):
    __tablename__ = "t_renters"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("t_users.id"), unique=True, nullable=False)
    id_document = Column(String(255), nullable=True)
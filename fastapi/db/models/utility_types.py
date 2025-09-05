from sqlalchemy import Column, Integer, String
from db.session import Base

class UtilityType(Base):
    __tablename__ = "t_utility_types"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, unique=True)

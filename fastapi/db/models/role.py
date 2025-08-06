from sqlalchemy import TIMESTAMP, Column, Integer, String, Text, func
from db.session import Base

class Role(Base):
    __tablename__ = "t_roles"
    id = Column(Integer, primary_key=True, index=True)
    role = Column(String, unique=True, index=True)
    description = Column(Text)
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())

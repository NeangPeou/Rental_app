# សម្រាប់ចាត់ថ្នាក់ប្រភេទអចលនវត្ថុ។
from sqlalchemy import Column, Integer, String
from db.session import Base

class PropertyType(Base):
    __tablename__ = "t_property_types"
    id = Column(Integer, primary_key=True, index=True)
    type_code = Column(String(20), unique=True, nullable=False)
    name = Column(String(100), nullable=False)
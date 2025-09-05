from sqlalchemy import Column, Integer, Float, Date, ForeignKey
from db.session import Base

class MeterReading(Base):
    __tablename__ = "t_meter_readings"
    id = Column(Integer, primary_key=True, index=True)
    unit_id = Column(Integer, ForeignKey("t_units.id"), nullable=False)
    utility_type_id = Column(Integer, ForeignKey("t_utility_types.id"), nullable=False)
    previous_reading = Column(Float, nullable=False)
    current_reading = Column(Float, nullable=False)
    usage = Column(Float, nullable=False)
    reading_date = Column(Date, nullable=False)

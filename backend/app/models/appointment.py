from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from app.db.database import Base

class AppointmentStatus(str, enum.Enum):
    UPCOMING = "Upcoming"
    COMPLETED = "Completed"
    CANCELLED = "Cancelled"

class Appointment(Base):
    __tablename__ = "appointments"
    
    id = Column(String, primary_key=True, index=True)
    doctor_id = Column(String, ForeignKey("doctors.id"), nullable=False)
    date = Column(DateTime, nullable=False)
    time_slot = Column(String, nullable=False)
    patient_name = Column(String, nullable=False)
    patient_age = Column(String, nullable=False)
    patient_phone = Column(String, nullable=False)
    patient_email = Column(String, nullable=True)
    patient_symptoms = Column(Text, nullable=True)
    status = Column(Enum(AppointmentStatus), default=AppointmentStatus.UPCOMING)
    token = Column(String, nullable=False, unique=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    doctor = relationship("Doctor", backref="appointments")
    prescription = relationship("Prescription", back_populates="appointment", uselist=False)

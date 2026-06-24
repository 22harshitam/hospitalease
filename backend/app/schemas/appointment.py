from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional
from app.models.appointment import AppointmentStatus

class PatientDetailsBase(BaseModel):
    name: str
    age: str
    phone: str
    email: Optional[EmailStr] = None
    symptoms: Optional[str] = None

class AppointmentBase(BaseModel):
    doctor_id: str
    date: datetime
    time_slot: str
    patient_details: PatientDetailsBase

class AppointmentCreate(AppointmentBase):
    pass

class AppointmentResponse(BaseModel):
    id: str
    doctor_id: str
    date: datetime
    time_slot: str
    patient_name: str
    patient_age: str
    patient_phone: str
    patient_email: Optional[str] = None
    patient_symptoms: Optional[str] = None
    status: AppointmentStatus
    token: str
    created_at: datetime
    
    class Config:
        from_attributes = True

class AppointmentUpdate(BaseModel):
    status: Optional[AppointmentStatus] = None

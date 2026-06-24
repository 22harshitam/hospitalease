from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime
import uuid

from app.db.database import get_db
from app.models.appointment import Appointment, AppointmentStatus
from app.models.doctor import Doctor
from app.schemas.appointment import AppointmentCreate, AppointmentResponse, AppointmentUpdate
from app.api.auth import get_current_doctor

router = APIRouter()

def generate_token():
    return f"HEA{uuid.uuid4().hex[:8].upper()}"

@router.get("/", response_model=List[AppointmentResponse])
async def get_appointments(
    doctor_id: str = None,
    status: AppointmentStatus = None,
    db: Session = Depends(get_db),
    current_doctor: Doctor = Depends(get_current_doctor)
):
    query = db.query(Appointment)
    
    # If doctor_id is provided, filter by doctor
    if doctor_id:
        # Only allow doctors to see their own appointments
        if current_doctor.id != doctor_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to view these appointments"
            )
        query = query.filter(Appointment.doctor_id == doctor_id)
    else:
        # If no doctor_id, show appointments for current doctor
        query = query.filter(Appointment.doctor_id == current_doctor.id)
    
    # Filter by status if provided
    if status:
        query = query.filter(Appointment.status == status)
    
    appointments = query.order_by(Appointment.date.desc()).all()
    return appointments

@router.get("/{appointment_id}", response_model=AppointmentResponse)
async def get_appointment(
    appointment_id: str,
    db: Session = Depends(get_db),
    current_doctor: Doctor = Depends(get_current_doctor)
):
    appointment = db.query(Appointment).filter(Appointment.id == appointment_id).first()
    if not appointment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Appointment not found"
        )
    
    # Only allow doctors to see their own appointments
    if appointment.doctor_id != current_doctor.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this appointment"
        )
    
    return appointment

@router.post("/", response_model=AppointmentResponse)
async def create_appointment(
    appointment: AppointmentCreate,
    db: Session = Depends(get_db)
):
    # Verify doctor exists
    doctor = db.query(Doctor).filter(Doctor.id == appointment.doctor_id).first()
    if not doctor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Doctor not found"
        )
    
    # Create new appointment
    db_appointment = Appointment(
        id=str(uuid.uuid4()),
        doctor_id=appointment.doctor_id,
        date=appointment.date,
        time_slot=appointment.time_slot,
        patient_name=appointment.patient_details.name,
        patient_age=appointment.patient_details.age,
        patient_phone=appointment.patient_details.phone,
        patient_email=appointment.patient_details.email,
        patient_symptoms=appointment.patient_details.symptoms,
        status=AppointmentStatus.UPCOMING,
        token=generate_token()
    )
    
    db.add(db_appointment)
    db.commit()
    db.refresh(db_appointment)
    
    return db_appointment

@router.put("/{appointment_id}", response_model=AppointmentResponse)
async def update_appointment(
    appointment_id: str,
    appointment_update: AppointmentUpdate,
    db: Session = Depends(get_db),
    current_doctor: Doctor = Depends(get_current_doctor)
):
    appointment = db.query(Appointment).filter(Appointment.id == appointment_id).first()
    if not appointment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Appointment not found"
        )
    
    # Only allow doctors to update their own appointments
    if appointment.doctor_id != current_doctor.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to update this appointment"
        )
    
    # Update status if provided
    if appointment_update.status:
        appointment.status = appointment_update.status
    
    db.commit()
    db.refresh(appointment)
    
    return appointment

@router.delete("/{appointment_id}")
async def cancel_appointment(
    appointment_id: str,
    db: Session = Depends(get_db),
    current_doctor: Doctor = Depends(get_current_doctor)
):
    appointment = db.query(Appointment).filter(Appointment.id == appointment_id).first()
    if not appointment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Appointment not found"
        )
    
    # Only allow doctors to cancel their own appointments
    if appointment.doctor_id != current_doctor.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to cancel this appointment"
        )
    
    appointment.status = AppointmentStatus.CANCELLED
    db.commit()
    
    return {"message": "Appointment cancelled successfully"}

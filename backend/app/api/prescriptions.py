from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.db.database import get_db
from app.models.prescription import Prescription
from app.models.appointment import Appointment
from app.models.doctor import Doctor
from app.schemas.prescription import PrescriptionCreate, PrescriptionResponse
from app.api.auth import get_current_doctor

router = APIRouter()

@router.get("/", response_model=List[PrescriptionResponse])
async def get_prescriptions(
    appointment_id: str = None,
    db: Session = Depends(get_db),
    current_doctor: Doctor = Depends(get_current_doctor)
):
    query = db.query(Prescription)
    
    if appointment_id:
        # Verify the appointment belongs to the current doctor
        appointment = db.query(Appointment).filter(Appointment.id == appointment_id).first()
        if not appointment or appointment.doctor_id != current_doctor.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to view prescriptions for this appointment"
            )
        query = query.filter(Prescription.appointment_id == appointment_id)
    else:
        # Get all prescriptions for the current doctor's appointments
        query = query.join(Appointment).filter(Appointment.doctor_id == current_doctor.id)
    
    prescriptions = query.order_by(Prescription.created_at.desc()).all()
    return prescriptions

@router.get("/{prescription_id}", response_model=PrescriptionResponse)
async def get_prescription(
    prescription_id: int,
    db: Session = Depends(get_db),
    current_doctor: Doctor = Depends(get_current_doctor)
):
    prescription = db.query(Prescription).filter(Prescription.id == prescription_id).first()
    if not prescription:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Prescription not found"
        )
    
    # Verify the appointment belongs to the current doctor
    appointment = db.query(Appointment).filter(Appointment.id == prescription.appointment_id).first()
    if not appointment or appointment.doctor_id != current_doctor.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this prescription"
        )
    
    return prescription

@router.post("/", response_model=PrescriptionResponse)
async def create_prescription(
    prescription: PrescriptionCreate,
    db: Session = Depends(get_db),
    current_doctor: Doctor = Depends(get_current_doctor)
):
    # Verify the appointment exists and belongs to the current doctor
    appointment = db.query(Appointment).filter(Appointment.id == prescription.appointment_id).first()
    if not appointment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Appointment not found"
        )
    
    if appointment.doctor_id != current_doctor.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to create prescription for this appointment"
        )
    
    # Check if prescription already exists for this appointment
    existing_prescription = db.query(Prescription).filter(Prescription.appointment_id == prescription.appointment_id).first()
    if existing_prescription:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Prescription already exists for this appointment"
        )
    
    # Create new prescription
    db_prescription = Prescription(
        appointment_id=prescription.appointment_id,
        medicines=prescription.medicines,
        instructions=prescription.instructions,
        date=prescription.date
    )
    
    db.add(db_prescription)
    
    # Update appointment status to completed
    appointment.status = "Completed"
    
    db.commit()
    db.refresh(db_prescription)
    
    return db_prescription

@router.put("/{prescription_id}", response_model=PrescriptionResponse)
async def update_prescription(
    prescription_id: int,
    prescription_update: PrescriptionCreate,
    db: Session = Depends(get_db),
    current_doctor: Doctor = Depends(get_current_doctor)
):
    prescription = db.query(Prescription).filter(Prescription.id == prescription_id).first()
    if not prescription:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Prescription not found"
        )
    
    # Verify the appointment belongs to the current doctor
    appointment = db.query(Appointment).filter(Appointment.id == prescription.appointment_id).first()
    if not appointment or appointment.doctor_id != current_doctor.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to update this prescription"
        )
    
    # Update prescription
    prescription.medicines = prescription_update.medicines
    prescription.instructions = prescription_update.instructions
    prescription.date = prescription_update.date
    
    db.commit()
    db.refresh(prescription)
    
    return prescription

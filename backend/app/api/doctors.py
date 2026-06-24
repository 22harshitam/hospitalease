from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.db.database import get_db
from app.models.doctor import Doctor
from app.schemas.doctor import DoctorCreate, DoctorResponse
from app.core.security import get_password_hash
from app.api.auth import get_current_doctor

router = APIRouter()

@router.get("/", response_model=List[DoctorResponse])
async def get_doctors(db: Session = Depends(get_db)):
    doctors = db.query(Doctor).all()
    return doctors

@router.get("/{doctor_id}", response_model=DoctorResponse)
async def get_doctor(doctor_id: str, db: Session = Depends(get_db)):
    doctor = db.query(Doctor).filter(Doctor.id == doctor_id).first()
    if not doctor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Doctor not found"
        )
    return doctor

@router.post("/", response_model=DoctorResponse)
async def create_doctor(doctor: DoctorCreate, db: Session = Depends(get_db)):
    # Check if email already exists
    existing_doctor = db.query(Doctor).filter(Doctor.email == doctor.email).first()
    if existing_doctor:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create new doctor
    hashed_password = get_password_hash(doctor.password)
    db_doctor = Doctor(
        id=str(len(db.query(Doctor).all()) + 1),  # Simple ID generation
        name=doctor.name,
        specialization=doctor.specialization,
        rating=doctor.rating,
        reviews=doctor.reviews,
        experience=doctor.experience,
        image_url=doctor.image_url,
        is_available=doctor.is_available,
        biography=doctor.biography,
        consultation_fee=doctor.consultation_fee,
        email=doctor.email,
        hashed_password=hashed_password
    )
    
    db.add(db_doctor)
    db.commit()
    db.refresh(db_doctor)
    
    return db_doctor

@router.put("/{doctor_id}", response_model=DoctorResponse)
async def update_doctor(
    doctor_id: str, 
    doctor_update: DoctorCreate, 
    db: Session = Depends(get_db),
    current_doctor: Doctor = Depends(get_current_doctor)
):
    # Only allow doctors to update their own profile
    if current_doctor.id != doctor_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to update this doctor"
        )
    
    doctor = db.query(Doctor).filter(Doctor.id == doctor_id).first()
    if not doctor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Doctor not found"
        )
    
    # Update fields
    for field, value in doctor_update.dict(exclude_unset=True).items():
        if field == "password":
            setattr(doctor, "hashed_password", get_password_hash(value))
        else:
            setattr(doctor, field, value)
    
    db.commit()
    db.refresh(doctor)
    
    return doctor

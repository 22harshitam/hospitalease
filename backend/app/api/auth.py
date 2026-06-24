from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta
from typing import Optional

from app.db.database import get_db
from app.models.doctor import Doctor
from app.schemas.doctor import DoctorLogin, DoctorResponse
from app.schemas.auth import Token, AuthResponse
from app.core.security import verify_password, create_access_token, verify_token
from app.core.config import settings

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/auth/login")

def get_current_doctor(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    payload = verify_token(token)
    if payload is None:
        raise credentials_exception
    
    email: str = payload.get("sub")
    if email is None:
        raise credentials_exception
    
    doctor = db.query(Doctor).filter(Doctor.email == email).first()
    if doctor is None:
        raise credentials_exception
    
    return doctor

def authenticate_doctor(db: Session, email: str, password: str) -> Optional[Doctor]:
    doctor = db.query(Doctor).filter(Doctor.email == email).first()
    if not doctor:
        return None
    if not verify_password(password, doctor.hashed_password):
        return None
    return doctor

@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    doctor = authenticate_doctor(db, form_data.username, form_data.password)
    if not doctor:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": doctor.email}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/login-json", response_model=Token)
async def login_json(doctor_login: DoctorLogin, db: Session = Depends(get_db)):
    doctor = authenticate_doctor(db, doctor_login.email, doctor_login.password)
    if not doctor:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": doctor.email}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=DoctorResponse)
async def read_users_me(current_doctor: Doctor = Depends(get_current_doctor)):
    return current_doctor

@router.post("/test", response_model=AuthResponse)
async def test_auth():
    return {"message": "Authentication endpoint is working"}

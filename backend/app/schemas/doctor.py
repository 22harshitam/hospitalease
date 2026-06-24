from pydantic import BaseModel, EmailStr
from typing import Optional

class DoctorBase(BaseModel):
    name: str
    specialization: str
    rating: float
    reviews: int
    experience: str
    image_url: str
    is_available: bool = True
    biography: str
    consultation_fee: float
    email: Optional[EmailStr] = None

class DoctorCreate(DoctorBase):
    password: str

class DoctorResponse(DoctorBase):
    id: str
    
    class Config:
        from_attributes = True

class DoctorLogin(BaseModel):
    email: EmailStr
    password: str

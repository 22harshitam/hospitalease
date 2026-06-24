from sqlalchemy import Column, Integer, String, Float, Boolean, Text
from app.db.database import Base

class Doctor(Base):
    __tablename__ = "doctors"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    specialization = Column(String, nullable=False)
    rating = Column(Float, nullable=False)
    reviews = Column(Integer, nullable=False)
    experience = Column(String, nullable=False)
    image_url = Column(String, nullable=False)
    is_available = Column(Boolean, default=True)
    biography = Column(Text, nullable=False)
    consultation_fee = Column(Float, nullable=False)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)

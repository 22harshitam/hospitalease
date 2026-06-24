from pydantic import BaseModel
from datetime import datetime
from typing import List

class PrescriptionBase(BaseModel):
    medicines: List[str]
    instructions: str
    date: datetime

class PrescriptionCreate(PrescriptionBase):
    appointment_id: str

class PrescriptionResponse(PrescriptionBase):
    id: int
    appointment_id: str
    created_at: datetime
    
    class Config:
        from_attributes = True

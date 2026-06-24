from pydantic import BaseModel

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: str = None

class AuthResponse(BaseModel):
    message: str
    doctor_id: str = None
    name: str = None

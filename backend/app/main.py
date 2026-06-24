from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, doctors, appointments, prescriptions
from app.core.config import settings

app = FastAPI(
    title="HospitalEasy API",
    description="Backend API for HospitalEasy appointment system",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["authentication"])
app.include_router(doctors.router, prefix="/api/doctors", tags=["doctors"])
app.include_router(appointments.router, prefix="/api/appointments", tags=["appointments"])
app.include_router(prescriptions.router, prefix="/api/prescriptions", tags=["prescriptions"])

@app.get("/")
async def root():
    return {"message": "HospitalEasy API is running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

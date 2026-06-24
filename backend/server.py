#!/usr/bin/env python3
"""
HospitalEasy Backend Server with PostgreSQL Database
Production-ready server with database persistence
"""
from flask import Flask, jsonify, request
from flask_cors import CORS
import jwt
from datetime import datetime, timedelta
import hashlib
import os
from werkzeug.security import check_password_hash
from database import db_manager, doctors_db, patients_db, appointments_db

app = Flask(__name__)
CORS(app)

# Configuration
SECRET_KEY = os.getenv('SECRET_KEY', "your-super-secret-key-change-in-production")
ALGORITHM = "HS256"

# Helper functions
def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=30)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.JWTError:
        return None

def get_current_user():
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return jsonify({"detail": "Not authenticated"}), 401
    
    token = auth_header.split(" ")[1]
    payload = verify_token(token)
    
    if not payload:
        return jsonify({"detail": "Invalid token"}), 401
    
    user_type = payload.get("user_type")
    email = payload.get("sub")
    
    # Return doctor info
    if user_type == "doctor":
        doctor = doctors_db.get_doctor_by_email(email)
        if doctor:
            return jsonify({
                "user_type": "doctor",
                **dict(doctor)
            })
        else:
            return jsonify({"detail": "Doctor not found"}), 404
    
    # Return patient info
    elif user_type == "patient":
        patient = patients_db.get_patient_by_email(email)
        if patient:
            return jsonify({
                "user_type": "patient",
                **dict(patient)
            })
        else:
            return jsonify({"detail": "Patient not found"}), 404
    
    else:
        return jsonify({"detail": "Invalid user type"}), 400

# API Routes

@app.route("/")
def root():
    return jsonify({
        "message": "HospitalEasy API Server with PostgreSQL",
        "version": "2.0.0",
        "database": "PostgreSQL"
    })

@app.route("/health")
def health_check():
    try:
        # Test database connection
        result = db_manager.execute_query("SELECT 1 as test", fetch_all=False)
        return jsonify({
            "status": "healthy",
            "database": "connected",
            "timestamp": datetime.utcnow().isoformat()
        })
    except Exception as e:
        return jsonify({
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }), 500

# Authentication endpoints
@app.route("/api/auth/test", methods=["GET"])
def auth_test():
    return jsonify({"message": "Auth endpoint working", "timestamp": datetime.utcnow().isoformat()})

@app.route("/api/auth/login-json", methods=["POST"])
def login():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")
    user_type = data.get("user_type", "doctor")  # Default to doctor
    
    if not email or not password:
        return jsonify({"detail": "Email and password required"}), 400
    
    try:
        if user_type == "doctor":
            user = doctors_db.get_doctor_by_email(email)
            # Use SHA-256 hashing for consistency
            password_hash = hashlib.sha256(password.encode()).hexdigest()
            if not user or user['password_hash'] != password_hash:
                return jsonify({"detail": "Invalid credentials"}), 401
            
            access_token = create_access_token({
                "sub": user["email"],
                "user_type": "doctor",
                "user_id": str(user["id"])
            })
            
            return jsonify({
                "access_token": access_token,
                "token_type": "bearer",
                "user_type": "doctor",
                "user": {
                    "id": str(user["id"]),
                    "name": user["name"],
                    "email": user["email"],
                    "specialization": user["specialization"]
                }
            })
        
        elif user_type == "patient":
            user = patients_db.get_patient_by_email(email)
            # Use SHA-256 hashing for consistency
            password_hash = hashlib.sha256(password.encode()).hexdigest()
            if not user or user['password_hash'] != password_hash:
                return jsonify({"detail": "Invalid credentials"}), 401
            
            access_token = create_access_token({
                "sub": user["email"],
                "user_type": "patient", 
                "user_id": str(user["id"])
            })
            
            return jsonify({
                "access_token": access_token,
                "token_type": "bearer",
                "user_type": "patient",
                "user": {
                    "id": str(user["id"]),
                    "name": user["name"],
                    "email": user["email"],
                    "phone": user["phone"]
                }
            })
        
        else:
            return jsonify({"detail": "Invalid user type"}), 400
            
    except Exception as e:
        return jsonify({"detail": f"Login error: {str(e)}"}), 500

@app.route("/api/auth/patient/register", methods=["POST"])
def register_patient():
    data = request.get_json()
    
    try:
        # Check if patient already exists
        existing_patient = patients_db.get_patient_by_email(data["email"])
        if existing_patient:
            return jsonify({"detail": "Patient with this email already exists"}), 400
        
        # Create new patient
        result = patients_db.create_patient(
            name=data["name"],
            email=data["email"],
            phone=data["phone"],
            age=data["age"],
            password=data["password"],
            address=data.get("address", ""),
            emergency_contact=data.get("emergency_contact", ""),
            blood_group=data.get("blood_group", "")
        )
        
        return jsonify({
            "message": "Patient registered successfully",
            "patient_id": str(result["id"])
        }), 201
        
    except Exception as e:
        return jsonify({"detail": f"Registration error: {str(e)}"}), 500

@app.route("/api/auth/me")
def get_current_user_info():
    return get_current_user()

# Doctor endpoints
@app.route("/api/doctors/")
def get_doctors():
    try:
        doctors = doctors_db.get_all_doctors()
        # Convert datetime objects to strings and remove sensitive data
        doctors_list = []
        for doctor in doctors:
            doctor_dict = dict(doctor)
            doctor_dict.pop('password_hash', None)
            if 'created_at' in doctor_dict:
                doctor_dict['created_at'] = doctor_dict['created_at'].isoformat()
            if 'updated_at' in doctor_dict:
                doctor_dict['updated_at'] = doctor_dict['updated_at'].isoformat()
            doctors_list.append(doctor_dict)
        
        return jsonify(doctors_list)
    except Exception as e:
        return jsonify({"detail": f"Error fetching doctors: {str(e)}"}), 500

@app.route("/api/doctors/<doctor_id>")
def get_doctor(doctor_id):
    try:
        doctor = doctors_db.get_doctor_by_id(doctor_id)
        if not doctor:
            return jsonify({"detail": "Doctor not found"}), 404
        
        doctor_dict = dict(doctor)
        doctor_dict.pop('password_hash', None)
        if 'created_at' in doctor_dict:
            doctor_dict['created_at'] = doctor_dict['created_at'].isoformat()
        if 'updated_at' in doctor_dict:
            doctor_dict['updated_at'] = doctor_dict['updated_at'].isoformat()
        
        return jsonify(doctor_dict)
    except Exception as e:
        return jsonify({"detail": f"Error fetching doctor: {str(e)}"}), 500

# Appointment endpoints
@app.route("/api/appointments/")
def get_appointments():
    try:
        # Get query parameters
        doctor_id = request.args.get('doctor_id')
        status = request.args.get('status')
        
        appointments = appointments_db.get_all_appointments(
            doctor_id=doctor_id, 
            status=status
        )
        
        # Convert datetime objects to strings
        appointments_list = []
        for appointment in appointments:
            appt_dict = dict(appointment)
            if 'appointment_date' in appt_dict:
                appt_dict['date'] = appt_dict.pop('appointment_date').isoformat()
            if 'created_at' in appt_dict:
                appt_dict['created_at'] = appt_dict['created_at'].isoformat()
            if 'updated_at' in appt_dict:
                appt_dict['updated_at'] = appt_dict['updated_at'].isoformat()
            appointments_list.append(appt_dict)
        
        return jsonify(appointments_list)
    except Exception as e:
        return jsonify({"detail": f"Error fetching appointments: {str(e)}"}), 500

@app.route("/api/appointments/", methods=["POST"])
def create_appointment():
    data = request.get_json()
    
    try:
        # Validate required fields
        required_fields = ['doctor_id', 'date', 'time_slot', 'patient_details']
        for field in required_fields:
            if field not in data:
                return jsonify({"detail": f"Missing required field: {field}"}), 400
        
        # Find or create patient
        patient_email = data["patient_details"].get("email")
        patient_id = None
        
        if patient_email:
            patient = patients_db.get_patient_by_email(patient_email)
            if patient:
                patient_id = str(patient["id"])
            else:
                # Create new patient if they don't exist
                patient_result = patients_db.create_patient(
                    name=data["patient_details"]["name"],
                    email=patient_email,
                    phone=data["patient_details"]["phone"],
                    age=data["patient_details"]["age"],
                    password=data["patient_details"].get("phone", "default123"), # Use phone as default password
                    address=data["patient_details"].get("address", ""),
                    emergency_contact=data["patient_details"].get("emergency_contact", ""),
                    blood_group=data["patient_details"].get("blood_group", "")
                )
                patient_id = str(patient_result["id"])
        
        # Generate unique token
        import random
        import string
        token = f"HEA{''.join(random.choices(string.digits, k=5))}"
        
        # Create appointment
        result = appointments_db.create_appointment(
            doctor_id=data["doctor_id"],
            patient_id=patient_id,
            appointment_date=data["date"],
            time_slot=data["time_slot"],
            symptoms=data["patient_details"].get("symptoms", ""),
            token=token,
            consultation_fee=data.get("consultation_fee", 0.0),
            id_file_path=data.get("id_file_path"),
            photo_path=data.get("photo_path")
        )
        
        # Get the created appointment with full details
        appointment = appointments_db.get_appointment_by_id(str(result["id"]))
        appointment_dict = dict(appointment)
        
        # Format response
        response_data = {
            "id": str(appointment_dict["id"]),
            "doctor_id": str(appointment_dict["doctor_id"]),
            "date": appointment_dict["appointment_date"].isoformat(),
            "time_slot": appointment_dict["time_slot"],
            "status": appointment_dict["status"],
            "token": appointment_dict["token"],
            "created_at": appointment_dict["created_at"].isoformat(),
            "patient_name": appointment_dict.get("patient_name", ""),
            "patient_age": appointment_dict.get("patient_age", ""),
            "patient_phone": appointment_dict.get("patient_phone", ""),
            "patient_email": appointment_dict.get("patient_email", ""),
            "patient_symptoms": appointment_dict.get("symptoms", ""),
            "doctor_name": appointment_dict.get("doctor_name", ""),
            "doctor_specialization": appointment_dict.get("doctor_specialization", "")
        }
        
        return jsonify(response_data), 201
        
    except Exception as e:
        return jsonify({"detail": f"Error creating appointment: {str(e)}"}), 500

@app.route("/api/appointments/<appointment_id>", methods=["PUT"])
def update_appointment(appointment_id):
    data = request.get_json()
    
    try:
        if "status" in data:
            appointments_db.update_appointment_status(appointment_id, data["status"])
        
        appointment = appointments_db.get_appointment_by_id(appointment_id)
        if not appointment:
            return jsonify({"detail": "Appointment not found"}), 404
        
        return jsonify(dict(appointment))
        
    except Exception as e:
        return jsonify({"detail": f"Error updating appointment: {str(e)}"}), 500

@app.route("/api/appointments/<appointment_id>", methods=["DELETE"])
def delete_appointment(appointment_id):
    try:
        appointments_db.cancel_appointment(appointment_id)
        return jsonify({"message": "Appointment cancelled successfully"})
    except Exception as e:
        return jsonify({"detail": f"Error cancelling appointment: {str(e)}"}), 500

if __name__ == "__main__":
    print("🚀 Starting HospitalEasy Server with PostgreSQL...")
    print("📋 Available endpoints:")
    print("   GET  /                    - Root endpoint")
    print("   GET  /health              - Health check")
    print("   POST /api/auth/login-json - Login")
    print("   POST /api/auth/patient/register - Patient registration")
    print("   GET  /api/auth/me         - Get current user")
    print("   GET  /api/doctors/        - Get all doctors")
    print("   GET  /api/appointments/   - Get appointments")
    print("   POST /api/appointments/   - Create appointment")
    print("\n🔑 Default credentials:")
    print("   Doctor Email: doctor@hospital.com")
    print("   Doctor Password: password123")
    print("\n🌐 Server running on: http://0.0.0.0:8000")
    print("💾 Database: PostgreSQL")
    
    app.run(host="0.0.0.0", port=8000, debug=True)

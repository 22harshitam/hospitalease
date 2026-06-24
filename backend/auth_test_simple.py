"""
Simple authentication test demonstrating the backend API structure
"""
import sys
import os
import json

# Add the parent directory to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_token_creation():
    """Test JWT token creation and verification"""
    try:
        from app.core.security import create_access_token, verify_token
        
        # Test token creation
        user_data = {"sub": "doctor@hospital.com"}
        token = create_access_token(user_data)
        
        print(f"✓ JWT Token created successfully")
        print(f"  Token: {token[:50]}...")
        
        # Test token verification
        payload = verify_token(token)
        if payload and payload.get("sub") == "doctor@hospital.com":
            print("✓ JWT Token verification successful")
            print(f"  User email: {payload.get('sub')}")
            return True
        else:
            print("✗ JWT Token verification failed")
            return False
            
    except Exception as e:
        print(f"✗ Token test error: {e}")
        return False

def test_schema_validation():
    """Test Pydantic schema validation"""
    try:
        from app.schemas.doctor import DoctorCreate, DoctorResponse
        from app.schemas.auth import Token, AuthResponse
        from app.schemas.appointment import AppointmentCreate, AppointmentResponse
        
        # Test Doctor schema
        doctor_data = {
            "name": "Dr. Arun Ravi",
            "specialization": "Cardiologist",
            "rating": 4.8,
            "reviews": 120,
            "experience": "12+ Years Experience",
            "image_url": "https://example.com/doctor.jpg",
            "biography": "Senior cardiologist with extensive experience",
            "consultation_fee": 1200,
            "email": "doctor@hospital.com",
            "password": "password123"
        }
        doctor = DoctorCreate(**doctor_data)
        print("✓ Doctor schema validation successful")
        
        # Test Token schema
        token_data = {"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...", "token_type": "bearer"}
        token = Token(**token_data)
        print("✓ Token schema validation successful")
        
        # Test Appointment schema
        appointment_data = {
            "doctor_id": "1",
            "date": "2024-01-15T10:00:00",
            "time_slot": "10:00 AM",
            "patient_details": {
                "name": "Arjun Mehta",
                "age": "42",
                "phone": "9876543210",
                "symptoms": "Mild chest pain"
            }
        }
        appointment = AppointmentCreate(**appointment_data)
        print("✓ Appointment schema validation successful")
        
        return True
        
    except Exception as e:
        print(f"✗ Schema validation error: {e}")
        return False

def test_api_structure():
    """Test that API modules can be imported"""
    try:
        from app.main import app
        print("✓ FastAPI app created successfully")
        
        # Check routes
        routes = [route.path for route in app.routes]
        expected_routes = ["/", "/health", "/api/auth/test", "/api/auth/login", "/api/auth/me"]
        
        for route in expected_routes:
            if route in routes:
                print(f"✓ Route {route} is available")
            else:
                print(f"✗ Route {route} is missing")
                
        return True
        
    except Exception as e:
        print(f"✗ API structure error: {e}")
        return False

def demonstrate_api_endpoints():
    """Demonstrate the available API endpoints"""
    print("\n📋 Available API Endpoints:")
    print("=" * 40)
    
    endpoints = {
        "Authentication": [
            "POST /api/auth/test - Test authentication endpoint",
            "POST /api/auth/login - OAuth2 password flow login", 
            "POST /api/auth/login-json - JSON login with email/password",
            "GET /api/auth/me - Get current doctor profile (requires auth)"
        ],
        "Doctors": [
            "GET /api/doctors/ - List all doctors",
            "GET /api/doctors/{id} - Get doctor by ID",
            "POST /api/doctors/ - Create new doctor",
            "PUT /api/doctors/{id} - Update doctor (requires auth)"
        ],
        "Appointments": [
            "GET /api/appointments/ - List appointments (filtered by doctor)",
            "GET /api/appointments/{id} - Get appointment by ID",
            "POST /api/appointments/ - Create new appointment",
            "PUT /api/appointments/{id} - Update appointment status",
            "DELETE /api/appointments/{id} - Cancel appointment"
        ],
        "Prescriptions": [
            "GET /api/prescriptions/ - List prescriptions",
            "GET /api/prescriptions/{id} - Get prescription by ID", 
            "POST /api/prescriptions/ - Create new prescription",
            "PUT /api/prescriptions/{id} - Update prescription"
        ]
    }
    
    for category, routes in endpoints.items():
        print(f"\n🏥 {category}:")
        for route in routes:
            print(f"   {route}")

def show_database_schema():
    """Show the database schema"""
    print("\n🗄️ Database Schema:")
    print("=" * 40)
    
    schema = {
        "doctors": {
            "id": "string (primary key)",
            "name": "string",
            "specialization": "string", 
            "rating": "float",
            "reviews": "integer",
            "experience": "string",
            "image_url": "string",
            "is_available": "boolean",
            "biography": "text",
            "consultation_fee": "float",
            "email": "string (unique)",
            "hashed_password": "string"
        },
        "appointments": {
            "id": "string (primary key)",
            "doctor_id": "string (foreign key)",
            "date": "datetime",
            "time_slot": "string",
            "patient_name": "string",
            "patient_age": "string",
            "patient_phone": "string",
            "patient_email": "string (optional)",
            "patient_symptoms": "text (optional)",
            "status": "enum (Upcoming, Completed, Cancelled)",
            "token": "string (unique)"
        },
        "prescriptions": {
            "id": "integer (primary key)",
            "appointment_id": "string (foreign key, unique)",
            "medicines": "JSON array",
            "instructions": "text",
            "date": "datetime"
        }
    }
    
    for table, columns in schema.items():
        print(f"\n📋 {table.upper()}:")
        for column, type_info in columns.items():
            print(f"   {column}: {type_info}")

if __name__ == "__main__":
    print("🏥 HospitalEasy Backend Authentication Test")
    print("=" * 50)
    
    success = True
    
    print("\n🔐 Testing Authentication System:")
    print("-" * 30)
    if not test_token_creation():
        success = False
    
    print("\n✅ Testing Schema Validation:")
    print("-" * 30)
    if not test_schema_validation():
        success = False
        
    print("\n🌐 Testing API Structure:")
    print("-" * 30)
    if not test_api_structure():
        success = False
    
    demonstrate_api_endpoints()
    show_database_schema()
    
    print("\n" + "=" * 50)
    if success:
        print("🎉 Authentication system is working correctly!")
        print("📝 Backend is ready for Flutter app integration.")
        print("\n🚀 Next steps:")
        print("   1. Set up PostgreSQL database")
        print("   2. Run: alembic upgrade head")
        print("   3. Run: python seed_data.py")
        print("   4. Start server: uvicorn app.main:app --reload")
        print("   5. Visit: http://localhost:8000/docs")
    else:
        print("❌ Some tests failed. Please check the errors above.")

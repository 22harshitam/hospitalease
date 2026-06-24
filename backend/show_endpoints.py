#!/usr/bin/env python3
"""
Script to display all available API endpoints
"""
import sys
import os

# Add the parent directory to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def show_all_endpoints():
    """Display all available API endpoints"""
    
    print("🌐 HospitalEasy Backend - All API Endpoints")
    print("=" * 60)
    
    endpoints = {
        "🔐 Authentication": [
            ("POST", "/api/auth/test", "Test authentication endpoint", "None"),
            ("POST", "/api/auth/login", "OAuth2 password flow login", "None"),
            ("POST", "/api/auth/login-json", "JSON login with email/password", "None"),
            ("GET", "/api/auth/me", "Get current doctor profile", "JWT Token")
        ],
        
        "👨‍⚕️ Doctors": [
            ("GET", "/api/doctors/", "List all doctors", "None"),
            ("GET", "/api/doctors/{id}", "Get doctor by ID", "None"),
            ("POST", "/api/doctors/", "Create new doctor", "None"),
            ("PUT", "/api/doctors/{id}", "Update doctor profile", "JWT Token (Own Profile)")
        ],
        
        "📅 Appointments": [
            ("GET", "/api/appointments/", "List appointments (filtered by doctor)", "JWT Token"),
            ("GET", "/api/appointments/{id}", "Get appointment by ID", "JWT Token (Own Appointments)"),
            ("POST", "/api/appointments/", "Create new appointment", "None"),
            ("PUT", "/api/appointments/{id}", "Update appointment status", "JWT Token (Own Appointments)"),
            ("DELETE", "/api/appointments/{id}", "Cancel appointment", "JWT Token (Own Appointments)")
        ],
        
        "💊 Prescriptions": [
            ("GET", "/api/prescriptions/", "List prescriptions (filtered by doctor)", "JWT Token"),
            ("GET", "/api/prescriptions/{id}", "Get prescription by ID", "JWT Token (Own Prescriptions)"),
            ("POST", "/api/prescriptions/", "Create new prescription", "JWT Token (Own Appointments)"),
            ("PUT", "/api/prescriptions/{id}", "Update prescription", "JWT Token (Own Prescriptions)")
        ],
        
        "🏠 System": [
            ("GET", "/", "Root endpoint", "None"),
            ("GET", "/health", "Health check", "None")
        ]
    }
    
    total_endpoints = 0
    
    for category, endpoint_list in endpoints.items():
        print(f"\n{category}")
        print("-" * 40)
        
        for method, path, description, auth in endpoint_list:
            print(f"{method:6} {path:<30} | {auth}")
            print(f"       └─ {description}")
            total_endpoints += 1
    
    print("\n" + "=" * 60)
    print(f"📊 Total Endpoints: {total_endpoints}")
    print(f"🔒 Endpoints requiring authentication: {sum(1 for cat in endpoints.values() for e in cat if e[3] != 'None')}")
    print(f"🌐 Public endpoints: {sum(1 for cat in endpoints.values() for e in cat if e[3] == 'None')}")
    
    print("\n🔑 Default Doctor Credentials:")
    print("   Email: doctor@hospital.com | Password: password123")
    print("   Email: priya@hospital.com | Password: password123")
    print("   Email: rahul@hospital.com | Password: password123")
    print("   Email: lakshmi@hospital.com | Password: password123")
    
    print("\n🚀 Server Start Command:")
    print("   python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000")
    
    print("\n📖 API Documentation:")
    print("   Swagger UI: http://localhost:8000/docs")
    print("   ReDoc: http://localhost:8000/redoc")
    
    print("\n🧪 Quick Test Commands:")
    print("   # Health check")
    print("   curl http://localhost:8000/health")
    print()
    print("   # Get all doctors")
    print("   curl http://localhost:8000/api/doctors/")
    print()
    print("   # Login")
    print('   curl -X POST http://localhost:8000/api/auth/login-json \\')
    print('     -H "Content-Type: application/json" \\')
    print('     -d \'{"email": "doctor@hospital.com", "password": "password123"}\'')
    print()
    print("   # Get appointments (requires auth)")
    print("   curl -X GET http://localhost:8000/api/appointments/ \\")
    print('     -H "Authorization: Bearer <YOUR_TOKEN>"')

if __name__ == "__main__":
    show_all_endpoints()

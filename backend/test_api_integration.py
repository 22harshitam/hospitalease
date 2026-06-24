#!/usr/bin/env python3
"""
Comprehensive API integration test
"""
import requests
import json
from datetime import datetime, timedelta

# API Configuration
BASE_URL = "http://localhost:8000"

def test_api_integration():
    """Test all API endpoints"""
    print("🧪 Starting API Integration Tests")
    print("=" * 50)
    
    results = []
    
    # Test 1: Health Check
    print("\n📋 Test 1: Health Check")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        if response.status_code == 200:
            print("✅ Health check passed")
            print(f"   Response: {response.json()}")
            results.append(True)
        else:
            print(f"❌ Health check failed: {response.status_code}")
            results.append(False)
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        results.append(False)
    
    # Test 2: Get Doctors
    print("\n📋 Test 2: Get All Doctors")
    try:
        response = requests.get(f"{BASE_URL}/api/doctors/", timeout=5)
        if response.status_code == 200:
            doctors = response.json()
            print(f"✅ Doctors retrieved: {len(doctors)} doctors")
            for doctor in doctors[:2]:
                print(f"   - {doctor['name']} ({doctor['specialization']})")
            results.append(True)
        else:
            print(f"❌ Get doctors failed: {response.status_code}")
            results.append(False)
    except Exception as e:
        print(f"❌ Get doctors failed: {e}")
        results.append(False)
    
    # Test 3: Authentication
    print("\n📋 Test 3: Doctor Login")
    try:
        login_data = {
            "email": "doctor@hospital.com",
            "password": "password123"
        }
        response = requests.post(f"{BASE_URL}/api/auth/login-json", 
                               json=login_data, timeout=5)
        if response.status_code == 200:
            token_data = response.json()
            token = token_data['access_token']
            print("✅ Login successful")
            print(f"   Token: {token[:20]}...")
            results.append(True)
            
            # Test 4: Get Current Doctor with Token
            print("\n📋 Test 4: Get Current Doctor")
            headers = {"Authorization": f"Bearer {token}"}
            response = requests.get(f"{BASE_URL}/api/auth/me", headers=headers, timeout=5)
            if response.status_code == 200:
                doctor = response.json()
                print(f"✅ Current doctor: {doctor['name']}")
                print(f"   Email: {doctor['email']}")
                print(f"   Specialization: {doctor['specialization']}")
                results.append(True)
            else:
                print(f"❌ Get current doctor failed: {response.status_code}")
                results.append(False)
                
            # Test 5: Get Appointments with Token
            print("\n📋 Test 5: Get Appointments")
            response = requests.get(f"{BASE_URL}/api/appointments/", headers=headers, timeout=5)
            if response.status_code == 200:
                appointments = response.json()
                print(f"✅ Appointments retrieved: {len(appointments)} appointments")
                for apt in appointments[:2]:
                    print(f"   - {apt['patient_name']} (Token: {apt['token']})")
                results.append(True)
            else:
                print(f"❌ Get appointments failed: {response.status_code}")
                results.append(False)
                
            # Test 6: Create Appointment
            print("\n📋 Test 6: Create Appointment")
            appointment_data = {
                "doctor_id": "1",
                "date": (datetime.now() + timedelta(days=2)).isoformat(),
                "time_slot": "02:00 PM",
                "patient_details": {
                    "name": "Test Patient",
                    "age": "35",
                    "phone": "9876543210",
                    "symptoms": "Test symptoms"
                }
            }
            response = requests.post(f"{BASE_URL}/api/appointments/", 
                                   json=appointment_data, timeout=5)
            if response.status_code == 200:
                appointment = response.json()
                print(f"✅ Appointment created: {appointment['id']}")
                print(f"   Token: {appointment['token']}")
                results.append(True)
            else:
                print(f"❌ Create appointment failed: {response.status_code}")
                print(f"   Error: {response.text}")
                results.append(False)
                
        else:
            print(f"❌ Login failed: {response.status_code}")
            print(f"   Error: {response.text}")
            results.append(False)
    except Exception as e:
        print(f"❌ Authentication test failed: {e}")
        results.append(False)
    
    # Results Summary
    print("\n" + "=" * 50)
    passed = sum(results)
    total = len(results)
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! API integration is working perfectly!")
    else:
        print("⚠️  Some tests failed. Check the errors above.")
    
    return passed == total

def test_server_connectivity():
    """Test if the server is running"""
    print("🌐 Testing server connectivity...")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=3)
        if response.status_code == 200:
            print("✅ Server is running and accessible")
            return True
        else:
            print(f"❌ Server responded with status {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server - is it running?")
        print("   Start the server with: python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000")
        return False
    except Exception as e:
        print(f"❌ Connectivity test failed: {e}")
        return False

if __name__ == "__main__":
    print("🏥 HospitalEasy Backend API Test")
    print("=" * 50)
    
    # First test connectivity
    if test_server_connectivity():
        # Run full integration test
        success = test_api_integration()
        exit(0 if success else 1)
    else:
        print("\n❌ Please start the backend server first:")
        print("   cd /Users/kiranlalk/Desktop/hospitaleasy/backend")
        print("   python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000")
        exit(1)

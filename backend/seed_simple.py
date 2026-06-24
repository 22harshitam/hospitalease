"""
Simple seed data script that handles bcrypt compatibility
"""
import os
import sys
from sqlalchemy.orm import Session
from datetime import datetime, timedelta

# Add the parent directory to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.db.database import SessionLocal, engine
from app.models import Doctor, Appointment, Prescription

def seed_doctors():
    """Seed the database with initial doctors"""
    db = SessionLocal()
    try:
        # Check if doctors already exist
        existing_doctors = db.query(Doctor).count()
        if existing_doctors > 0:
            print(f"Database already has {existing_doctors} doctors. Skipping seed.")
            return True
        
        doctors_data = [
            {
                "id": "1",
                "name": "Dr. Arun Ravi",
                "specialization": "Cardiologist",
                "rating": 4.8,
                "reviews": 120,
                "experience": "12+ Years Experience",
                "image_url": "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
                "biography": "Dr. Arun Ravi is a senior Cardiologist in Mumbai with over 12 years of experience at AIIMS Delhi.",
                "consultation_fee": 1200,
                "email": "doctor@hospital.com",
                "hashed_password": "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj6ukx.LFvO6"  # pre-hashed "password123"
            },
            {
                "id": "2",
                "name": "Dr. Priya Sharma",
                "specialization": "Pediatrician",
                "rating": 4.6,
                "reviews": 98,
                "experience": "8+ Years Experience",
                "image_url": "https://img.freepik.com/free-photo/pleased-young-female-doctor-white-coat-with-stethoscope-around-neck-standing-with-folded-arms-isolated-white-wall_231208-2200.jpg",
                "biography": "Dr. Priya Sharma is a leading Pediatrician in Bangalore, known for her gentle care for infants and children.",
                "consultation_fee": 800,
                "email": "priya@hospital.com",
                "hashed_password": "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj6ukx.LFvO6"  # pre-hashed "password123"
            },
            {
                "id": "3",
                "name": "Dr. Rahul Verma",
                "specialization": "Orthopedic",
                "rating": 4.7,
                "reviews": 110,
                "experience": "15+ Years Experience",
                "image_url": "https://img.freepik.com/free-photo/attractive-medical-professional-with-stethoscope-arms-crossed_2312148827766.jpg",
                "biography": "Dr. Rahul Verma is an expert Orthopedic Surgeon in Pune, specializing in robotic joint replacements.",
                "consultation_fee": 1500,
                "email": "rahul@hospital.com",
                "hashed_password": "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj6ukx.LFvO6"  # pre-hashed "password123"
            },
            {
                "id": "4",
                "name": "Dr. K. S. Lakshmi",
                "specialization": "Dermatologist",
                "rating": 4.9,
                "reviews": 150,
                "experience": "6+ Years Experience",
                "image_url": "https://img.freepik.com/free-photo/portrait-smiling-handsome-male-doctor-man_171337-5055.jpg",
                "biography": "Dr. Lakshmi brings global dermatological expertise to her clinic in Kerala, focusing on advanced skin care.",
                "consultation_fee": 900,
                "email": "lakshmi@hospital.com",
                "hashed_password": "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj6ukx.LFvO6"  # pre-hashed "password123"
            }
        ]
        
        for doctor_data in doctors_data:
            doctor = Doctor(**doctor_data)
            db.add(doctor)
        
        db.commit()
        print(f"✅ Created {len(doctors_data)} doctors")
        return True
        
    except Exception as e:
        print(f"❌ Error seeding doctors: {e}")
        db.rollback()
        return False
    finally:
        db.close()

def seed_appointments():
    """Seed the database with sample appointments"""
    db = SessionLocal()
    try:
        # Check if appointments already exist
        existing_appointments = db.query(Appointment).count()
        if existing_appointments > 0:
            print(f"Database already has {existing_appointments} appointments. Skipping seed.")
            return True
        
        appointments_data = [
            {
                "id": "1",
                "doctor_id": "1",
                "date": datetime.now() + timedelta(days=1),
                "time_slot": "10:00 AM",
                "patient_name": "Arjun Mehta",
                "patient_age": "42",
                "patient_phone": "9876543210",
                "patient_symptoms": "Mild chest pain and high blood pressure",
                "token": "HEA12345"
            },
            {
                "id": "2",
                "doctor_id": "1",
                "date": datetime.now(),
                "time_slot": "11:30 AM",
                "patient_name": "Sunita Deshmukh",
                "patient_age": "29",
                "patient_phone": "9123456789",
                "patient_symptoms": "Severe migraine and nausea",
                "token": "HEA67890"
            }
        ]
        
        for appointment_data in appointments_data:
            appointment = Appointment(**appointment_data)
            db.add(appointment)
        
        db.commit()
        print(f"✅ Created {len(appointments_data)} appointments")
        return True
        
    except Exception as e:
        print(f"❌ Error seeding appointments: {e}")
        db.rollback()
        return False
    finally:
        db.close()

if __name__ == "__main__":
    print("🌱 Seeding database...")
    success = True
    
    if not seed_doctors():
        success = False
    
    if not seed_appointments():
        success = False
    
    if success:
        print("\n🎉 Database seeding completed successfully!")
        print("\n📋 Default Doctor Credentials:")
        print("   Email: doctor@hospital.com | Password: password123")
        print("   Email: priya@hospital.com | Password: password123")
        print("   Email: rahul@hospital.com | Password: password123")
        print("   Email: lakshmi@hospital.com | Password: password123")
    else:
        print("\n❌ Database seeding failed. Please check the errors above.")

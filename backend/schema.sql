-- HospitalEasy Database Schema
-- PostgreSQL Database Schema for Hospital Management System

-- Create database (run this separately)
-- CREATE DATABASE hospitaleasy;

-- Drop existing tables if they exist (for fresh start)
DROP VIEW IF EXISTS appointment_details;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS doctors;

-- Enable UUID extension for generating unique IDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Doctors Table
CREATE TABLE doctors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    rating DECIMAL(3,2) DEFAULT 0.0,
    reviews INTEGER DEFAULT 0,
    experience VARCHAR(100),
    image_url TEXT,
    is_available BOOLEAN DEFAULT true,
    biography TEXT,
    consultation_fee DECIMAL(10,2) DEFAULT 0.0,
    password_hash VARCHAR(255) NOT NULL, -- For doctor login
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Patients Table  
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    age VARCHAR(10) NOT NULL,
    password_hash VARCHAR(255) NOT NULL, -- For patient login
    address TEXT,
    emergency_contact VARCHAR(255),
    blood_group VARCHAR(10),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Appointments Table
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
    patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
    appointment_date DATE NOT NULL,
    time_slot VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'Upcoming' CHECK (status IN ('Upcoming', 'Completed', 'Cancelled')),
    symptoms TEXT,
    token VARCHAR(50) UNIQUE NOT NULL,
    id_file_path TEXT, -- Path to uploaded ID proof
    photo_path TEXT,  -- Path to uploaded photo
    consultation_fee DECIMAL(10,2),
    notes TEXT,        -- Doctor notes after consultation
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_doctors_specialization ON doctors(specialization);
CREATE INDEX idx_doctors_email ON doctors(email);
CREATE INDEX idx_patients_email ON patients(email);
CREATE INDEX idx_appointments_doctor_id ON appointments(doctor_id);
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_token ON appointments(token);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers to automatically update updated_at columns
CREATE TRIGGER update_doctors_updated_at BEFORE UPDATE ON doctors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample doctors data
INSERT INTO doctors (name, email, specialization, rating, reviews, experience, image_url, is_available, biography, consultation_fee, password_hash) VALUES
(
    'Dr. Arun Ravi',
    'doctor@hospital.com',
    'Cardiologist',
    4.8,
    120,
    '12+ Years Experience',
    'https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg',
    true,
    'Dr. Arun Ravi is a senior Cardiologist in Mumbai with over 12 years of experience at AIIMS Delhi.',
    1200.00,
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj6ukx.LFvGK' -- password123
),
(
    'Dr. Priya Sharma',
    'priya@hospital.com', 
    'Pediatrician',
    4.6,
    98,
    '8+ Years Experience',
    'https://img.freepik.com/free-photo/pleased-young-female-doctor-white-coat-with-stethoscope-around-neck-standing-with-folded-arms-isolated-white-wall_231208-2200.jpg',
    true,
    'Dr. Priya Sharma is a leading Pediatrician in Bangalore, known for her gentle care for infants and children.',
    800.00,
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj6ukx.LFvGK' -- password123
);

-- Insert sample appointment data
INSERT INTO appointments (doctor_id, patient_id, appointment_date, time_slot, status, symptoms, token, consultation_fee) VALUES
(
    (SELECT id FROM doctors WHERE email = 'doctor@hospital.com' LIMIT 1),
    (SELECT id FROM patients WHERE email = 'arjun@example.com' LIMIT 1), -- This will be NULL if patient doesn't exist
    '2024-01-15',
    '10:00 AM',
    'Upcoming',
    'Mild chest pain and high blood pressure',
    'HEA12345',
    1200.00
);

-- Create view for appointment details with doctor and patient information
CREATE VIEW appointment_details AS
SELECT 
    a.id,
    a.appointment_date,
    a.time_slot,
    a.status,
    a.symptoms,
    a.token,
    a.consultation_fee,
    a.created_at,
    d.name as doctor_name,
    d.specialization as doctor_specialization,
    d.email as doctor_email,
    d.image_url as doctor_image_url,
    d.consultation_fee as doctor_consultation_fee,
    p.name as patient_name,
    p.age as patient_age,
    p.phone as patient_phone,
    p.email as patient_email
FROM appointments a
LEFT JOIN doctors d ON a.doctor_id = d.id  
LEFT JOIN patients p ON a.patient_id = p.id;

-- Grant permissions (adjust as needed)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hospitaleasy_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hospitaleasy_user;

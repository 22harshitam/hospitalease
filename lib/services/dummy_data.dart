import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/patient.dart';

class DummyDataService {
  static List<Patient> registeredPatients = [];

  static List<Doctor> get doctors => [
    Doctor(
      id: '1',
      name: 'Dr. Arun Ravi',
      specialization: 'Cardiologist',
      rating: 4.8,
      reviews: 120,
      experience: '12+ Years Experience',
      imageUrl:
          'https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg',
      biography:
          'Dr. Arun Ravi is a senior Cardiologist in Mumbai with over 12 years of experience at AIIMS Delhi.',
      consultationFee: 1200,
      email: 'doctor@hospital.com',
      password: 'password123',
    ),
    Doctor(
      id: '2',
      name: 'Dr. Priya Sharma',
      specialization: 'Pediatrician',
      rating: 4.6,
      reviews: 98,
      experience: '8+ Years Experience',
      imageUrl:
          'https://img.freepik.com/free-photo/pleased-young-female-doctor-white-coat-with-stethoscope-around-neck-standing-with-folded-arms-isolated-white-wall_231208-2200.jpg',
      biography:
          'Dr. Priya Sharma is a leading Pediatrician in Bangalore, known for her gentle care for infants and children.',
      consultationFee: 800,
      email: 'priya@hospital.com',
      password: 'password123',
    ),
    Doctor(
      id: '3',
      name: 'Dr. Rahul Verma',
      specialization: 'Orthopedic',
      rating: 4.7,
      reviews: 110,
      experience: '15+ Years Experience',
      imageUrl:
          'https://img.freepik.com/free-photo/attractive-medical-professional-with-stethoscope-arms-crossed_23-2148827766.jpg',
      biography:
          'Dr. Rahul Verma is an expert Orthopedic Surgeon in Pune, specializing in robotic joint replacements.',
      consultationFee: 1500,
      email: 'rahul@hospital.com',
      password: 'password123',
    ),
    Doctor(
      id: '4',
      name: 'Dr. K. S. Lakshmi',
      specialization: 'Dermatologist',
      rating: 4.9,
      reviews: 150,
      experience: '6+ Years Experience',
      imageUrl:
          'https://img.freepik.com/free-photo/portrait-smiling-handsome-male-doctor-man_171337-5055.jpg', // Placeholder
      biography:
          'Dr. Lakshmi brings global dermatological expertise to her clinic in Kerala, focusing on advanced skin care.',
      consultationFee: 900,
      email: 'lakshmi@hospital.com',
      password: 'password123',
    ),
  ];

  static List<Appointment> get appointments => [
    Appointment(
      id: 'apt1',
      doctor: doctors[0], // Dr. Arun Ravi
      date: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '10:00 AM',
      patientDetails: PatientDetails(
        name: 'amrith',
        age: '35',
        phone: '9876543210',
        symptoms: 'Chest pain and shortness of breath',
      ),
      status: 'Upcoming',
      token: 'DUMMY-1234',
    ),
    Appointment(
      id: 'apt2',
      doctor: doctors[0], // Dr. Arun Ravi
      date: DateTime.now().add(const Duration(hours: 2)),
      timeSlot: '11:30 AM',
      patientDetails: PatientDetails(
        name: 'Alice',
        age: '42',
        phone: '9876543211',
        symptoms: 'Routine checkup',
      ),
      status: 'Upcoming',
      token: 'DUMMY-1235',
    ),
    Appointment(
      id: 'apt3',
      doctor: doctors[1], // Dr. Priya Sharma
      date: DateTime.now().add(const Duration(days: 2)),
      timeSlot: '09:00 AM',
      patientDetails: PatientDetails(
        name: 'Baby James',
        age: '2',
        phone: '9876543212',
        symptoms: 'Fever and rash',
      ),
      status: 'Upcoming',
      token: 'DUMMY-5678',
    ),
  ];

  static List<String> get specializations => [
    'Cardiology',
    'Pediatrics',
    'Orthopedic',
    'Dermatology',
    'Neurology',
    'Gastroenterology',
  ];

  static List<String> get timeSlots => [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
  ];
}

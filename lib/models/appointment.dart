import 'doctor.dart';
import 'prescription.dart';

class PatientDetails {
  final String name;
  final String age;
  final String phone;
  final String? email;
  final String? idFilePath; // Functional: local path to the picked file
  final String? photoPath;  // Functional: local path to the captured photo
  final String? symptoms;

  PatientDetails({
    required this.name,
    required this.age,
    required this.phone,
    this.email,
    this.idFilePath,
    this.photoPath,
    this.symptoms,
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'phone': phone,
      'email': email,
      'idFilePath': idFilePath,
      'photoPath': photoPath,
      'symptoms': symptoms,
    };
  }

  factory PatientDetails.fromJson(Map<String, dynamic> json) {
    return PatientDetails(
      name: json['name'],
      age: json['age'],
      phone: json['phone'],
      email: json['email'],
      idFilePath: json['idFilePath'],
      photoPath: json['photoPath'],
      symptoms: json['symptoms'],
    );
  }
}

class Appointment {
  final String id;
  final Doctor doctor;
  final DateTime date;
  final String timeSlot;
  final PatientDetails patientDetails;
  String status; // 'Upcoming', 'Completed', 'Cancelled'
  final String token;
  Prescription? prescription;

  Appointment({
    required this.id,
    required this.doctor,
    required this.date,
    required this.timeSlot,
    required this.patientDetails,
    this.status = 'Upcoming',
    required this.token,
    this.prescription,
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor': doctor.toJson(),
      'date': date.toIso8601String(),
      'time_slot': timeSlot,
      'patient_details': patientDetails.toJson(),
      'status': status,
      'token': token,
      'prescription': prescription?.toJson(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctor: Doctor.fromJson(json['doctor']),
      date: DateTime.parse(json['date']),
      timeSlot: json['time_slot'],
      patientDetails: PatientDetails.fromJson(json['patient_details']),
      status: json['status'],
      token: json['token'],
      prescription: json['prescription'] != null
          ? Prescription.fromJson(json['prescription'])
          : null,
    );
  }
}

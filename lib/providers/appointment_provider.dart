import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/prescription.dart';
import '../services/dummy_data.dart';

class AppointmentProvider extends ChangeNotifier {
  Doctor? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  
  // Current booking details
  String? _pickedIdPath;
  String? _pickedPhotoPath;
  
  final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      doctor: DummyDataService.doctors[0],
      date: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '10:00 AM',
      patientDetails: PatientDetails(
        name: 'Arjun Mehta',
        age: '42',
        phone: '9876543210',
        symptoms: 'Mild chest pain and high blood pressure',
      ),
      token: 'HEA12345',
    ),
    Appointment(
      id: '2',
      doctor: DummyDataService.doctors[0],
      date: DateTime.now(),
      timeSlot: '11:30 AM',
      patientDetails: PatientDetails(
        name: 'Sunita Deshmukh',
        age: '29',
        phone: '9123456789',
        symptoms: 'Severe migraine and nausea',
      ),
      token: 'HEA67890',
    ),
  ];

  Doctor? get selectedDoctor => _selectedDoctor;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;
  String? get pickedIdPath => _pickedIdPath;
  String? get pickedPhotoPath => _pickedPhotoPath;
  List<Appointment> get appointments => _appointments;

  List<Appointment> get prescriptions => 
      _appointments.where((a) => a.prescription != null).toList();

  List<Appointment> get documents => 
      _appointments.where((a) => a.patientDetails.idFilePath != null || a.patientDetails.photoPath != null).toList();

  void selectDoctor(Doctor doctor) {
    _selectedDoctor = doctor;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void selectTimeSlot(String slot) {
    _selectedTimeSlot = slot;
    notifyListeners();
  }

  void setPickedIdPath(String? path) {
    _pickedIdPath = path;
    notifyListeners();
  }

  void setPickedPhotoPath(String? path) {
    _pickedPhotoPath = path;
    notifyListeners();
  }

  Future<Appointment> confirmBooking(PatientDetails patientDetails) async {
    if (_selectedDoctor == null || _selectedDate == null || _selectedTimeSlot == null) {
      throw Exception('Missing booking information');
    }

    // Simulate delay
    await Future.delayed(const Duration(seconds: 2));

    final newAppointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      doctor: _selectedDoctor!,
      date: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
      patientDetails: patientDetails,
      token: 'HEA${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );

    _appointments.insert(0, newAppointment);
    
    // Clear selections for next booking
    _selectedDoctor = null;
    _selectedDate = null;
    _selectedTimeSlot = null;
    _pickedIdPath = null;
    _pickedPhotoPath = null;

    notifyListeners();
    return newAppointment;
  }

  void cancelAppointment(String id) {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _appointments[index].status = 'Cancelled';
      notifyListeners();
    }
  }

  List<Appointment> getAppointmentsForDoctor(String doctorId) {
    return _appointments.where((a) => a.doctor.id == doctorId).toList();
  }

  void addPrescription(String appointmentId, Prescription prescription) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index].prescription = prescription;
      _appointments[index].status = 'Completed';
      notifyListeners();
    }
  }

  List<String> get availableTimeSlots => DummyDataService.timeSlots;
}

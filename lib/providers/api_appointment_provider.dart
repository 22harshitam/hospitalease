import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/prescription.dart';
import '../services/api/appointment_service.dart';
import '../services/api/doctor_service.dart';
import '../services/api/prescription_service.dart';
import '../services/dummy_data.dart';

class ApiAppointmentProvider extends ChangeNotifier {
  Doctor? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  
  // Current booking details
  String? _pickedIdPath;
  String? _pickedPhotoPath;
  
  // Data state
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  List<Appointment> _appointments = [];
  List<Prescription> _prescriptions = [];
  
  // Loading states
  bool _isLoadingDoctors = false;
  bool _isLoadingAppointments = false;
  bool _isLoadingPrescriptions = false;
  
  // Error states
  String? _doctorsError;
  String? _appointmentsError;
  String? _prescriptionsError;

  // Getters
  Doctor? get selectedDoctor => _selectedDoctor;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;
  String? get pickedIdPath => _pickedIdPath;
  String? get pickedPhotoPath => _pickedPhotoPath;
  
  List<Doctor> get doctors => _filteredDoctors.isEmpty ? _doctors : _filteredDoctors;
  List<Appointment> get appointments => _appointments;
  List<Prescription> get prescriptions => _prescriptions;
  
  List<Appointment> get appointmentsWithPrescriptions => 
      _appointments.where((a) => a.prescription != null).toList();

  List<Appointment> get appointmentsWithDocuments => 
      _appointments.where((a) => a.patientDetails.idFilePath != null || a.patientDetails.photoPath != null).toList();

  // Loading getters
  bool get isLoadingDoctors => _isLoadingDoctors;
  bool get isLoadingAppointments => _isLoadingAppointments;
  bool get isLoadingPrescriptions => _isLoadingPrescriptions;
  
  // Error getters
  String? get doctorsError => _doctorsError;
  String? get appointmentsError => _appointmentsError;
  String? get prescriptionsError => _prescriptionsError;

  final DoctorService _doctorService = DoctorService();
  final AppointmentService _appointmentService = AppointmentService();
  final PrescriptionService _prescriptionService = PrescriptionService();

  // Initialize data
  Future<void> initialize() async {
    await loadDoctors();
    await loadAppointments();
    await loadPrescriptions();
  }

  // Load doctors from API
  Future<void> loadDoctors() async {
    try {
      _isLoadingDoctors = true;
      _doctorsError = null;
      notifyListeners();

      _doctors = await _doctorService.getAllDoctors();
      _isLoadingDoctors = false;
      notifyListeners();
    } catch (e) {
      print('API Error loading doctors: $e. Falling back to dummy data.');
      _doctors = DummyDataService.doctors;
      _doctorsError = null;
      _isLoadingDoctors = false;
      notifyListeners();
    }
  }

  // Load appointments from API
  Future<void> loadAppointments({String? doctorId}) async {
    try {
      _isLoadingAppointments = true;
      _appointmentsError = null;
      notifyListeners();

      _appointments = await _appointmentService.getAllAppointments(doctorId: doctorId);
      _isLoadingAppointments = false;
      notifyListeners();
    } catch (e) {
      print('API Error loading appointments: $e. Falling back to dummy data.');
      if (doctorId != null) {
        _appointments = DummyDataService.appointments.where((a) => a.doctor.id == doctorId).toList();
      } else {
        _appointments = DummyDataService.appointments;
      }
      _appointmentsError = null;
      _isLoadingAppointments = false;
      notifyListeners();
    }
  }

  // Load prescriptions from API
  Future<void> loadPrescriptions({String? appointmentId}) async {
    try {
      _isLoadingPrescriptions = true;
      _prescriptionsError = null;
      notifyListeners();

      _prescriptions = await _prescriptionService.getAllPrescriptions(appointmentId: appointmentId);
      _isLoadingPrescriptions = false;
      notifyListeners();
    } catch (e) {
      print('API Error loading prescriptions: $e. Falling back to dummy data.');
      _prescriptions = [];
      _prescriptionsError = null;
      _isLoadingPrescriptions = false;
      notifyListeners();
    }
  }

  // Selection methods
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

  // Create appointment
  Future<Appointment> confirmBooking(PatientDetails patientDetails) async {
    try {
      if (_selectedDoctor == null || _selectedDate == null || _selectedTimeSlot == null) {
        throw Exception('Missing booking information');
      }

      final newAppointment = await _appointmentService.createAppointment(
        doctorId: _selectedDoctor!.id,
        date: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        patientDetails: patientDetails,
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
    } catch (e) {
      print('API Error confirming booking: $e. Using local dummy logic.');
      final newAppointment = Appointment(
        id: 'dummy_apt_${DateTime.now().millisecondsSinceEpoch}',
        doctor: _selectedDoctor!,
        date: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        patientDetails: patientDetails,
        token: 'DUMMY-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      );

      _appointments.insert(0, newAppointment);
      
      _selectedDoctor = null;
      _selectedDate = null;
      _selectedTimeSlot = null;
      _pickedIdPath = null;
      _pickedPhotoPath = null;

      notifyListeners();
      return newAppointment;
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(String id) async {
    try {
      await _appointmentService.cancelAppointment(id);
      
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _appointments[index].status = 'Cancelled';
        notifyListeners();
      }
    } catch (e) {
      print('API Error cancelling appointment: $e. Using local dummy logic.');
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _appointments[index].status = 'Cancelled';
        notifyListeners();
      }
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String id, String status) async {
    try {
      final updatedAppointment = await _appointmentService.updateAppointmentStatus(
        appointmentId: id,
        status: status,
      );
      
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _appointments[index] = updatedAppointment;
        notifyListeners();
      }
    } catch (e) {
      print('API Error updating status: $e. Using local dummy logic.');
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _appointments[index].status = status;
        notifyListeners();
      }
    }
  }

  // Add prescription
  Future<void> addPrescription(String appointmentId, Prescription prescription) async {
    try {
      final createdPrescription = await _prescriptionService.createPrescription(
        appointmentId: appointmentId,
        medicines: prescription.medicines,
        instructions: prescription.instructions,
        date: prescription.date,
      );

      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index].prescription = createdPrescription;
        _appointments[index].status = 'Completed';
        notifyListeners();
      }
    } catch (e) {
      print('API Error adding prescription: $e. Using local dummy logic.');
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index].prescription = prescription;
        _appointments[index].status = 'Completed';
        notifyListeners();
      }
    }
  }

  // Get appointments for specific doctor
  List<Appointment> getAppointmentsForDoctor(String doctorId, {String? doctorEmail}) {
    final cleanId = doctorId.trim().toLowerCase();
    final cleanEmail = doctorEmail?.trim().toLowerCase();
    return _appointments.where((a) {
      final aDocId = a.doctor.id.trim().toLowerCase();
      final aDocEmail = a.doctor.email?.trim().toLowerCase();
      
      if (aDocId == cleanId) return true;
      if (cleanEmail != null && aDocEmail == cleanEmail) return true;
      return false;
    }).toList();
  }

  // Get available time slots (you might want to fetch this from API too)
  List<String> get availableTimeSlots => [
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

  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadDoctors(),
      loadAppointments(),
      loadPrescriptions(),
    ]);
  }

  // Search doctors
  void searchDoctors(String query) {
    if (query.isEmpty) {
      _filteredDoctors = [];
    } else {
      _filteredDoctors = _doctors.where((doctor) {
        final name = doctor.name.toLowerCase();
        final specialization = doctor.specialization.toLowerCase();
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || specialization.contains(searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  // Clear errors
  void clearErrors() {
    _doctorsError = null;
    _appointmentsError = null;
    _prescriptionsError = null;
    notifyListeners();
  }
}

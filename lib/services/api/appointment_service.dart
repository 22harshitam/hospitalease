import 'dart:convert';

import '../../models/appointment.dart';
import '../../models/doctor.dart';
import 'api_client.dart';
import 'api_config.dart';

class AppointmentService {
  final ApiClient _apiClient = ApiClient();

  /// Get all appointments (filtered by current doctor)
  Future<List<Appointment>> getAllAppointments({
    String? doctorId,
    String? status,
  }) async {
    try {
      String endpoint = ApiConfig.appointments;
      List<String> queryParams = [];
      
      if (doctorId != null) {
        queryParams.add('doctor_id=$doctorId');
      }
      if (status != null) {
        queryParams.add('status=$status');
      }
      
      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiClient.get(endpoint, requireAuth: true);
      final List<dynamic> data = jsonDecode(response.body);
      
      return data.map((json) => _mapAppointmentFromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to get appointments: ${e.toString()}', 0);
    }
  }

  /// Get appointment by ID
  Future<Appointment> getAppointmentById(String appointmentId) async {
    try {
      final response = await _apiClient.get('${ApiConfig.appointmentById}$appointmentId', requireAuth: true);
      final data = jsonDecode(response.body);
      
      return _mapAppointmentFromJson(data);
    } catch (e) {
      throw ApiException('Failed to get appointment: ${e.toString()}', 0);
    }
  }

  /// Create new appointment
  Future<Appointment> createAppointment({
    required String doctorId,
    required DateTime date,
    required String timeSlot,
    required PatientDetails patientDetails,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.appointments,
        body: {
          'doctor_id': doctorId,
          'date': date.toIso8601String(),
          'time_slot': timeSlot,
          'patient_details': {
            'name': patientDetails.name,
            'age': patientDetails.age,
            'phone': patientDetails.phone,
            'email': patientDetails.email,
            'symptoms': patientDetails.symptoms,
          },
        },
        requireAuth: false,
      );
      
      final data = jsonDecode(response.body);
      return _mapAppointmentFromJson(data);
    } catch (e) {
      throw ApiException('Failed to create appointment: ${e.toString()}', 0);
    }
  }

  /// Update appointment status
  Future<Appointment> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    try {
      final response = await _apiClient.put(
        '${ApiConfig.appointmentById}$appointmentId',
        body: {
          'status': status,
        },
        requireAuth: true,
      );
      
      final data = jsonDecode(response.body);
      
      return _mapAppointmentFromJson(data);
    } catch (e) {
      throw ApiException('Failed to update appointment: ${e.toString()}', 0);
    }
  }

  /// Cancel appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      await _apiClient.delete('${ApiConfig.appointmentById}$appointmentId', requireAuth: true);
      return true;
    } catch (e) {
      throw ApiException('Failed to cancel appointment: ${e.toString()}', 0);
    }
  }

  /// Get appointments for specific doctor
  Future<List<Appointment>> getAppointmentsForDoctor(String doctorId) async {
    try {
      return await getAllAppointments(doctorId: doctorId);
    } catch (e) {
      throw ApiException('Failed to get appointments for doctor: ${e.toString()}', 0);
    }
  }

  /// Helper method to map JSON to Appointment model
  Appointment _mapAppointmentFromJson(Map<String, dynamic> json) {
    // Handle patient details from PostgreSQL response format
    Map<String, dynamic> patientData;
    if (json['patient_details'] is Map) {
      patientData = json['patient_details'];
    } else {
      // PostgreSQL response format has flat patient fields
      patientData = {
        'name': json['patient_name'] ?? '',
        'age': json['patient_age'] ?? '',
        'phone': json['patient_phone'] ?? '',
        'email': json['patient_email'] ?? '',
        'symptoms': json['patient_symptoms'] ?? json['symptoms'] ?? '',
      };
    }
    
    // Handle doctor information from PostgreSQL response
    String doctorId = json['doctor_id']?.toString() ?? '';
    String doctorName = json['doctor_name'] ?? 'Doctor';
    String doctorSpecialization = json['doctor_specialization'] ?? 'General';
    
    // If doctor details are not in the response, use basic info
    return Appointment(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      doctor: Doctor(
        id: doctorId,
        name: doctorName,
        specialization: doctorSpecialization,
        rating: (json['doctor_rating'] ?? 4.5).toDouble(),
        reviews: json['doctor_reviews'] ?? 0,
        experience: json['doctor_experience'] ?? '',
        imageUrl: json['doctor_image_url'] ?? '',
        biography: json['doctor_biography'] ?? '',
        consultationFee: (json['doctor_consultation_fee'] ?? 500.0).toDouble(),
      ),
      date: DateTime.parse(json['date']),
      timeSlot: json['time_slot'] ?? '',
      patientDetails: PatientDetails(
        name: patientData['name'] ?? '',
        age: patientData['age'] ?? '',
        phone: patientData['phone'] ?? '',
        email: patientData['email'],
        symptoms: patientData['symptoms'],
      ),
      status: json['status'] ?? 'Upcoming',
      token: json['token'] ?? 'APT${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

import 'dart:convert';
import 'api_client.dart';
import 'api_config.dart';
import '../../models/prescription.dart';

class PrescriptionService {
  final ApiClient _apiClient = ApiClient();

  /// Get all prescriptions (filtered by current doctor)
  Future<List<Prescription>> getAllPrescriptions({
    String? appointmentId,
  }) async {
    try {
      String endpoint = ApiConfig.prescriptions;
      
      if (appointmentId != null) {
        endpoint += '?appointment_id=$appointmentId';
      }

      final response = await _apiClient.get(endpoint, requireAuth: true);
      final List<dynamic> data = jsonDecode(response.body);
      
      return data.map((json) => _mapPrescriptionFromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to get prescriptions: ${e.toString()}', 0);
    }
  }

  /// Get prescription by ID
  Future<Prescription> getPrescriptionById(int prescriptionId) async {
    try {
      final response = await _apiClient.get('${ApiConfig.prescriptionById}$prescriptionId', requireAuth: true);
      final data = jsonDecode(response.body);
      
      return _mapPrescriptionFromJson(data);
    } catch (e) {
      throw ApiException('Failed to get prescription: ${e.toString()}', 0);
    }
  }

  /// Create new prescription
  Future<Prescription> createPrescription({
    required String appointmentId,
    required List<String> medicines,
    required String instructions,
    required DateTime date,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.prescriptions,
        body: {
          'appointment_id': appointmentId,
          'medicines': medicines,
          'instructions': instructions,
          'date': date.toIso8601String(),
        },
        requireAuth: true,
      );
      
      final data = jsonDecode(response.body);
      
      return _mapPrescriptionFromJson(data);
    } catch (e) {
      throw ApiException('Failed to create prescription: ${e.toString()}', 0);
    }
  }

  /// Update prescription
  Future<Prescription> updatePrescription({
    required int prescriptionId,
    required List<String> medicines,
    required String instructions,
    required DateTime date,
  }) async {
    try {
      final response = await _apiClient.put(
        '${ApiConfig.prescriptionById}$prescriptionId',
        body: {
          'medicines': medicines,
          'instructions': instructions,
          'date': date.toIso8601String(),
        },
        requireAuth: true,
      );
      
      final data = jsonDecode(response.body);
      
      return _mapPrescriptionFromJson(data);
    } catch (e) {
      throw ApiException('Failed to update prescription: ${e.toString()}', 0);
    }
  }

  /// Get prescriptions for specific appointment
  Future<List<Prescription>> getPrescriptionsForAppointment(String appointmentId) async {
    try {
      return await getAllPrescriptions(appointmentId: appointmentId);
    } catch (e) {
      throw ApiException('Failed to get prescriptions for appointment: ${e.toString()}', 0);
    }
  }

  /// Helper method to map JSON to Prescription model
  Prescription _mapPrescriptionFromJson(Map<String, dynamic> json) {
    return Prescription(
      medicines: List<String>.from(json['medicines']),
      instructions: json['instructions'],
      date: DateTime.parse(json['date']),
    );
  }
}

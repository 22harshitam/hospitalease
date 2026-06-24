import 'dart:convert';

import 'package:hospitaleasy/models/patient.dart';

import '../../models/doctor.dart';
import 'api_client.dart';
import 'api_config.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Test authentication endpoint
  Future<bool> testAuth() async {
    try {
      final response = await _apiClient.get(ApiConfig.authTest, requireAuth: false);
      final data = jsonDecode(response.body);
      return data['message'] == 'Authentication endpoint is working';
    } catch (e) {
      throw ApiException('Failed to test authentication: ${e.toString()}', 0);
    }
  }

  /// Login with email and password
  Future<String> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.authLogin,
        body: {
          'email': email,
          'password': password,
        },
        requireAuth: false,
      );

      final data = jsonDecode(response.body);
      final token = data['access_token'];
      
      // Save token securely
      await _apiClient.saveAuthToken(token);
      
      return token;
    } catch (e) {
      throw ApiException('Login failed: ${e.toString()}', 0);
    }
  }

  /// Doctor login with email and password
  Future<String> loginAsDoctor(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.authLogin,
        body: {
          'email': email,
          'password': password,
          'user_type': 'doctor',
        },
        requireAuth: false,
      );

      final data = jsonDecode(response.body);
      final token = data['access_token'];
      
      // Save token securely
      await _apiClient.saveAuthToken(token);
      
      return token;
    } catch (e) {
      throw ApiException('Doctor login failed: ${e.toString()}', 0);
    }
  }

  /// Patient login with email and password
  Future<String> loginAsPatient(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/patient/login',
        body: {
          'email': email,
          'password': password,
        },
        requireAuth: false,
      );

      final data = jsonDecode(response.body);
      final token = data['access_token'];
      
      // Save token securely
      await _apiClient.saveAuthToken(token);
      
      return token;
    } catch (e) {
      throw ApiException('Patient login failed: ${e.toString()}', 0);
    }
  }

  /// Patient registration
  Future<String> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String age,
    String? address,
    String? emergencyContact,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/patient/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'age': age,
          'address': address ?? '',
          'emergency_contact': emergencyContact ?? '',
        },
        requireAuth: false,
      );

      final data = jsonDecode(response.body);
      final token = data['access_token'];
      
      // Save token securely
      await _apiClient.saveAuthToken(token);
      
      return token;
    } catch (e) {
      throw ApiException('Patient registration failed: ${e.toString()}', 0);
    }
  }

  /// Get current doctor profile
  Future<Doctor> getCurrentDoctor() async {
    try {
      final response = await _apiClient.get(ApiConfig.authMe, requireAuth: true);
      final data = jsonDecode(response.body);
      
      return Doctor(
        id: data['id'],
        name: data['name'],
        specialization: data['specialization'],
        rating: data['rating'].toDouble(),
        reviews: data['reviews'],
        experience: data['experience'],
        imageUrl: data['image_url'],
        isAvailable: data['is_available'],
        biography: data['biography'],
        consultationFee: data['consultation_fee'].toDouble(),
        email: data['email'],
      );
    } catch (e) {
      throw ApiException('Failed to get doctor profile: ${e.toString()}', 0);
    }
  }

  /// Get current patient profile
  Future<Patient> getCurrentPatient() async {
    try {
      final response = await _apiClient.get(ApiConfig.authMe, requireAuth: true);
      final data = jsonDecode(response.body);
      
      return Patient(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        phone: data['phone'],
        age: data['age'],
        bloodGroup: data['blood_group'],
        address: data['address'],
        emergencyContact: data['emergency_contact'],
        createdAt: DateTime.parse(data['created_at']),
      );
    } catch (e) {
      throw ApiException('Failed to get patient profile: ${e.toString()}', 0);
    }
  }

  /// Logout and clear token
  Future<void> logout() async {
    try {
      await _apiClient.clearAuthToken();
    } catch (e) {
      throw ApiException('Logout failed: ${e.toString()}', 0);
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await _apiClient.getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Validate current token
  Future<bool> validateToken() async {
    try {
      await getCurrentDoctor();
      return true;
    } catch (e) {
      await _apiClient.clearAuthToken();
      return false;
    }
  }
}

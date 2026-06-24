import 'dart:convert';
import 'api_client.dart';
import 'api_config.dart';
import '../../models/doctor.dart';

class DoctorService {
  final ApiClient _apiClient = ApiClient();

  /// Get all doctors
  Future<List<Doctor>> getAllDoctors() async {
    try {
      final response = await _apiClient.get(ApiConfig.doctors, requireAuth: false);
      final List<dynamic> data = jsonDecode(response.body);
      
      return data.map((json) => Doctor(
        id: json['id'],
        name: json['name'],
        specialization: json['specialization'],
        rating: json['rating'].toDouble(),
        reviews: json['reviews'],
        experience: json['experience'],
        imageUrl: json['image_url'],
        isAvailable: json['is_available'],
        biography: json['biography'],
        consultationFee: json['consultation_fee'].toDouble(),
        email: json['email'],
      )).toList();
    } catch (e) {
      throw ApiException('Failed to get doctors: ${e.toString()}', 0);
    }
  }

  /// Get doctor by ID
  Future<Doctor> getDoctorById(String doctorId) async {
    try {
      final response = await _apiClient.get('${ApiConfig.doctorById}$doctorId', requireAuth: false);
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
      throw ApiException('Failed to get doctor: ${e.toString()}', 0);
    }
  }

  /// Create new doctor
  Future<Doctor> createDoctor({
    required String name,
    required String specialization,
    required double rating,
    required int reviews,
    required String experience,
    required String imageUrl,
    required String biography,
    required double consultationFee,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.doctors,
        body: {
          'name': name,
          'specialization': specialization,
          'rating': rating,
          'reviews': reviews,
          'experience': experience,
          'image_url': imageUrl,
          'biography': biography,
          'consultation_fee': consultationFee,
          'email': email,
          'password': password,
        },
        requireAuth: false,
      );
      
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
      throw ApiException('Failed to create doctor: ${e.toString()}', 0);
    }
  }

  /// Update doctor profile
  Future<Doctor> updateDoctor({
    required String doctorId,
    String? name,
    String? specialization,
    double? rating,
    int? reviews,
    String? experience,
    String? imageUrl,
    bool? isAvailable,
    String? biography,
    double? consultationFee,
    String? email,
    String? password,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      
      if (name != null) body['name'] = name;
      if (specialization != null) body['specialization'] = specialization;
      if (rating != null) body['rating'] = rating;
      if (reviews != null) body['reviews'] = reviews;
      if (experience != null) body['experience'] = experience;
      if (imageUrl != null) body['image_url'] = imageUrl;
      if (isAvailable != null) body['is_available'] = isAvailable;
      if (biography != null) body['biography'] = biography;
      if (consultationFee != null) body['consultation_fee'] = consultationFee;
      if (email != null) body['email'] = email;
      if (password != null) body['password'] = password;

      final response = await _apiClient.put(
        '${ApiConfig.doctorById}$doctorId',
        body: body,
        requireAuth: true,
      );
      
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
      throw ApiException('Failed to update doctor: ${e.toString()}', 0);
    }
  }
}

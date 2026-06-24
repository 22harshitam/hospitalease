import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/dummy_data.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isDoctor = false;
  String? _userName;
  String? _userEmail;
  Doctor? _loggedDoctor;

  bool get isAuthenticated => _isAuthenticated;
  bool get isDoctor => _isDoctor;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  Doctor? get loggedDoctor => _loggedDoctor;

  Future<void> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _isDoctor = false;
    _userName = 'Aarav Sharma';
    _userEmail = email;
    _loggedDoctor = null;
    notifyListeners();
  }

  Future<void> loginAsDoctor(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final doctor = DummyDataService.doctors.firstWhere(
      (d) => d.email == email && d.password == password,
      orElse: () => throw Exception('Invalid doctor credentials'),
    );

    _isAuthenticated = true;
    _isDoctor = true;
    _userName = doctor.name;
    _userEmail = doctor.email;
    _loggedDoctor = doctor;
    notifyListeners();
  }

  Future<void> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _isDoctor = false;
    _userName = null;
    _userEmail = null;
    _loggedDoctor = null;
    notifyListeners();
  }

  void loginAsGuest() {
    _isAuthenticated = true;
    _userName = 'Guest User';
    _userEmail = 'guest@example.com';
    notifyListeners();
  }
}

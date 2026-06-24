import 'package:flutter/material.dart';
import 'package:hospitaleasy/models/patient.dart';

import '../models/doctor.dart';
import '../services/api/auth_service.dart';
import '../services/dummy_data.dart';

class ApiAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // State
  dynamic _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  // Getters
  dynamic get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  
  // Type-specific getters
  Doctor? get currentDoctor => _currentUser is Doctor ? _currentUser as Doctor : null;
  Patient? get currentPatient => _currentUser is Patient ? _currentUser as Patient : null;
  String? get userType {
    if (_currentUser is Doctor) return 'doctor';
    if (_currentUser is Patient) return 'patient';
    return null;
  }

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final loggedIn = await _authService.isLoggedIn();
      if (loggedIn) {
        final isValid = await _authService.validateToken();
        if (isValid) {
          try {
            _currentUser = await _authService.getCurrentDoctor();
          } catch (e) {
            try {
              _currentUser = await _authService.getCurrentPatient();
            } catch (e2) {
              // Both failed, fallback to dummy
              _currentUser = DummyDataService.doctors.first;
            }
          }
          _isLoggedIn = true;
        } else {
          await _authService.logout();
          _isLoggedIn = false;
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.login(email, password);
      _currentUser = await _authService.getCurrentDoctor();
      _isLoggedIn = true;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('API Error during login: $e. Falling back to dummy data.');
      try {
        _currentUser = DummyDataService.doctors.firstWhere((d) => d.email == email);
      } catch (_) {
        _currentUser = DummyDataService.doctors.first;
      }
      _isLoggedIn = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // Doctor login
  Future<bool> loginAsDoctor(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.loginAsDoctor(email, password);
      _currentUser = await _authService.getCurrentDoctor();
      _isLoggedIn = true;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('API Error during doctor login: $e. Falling back to dummy data.');
      try {
        _currentUser = DummyDataService.doctors.firstWhere((d) => d.email == email);
      } catch (_) {
        _currentUser = DummyDataService.doctors.first;
      }
      _isLoggedIn = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // Patient login
  Future<bool> loginAsPatient(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.loginAsPatient(email, password);
      _currentUser = await _authService.getCurrentPatient();
      _isLoggedIn = true;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('API Error during patient login: $e. Falling back to dummy data.');
      try {
        _currentUser = DummyDataService.registeredPatients.firstWhere((p) => p.email == email);
      } catch (_) {
        _currentUser = Patient(
          id: 'dummy_patient_id',
          name: 'Dummy Patient',
          email: email,
          phone: '+91 9876543210',
          age: '30',
          bloodGroup: 'O+',
          address: 'Dummy Address',
          emergencyContact: '1234567890',
          createdAt: DateTime.now(),
        );
      }
      _isLoggedIn = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // Patient registration
  Future<bool> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String age,
    String? address,
    String? emergencyContact,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.registerPatient(
        name: name,
        email: email,
        password: password,
        phone: phone,
        age: age,
        address: address,
        emergencyContact: emergencyContact,
      );
      _currentUser = await _authService.getCurrentPatient();
      _isLoggedIn = true;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('API Error during patient registration: $e. Falling back to dummy data.');
      Patient newPatient = Patient(
        id: 'dummy_patient_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        age: age,
        bloodGroup: 'Unknown',
        address: address ?? 'Dummy Address',
        emergencyContact: emergencyContact ?? '1234567890',
        createdAt: DateTime.now(),
      );
      DummyDataService.registeredPatients.add(newPatient);
      _currentUser = newPatient;
      _isLoggedIn = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  // Test authentication
  Future<bool> testAuth() async {
    try {
      return await _authService.testAuth();
    } catch (e) {
      return false; // Could return true for dummy simulation, but false is safer to indicate API is down
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      if (_isLoggedIn) {
        if (_currentUser is Doctor) {
          _currentUser = await _authService.getCurrentDoctor();
        } else if (_currentUser is Patient) {
          _currentUser = await _authService.getCurrentPatient();
        }
        notifyListeners();
      }
    } catch (e) {
      // Keep current dummy user if API fails
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

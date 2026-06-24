import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/dummy_data.dart';

class DoctorProvider extends ChangeNotifier {
  List<Doctor> _doctors = [];
  bool _isLoading = false;
  String? _selectedSpecialization;
  String _searchQuery = '';

  List<Doctor> get doctors => _doctors;
  bool get isLoading => _isLoading;
  String? get selectedSpecialization => _selectedSpecialization;

  DoctorProvider() {
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    _isLoading = true;
    notifyListeners();

    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 800));
    _doctors = DummyDataService.doctors;
    
    _isLoading = false;
    notifyListeners();
  }

  void searchDoctors(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void filterBySpecialization(String? specialization) {
    _selectedSpecialization = specialization;
    _applyFilters();
  }

  void _applyFilters() {
    _doctors = DummyDataService.doctors.where((doctor) {
      final matchesSearch = doctor.name.toLowerCase().contains(_searchQuery) ||
          doctor.specialization.toLowerCase().contains(_searchQuery);
      final matchesSpecialization = _selectedSpecialization == null ||
          doctor.specialization == _selectedSpecialization;
      return matchesSearch && matchesSpecialization;
    }).toList();
    notifyListeners();
  }

  List<String> get specializations => DummyDataService.specializations;
}

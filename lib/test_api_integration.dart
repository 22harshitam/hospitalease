import 'dart:io';

import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../services/api/api_client.dart';
import '../services/api/appointment_service.dart';
import '../services/api/auth_service.dart';
import '../services/api/doctor_service.dart';

/// Simple test to verify API integration
class ApiIntegrationTest {
  static Future<void> runTests() async {
    print('🧪 Starting API Integration Tests...\n');
    
    final apiClient = ApiClient();
    final authService = AuthService();
    final doctorService = DoctorService();
    final appointmentService = AppointmentService();
    
    bool allTestsPassed = true;
    
    // Test 1: Health Check
    print('📋 Test 1: Health Check');
    try {
      final response = await apiClient.get('/health', requireAuth: false);
      print('✅ Health check passed: ${response.body}');
    } catch (e) {
      print('❌ Health check failed: $e');
      allTestsPassed = false;
    }
    
    // Test 2: Authentication Test
    print('\n📋 Test 2: Authentication Test');
    try {
      final result = await authService.testAuth();
      print('✅ Authentication test passed: $result');
    } catch (e) {
      print('❌ Authentication test failed: $e');
      allTestsPassed = false;
    }
    
    // Test 3: Doctor Login
    print('\n📋 Test 3: Doctor Login');
    try {
      final token = await authService.login('doctor@hospital.com', 'password123');
      print('✅ Login successful: Token received');
      print('   Token: ${token.substring(0, 20)}...');
    } catch (e) {
      print('❌ Login failed: $e');
      allTestsPassed = false;
    }
    
    // Test 4: Get Current Doctor
    print('\n📋 Test 4: Get Current Doctor');
    try {
      final doctor = await authService.getCurrentDoctor();
      print('✅ Current doctor retrieved: ${doctor.name}');
      print('   Email: ${doctor.email}');
      print('   Specialization: ${doctor.specialization}');
    } catch (e) {
      print('❌ Get current doctor failed: $e');
      allTestsPassed = false;
    }
    
    // Test 5: Get All Doctors
    print('\n📋 Test 5: Get All Doctors');
    try {
      final doctors = await doctorService.getAllDoctors();
      print('✅ Doctors retrieved: ${doctors.length} doctors found');
      for (final doctor in doctors.take(2)) {
        print('   - ${doctor.name} (${doctor.specialization})');
      }
    } catch (e) {
      print('❌ Get doctors failed: $e');
      allTestsPassed = false;
    }
    
    // Test 6: Get Appointments
    print('\n📋 Test 6: Get Appointments');
    try {
      final appointments = await appointmentService.getAllAppointments();
      print('✅ Appointments retrieved: ${appointments.length} appointments found');
      for (final appointment in appointments.take(2)) {
        print('   - ${appointment.patientDetails.name} with Dr. ${appointment.doctor.name}');
      }
    } catch (e) {
      print('❌ Get appointments failed: $e');
      allTestsPassed = false;
    }
    
    // Test 7: Create Appointment
    print('\n📋 Test 7: Create Appointment');
    try {
      final newAppointment = await appointmentService.createAppointment(
        doctorId: '1',
        date: DateTime.now().add(Duration(days: 2)),
        timeSlot: '02:00 PM',
        patientDetails: PatientDetails(
          name: 'Test Patient',
          age: '35',
          phone: '9876543210',
          symptoms: 'Test symptoms',
        ),
      );
      print('✅ Appointment created successfully');
      print('   ID: ${newAppointment.id}');
      print('   Token: ${newAppointment.token}');
    } catch (e) {
      print('❌ Create appointment failed: $e');
      allTestsPassed = false;
    }
    
    // Test 8: Logout
    print('\n📋 Test 8: Logout');
    try {
      await authService.logout();
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout failed: $e');
      allTestsPassed = false;
    }
    
    // Final Result
    print('\n${'=' * 50}');
    if (allTestsPassed) {
      print('🎉 All API integration tests passed!');
      print('✅ Your Flutter app is ready to connect to the backend!');
    } else {
      print('❌ Some tests failed. Please check the errors above.');
    }
    print('=' * 50);
  }
  
  /// Test network connectivity
  static Future<bool> testNetworkConnectivity() async {
    print('🌐 Testing network connectivity...');
    try {
      final result = await InternetAddress.lookup('localhost');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('✅ Network connectivity OK');
        return true;
      }
    } catch (e) {
      print('❌ Network connectivity failed: $e');
    }
    return false;
  }
  
  /// Test backend server availability
  static Future<bool> testBackendServer() async {
    print('🔧 Testing backend server availability...');
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get('/health', requireAuth: false);
      if (response.statusCode == 200) {
        print('✅ Backend server is running');
        return true;
      }
    } catch (e) {
      print('❌ Backend server not available: $e');
    }
    return false;
  }
}

/// Widget to run tests in Flutter app
class ApiTestWidget extends StatefulWidget {
  const ApiTestWidget({super.key});

  @override
  _ApiTestWidgetState createState() => _ApiTestWidgetState();
}

class _ApiTestWidgetState extends State<ApiTestWidget> {
  bool _isRunning = false;
  String _result = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Integration Test'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isRunning ? null : _runTests,
              child: _isRunning 
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Running Tests...'),
                    ],
                  )
                : Text('Run API Tests'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result.isEmpty ? 'Test results will appear here...' : _result,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _result = 'Running API integration tests...\n\n';
    });
    
    try {
      await ApiIntegrationTest.runTests();
      setState(() {
        _isRunning = false;
        _result += '\n✅ Tests completed! Check console for detailed results.';
      });
    } catch (e) {
      setState(() {
        _isRunning = false;
        _result += '\n❌ Test execution failed: $e';
      });
    }
  }
}

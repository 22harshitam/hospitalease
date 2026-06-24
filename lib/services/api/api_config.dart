class ApiConfig {
  // If using Android Emulator, use '10.0.2.2'. If using a physical device, use '10.75.161.160'.
  static const String baseUrl = 'http://192.168.0.108:8000';
  static const Duration timeout = Duration(seconds: 3);
  
  // Endpoints
  static const String authTest = '/api/auth/test';
  static const String authLogin = '/api/auth/login-json';
  static const String authMe = '/api/auth/me';
  
  static const String doctors = '/api/doctors';
  static const String doctorById = '/api/doctors/';
  
  static const String appointments = '/api/appointments';
  static const String appointmentById = '/api/appointments/';
  
  static const String prescriptions = '/api/prescriptions';
  static const String prescriptionById = '/api/prescriptions/';
  
  static const String health = '/health';
  static const String root = '/';
}

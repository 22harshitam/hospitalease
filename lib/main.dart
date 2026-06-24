import 'package:flutter/material.dart';
import 'package:hospitaleasy/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'providers/api_appointment_provider.dart';
import 'providers/api_auth_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API providers
  final authProvider = ApiAuthProvider();
  await authProvider.initialize();

  final appointmentProvider = ApiAppointmentProvider();
  await appointmentProvider.initialize();

  // Initialize AuthProvider for guest functionality
  final localAuthProvider = AuthProvider();

  runApp(
    HospitalEasyApp(
      authProvider: authProvider,
      appointmentProvider: appointmentProvider,
      localAuthProvider: localAuthProvider,
    ),
  );
}

class HospitalEasyApp extends StatelessWidget {
  final ApiAuthProvider authProvider;
  final ApiAppointmentProvider appointmentProvider;
  final AuthProvider localAuthProvider;

  const HospitalEasyApp({
    super.key,
    required this.authProvider,
    required this.appointmentProvider,
    required this.localAuthProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: appointmentProvider),
        ChangeNotifierProvider.value(value: localAuthProvider),
      ],
      child: MaterialApp(
        title: 'HospitalEasy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}

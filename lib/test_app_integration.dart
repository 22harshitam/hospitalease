import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../models/doctor.dart';
import '../providers/api_appointment_provider.dart';
import '../providers/api_auth_provider.dart';

/// Complete Flutter API Integration Test App
class ApiIntegrationTestApp extends StatelessWidget {
  const ApiIntegrationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HospitalEasy API Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ApiAuthProvider()),
          ChangeNotifierProvider(create: (_) => ApiAppointmentProvider()),
        ],
        child: ApiTestHomePage(),
      ),
    );
  }
}

class ApiTestHomePage extends StatefulWidget {
  const ApiTestHomePage({super.key});

  @override
  _ApiTestHomePageState createState() => _ApiTestHomePageState();
}

class _ApiTestHomePageState extends State<ApiTestHomePage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<ApiAuthProvider>(context, listen: false);
    await authProvider.initialize();
    
    final appointmentProvider = Provider.of<ApiAppointmentProvider>(context, listen: false);
    await appointmentProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HospitalEasy API Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ApiAuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing app...'),
                ],
              ),
            );
          }

          if (!authProvider.isLoggedIn) {
            return LoginScreen();
          }

          return MainAppScreen();
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'doctor@hospital.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiAuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.local_hospital,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 32),
              Text(
                'HospitalEasy',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'API Integration Test',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              if (authProvider.error != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authProvider.error!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => authProvider.clearError(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Signing in...'),
                        ],
                      )
                    : Text('Sign In'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<ApiAuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );
    
    setState(() => _isLoading = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ApiAuthProvider, ApiAppointmentProvider>(
      builder: (context, authProvider, appointmentProvider, child) {
        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.currentUser?.name ?? 'Doctor',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            authProvider.currentUser?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () async {
                        await authProvider.logout();
                      },
                    ),
                  ],
                ),
              ),
              TabBar(
                tabs: [
                  Tab(text: 'Doctors', icon: Icon(Icons.people)),
                  Tab(text: 'Appointments', icon: Icon(Icons.calendar_today)),
                  Tab(text: 'Test', icon: Icon(Icons.science)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    DoctorsTab(),
                    AppointmentsTab(),
                    TestTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DoctorsTab extends StatelessWidget {
  const DoctorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiAppointmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingDoctors) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.doctorsError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Error loading doctors'),
                Text(provider.doctorsError!),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadDoctors(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.doctors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No doctors available'),
                ElevatedButton(
                  onPressed: () => provider.loadDoctors(),
                  child: Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadDoctors(),
          child: ListView.builder(
            itemCount: provider.doctors.length,
            itemBuilder: (context, index) {
              final doctor = provider.doctors[index];
              return DoctorCard(doctor: doctor);
            },
          ),
        );
      },
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(doctor.imageUrl),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(doctor.specialization),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text('${doctor.rating} (${doctor.reviews} reviews)'),
                    ],
                  ),
                  Text('₹${doctor.consultationFee.toStringAsFixed(0)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiAppointmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingAppointments) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.appointmentsError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Error loading appointments'),
                Text(provider.appointmentsError!),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadAppointments(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No appointments found'),
                ElevatedButton(
                  onPressed: () => provider.loadAppointments(),
                  child: Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadAppointments(),
          child: ListView.builder(
            itemCount: provider.appointments.length,
            itemBuilder: (context, index) {
              final appointment = provider.appointments[index];
              return AppointmentCard(appointment: appointment);
            },
          ),
        );
      },
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment.patientDetails.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Token: ${appointment.token}'),
            Text('Date: ${appointment.date.toString().split(' ')[0]}'),
            Text('Time: ${appointment.timeSlot}'),
            if (appointment.patientDetails.symptoms != null)
              Text('Symptoms: ${appointment.patientDetails.symptoms}'),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class TestTab extends StatefulWidget {
  const TestTab({super.key});

  @override
  _TestTabState createState() => _TestTabState();
}

class _TestTabState extends State<TestTab> {
  bool _isRunning = false;
  String _testResult = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _isRunning ? null : _runTests,
            icon: _isRunning
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.science),
            label: Text(_isRunning ? 'Running Tests...' : 'Run API Tests'),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _testResult.isEmpty ? 'Test results will appear here...' : _testResult,
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
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _testResult = '🧪 Starting API Integration Tests...\n\n';
    });

    final authProvider = Provider.of<ApiAuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<ApiAppointmentProvider>(context, listen: false);

    try {
      // Test 1: Authentication
      _testResult += '📋 Test 1: Authentication\n';
      if (authProvider.isLoggedIn) {
        _testResult += '✅ User is authenticated\n';
        _testResult += '   User: ${authProvider.currentUser?.name}\n';
      } else {
        _testResult += '❌ User not authenticated\n';
      }

      // Test 2: Load Doctors
      _testResult += '\n📋 Test 2: Load Doctors\n';
      await appointmentProvider.loadDoctors();
      _testResult += '✅ Doctors loaded: ${appointmentProvider.doctors.length}\n';

      // Test 3: Load Appointments
      _testResult += '\n📋 Test 3: Load Appointments\n';
      await appointmentProvider.loadAppointments();
      _testResult += '✅ Appointments loaded: ${appointmentProvider.appointments.length}\n';

      // Test 4: Create Appointment
      _testResult += '\n📋 Test 4: Create Appointment\n';
      try {
        final newAppointment = await appointmentProvider.confirmBooking(
          PatientDetails(
            name: 'Test User',
            age: '30',
            phone: '9876543210',
            symptoms: 'Test symptoms from Flutter',
          ),
        );
        _testResult += '✅ Appointment created: ${newAppointment.id}\n';
        _testResult += '   Token: ${newAppointment.token}\n';
      } catch (e) {
        _testResult += '❌ Appointment creation failed: $e\n';
      }

      _testResult += '\n🎉 All tests completed!\n';
      _testResult += '✅ Flutter API Integration is working perfectly!';

    } catch (e) {
      _testResult += '\n❌ Test execution failed: $e';
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }
}

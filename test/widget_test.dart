import 'package:flutter_test/flutter_test.dart';
import 'package:hospitaleasy/models/appointment.dart';
import 'package:hospitaleasy/providers/api_appointment_provider.dart';
import 'package:hospitaleasy/providers/api_auth_provider.dart';

void main() {
  test('Simulate Patient Register -> Book Appointment -> Logout -> Doctor Login -> Check Appointments', () async {
    final authProvider = ApiAuthProvider();
    final appointmentProvider = ApiAppointmentProvider();

    // 1. Initialize
    print('Step 1: Initializing providers');
    await authProvider.initialize();
    await appointmentProvider.initialize();

    print('Initial appointments length: ${appointmentProvider.appointments.length}');
    for (var a in appointmentProvider.appointments) {
      print('  - Appointment ${a.id}: Doctor ${a.doctor.name} (${a.doctor.id}), Status: ${a.status}');
    }

    // 2. Register Patient
    print('\nStep 2: Registering patient');
    bool regSuccess = await authProvider.registerPatient(
      name: 'Offline Patient',
      email: 'patient@offline.com',
      password: 'password123',
      phone: '9876543210',
      age: '25',
    );
    print('Patient registration success: $regSuccess');
    print('Current user: ${authProvider.currentUser?.name} (isPatient: ${authProvider.currentUser != null})');

    // 3. Book Appointment
    print('\nStep 3: Booking appointment');
    // Select first doctor (Dr. Arun Ravi, ID: '1')
    final doctor = appointmentProvider.doctors.first;
    print('Selected doctor: ${doctor.name} (${doctor.id})');
    appointmentProvider.selectDoctor(doctor);
    appointmentProvider.selectDate(DateTime.now().add(const Duration(days: 3)));
    appointmentProvider.selectTimeSlot('10:00 AM');

    final newApt = await appointmentProvider.confirmBooking(
      PatientDetails(
        name: 'Offline Patient',
        age: '25',
        phone: '9876543210',
        symptoms: 'Fever',
      ),
    );
    print('Booking confirmed: Appointment ID: ${newApt.id}, Doctor: ${newApt.doctor.name} (${newApt.doctor.id})');
    print('Appointments length after booking: ${appointmentProvider.appointments.length}');

    // 4. Logout Patient
    print('\nStep 4: Logging out patient');
    await authProvider.logout();
    print('Logged out. Current user is null: ${authProvider.currentUser == null}');

    // 5. Login Doctor
    print('\nStep 5: Logging in doctor');
    bool logSuccess = await authProvider.loginAsDoctor('doctor@hospital.com', 'password123');
    print('Doctor login success: $logSuccess');
    final currentDoc = authProvider.currentDoctor;
    print('Current doctor: ${currentDoc?.name} (${currentDoc?.id})');

    // 6. Check Appointments on Doctor Dashboard
    print('\nStep 6: Check dashboard counts');
    final myAppointmentsDashboard = currentDoc != null
        ? appointmentProvider.appointments.where((a) => a.doctor.id == currentDoc.id).toList()
        : [];
    final upcomingCount = myAppointmentsDashboard.where((a) => a.status == 'Upcoming').length;
    print('Dashboard Appointments Count (myAppointments.length): ${myAppointmentsDashboard.length}');
    print('Dashboard Upcoming Count: $upcomingCount');

    // 7. Check Appointments on Doctor Appointments Screen
    print('\nStep 7: Check appointments screen list');
    final appointmentsScreenList = appointmentProvider.getAppointmentsForDoctor(currentDoc!.id);
    print('Appointments Screen List Count: ${appointmentsScreenList.length}');
    for (var a in appointmentsScreenList) {
      print('  - Screen Appointment ${a.id}: Doctor ${a.doctor.name} (${a.doctor.id}), Status: ${a.status}');
    }

    expect(appointmentsScreenList.length, equals(myAppointmentsDashboard.length));
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/api_auth_provider.dart';
import '../../providers/api_appointment_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/prescription_slip.dart';
import 'add_prescription_screen.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  void _viewPrescription(BuildContext context, dynamic appointment) {
    if (appointment.prescription == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge)),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.medium),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: PrescriptionSlip(
                    appointment: appointment,
                    prescription: appointment.prescription!,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<ApiAuthProvider>(context);
    final doctor = authProvider.currentDoctor;
    
    if (doctor == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Scheduled Appointments'),
      ),
      body: Consumer<ApiAppointmentProvider>(
        builder: (context, provider, child) {
          final appointments = provider.getAppointmentsForDoctor(doctor.id, doctorEmail: doctor.email);
          
          if (appointments.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 60, color: AppColors.grey.withOpacity(0.5)),
                    const SizedBox(height: AppSpacing.medium),
                    const Text('No appointments found', style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.large),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DIAGNOSTICS:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          const SizedBox(height: AppSpacing.small),
                          Text('Logged-in Doctor ID: "${doctor.id}"'),
                          Text('Logged-in Doctor Email: "${doctor.email}"'),
                          Text('Total appointments in provider: ${provider.appointments.length}'),
                          const SizedBox(height: AppSpacing.small),
                          const Text('Appointments Detail:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...provider.appointments.map((a) => Text(
                            '- ID: ${a.id}, DocID: "${a.doctor.id}", DocEmail: "${a.doctor.email}", Match: ${a.doctor.id == doctor.id || a.doctor.email == doctor.email}',
                            style: const TextStyle(fontSize: 12),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.medium),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final patient = appointment.patientDetails;
              
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.medium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  side: BorderSide(color: AppColors.grey.withOpacity(0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                '${patient.age} Yrs • ${patient.phone}',
                                style: const TextStyle(color: AppColors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                          _StatusBadge(status: appointment.status),
                        ],
                      ),
                      const Divider(height: AppSpacing.large),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 16, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('EEE, d MMM yyyy').format(appointment.date),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: AppSpacing.medium),
                          const Icon(Icons.access_time, size: 16, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Text(
                            appointment.timeSlot,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      if (patient.symptoms != null && patient.symptoms!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.medium),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.small),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppRadius.small),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: AppColors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Symptoms: ${patient.symptoms}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textBody),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.large),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _viewPatientDetails(context, appointment),
                              child: const Text('Patient Details'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.medium),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (appointment.status == 'Completed') {
                                  _viewPrescription(context, appointment);
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AddPrescriptionScreen(appointment: appointment),
                                    ),
                                  );
                                }
                              },
                              child: Text(appointment.status == 'Completed' ? 'View Prescription' : 'Add Prescription'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _viewPatientDetails(BuildContext context, dynamic appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge)),
      ),
      builder: (context) {
        final patient = appointment.patientDetails;
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.extraLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Patient Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.large),
              _detailRow(Icons.person, 'Full Name', patient.name),
              _detailRow(Icons.cake, 'Age', '${patient.age} Years'),
              _detailRow(Icons.phone, 'Phone Number', patient.phone),
              _detailRow(Icons.email, 'Email Address', patient.email ?? 'N/A'),
              const Divider(),
              _detailRow(Icons.description, 'Symptoms', patient.symptoms ?? 'No symptoms provided'),
              const SizedBox(height: AppSpacing.extraLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: AppSpacing.medium),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Upcoming': color = AppColors.secondary; break;
      case 'Completed': color = AppColors.success; break;
      case 'Cancelled': color = Colors.red; break;
      default: color = AppColors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

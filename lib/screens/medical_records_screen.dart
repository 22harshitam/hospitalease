import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/api_appointment_provider.dart';
import '../utils/constants.dart';
import '../widgets/prescription_slip.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medical Records'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Prescriptions'),
              Tab(text: 'Test Documents'),
            ],
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey,
          ),
        ),
        body: Consumer<ApiAppointmentProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                _buildPrescriptionsTab(context, provider),
                _buildDocumentsTab(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrescriptionsTab(
    BuildContext context,
    ApiAppointmentProvider provider,
  ) {
    final prescriptions = provider.appointmentsWithPrescriptions;

    if (prescriptions.isEmpty) {
      return _buildEmptyState(
        Icons.description_outlined,
        'No prescriptions found',
        'Once a doctor prescribes medication, it will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final appointment = prescriptions[index];
        return _RecordCard(
          title: 'Prescription - ${appointment.doctor.name}',
          subtitle: 'Visit on ${DateFormat('dd MMM yyyy').format(appointment.date)}',
          date: DateFormat('MMM d').format(appointment.date),
          icon: Icons.medication_outlined,
          onTap: () => _viewPrescription(context, appointment),
        );
      },
    );
  }

  Widget _buildDocumentsTab(
    BuildContext context,
    ApiAppointmentProvider provider,
  ) {
    // Simplified documents tab - use appointments with documents
    final documents = provider.appointmentsWithDocuments;

    if (documents.isEmpty) {
      return _buildEmptyState(
        Icons.folder_shared_outlined,
        'No documents found',
        'Any medical reports or IDs uploaded during booking appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final appointment = documents[index];
        return _RecordCard(
          title: 'Medical Attachment',
          subtitle: 'Appointment with ${appointment.doctor.name}',
          date: DateFormat('MMM d').format(appointment.date),
          icon: Icons.attachment_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Viewing document feature coming soon!')),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String description) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.extraLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: AppColors.grey.withOpacity(0.5)),
            const SizedBox(height: AppSpacing.medium),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textHeading),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _viewPrescription(BuildContext context, dynamic appointment) {
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
}

class _RecordCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final VoidCallback onTap;

  const _RecordCard({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.medium),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Text(
            date,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.grey),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

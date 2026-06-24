import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/api_appointment_provider.dart';
import '../utils/constants.dart';
import '../widgets/prescription_slip.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey,
          ),
        ),
        body: Consumer<ApiAppointmentProvider>(
          builder: (context, provider, child) {
            final appointments = provider.appointments;
            
            return TabBarView(
              children: [
                _buildAppointmentList(context, provider, appointments.where((a) => a.status == 'Upcoming').toList()),
                _buildAppointmentList(context, provider, appointments.where((a) => a.status == 'Completed').toList()),
                _buildAppointmentList(context, provider, appointments.where((a) => a.status == 'Cancelled').toList()),
              ],
            );
          },
        ),
      ),
    );
  }

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

  Widget _buildAppointmentList(
    BuildContext context,
    ApiAppointmentProvider provider,
    List<dynamic> list,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 60, color: AppColors.grey.withOpacity(0.5)),
            const SizedBox(height: AppSpacing.medium),
            const Text('No appointments found', style: TextStyle(color: AppColors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final appointment = list[index];
        final doctor = appointment.doctor;
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.medium),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(doctor.imageUrl),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(doctor.specialization, style: const TextStyle(color: AppColors.secondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    _StatusBadge(status: appointment.status),
                  ],
                ),
                const Divider(height: AppSpacing.large),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 16, color: AppColors.grey),
                    const SizedBox(width: 8),
                    Text(DateFormat('EEE, d MMM yyyy').format(appointment.date), style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: AppSpacing.medium),
                    const Icon(Icons.access_time, size: 16, color: AppColors.grey),
                    const SizedBox(width: 8),
                    Text(appointment.timeSlot, style: const TextStyle(fontSize: 13)),
                  ],
                ),
                if (appointment.status == 'Upcoming') ...[
                  const SizedBox(height: AppSpacing.medium),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showCancelDialog(context, provider, appointment.id),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                          child: const Text('Cancel Appointment'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Reschedule'),
                        ),
                      ),
                    ],
                  ),
                ] else if (appointment.status == 'Completed' && appointment.prescription != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _viewPrescription(context, appointment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('View Prescription'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCancelDialog(
    BuildContext context,
    ApiAppointmentProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () {
              provider.cancelAppointment(id);
              Navigator.pop(context);
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
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

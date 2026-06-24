import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../providers/api_appointment_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_inputs.dart';
import 'success_screen.dart';

class ReviewAppointmentScreen extends StatefulWidget {
  final PatientDetails patientDetails;

  const ReviewAppointmentScreen({super.key, required this.patientDetails});

  @override
  State<ReviewAppointmentScreen> createState() => _ReviewAppointmentScreenState();
}

class _ReviewAppointmentScreenState extends State<ReviewAppointmentScreen> {
  bool _isBooking = false;

  void _handleConfirm() async {
    setState(() => _isBooking = true);
    try {
      final appointment = await Provider.of<ApiAppointmentProvider>(
        context,
        listen: false,
      )
          .confirmBooking(widget.patientDetails);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => SuccessScreen(appointment: appointment)),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Appointment')),
      body: Consumer<ApiAppointmentProvider>(
        builder: (context, provider, child) {
          final doctor = provider.selectedDoctor;
          final date = provider.selectedDate;
          final time = provider.selectedTimeSlot;
          final patient = widget.patientDetails;

          if (doctor == null || date == null || time == null) {
            return const Center(child: Text('Missing information'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDoctorSummary(doctor),
                      const Divider(height: AppSpacing.extraLarge),
                      _buildInfoSection('Appointment Details', [
                        _InfoRow(label: 'Date', value: DateFormat('EEEE, d MMM yyyy').format(date)),
                        _InfoRow(label: 'Time', value: time),
                        _InfoRow(label: 'Consultation Fee', value: '₹${doctor.consultationFee.toInt()}'),
                      ]),
                      const SizedBox(height: AppSpacing.large),
                      _buildInfoSection('Patient Details', [
                        _InfoRow(label: 'Name', value: patient.name),
                        _InfoRow(label: 'Age', value: patient.age),
                        _InfoRow(label: 'Phone', value: patient.phone),
                        if (patient.idFilePath != null) const _InfoRow(label: 'ID Proof', value: 'Uploaded √'),
                        if (patient.photoPath != null) const _InfoRow(label: 'Patient Photo', value: 'Uploaded √'),
                      ]),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: CustomButton(
                  text: 'Confirm Booking',
                  isLoading: _isBooking,
                  onPressed: _handleConfirm,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDoctorSummary(doctor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.background),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(doctor.imageUrl),
          ),
          const SizedBox(width: AppSpacing.medium),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(doctor.specialization, style: const TextStyle(color: AppColors.secondary, fontSize: 14)),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text(doctor.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(' (${doctor.reviews} Reviews)', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textHeading)),
        const SizedBox(height: AppSpacing.medium),
        ...rows,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textHeading)),
        ],
      ),
    );
  }
}

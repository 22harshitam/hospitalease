import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/appointment.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_inputs.dart';
import '../../services/export_service.dart';
import '../doctor_listing_screen.dart';

class SuccessScreen extends StatelessWidget {
  final Appointment appointment;

  const SuccessScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ZoomIn(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.extraLarge),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: AppColors.white, size: 60),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              FadeInUp(
                child: Column(
                  children: [
                    Text(
                      'Appointment Confirmed!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    const Text(
                      'Your appointment has been booked successfully.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              
              // QR Code Section
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    border: Border.all(color: AppColors.background),
                  ),
                  child: QrImageView(
                    data: appointment.token,
                    version: QrVersions.auto,
                    size: 150.0,
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.large),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.large),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    border: Border.all(color: AppColors.background),
                  ),
                  child: Column(
                    children: [
                      const Text('Your Token Number', style: TextStyle(color: AppColors.grey)),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        appointment.token,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      const Text('Please show this token at the hospital', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.extraLarge),
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => ExportService.generateAppointmentPdf(appointment),
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => ExportService.shareToken(appointment),
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    CustomButton(
                      text: 'Back to Home',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const DoctorListingScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

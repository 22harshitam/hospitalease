import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../models/prescription.dart';
import '../utils/constants.dart';

class PrescriptionSlip extends StatelessWidget {
  final Appointment appointment;
  final Prescription prescription;

  const PrescriptionSlip({
    super.key,
    required this.appointment,
    required this.prescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Doctor Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      appointment.doctor.specialization,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      appointment.doctor.experience,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'HOSPITALEASY CLINIC',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    'Reg No: HE-2024-001',
                    style: TextStyle(fontSize: 10, color: AppColors.grey),
                  ),
                  Text(
                    'Bangalore, India',
                    style: TextStyle(fontSize: 12, color: AppColors.grey.withOpacity(0.8)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
          const Divider(thickness: 1.5),
          const SizedBox(height: AppSpacing.medium),
          
          // Patient Info Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPatientInfo('PATIENT NAME', appointment.patientDetails.name),
              _buildPatientInfo('DATE', DateFormat('dd MMM yyyy').format(prescription.date)),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPatientInfo('AGE / GENDER', '${appointment.patientDetails.age} Yrs / Male'), // Assuming Male for placeholder
              _buildPatientInfo('TICKET NO', appointment.token),
            ],
          ),
          
          const SizedBox(height: AppSpacing.extraLarge),
          
          // RX Symbol
          const Text(
            'Rx',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          
          // Medicines List
          ...prescription.medicines.map((medicine) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.radio_button_checked, size: 8, color: AppColors.secondary),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Text(
                    medicine,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textHeading,
                    ),
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: AppSpacing.large),
          
          // Instructions Section
          const Text(
            'DIAGNOSIS / INSTRUCTIONS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.grey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Text(
              prescription.instructions,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textBody,
              ),
            ),
          ),
          
          const SizedBox(height: 50),
          
          // Footer / Signature
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact: +91 80 4567 8900', style: TextStyle(fontSize: 10, color: AppColors.grey)),
                  Text('Email: care@hospitaleasy.in', style: TextStyle(fontSize: 10, color: AppColors.grey)),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Digitally Signed',
                    style: TextStyle(
                      fontFamily: 'Cursive', // Note: fallback if font doesn't exist
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(height: 1, width: 120, color: AppColors.grey.withOpacity(0.5)),
                  const SizedBox(height: 4),
                  Text(
                    appointment.doctor.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textHeading,
          ),
        ),
      ],
    );
  }
}

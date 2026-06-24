import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment.dart';
import '../../models/prescription.dart';
import '../../providers/api_appointment_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_inputs.dart';
import '../../widgets/prescription_slip.dart';

class AddPrescriptionScreen extends StatefulWidget {
  final Appointment appointment;

  const AddPrescriptionScreen({super.key, required this.appointment});

  @override
  State<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  final _medicinesController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _medicinesController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _submitPrescription() {
    if (_formKey.currentState!.validate()) {
      final medicines = _parseMedicines();

      final prescription = Prescription(
        medicines: medicines,
        instructions: _instructionsController.text,
        date: DateTime.now(),
      );

      Provider.of<ApiAppointmentProvider>(context, listen: false)
          .addPrescription(widget.appointment.id, prescription);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription added successfully', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.success),
      );

      Navigator.pop(context);
    }
  }

  List<String> _parseMedicines() {
    return _medicinesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  void _showPreview() {
    if (!_formKey.currentState!.validate()) return;

    final medicines = _parseMedicines();
    final instructions = _instructionsController.text;

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
                    appointment: widget.appointment,
                    prescription: Prescription(
                      medicines: medicines,
                      instructions: instructions,
                      date: DateTime.now(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Edit Details'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _submitPrescription();
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Confirm & Save'),
                      ),
                    ),
                  ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Prescription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.medium),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: AppColors.secondary),
                    const SizedBox(width: AppSpacing.medium),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.appointment.patientDetails.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Appointment: ${widget.appointment.timeSlot}',
                          style: const TextStyle(color: AppColors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.extraLarge),
              CustomTextField(
                label: 'Medicines',
                hintText: 'e.g. Paracetamol 500mg, Amoxicillin 250mg',
                controller: _medicinesController,
                maxLines: 3,
                prefixIcon: Icons.medication_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter at least one medicine';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.large),
              CustomTextField(
                label: 'Instructions',
                hintText: 'e.g. 1-0-1 after food for 5 days',
                controller: _instructionsController,
                maxLines: 5,
                prefixIcon: Icons.note_alt_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter instructions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.extraLarge),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showPreview,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Preview'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitPrescription,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Directly'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

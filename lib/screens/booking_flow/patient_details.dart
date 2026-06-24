import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../providers/api_appointment_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_inputs.dart';
import 'review_appointment.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _symptomsController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickPhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      if (!mounted) return;
      Provider.of<ApiAppointmentProvider>(
        context,
        listen: false,
      ).setPickedPhotoPath(photo.path);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null) {
      if (!mounted) return;
      Provider.of<ApiAppointmentProvider>(
        context,
        listen: false,
      ).setPickedIdPath(result.files.single.path);
    }
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ApiAppointmentProvider>(
        context,
        listen: false,
      );
      final details = PatientDetails(
        name: _nameController.text,
        age: _ageController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        symptoms: _symptomsController.text,
        idFilePath: provider.pickedIdPath,
        photoPath: provider.pickedPhotoPath,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewAppointmentScreen(patientDetails: details),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Details')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    CustomTextField(
                      label: 'Full Name',
                      hintText: 'Enter patient name',
                      controller: _nameController,
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Age',
                            hintText: 'Ex: 25',
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: CustomTextField(
                            label: 'Phone Number',
                            hintText: 'Enter phone',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    CustomTextField(
                      label: 'Email (Optional)',
                      hintText: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSpacing.extraLarge),
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Consumer<ApiAppointmentProvider>(
                      builder: (context, provider, _) => Column(
                        children: [
                          _buildUploadSection(
                            'Upload ID Proof (Optional)',
                            Icons.upload_file_rounded,
                            _pickFile,
                            provider.pickedIdPath != null,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          _buildUploadSection(
                            'Take Patient Photo (Optional)',
                            Icons.camera_alt_rounded,
                            _pickPhoto,
                            provider.pickedPhotoPath != null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    CustomTextField(
                      label: 'Any Symptoms? (Optional)',
                      hintText: 'Write about your symptoms',
                      controller: _symptomsController,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: CustomButton(text: 'Next', onPressed: _handleNext),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isUploaded,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.small),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.large),
            decoration: BoxDecoration(
              color: isUploaded
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: isUploaded ? AppColors.success : AppColors.background,
                width: 2,
              ),
            ),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isUploaded ? AppColors.success : AppColors.secondary,
                ),
                const SizedBox(width: AppSpacing.small),
                Text(
                  isUploaded ? 'File Uploaded' : 'Upload Document',
                  style: TextStyle(
                    color: isUploaded ? AppColors.success : AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

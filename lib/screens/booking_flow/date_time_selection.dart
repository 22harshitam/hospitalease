import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/api_appointment_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_inputs.dart';
import 'patient_details.dart';

class DateTimeSelectionScreen extends StatelessWidget {
  const DateTimeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Date & Time'),
        centerTitle: true,
      ),
      body: Consumer<ApiAppointmentProvider>(
        builder: (context, provider, child) {
          final doctor = provider.selectedDoctor;
          if (doctor == null) return const Center(child: Text('Please select a doctor first'));

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Select Date'),
                      const SizedBox(height: AppSpacing.medium),
                      _DateSelector(
                        selectedDate: provider.selectedDate,
                        onDateSelected: (date) => provider.selectDate(date),
                      ),
                      const SizedBox(height: AppSpacing.extraLarge),
                      _buildSectionTitle('Available Time'),
                      const SizedBox(height: AppSpacing.medium),
                      Wrap(
                        spacing: AppSpacing.small,
                        runSpacing: AppSpacing.small,
                        children: provider.availableTimeSlots.map((slot) {
                          final isSelected = provider.selectedTimeSlot == slot;
                          return ChoiceChip(
                            label: Text(slot),
                            selected: isSelected,
                            onSelected: (selected) => provider.selectTimeSlot(slot),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.textHeading,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            showCheckmark: false,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: CustomButton(
                  text: 'Next',
                  onPressed: (provider.selectedDate != null && provider.selectedTimeSlot != null)
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PatientDetailsScreen(),
                            ),
                          );
                        }
                      : () {},
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textHeading,
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const _DateSelector({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = List.generate(30, (index) => now.add(Duration(days: index)));

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = selectedDate != null &&
              selectedDate!.year == date.year &&
              selectedDate!.month == date.month &&
              selectedDate!.day == date.day;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.medium),
            child: InkWell(
              onTap: () => onDateSelected(date),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Container(
                width: 70,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: isSelected ? null : Border.all(color: AppColors.background, width: 2),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? AppColors.white.withOpacity(0.8) : AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.white : AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM').format(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? AppColors.white.withOpacity(0.8) : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

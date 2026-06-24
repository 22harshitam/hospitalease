import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/api_appointment_provider.dart';
import '../utils/constants.dart';
import '../widgets/doctor_card.dart';
import '../widgets/shimmer_loading.dart';
import 'booking_flow/date_time_selection.dart';
import 'medical_records_screen.dart';
import 'my_appointments_screen.dart';
import 'profile_screen.dart';
import 'hospital_map_screen.dart';

class DoctorListingScreen extends StatefulWidget {
  const DoctorListingScreen({super.key});

  @override
  State<DoctorListingScreen> createState() => _DoctorListingScreenState();
}

class _DoctorListingScreenState extends State<DoctorListingScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),
    const MyAppointmentsScreen(),
    const MedicalRecordsScreen(),
    const HospitalMapScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        elevation: 10,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            activeIcon: Icon(Icons.folder_shared),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Your Specialist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.red),
            tooltip: 'Call Ambulance',
            onPressed: () async {
              final Uri url = Uri.parse('tel:+918137852521');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open phone app')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Badge(
              label: Text('2'),
              child: Icon(Icons.notifications_outlined),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<ApiAppointmentProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) => provider.searchDoctors(value),
                        decoration: const InputDecoration(
                          hintText: 'Search doctor, specialization...',
                          prefixIcon: Icon(Icons.search, color: AppColors.grey),
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: AppColors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              const _SpecializationFilter(),
              Expanded(
                child: provider.isLoadingDoctors
                    ? const ShimmerLoading()
                    : provider.doctors.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.medium),
                        itemCount: provider.doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = provider.doctors[index];
                          return FadeInUp(
                            delay: Duration(milliseconds: 100 * index),
                            child: DoctorCard(
                              doctor: doctor,
                              onTap: () {
                                Provider.of<ApiAppointmentProvider>(
                                  context,
                                  listen: false,
                                ).selectDoctor(doctor);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const DateTimeSelectionScreen(),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.medium),
          const Text(
            'No doctors found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: AppSpacing.extraSmall),
          const Text('Try adjusting your search or filter'),
        ],
      ),
    );
  }
}

class _SpecializationFilter extends StatelessWidget {
  const _SpecializationFilter();

  @override
  Widget build(BuildContext context) {
    // Simplified specialization filter - just show "All" for now
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
        itemCount: 1,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.small),
            child: FilterChip(
              label: Text('All'),
              selected: true,
              onSelected: (selected) {
                // No filtering for now - show all doctors
              },
            ),
          );
        },
      ),
    );
  }
}

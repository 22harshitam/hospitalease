import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/api_appointment_provider.dart';
import '../providers/api_auth_provider.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ApiAuthProvider, ApiAppointmentProvider>(
      builder: (context, auth, appointment, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('My Profile')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.large),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (auth.currentPatient?.name ??
                            auth.currentDoctor?.name ??
                            'User')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  auth.currentPatient?.name ??
                      auth.currentDoctor?.name ??
                      'User Name',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  auth.currentPatient?.email ??
                      auth.currentDoctor?.email ??
                      'email@example.com',
                  style: const TextStyle(color: AppColors.grey),
                ),
                const SizedBox(height: AppSpacing.extraLarge),
                
                Row(
                  children: [
                    _buildStatCard('Appointments', appointment.appointments.length.toString(), Icons.event_available, AppColors.secondary),
                    const SizedBox(width: AppSpacing.medium),
                    _buildStatCard('Health Records', '5', Icons.folder_outlined, AppColors.success),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.extraLarge),
                _buildProfileItem(context, 'Personal Information', Icons.person_outline),
                _buildProfileItem(context, 'Payment Methods', Icons.payment_outlined),
                _buildProfileItem(context, 'Settings', Icons.settings_outlined),
                _buildProfileItem(context, 'Help & Support', Icons.help_outline),
                
                const SizedBox(height: AppSpacing.extraLarge),
                ListTile(
                  title: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  leading: const Icon(Icons.logout, color: Colors.red),
                  onTap: () {
                    auth.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.background),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: AppSpacing.small),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textHeading)),
            Text(title, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: () {},
    );
  }
}

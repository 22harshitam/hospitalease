import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hospitaleasy/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/api_auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_inputs.dart';
import '../doctor/doctor_dashboard_screen.dart';
import '../doctor_listing_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isDoctorMode = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<ApiAuthProvider>(
          context,
          listen: false,
        );

        bool success = false;
        if (_isDoctorMode) {
          // Doctor login
          success = await authProvider.loginAsDoctor(
            _emailController.text,
            _passwordController.text,
          );
          if (success && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
            );
          }
        } else {
          // Patient login
          success = await authProvider.loginAsPatient(
            _emailController.text,
            _passwordController.text,
          );
          if (success && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DoctorListingScreen()),
            );
          }
        }

        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login failed: ${authProvider.error ?? "Invalid credentials"}',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login failed: ${e.toString().replaceAll('Exception: ', '')}',
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.extraLarge),
                FadeInDown(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                FadeInLeft(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        'Login to your account to continue',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.extraLarge),
                FadeInRight(
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Email Address',
                        hintText: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      CustomTextField(
                        label: 'Password',
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                    decoration: BoxDecoration(
                      color: _isDoctorMode ? AppColors.secondary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(
                        color: _isDoctorMode ? AppColors.secondary : AppColors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Log in as Doctor',
                        style: TextStyle(
                          color: _isDoctorMode ? AppColors.secondary : AppColors.textHeading,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      secondary: Icon(
                        Icons.medical_services_outlined,
                        color: _isDoctorMode ? AppColors.secondary : AppColors.grey,
                      ),
                      value: _isDoctorMode,
                      onChanged: (value) => setState(() => _isDoctorMode = value),
                      activeThumbColor: AppColors.secondary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                FadeInUp(
                  child: CustomButton(
                    text: _isDoctorMode ? 'Doctor Log In' : 'Log In',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false).loginAsGuest();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const DoctorListingScreen()),
                      );
                    },
                    child: const Text('Continue as Guest'),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        );
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

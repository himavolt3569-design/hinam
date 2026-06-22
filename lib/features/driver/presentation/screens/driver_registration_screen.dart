import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hinam/features/driver/presentation/widgets/registration_form_card.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/driver/data/models/driver_model.dart';
import 'package:hinam/features/driver/presentation/providers/driver_provider.dart';

class DriverRegistrationScreen extends ConsumerStatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  ConsumerState<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends ConsumerState<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _busNumberController = TextEditingController();
  final _routeController = TextEditingController();
  final _schoolController = TextEditingController();

  bool _isSaving = false;
  String _busType = 'public';

  @override
  void dispose() {
    _nameController.dispose();
    _busNumberController.dispose();
    _routeController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider.notifier).currentUser();
    if (user == null || user.phoneNumber == null) return;

    setState(() => _isSaving = true);

    try {
      final driver = DriverModel(
        uid: user.uid,
        fullName: _nameController.text.trim(),
        phoneNumber: user.phoneNumber!,
        busNumber: _busNumberController.text.trim(),
        busType: _busType,
        routeName: _busType == 'public' ? _routeController.text.trim() : null,
        schoolName: _busType == 'school' ? _schoolController.text.trim() : null,
        isApproved: false,
        createdAt: Timestamp.now(),
      );

      await ref.read(driverRepositoryProvider).createDriver(driver);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Driver Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.badge_outlined, color: Colors.white, size: 28),
              ),

              const SizedBox(height: 16),

              const Text(
                'Complete Your Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),

              const SizedBox(height: 4),

              const Text(
                'Tell us about yourself and your bus.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 28),

              RegistrationFormCard(
                nameController: _nameController,
                busNumberController: _busNumberController,
                routeController: _routeController,
                schoolController: _schoolController,
                busType: _busType,
                onBusTypeChanged: (value) => setState(() => _busType = value),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _isSaving ? null : _completeRegistration,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Complete Registration'),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Your profile will be reviewed before approval.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

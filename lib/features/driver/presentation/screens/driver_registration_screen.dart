import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hinam/features/driver/presentation/widgets/registration_form_card.dart';

import 'package:hinam/core/routes/app_routes.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primary.withValues(alpha: 0.07), colorScheme.surface],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        // Hero icon
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.32),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(Icons.badge_outlined, color: colorScheme.onPrimary, size: 38),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Complete Your Profile',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Tell us about yourself and your bus.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.45)),
                        ),

                        const SizedBox(height: 32),

                        // Form card
                        RegistrationFormCard(
                          nameController: _nameController,
                          busNumberController: _busNumberController,
                          routeController: _routeController,
                          schoolController: _schoolController,
                          busType: _busType,
                          onBusTypeChanged: (value) => setState(() => _busType = value),
                        ),

                        const SizedBox(height: 24),

                        // Submit
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: _isSaving ? null : _completeRegistration,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isSaving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onPrimary),
                                  )
                                : const Text(
                                    'Complete Registration',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Your profile will be reviewed before approval.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.35)),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

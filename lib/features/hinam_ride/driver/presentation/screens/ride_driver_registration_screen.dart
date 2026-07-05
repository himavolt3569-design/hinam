import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/hinam_ride/driver/data/models/ride_driver_model.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_driver_provider.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/widgets/ride_driver_registration_form.dart';
import 'package:hinam/shared/widgets/loading_button.dart';

class RideDriverRegistrationScreen extends ConsumerStatefulWidget {
  const RideDriverRegistrationScreen({super.key});

  @override
  ConsumerState<RideDriverRegistrationScreen> createState() =>
      _RideDriverRegistrationScreenState();
}

class _RideDriverRegistrationScreenState
    extends ConsumerState<RideDriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  String _gender = '';
  String _vehicleType = '';
  DateTime? _dateOfBirth;

  bool _isSaving = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _vehiclePlateController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth.')),
      );
      return;
    }

    final age = DateTime.now().difference(_dateOfBirth!).inDays / 365.25;
    if (age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be at least 18 years old.')),
      );
      return;
    }

    final user = ref.read(authControllerProvider.notifier).currentUser();
    if (user == null || user.phoneNumber == null) return;

    setState(() => _isSaving = true);

    try {
      final driver = RideDriverModel(
        uid: user.uid,
        fullName: _fullNameController.text.trim(),
        phoneNumber: user.phoneNumber!,
        gender: _gender,
        dateOfBirth: _dateOfBirth!,
        vehicleType: _vehicleType,
        vehiclePlate: _vehiclePlateController.text.trim(),
        licenseNumber: _licenseNumberController.text.trim(),
        verificationStatus: VerificationStatus.pending,
        isOnline: false,
        ratingAvg: 0,
        totalRides: 0,
        createdAt: Timestamp.now(),
      );

      await ref.read(rideDriverRepositoryProvider).createDriver(driver);

      if (!mounted) return;
      setState(() => _isSubmitted = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ride Driver Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _isSubmitted ? _buildSubmittedState() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
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
            child: const Icon(
              Icons.two_wheeler_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Drive with Hinam Ride',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Tell us about yourself and your vehicle.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 28),

          RideDriverRegistrationForm(
            fullNameController: _fullNameController,
            vehiclePlateController: _vehiclePlateController,
            licenseNumberController: _licenseNumberController,
            gender: _gender,
            onGenderChanged: (value) => setState(() => _gender = value),
            vehicleType: _vehicleType,
            onVehicleTypeChanged: (value) =>
                setState(() => _vehicleType = value),
            dateOfBirth: _dateOfBirth,
            onDateOfBirthChanged: (value) =>
                setState(() => _dateOfBirth = value),
          ),

          const SizedBox(height: 20),

          LoadingButton(
            text: 'Submit for Review',
            isLoading: _isSaving,
            onPressed: _completeRegistration,
          ),

          const SizedBox(height: 12),

          const Text(
            'Your profile will be reviewed before you can go online.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSubmittedState() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Registration Submitted',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your profile is now pending review. We will notify you once it has been verified.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

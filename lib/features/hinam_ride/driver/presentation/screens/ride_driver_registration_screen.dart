import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/hinam_ride/driver/data/models/ride_driver_model.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_driver_profile_provider.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_driver_provider.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/widgets/ride_driver_registration_form.dart';
import 'package:hinam/features/hinam_ride/verification/data/models/verification_request_model.dart';
import 'package:hinam/features/hinam_ride/verification/presentation/providers/ride_verification_provider.dart';
import 'package:hinam/features/hinam_ride/verification/presentation/widgets/document_upload_tile.dart';
import 'package:hinam/features/hinam_ride/verification/presentation/widgets/verification_status_banner.dart';
import 'package:hinam/shared/widgets/loading_button.dart';

class RideDriverRegistrationScreen extends ConsumerStatefulWidget {
  const RideDriverRegistrationScreen({super.key});

  @override
  ConsumerState<RideDriverRegistrationScreen> createState() =>
      _RideDriverRegistrationScreenState();
}

class _RideDriverRegistrationScreenState
    extends ConsumerState<RideDriverRegistrationScreen> {
  static const _requiredDocuments = {
    'licensePhoto': 'Driving License Photo',
    'vehicleRegistration': 'Vehicle Registration Photo',
  };

  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  String _gender = '';
  String _vehicleType = '';
  DateTime? _dateOfBirth;
  final Map<String, File> _documents = {};

  bool _isSaving = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(authControllerProvider.notifier).currentUser();
      if (user != null) {
        ref.read(rideDriverProfileProvider.notifier).loadDriver(user.uid);
      }
    });
  }

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

    if (!_requiredDocuments.keys.every(_documents.containsKey)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents.'),
        ),
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

      await ref
          .read(submitVerificationControllerProvider.notifier)
          .submit(
            subjectType: VerificationSubjectType.driver,
            subjectId: user.uid,
            documents: _documents,
          );

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
    final profileState = ref.watch(rideDriverProfileProvider);

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
        child: profileState.when(
          loading: () => const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) =>
              SizedBox(height: 300, child: Center(child: Text('$error'))),
          data: (driver) {
            if (_isSubmitted) {
              return _buildSubmittedState(VerificationStatus.pending);
            }
            if (driver != null) {
              return _buildSubmittedState(driver.verificationStatus);
            }
            return _buildForm();
          },
        ),
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

          Text(
            'Verification Documents',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 10),

          for (final entry in _requiredDocuments.entries)
            DocumentUploadTile(
              label: entry.value,
              file: _documents[entry.key],
              onPicked: (file) => setState(() => _documents[entry.key] = file),
            ),

          const SizedBox(height: 10),

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

  Widget _buildSubmittedState(VerificationStatus status) {
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
            Icons.assignment_turned_in_outlined,
            color: AppColors.success,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Your Ride Driver Application',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We will notify you once your documents have been reviewed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        VerificationStatusBanner(status: status),
      ],
    );
  }
}

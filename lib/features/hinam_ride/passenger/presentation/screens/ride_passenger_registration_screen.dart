import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/hinam_ride/passenger/data/models/ride_passenger_model.dart';
import 'package:hinam/features/hinam_ride/passenger/presentation/providers/ride_passenger_profile_provider.dart';
import 'package:hinam/features/hinam_ride/passenger/presentation/providers/ride_passenger_provider.dart';
import 'package:hinam/features/hinam_ride/passenger/presentation/widgets/ride_passenger_registration_form.dart';
import 'package:hinam/shared/widgets/loading_button.dart';

class RidePassengerRegistrationScreen extends ConsumerStatefulWidget {
  const RidePassengerRegistrationScreen({super.key});

  @override
  ConsumerState<RidePassengerRegistrationScreen> createState() =>
      _RidePassengerRegistrationScreenState();
}

class _RidePassengerRegistrationScreenState
    extends ConsumerState<RidePassengerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();

  String _gender = '';
  final List<EmergencyContactControllers> _contacts = [
    EmergencyContactControllers(),
  ];

  bool _isSaving = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(authControllerProvider.notifier).currentUser();
      if (user != null) {
        ref.read(ridePassengerProfileProvider.notifier).loadPassenger(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    for (final contact in _contacts) {
      contact.dispose();
    }
    super.dispose();
  }

  void _addContact() {
    if (_contacts.length >= RidePassengerModel.maxEmergencyContacts) return;
    setState(() => _contacts.add(EmergencyContactControllers()));
  }

  void _removeContact(int index) {
    if (_contacts.length <= 1) return;
    setState(() {
      _contacts[index].dispose();
      _contacts.removeAt(index);
    });
  }

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider.notifier).currentUser();
    if (user == null || user.phoneNumber == null) return;

    setState(() => _isSaving = true);

    try {
      final passenger = RidePassengerModel(
        uid: user.uid,
        fullName: _fullNameController.text.trim(),
        phoneNumber: user.phoneNumber!,
        gender: _gender,
        emergencyContacts: _contacts
            .map(
              (contact) => EmergencyContact(
                name: contact.name.text.trim(),
                phone: contact.phone.text.trim(),
              ),
            )
            .toList(),
        ratingAvg: 0,
        totalRides: 0,
        createdAt: Timestamp.now(),
      );

      await ref
          .read(ridePassengerRepositoryProvider)
          .createPassenger(passenger);

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
    final profileState = ref.watch(ridePassengerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ride Passenger Registration'),
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
          data: (passenger) {
            if (_isSubmitted || passenger != null) {
              return _buildRegisteredState();
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
              Icons.favorite_border_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Book a Hinam Ride',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Tell us about yourself and who to contact in an emergency.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 28),

          RidePassengerRegistrationForm(
            fullNameController: _fullNameController,
            gender: _gender,
            onGenderChanged: (value) => setState(() => _gender = value),
            emergencyContacts: _contacts,
            onAddContact: _addContact,
            onRemoveContact: _removeContact,
          ),

          const SizedBox(height: 20),

          LoadingButton(
            text: 'Complete Registration',
            isLoading: _isSaving,
            onPressed: _completeRegistration,
          ),

          const SizedBox(height: 12),

          const Text(
            'You can start requesting rides right after registering.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRegisteredState() {
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
          "You're Registered",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'You can now request rides with Hinam Ride.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

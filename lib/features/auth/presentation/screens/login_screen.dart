import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routes/app_routes.dart';
import '../models/otp_arguments.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/phone_input_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = '+977${_phoneController.text.trim()}';

    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendOtp(
            phoneNumber: phoneNumber,
            onCodeSent: (verificationId) {
              Navigator.pushNamed(
                context,
                AppRoutes.otp,
                arguments: OtpArguments(phoneNumber: phoneNumber, verificationId: verificationId),
              );
            },
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),

          // Icon — solid filled, with shadow
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: colorScheme.primary.withValues(alpha: 0.32), blurRadius: 24, offset: const Offset(0, 10)),
                ],
              ),
              child: Icon(Icons.directions_bus_rounded, size: 40, color: colorScheme.onPrimary),
            ),
          ),

          const SizedBox(height: 22),

          // App name — heavy
          Text(
            'HINAM',
            textAlign: TextAlign.center,
            style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 3, height: 1),
          ),

          const SizedBox(height: 6),

          Text(
            'Smart Mobility Nepal',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.45), letterSpacing: 0.3),
          ),

          const SizedBox(height: 10),

          Text(
            'Track public and school buses in real time.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.35)),
          ),

          const SizedBox(height: 28),

          // Feature Chips
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: const [
              Chip(label: Text('🚌 Live Tracking')),
              Chip(label: Text('🏫 School Bus')),
              Chip(label: Text('📍 Real-Time Updates')),
            ],
          ),

          const SizedBox(height: 40),

          // Login Card — shadow instead of border
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 32,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone Number', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    "We'll send you a one-time code",
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(height: 16),
                  PhoneInputField(controller: _phoneController),
                  const SizedBox(height: 20),
                  AuthButton(text: 'Continue', isLoading: authState.isLoading, onPressed: _sendOtp),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 12, color: colorScheme.onSurface.withValues(alpha: 0.3)),
              const SizedBox(width: 4),
              Text(
                'Secure login via OTP verification',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.3)),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

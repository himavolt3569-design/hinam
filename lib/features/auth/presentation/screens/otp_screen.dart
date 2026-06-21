import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hinam/features/driver/presentation/providers/driver_provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/otp_input_field.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpScreen({super.key, required this.phoneNumber, required this.verificationId});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    super.dispose();
  }

  void _onOtpChanged() {
    if (_otpController.text.length == 6 && !_isVerifying) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;
    if (!_formKey.currentState!.validate()) return;
    _isVerifying = true;

    try {
      final user = await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(verificationId: widget.verificationId, smsCode: _otpController.text.trim());

      if (user == null) return;
      if (!mounted) return;

      TextInput.finishAutofillContext();

      final driverRepository = ref.read(driverRepositoryProvider);
      final exists = await driverRepository.driverExists(user.uid);

      Navigator.pushNamedAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        exists ? AppRoutes.dashboard : AppRoutes.driverRegistration,
        (_) => false,
      );
    } catch (e) {
      _isVerifying = false;
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
          const SizedBox(height: 16),

          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Lock icon
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
              child: Icon(Icons.lock_outline_rounded, size: 38, color: colorScheme.onPrimary),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Verify OTP',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),

          const SizedBox(height: 8),

          Text(
            'We sent a verification code to',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.45)),
          ),

          const SizedBox(height: 4),

          Text(
            widget.phoneNumber,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.primary),
          ),

          const SizedBox(height: 40),

          // OTP Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.08), blurRadius: 32, offset: const Offset(0, 8)),
                BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enter 6-digit code', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      'Code expires in 10 minutes',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                    const SizedBox(height: 20),
                    OtpInputField(controller: _otpController),
                    const SizedBox(height: 20),
                    AuthButton(text: 'Verify', isLoading: authState.isLoading, onPressed: _verifyOtp),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

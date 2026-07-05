import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/otp_arguments.dart';
import '../providers/auth_controller.dart';
import 'package:hinam/shared/widgets/loading_button.dart';
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
                arguments: OtpArguments(
                  phoneNumber: phoneNumber,
                  verificationId: verificationId,
                ),
              );
            },
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 56),

          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.directions_bus_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Sign in to Hinam',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Enter your phone number to continue.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 36),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                PhoneInputField(controller: _phoneController),
                const SizedBox(height: 16),
                LoadingButton(
                  text: 'Continue',
                  isLoading: authState.isLoading,
                  onPressed: _sendOtp,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 5),
              Text(
                'Verified via OTP',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

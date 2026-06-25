import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/admin/data/repositories/admin_repository.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/auth/presentation/widgets/choice_button.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _showChoice = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = ref.read(authControllerProvider.notifier).currentUser();
    if (!mounted) return;

    if (user != null) {
      final isAdmin = await ref.read(adminRepositoryProvider).isAdmin(user.uid);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        isAdmin ? AppRoutes.adminDashboard : AppRoutes.dashboard,
      );
    } else {
      setState(() => _showChoice = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),

              // Brand mark
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Hinam',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Smart Mobility Nepal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              if (!_showChoice)
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),

              if (_showChoice) ...[
                const Text(
                  'How are you using Hinam?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ChoiceButton(
                  icon: Icons.directions_bus_rounded,
                  label: 'View Nearby Buses',
                  filled: true,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.publicBusList,
                  ),
                ),
                const SizedBox(height: 8),
                ChoiceButton(
                  icon: Icons.school_rounded,
                  label: 'Track School Bus',
                  color: AppColors.schoolGreen,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.schoolBusList,
                  ),
                ),
                const SizedBox(height: 8),
                ChoiceButton(
                  icon: Icons.directions_bus_filled_rounded,
                  label: "I'm a Driver",
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

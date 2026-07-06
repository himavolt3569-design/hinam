import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/admin/data/repositories/admin_repository.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/auth/presentation/widgets/choice_button.dart';
import 'package:hinam/features/driver/presentation/providers/driver_provider.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_driver_provider.dart';
import 'package:hinam/features/hinam_ride/passenger/presentation/providers/ride_passenger_provider.dart';

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

  /// Resolves a returning authenticated user's role in a single, explicit
  /// priority order — admin, then bus driver, then ride driver, then ride
  /// passenger — rather than scattering role checks across screens. A
  /// brand-new user (or a lookup finding none of the above) falls through
  /// to the manual choice screen.
  Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = ref.read(authControllerProvider.notifier).currentUser();
    if (!mounted) return;

    if (user == null) {
      setState(() => _showChoice = true);
      return;
    }

    final isAdmin = await ref.read(adminRepositoryProvider).isAdmin(user.uid);
    if (!mounted) return;
    if (isAdmin) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      return;
    }

    final isBusDriver = await ref
        .read(driverRepositoryProvider)
        .driverExists(user.uid);
    if (!mounted) return;
    if (isBusDriver) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      return;
    }

    final isRideDriver = await ref
        .read(rideDriverRepositoryProvider)
        .driverExists(user.uid);
    if (!mounted) return;
    if (isRideDriver) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.rideDriverRegistration,
      );
      return;
    }

    final isRidePassenger = await ref
        .read(ridePassengerRepositoryProvider)
        .passengerExists(user.uid);
    if (!mounted) return;
    if (isRidePassenger) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.ridePassengerRegistration,
      );
      return;
    }

    setState(() => _showChoice = true);
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
                const SizedBox(height: 8),
                ChoiceButton(
                  icon: Icons.two_wheeler_rounded,
                  label: 'Drive with Hinam Ride',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.rideDriverRegistration,
                  ),
                ),
                const SizedBox(height: 8),
                ChoiceButton(
                  icon: Icons.favorite_rounded,
                  label: 'Book a Hinam Ride',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.ridePassengerRegistration,
                  ),
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

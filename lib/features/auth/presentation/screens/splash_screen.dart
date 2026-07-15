import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/admin/data/repositories/admin_repository.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
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

    final isBusDriver = await ref.read(driverRepositoryProvider).driverExists(user.uid);
    if (!mounted) return;
    if (isBusDriver) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      return;
    }

    final isRideDriver = await ref.read(rideDriverRepositoryProvider).driverExists(user.uid);
    if (!mounted) return;
    if (isRideDriver) {
      Navigator.pushReplacementNamed(context, AppRoutes.rideDriverRegistration);
      return;
    }

    final isRidePassenger = await ref.read(ridePassengerRepositoryProvider).passengerExists(user.uid);
    if (!mounted) return;
    if (isRidePassenger) {
      Navigator.pushReplacementNamed(context, AppRoutes.ridePassengerRegistration);
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
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 32),
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              if (!_showChoice)
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                ),

              if (_showChoice) ...[
                const Text(
                  'HOW ARE YOU USING HINAM?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),

                // Primary actions — the two things most people open the app
                // for. Rendered as large hero cards side by side.
                Row(
                  children: [
                    Expanded(
                      child: _HeroChoiceCard(
                        icon: Icons.directions_bus_rounded,
                        label: 'Nearby Buses',
                        color: AppColors.primary,
                        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.publicBusList),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HeroChoiceCard(
                        icon: Icons.school_rounded,
                        label: 'School Bus',
                        color: AppColors.schoolGreen,
                        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.schoolBusList),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade200)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'OR CONTINUE AS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade200)),
                  ],
                ),
                const SizedBox(height: 14),

                // Secondary, role-based actions — compact grid tiles.
                Row(
                  children: [
                    Expanded(
                      child: _GridChoiceTile(
                        icon: Icons.directions_bus_filled_rounded,
                        label: 'Driver',
                        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GridChoiceTile(
                        icon: Icons.two_wheeler_rounded,
                        label: 'Ride Driver',
                        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.rideDriverRegistration),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GridChoiceTile(
                        icon: Icons.favorite_rounded,
                        label: 'Book Ride',
                        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.ridePassengerRegistration),
                      ),
                    ),
                  ],
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

/// Large featured card used for the two primary, passenger-facing actions.
class _HeroChoiceCard extends StatelessWidget {
  const _HeroChoiceCard({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.16)),
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.30), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact icon tile used for secondary, role-based actions.
class _GridChoiceTile extends StatelessWidget {
  const _GridChoiceTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Icon(icon, color: AppColors.textPrimary, size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/features/admin/data/repositories/admin_repository.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/auth/presentation/widgets/choice_button.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  bool _showChoice = false;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 1400));

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
      _fadeCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [scheme.primary, scheme.primary.withValues(alpha: 0.85), const Color(0xFFF8F9FE)],
                stops: const [0.0, 0.45, 0.72],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Brand section ───────────────────────────────────────
                SizedBox(
                  height: size.height * 0.48,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Large bus icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.directions_bus_rounded, size: 54, color: Colors.white),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'HINAM',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 8,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Smart Mobility Nepal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bottom card ─────────────────────────────────────────
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FE),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: _showChoice ? _ChoiceSection(fadeAnim: _fadeAnim) : const _LoadingSection(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading…',
            style: TextStyle(fontSize: 13, color: scheme.onSurface.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}

class _ChoiceSection extends StatelessWidget {
  final Animation<double> fadeAnim;

  const _ChoiceSection({required this.fadeAnim});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: fadeAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How are you using Hinam?',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose your role to get started.',
              style: text.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: 24),

            ChoiceButton(
              icon: Icons.map_rounded,
              label: 'View Nearby Buses',
              subtitle: 'Track public buses in real time',
              filled: true,
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.passengerMap),
            ),

            const SizedBox(height: 12),

            ChoiceButton(
              icon: Icons.school_rounded,
              label: 'Track School Bus',
              subtitle: 'See your child\'s school bus location',
              color: const Color(0xFF15803D),
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.parentTracking),
            ),

            const SizedBox(height: 12),

            ChoiceButton(
              icon: Icons.directions_bus_filled_rounded,
              label: "I'm a Driver",
              subtitle: 'Share your location with passengers',
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}

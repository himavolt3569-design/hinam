import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/driver/data/models/driver_model.dart';
import 'package:hinam/features/driver/presentation/providers/driver_profile_provider.dart';
import 'package:hinam/features/driver/presentation/widgets/bus_info_card.dart';
import 'package:hinam/features/driver/presentation/widgets/dashboard_header.dart';
import 'package:hinam/features/driver/presentation/widgets/location_info_card.dart';
import 'package:hinam/features/driver/presentation/widgets/route_school_tile.dart';
import 'package:hinam/features/driver/presentation/widgets/student_counter_tile.dart';
import 'package:hinam/features/driver/presentation/widgets/tracking_status_bar.dart';
import 'package:hinam/features/tracking/presentation/providers/tracking_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(authControllerProvider.notifier).currentUser();
      if (user != null) {
        ref.read(driverProfileProvider.notifier).loadDriver(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProfileProvider);

    return driverState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text(error.toString()))),
      data: (driver) {
        if (driver == null) {
          return const Scaffold(body: Center(child: Text('Driver not found')));
        }
        return _DashboardBody(driver: driver);
      },
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  final DriverModel driver;

  const _DashboardBody({required this.driver});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isPublic = driver.busType == 'public';
    final routeOrSchool = driver.routeName ?? driver.schoolName;
    final trackingState = ref.watch(trackingProvider);
    final isTracking = trackingState.isTracking;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        children: [
          // ── Gradient header ─────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primary, scheme.primary.withValues(alpha: 0.85)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    DashboardHeader(
                      driverName: driver.fullName,
                      onLogout: () => ref.read(authControllerProvider.notifier).signOut(),
                    ),
                    if (!driver.isApproved) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.pending_rounded, size: 18, color: Colors.orange),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Pending approval — tracking will be enabled once an admin reviews your account.',
                                style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable body ─────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BusInfoCard(
                    busNumber: driver.busNumber,
                    isPublic: isPublic,
                    isApproved: driver.isApproved,
                  ),

                  if (routeOrSchool != null) ...[
                    const SizedBox(height: 12),
                    RouteSchoolTile(isPublic: isPublic, value: routeOrSchool),
                  ],

                  if (isTracking) ...[
                    const SizedBox(height: 12),
                    TrackingStatusBar(isTracking: isTracking),
                  ],

                  if (trackingState.position != null) ...[
                    const SizedBox(height: 12),
                    LocationInfoCard(position: trackingState.position!),
                  ],

                  if (!isPublic && isTracking) ...[
                    const SizedBox(height: 12),
                    StudentCounterTile(
                      count: trackingState.studentCount,
                      onIncrement: () => ref.read(trackingProvider.notifier).incrementStudentCount(),
                      onDecrement: () => ref.read(trackingProvider.notifier).decrementStudentCount(),
                    ),
                  ],

                  const SizedBox(height: 28),

                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.manageBusStops),
                    icon: const Icon(Icons.signpost_rounded, size: 18),
                    label: const Text('Manage Bus Stops'),
                  ),

                  const SizedBox(height: 12),

                  FilledButton.icon(
                    onPressed: driver.isApproved
                        ? () {
                            isTracking
                                ? ref.read(trackingProvider.notifier).stopTracking()
                                : ref.read(trackingProvider.notifier).startTracking();
                          }
                        : null,
                    icon: Icon(isTracking ? Icons.stop_rounded : Icons.location_on_rounded, size: 20),
                    label: Text(isTracking ? 'Stop Tracking' : 'Start Tracking'),
                    style: FilledButton.styleFrom(
                      backgroundColor: isTracking ? Colors.red : null,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

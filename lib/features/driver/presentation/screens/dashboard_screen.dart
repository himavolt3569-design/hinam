import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/driver/data/models/driver_model.dart';
import 'package:hinam/features/driver/presentation/providers/driver_profile_provider.dart';
import 'package:hinam/features/driver/presentation/widgets/bus_info_card.dart';
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
    final isPublic = driver.busType == 'public';
    final routeOrSchool = driver.routeName ?? driver.schoolName;
    final trackingState = ref.watch(trackingProvider);
    final isTracking = trackingState.isTracking;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w400),
            ),
            Text(
              driver.fullName,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded, size: 20),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!driver.isApproved)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.pending_rounded, size: 18, color: AppColors.warning),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pending approval — tracking will be enabled once an admin reviews your account.',
                        style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            BusInfoCard(
              busNumber: driver.busNumber,
              isPublic: isPublic,
              isApproved: driver.isApproved,
            ),

            if (routeOrSchool != null) ...[
              const SizedBox(height: 10),
              RouteSchoolTile(isPublic: isPublic, value: routeOrSchool),
            ],

            if (isTracking) ...[
              const SizedBox(height: 10),
              TrackingStatusBar(isTracking: isTracking),
            ],

            if (trackingState.position != null) ...[
              const SizedBox(height: 10),
              LocationInfoCard(position: trackingState.position!),
            ],

            if (!isPublic && isTracking) ...[
              const SizedBox(height: 10),
              StudentCounterTile(
                count: trackingState.studentCount,
                onIncrement: () => ref.read(trackingProvider.notifier).incrementStudentCount(),
                onDecrement: () => ref.read(trackingProvider.notifier).decrementStudentCount(),
              ),
            ],

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.manageBusStops),
              icon: const Icon(Icons.signpost_rounded, size: 18),
              label: const Text('Manage Bus Stops'),
            ),

            const SizedBox(height: 10),

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
                backgroundColor: isTracking ? AppColors.error : null,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

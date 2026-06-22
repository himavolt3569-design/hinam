import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/admin/data/repositories/admin_repository.dart';
import 'package:hinam/features/driver/data/models/driver_model.dart';
import 'package:hinam/features/tracking/data/models/bus_location_model.dart';

final isAdminProvider = FutureProvider.family<bool, String>((ref, uid) {
  return ref.read(adminRepositoryProvider).isAdmin(uid);
});

final pendingDriversProvider = StreamProvider<List<DriverModel>>((ref) {
  return ref.watch(adminRepositoryProvider).watchPendingDrivers();
});

final allDriversProvider = StreamProvider<List<DriverModel>>((ref) {
  return ref.watch(adminRepositoryProvider).watchAllDrivers();
});

final adminActiveBusesProvider = StreamProvider<List<BusLocationModel>>((ref) {
  return ref.watch(adminRepositoryProvider).watchActiveBuses();
});

final driverApprovalControllerProvider =
    AsyncNotifierProvider<DriverApprovalController, void>(
      DriverApprovalController.new,
    );

class DriverApprovalController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> approve(String uid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).approveDriver(uid),
    );
  }

  Future<void> reject(String uid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).rejectDriver(uid),
    );
  }
}

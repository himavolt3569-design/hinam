import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_driver_provider.dart';
import 'package:hinam/features/hinam_ride/passenger/presentation/providers/ride_passenger_provider.dart';

/// Resolves a uid to a display name for admin review cards (reports,
/// incidents) — a ride participant may be either a driver or a passenger,
/// so this checks both existing profile repositories rather than either
/// admin sub-area duplicating its own lookup.
final rideParticipantNameProvider = FutureProvider.family<String, String>((
  ref,
  uid,
) async {
  final driver = await ref.read(rideDriverRepositoryProvider).getDriver(uid);
  if (driver != null) return driver.fullName;

  final passenger = await ref
      .read(ridePassengerRepositoryProvider)
      .getPassenger(uid);
  if (passenger != null) return passenger.fullName;

  return 'Unknown User';
});

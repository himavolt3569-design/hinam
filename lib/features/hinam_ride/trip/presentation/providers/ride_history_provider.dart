import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';
import 'active_ride_provider.dart' show rideTripRepositoryProvider;

final rideHistoryProvider =
    StreamProvider.family<List<RideModel>, ({String uid, bool isDriver})>((
      ref,
      query,
    ) {
      return ref
          .watch(rideTripRepositoryProvider)
          .watchRideHistory(uid: query.uid, isDriver: query.isDriver);
    });

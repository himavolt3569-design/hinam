import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'active_ride_provider.dart' show rideTripRepositoryProvider;

final ratingControllerProvider = AsyncNotifierProvider<RatingController, void>(
  RatingController.new,
);

class RatingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submitRating({
    required String rideId,
    required bool isDriver,
    required double rating,
    String? comment,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(rideTripRepositoryProvider)
          .submitRating(
            rideId: rideId,
            isDriver: isDriver,
            rating: rating,
            comment: comment,
          ),
    );
  }
}

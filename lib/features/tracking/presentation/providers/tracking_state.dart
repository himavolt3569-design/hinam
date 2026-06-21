import 'package:geolocator/geolocator.dart';

class TrackingState {
  final bool isTracking;
  final Position? position;
  final int studentCount;

  const TrackingState({required this.isTracking, this.position, this.studentCount = 0});

  TrackingState copyWith({bool? isTracking, Position? position, int? studentCount}) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      position: position ?? this.position,
      studentCount: studentCount ?? this.studentCount,
    );
  }
}

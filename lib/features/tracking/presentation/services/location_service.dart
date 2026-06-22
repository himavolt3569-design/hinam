import 'dart:io';

import 'package:geolocator/geolocator.dart';

class LocationService {
  static const _accuracy = LocationAccuracy.high;
  static const _distanceFilter = 10;

  LocationSettings get _settings {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: _accuracy,
        distanceFilter: _distanceFilter,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Hinam is running in background',
          notificationText: 'Your location is being shared with passengers.',
          enableWakeLock: true,
        ),
      );
    }

    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: _accuracy,
        distanceFilter: _distanceFilter,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    }

    return const LocationSettings(
      accuracy: _accuracy,
      distanceFilter: _distanceFilter,
    );
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(locationSettings: _settings);
  }

  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return Geolocator.getCurrentPosition(locationSettings: _settings);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:hinam/features/bus_stops/data/models/bus_stop_model.dart';
import 'package:hinam/features/bus_stops/presentation/providers/bus_stops_provider.dart';
import 'package:hinam/features/passenger/presentation/providers/bus_locations_provider.dart';
import 'package:hinam/features/tracking/data/models/bus_location_model.dart';

const _fallbackSpeedMs = 5.0; // ~18 km/h — used when bus is stationary
const _distanceCalc = Distance();

// ── Models ─────────────────────────────────────────────────────────────────

class EtaResult {
  final String busNumber;
  final String busType;
  final String? routeName;
  final String? schoolName;
  final double distanceMeters;
  final Duration eta;

  const EtaResult({
    required this.busNumber,
    required this.busType,
    this.routeName,
    this.schoolName,
    required this.distanceMeters,
    required this.eta,
  });

  String get formattedDistance {
    if (distanceMeters < 1000) return '${distanceMeters.round()} m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  String get formattedEta {
    if (eta.inSeconds < 60) return '< 1 min';
    if (eta.inMinutes < 60) return '${eta.inMinutes} min';
    return '${eta.inHours}h ${eta.inMinutes.remainder(60)}m';
  }
}

class EtaToStop {
  final BusStopModel stop;
  final double distanceMeters;
  final Duration eta;

  const EtaToStop({
    required this.stop,
    required this.distanceMeters,
    required this.eta,
  });

  String get formattedDistance {
    if (distanceMeters < 1000) return '${distanceMeters.round()} m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  String get formattedEta {
    if (eta.inSeconds < 60) return '< 1 min';
    if (eta.inMinutes < 60) return '${eta.inMinutes} min';
    return '${eta.inHours}h ${eta.inMinutes.remainder(60)}m';
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

double _metersTo(BusLocationModel bus, BusStopModel stop) {
  return _distanceCalc.as(
    LengthUnit.Meter,
    LatLng(bus.latitude, bus.longitude),
    LatLng(stop.latitude, stop.longitude),
  );
}

Duration _eta(double meters, double speedMs) {
  final speed = speedMs > 1.0 ? speedMs : _fallbackSpeedMs;
  return Duration(seconds: (meters / speed).round());
}

// ── Providers ──────────────────────────────────────────────────────────────

/// For a given stop: returns all active buses sorted by ETA (nearest first).
final stopEtaProvider = Provider.family<List<EtaResult>, String>((ref, stopId) {
  final stops = ref.watch(busStopsProvider).asData?.value ?? [];
  final stopMatches = stops.where((s) => s.id == stopId);
  if (stopMatches.isEmpty) return [];
  final stop = stopMatches.first;

  final buses = ref.watch(busLocationsProvider).asData?.value ?? [];

  final results = buses.map((bus) {
    final meters = _metersTo(bus, stop);
    return EtaResult(
      busNumber: bus.busNumber,
      busType: bus.busType,
      routeName: bus.routeName,
      schoolName: bus.schoolName,
      distanceMeters: meters,
      eta: _eta(meters, bus.speed),
    );
  }).toList()..sort((a, b) => a.eta.compareTo(b.eta));

  return results;
});

/// For a given bus: returns its nearest stop + ETA.
final busNearestStopProvider = Provider.family<EtaToStop?, String>((
  ref,
  driverId,
) {
  final stops = ref.watch(busStopsProvider).asData?.value ?? [];
  if (stops.isEmpty) return null;

  final buses = ref.watch(busLocationsProvider).asData?.value ?? [];
  final busMatches = buses.where((b) => b.driverId == driverId);
  if (busMatches.isEmpty) return null;
  final bus = busMatches.first;

  BusStopModel? nearest;
  double minDist = double.infinity;

  for (final stop in stops) {
    final d = _metersTo(bus, stop);
    if (d < minDist) {
      minDist = d;
      nearest = stop;
    }
  }

  if (nearest == null) return null;

  return EtaToStop(
    stop: nearest,
    distanceMeters: minDist,
    eta: _eta(minDist, bus.speed),
  );
});

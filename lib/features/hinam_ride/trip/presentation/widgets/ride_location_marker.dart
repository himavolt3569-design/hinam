import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Marker buildRideLocationMarker(LatLng point, Color color, IconData icon) {
  return Marker(
    point: point,
    width: 40,
    height: 40,
    child: Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    ),
  );
}

// lib/services/map_service.dart
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:latlong2/latlong.dart';

class MapService {
  // Convert latlong2 LatLng -> Google Maps LatLng
  gm.LatLng toGoogleLatLng(LatLng point) => gm.LatLng(point.latitude, point.longitude);

  // Convert Google LatLng -> latlong2 LatLng
  LatLng fromGoogleLatLng(gm.LatLng point) => LatLng(point.latitude, point.longitude);

  // Calculate bounding box (LatLngBounds) for a list of coordinates
  gm.LatLngBounds getBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return gm.LatLngBounds(
        southwest: gm.LatLng(0, 0),
        northeast: gm.LatLng(0, 0),
      );
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return gm.LatLngBounds(
      southwest: gm.LatLng(minLat, minLng),
      northeast: gm.LatLng(maxLat, maxLng),
    );
  }

  // Build a polyline-compatible list for Google Maps
  List<gm.LatLng> buildGooglePolylinePoints(List<LatLng> points) {
    return points.map((p) => gm.LatLng(p.latitude, p.longitude)).toList();
  }
}

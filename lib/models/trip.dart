import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double distance; // in kilometers
  final double cost;
  final String scooterId;
  final List<LatLng>? routeCoordinates;
  final String? paymentMethod;
  final bool isCancelled;
  final String? cancellationReason;

  const Trip({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.distance,
    required this.cost,
    required this.scooterId,
    this.routeCoordinates,
    this.paymentMethod,
    this.isCancelled = false,
    this.cancellationReason,
  });

  /// Calculate trip duration (if `endTime` is null, use current time)
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Creates a copy of the Trip object with optional modifications
  Trip copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    double? distance,
    double? cost,
    String? scooterId,
    List<LatLng>? routeCoordinates,
    String? paymentMethod,
    bool? isCancelled,
    String? cancellationReason,
  }) {
    return Trip(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distance: distance ?? this.distance,
      cost: cost ?? this.cost,
      scooterId: scooterId ?? this.scooterId,
      routeCoordinates: routeCoordinates ?? this.routeCoordinates,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isCancelled: isCancelled ?? this.isCancelled,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  /// Deserialize Trip object from JSON
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      distance: (json['distance'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      scooterId: json['scooterId'] ?? '',
      routeCoordinates: json['routeCoordinates'] != null
          ? (json['routeCoordinates'] as List)
          .map((coord) {
        final lat = (coord['lat'] as num).toDouble();
        final lng = (coord['lng'] as num).toDouble();
        return LatLng(lat, lng);
      })
          .toList()
          : null,
      paymentMethod: json['paymentMethod'],
      isCancelled: json['isCancelled'] == true,
      cancellationReason: json['cancellationReason'],
    );
  }

  /// Serialize Trip object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'distance': distance,
      'cost': cost,
      'scooterId': scooterId,
      'routeCoordinates': routeCoordinates
          ?.map((coord) => {'lat': coord.latitude, 'lng': coord.longitude})
          .toList(),
      'paymentMethod': paymentMethod,
      'isCancelled': isCancelled,
      'cancellationReason': cancellationReason,
    };
  }

  @override
  String toString() =>
      'Trip(id: $id, scooterId: $scooterId, distance: $distance km, cost: $cost, cancelled: $isCancelled)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Trip &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

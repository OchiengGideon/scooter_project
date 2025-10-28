import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class RideReceipt {
  final String receiptId;
  final String rideId;
  final String scooterId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalDistance; // in meters
  final double totalFare;
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double deductions;
  final double tax;
  final List<LatLng> routeCoordinates;
  final String paymentMethod;
  final String? promoCode;
  final double promoDiscount;

  const RideReceipt({
    required this.receiptId,
    required this.rideId,
    required this.scooterId,
    required this.startTime,
    required this.endTime,
    required this.totalDistance,
    required this.totalFare,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.deductions,
    required this.tax,
    required this.routeCoordinates,
    required this.paymentMethod,
    this.promoCode,
    this.promoDiscount = 0.0,
  });

  Duration get duration => endTime.difference(startTime);
  double get distanceKm => totalDistance / 1000;
  double get subtotal => baseFare + distanceFare + timeFare;
  double get finalAmount => subtotal - deductions - promoDiscount + tax;

  // JSON serialization
  factory RideReceipt.fromJson(Map<String, dynamic> json) {
    return RideReceipt(
      receiptId: json['receipt_id'],
      rideId: json['ride_id'],
      scooterId: json['scooter_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      totalDistance: (json['total_distance'] as num).toDouble(),
      totalFare: (json['total_fare'] as num).toDouble(),
      baseFare: (json['base_fare'] as num).toDouble(),
      distanceFare: (json['distance_fare'] as num).toDouble(),
      timeFare: (json['time_fare'] as num).toDouble(),
      deductions: (json['deductions'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      routeCoordinates: (json['route_coordinates'] as List).map((coord) {
        return LatLng(coord['lat'], coord['lng']);
      }).toList(),
      paymentMethod: json['payment_method'],
      promoCode: json['promo_code'],
      promoDiscount: (json['promo_discount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receipt_id': receiptId,
      'ride_id': rideId,
      'scooter_id': scooterId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'total_distance': totalDistance,
      'total_fare': totalFare,
      'base_fare': baseFare,
      'distance_fare': distanceFare,
      'time_fare': timeFare,
      'deductions': deductions,
      'tax': tax,
      'route_coordinates': routeCoordinates.map((coord) {
        return {'lat': coord.latitude, 'lng': coord.longitude};
      }).toList(),
      'payment_method': paymentMethod,
      'promo_code': promoCode,
      'promo_discount': promoDiscount,
    };
  }

  RideReceipt copyWith({
    String? receiptId,
    String? rideId,
    String? scooterId,
    DateTime? startTime,
    DateTime? endTime,
    double? totalDistance,
    double? totalFare,
    double? baseFare,
    double? distanceFare,
    double? timeFare,
    double? deductions,
    double? tax,
    List<LatLng>? routeCoordinates,
    String? paymentMethod,
    String? promoCode,
    double? promoDiscount,
  }) {
    return RideReceipt(
      receiptId: receiptId ?? this.receiptId,
      rideId: rideId ?? this.rideId,
      scooterId: scooterId ?? this.scooterId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDistance: totalDistance ?? this.totalDistance,
      totalFare: totalFare ?? this.totalFare,
      baseFare: baseFare ?? this.baseFare,
      distanceFare: distanceFare ?? this.distanceFare,
      timeFare: timeFare ?? this.timeFare,
      deductions: deductions ?? this.deductions,
      tax: tax ?? this.tax,
      routeCoordinates: routeCoordinates ?? this.routeCoordinates,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCode: promoCode ?? this.promoCode,
      promoDiscount: promoDiscount ?? this.promoDiscount,
    );
  }

  @override
  String toString() {
    return 'RideReceipt(receiptId: $receiptId, totalFare: $totalFare, duration: $duration, distance: ${distanceKm.toStringAsFixed(2)} km)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideReceipt && other.receiptId == receiptId;
  }

  @override
  int get hashCode => receiptId.hashCode;
}
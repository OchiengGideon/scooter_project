// lib/services/user_service.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/trip.dart';

class UserService {
  static const String _userKey = 'user_data';
  static const String _profileCompletedKey = 'profile_completed';

  // Save user data to SharedPreferences
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert user to JSON and save
      final userJson = user.toJson();

      await prefs.setString(_userKey, json.encode(userJson));
      await prefs.setBool(_profileCompletedKey, user.profileCompleted);
    } catch (e, s) {
      if (kDebugMode) debugPrint('Error saving user: $e\n$s');
      rethrow;
    }
  }

  // Load user data from SharedPreferences
  static Future<User?> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userKey);

      if (userString == null) return null;

      final userJson = json.decode(userString) as Map<String, dynamic>;
      return User.fromJson(userJson);
    } catch (e, s) {
      if (kDebugMode) debugPrint('Error loading user: $e\n$s');
      return null;
    }
  }

  // Clear user data (for logout)
  static Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_profileCompletedKey);
    } catch (e, s) {
      if (kDebugMode) debugPrint('Error clearing user: $e\n$s');
    }
  }

  // Helper methods for Trip serialization (kept for backward compatibility)
  static Map<String, dynamic> _tripToJson(Trip trip) {
    return {
      'id': trip.id,
      'startTime': trip.startTime.toIso8601String(),
      'endTime': trip.endTime?.toIso8601String(),
      'distance': trip.distance,
      'cost': trip.cost,
      'scooterId': trip.scooterId,
    };
  }

  static Trip _tripFromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      distance: (json['distance'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      scooterId: json['scooterId'],
    );
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/trip.dart';

class UserService {
  static const String _userKey = 'user_data';
  static const String _profileCompletedKey = 'profile_completed';

  // Save user data to SharedPreferences
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert user to JSON and save
    final userJson = {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'studentId': user.studentId,
      'department': user.department,
      'balance': user.balance,
      'profileCompleted': user.profileCompleted,
      'tripHistory': user.tripHistory.map((trip) => _tripToJson(trip)).toList(),
    };

    await prefs.setString(_userKey, json.encode(userJson));
    await prefs.setBool(_profileCompletedKey, user.profileCompleted);
  }

  // Load user data from SharedPreferences
  static Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString == null) return null;

    try {
      final userJson = json.decode(userString) as Map<String, dynamic>;

      return User(
        id: userJson['id'] ?? '1',
        name: userJson['name'] ?? '',
        email: userJson['email'] ?? '',
        phone: userJson['phone'],
        studentId: userJson['studentId'],
        department: userJson['department'],
        balance: (userJson['balance'] as num?)?.toDouble() ?? 0.0,
        tripHistory: (userJson['tripHistory'] as List<dynamic>?)
            ?.map((tripJson) => _tripFromJson(tripJson))
            .toList() ?? [],
        profileCompleted: userJson['profileCompleted'] ?? false,
      );
    } catch (e) {
      print('Error loading user: $e');
      return null;
    }
  }

  // Clear user data (for logout)
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_profileCompletedKey);
  }

  // Helper methods for Trip serialization
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
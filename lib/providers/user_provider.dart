import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/trip.dart';

class UserProvider with ChangeNotifier {
  User _user = User.createDefault();
  bool _isLoading = false;

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isProfileCompleted => _user.profileCompleted;

  // Load user data (in real app, this would fetch from API)
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));

    // Mock user data - replace with actual API call
    _user = User(
      id: 'user_123',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+1234567890',
      studentId: 'STU2023001',
      department: 'Computer Science',
      balance: 25.50,
      tripHistory: [
        Trip(
          id: 'trip_1',
          startTime: DateTime.now().subtract(Duration(days: 1)),
          endTime: DateTime.now().subtract(Duration(days: 1, hours: 0, minutes: 15)),
          distance: 2.3,
          cost: 2.30,
          scooterId: 'SCOOT-123',
        ),
        Trip(
          id: 'trip_2',
          startTime: DateTime.now().subtract(Duration(days: 2)),
          endTime: DateTime.now().subtract(Duration(days: 2, hours: 0, minutes: 12)),
          distance: 1.7,
          cost: 1.70,
          scooterId: 'SCOOT-456',
        ),
      ],
      profileCompleted: false, // Set to false to test profile completion flow
    );

    _isLoading = false;
    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String studentId,
    required String department,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    _user = _user.copyWith(
      name: name,
      email: email,
      phone: phone,
      studentId: studentId,
      department: department,
      profileCompleted: true,
    );

    _isLoading = false;
    notifyListeners();
  }

  // Add funds to wallet
  Future<void> addFunds(double amount) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    _user = _user.copyWith(
      balance: _user.balance + amount,
    );

    _isLoading = false;
    notifyListeners();
  }

  // Start a new trip
  Future<void> startTrip(String scooterId) async {
    final newTrip = Trip(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      startTime: DateTime.now(),
      distance: 0.0,
      cost: 0.0,
      scooterId: scooterId,
    );

    _user = _user.copyWith(
      tripHistory: [..._user.tripHistory, newTrip],
    );

    notifyListeners();
  }

  // End current trip
  Future<void> endTrip(double distance, double cost) async {
    if (_user.tripHistory.isEmpty) return;

    final updatedTrips = List<Trip>.from(_user.tripHistory);
    if (updatedTrips.isNotEmpty) {
      final lastTrip = updatedTrips.last;
      final updatedTrip = Trip(
        id: lastTrip.id,
        startTime: lastTrip.startTime,
        endTime: DateTime.now(),
        distance: distance,
        cost: cost,
        scooterId: lastTrip.scooterId,
      );
      updatedTrips[updatedTrips.length - 1] = updatedTrip;

      _user = _user.copyWith(
        tripHistory: updatedTrips,
        balance: _user.balance - cost,
      );
    }

    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/trip.dart';
import '../services/user_service.dart';
import 'dart:convert';

class UserProvider with ChangeNotifier {
  User _user = User.createDefault();
  bool _isLoading = false;

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isProfileCompleted => _user.profileCompleted;

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    // Try to load saved user data
    final savedUser = await UserService.loadUser();

    if (savedUser != null) {
      _user = savedUser;
    } else {
      // Create default user if no saved data
      _user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: '',
        email: '',
        phone: null,
        studentId: null,
        department: null,
        balance: 25.50, // Starting balance
        tripHistory: [],
        profileCompleted: false,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update user profile and save
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String studentId,
    required String department,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));

    _user = _user.copyWith(
      name: name,
      email: email,
      phone: phone,
      studentId: studentId,
      department: department,
      profileCompleted: true,
    );

    // Save to persistence
    await UserService.saveUser(_user);

    _isLoading = false;
    notifyListeners();
  }

  // Add funds to wallet and save
  Future<void> addFunds(double amount) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    _user = _user.copyWith(
      balance: _user.balance + amount,
    );

    // Save to persistence
    await UserService.saveUser(_user);

    _isLoading = false;
    notifyListeners();
  }

  // Start a new trip and save
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

    // Save to persistence
    await UserService.saveUser(_user);

    notifyListeners();
  }

  // End current trip and save
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

    // Save to persistence
    await UserService.saveUser(_user);

    notifyListeners();
  }

  // Clear user data (for logout)
  Future<void> logout() async {
    await UserService.clearUser();
    _user = User.createDefault();
    notifyListeners();
  }
}
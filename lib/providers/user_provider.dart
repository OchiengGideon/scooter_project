// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/trip.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  User _user = User.createDefault();
  bool _isLoading = false;

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isProfileCompleted => _user.profileCompleted;

  // Helper to run any async action and toggle the loading state
  Future<T> _runWithLoading<T>(Future<T> Function() action) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    await _runWithLoading(() async {
      try {
        final savedUser = await UserService.loadUser();
        if (savedUser != null) {
          _user = savedUser;
        } else {
          _user = User.createDefault();
        }
      } catch (e) {
        debugPrint('Error loading user data in provider: $e');
        _user = User.createDefault();
      }
    });
  }

  // Alias
  Future<void> loadUser() async => loadUserData();

  // Login user
  Future<void> login({required String email, required String password}) async {
    await _runWithLoading(() async {
      // Simulate API call delay (replace with real API call later)
      await Future.delayed(const Duration(seconds: 1));

      final savedUser = await UserService.loadUser();

      if (savedUser != null && savedUser.email == email) {
        _user = savedUser;
      } else {
        _user = User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Demo User',
          email: email,
          phone: null,
          studentId: null,
          department: null,
          balance: 25.0,
          tripHistory: [],
          profileCompleted: false,
        );

        await UserService.saveUser(_user);
      }
    });
  }

  // Register user
  Future<void> register({required String email, required String password}) async {
    await _runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));

      _user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'New User',
        email: email,
        phone: null,
        studentId: null,
        department: null,
        balance: 10.0,
        tripHistory: [],
        profileCompleted: false,
      );

      await UserService.saveUser(_user);
    });
  }

  // Update user profile and save
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String studentId,
    required String department,
  }) async {
    await _runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));

      _user = _user.copyWith(
        name: name,
        email: email,
        phone: phone,
        studentId: studentId,
        department: department,
        profileCompleted: true,
      );

      await UserService.saveUser(_user);
    });
  }

  // Add funds to wallet and save
  Future<void> addFunds(double amount) async {
    await _runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));

      _user = _user.copyWith(
        balance: _user.balance + amount,
      );

      await UserService.saveUser(_user);
    });
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

    await UserService.saveUser(_user);
    notifyListeners();
  }

  // Clear user data (for logout)
  Future<void> logout() async {
    await UserService.clearUser();
    _user = User.createDefault();
    notifyListeners();
  }

  // Explicitly set loading state (rarely needed)
  void setState(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

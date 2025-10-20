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

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to load saved user data
      final savedUser = await UserService.loadUser();

      if (savedUser != null) {
        _user = savedUser;
      } else {
        // Create default user if no saved data
        _user = User.createDefault();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Create default user on error
      _user = User.createDefault();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load user (alias for loadUserData for compatibility)
  Future<void> loadUser() async {
    await loadUserData();
  }

  // Login user
  Future<void> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));

      // Check if we have an existing user with this email
      final savedUser = await UserService.loadUser();

      if (savedUser != null && savedUser.email == email) {
        // Use existing user
        _user = savedUser;
      } else {
        // Create new user for demo purposes
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

        // Save to persistence
        await UserService.saveUser(_user);
      }

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Register user
  Future<void> register({required String email, required String password}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));

      // Create new user
      _user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'New User',
        email: email,
        phone: null,
        studentId: null,
        department: null,
        balance: 10.0, // Starting bonus
        tripHistory: [],
        profileCompleted: false,
      );

      // Save to persistence
      await UserService.saveUser(_user);

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
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

    try {
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
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add funds to wallet and save
  Future<void> addFunds(double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));

      _user = _user.copyWith(
        balance: _user.balance + amount,
      );

      // Save to persistence
      await UserService.saveUser(_user);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
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

  // Set loading state
  void setState(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
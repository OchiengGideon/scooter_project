// lib/models/user.dart
import 'trip.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? studentId;
  final String? department;
  final double balance;
  final List<Trip> tripHistory;
  final bool profileCompleted;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.studentId,
    this.department,
    required this.balance,
    required this.tripHistory,
    required this.profileCompleted,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? studentId,
    String? department,
    double? balance,
    List<Trip>? tripHistory,
    bool? profileCompleted,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      balance: balance ?? this.balance,
      tripHistory: tripHistory ?? this.tripHistory,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }

  static User createDefault() {
    return User(
      id: '',
      name: '',
      email: '',
      balance: 0.0,
      tripHistory: [],
      profileCompleted: false,
    );
  }

  // ---------- JSON Serialization ----------
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      studentId: json['studentId']?.toString(),
      department: json['department']?.toString(),
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      tripHistory: (json['tripHistory'] as List<dynamic>?)
          ?.map((t) => Trip.fromJson(Map<String, dynamic>.from(t)))
          .toList() ??
          [],
      profileCompleted: json['profileCompleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'studentId': studentId,
      'department': department,
      'balance': balance,
      'profileCompleted': profileCompleted,
      'tripHistory': tripHistory.map((t) => t.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, balance: $balance)';
}

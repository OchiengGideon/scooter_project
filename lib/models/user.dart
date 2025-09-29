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
      id: '1',
      name: '',
      email: '',
      balance: 0.0,
      tripHistory: [],
      profileCompleted: false,
    );
  }
}
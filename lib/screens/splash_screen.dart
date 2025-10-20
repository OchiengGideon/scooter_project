// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadDataAndNavigate();
  }

  Future<void> _loadDataAndNavigate() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Load user data from persistence
    await userProvider.loadUserData();

    // Add a small delay for smooth transition
    await Future.delayed(Duration(milliseconds: 1500));

    if (mounted) {
      final user = userProvider.user;

      if (user.id.isEmpty || user.email.isEmpty) {
        // No user found or new user, go to auth
        Navigator.pushReplacementNamed(context, '/auth');
      } else if (user.profileCompleted) {
        // User has completed profile, go to main screen
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        // User exists but profile not completed, go to main (which will enforce profile completion)
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.electric_scooter,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Scooter Service',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Ride with ease',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
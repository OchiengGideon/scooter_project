import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
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

    // Navigate to appropriate screen based on profile completion
    Future.delayed(Duration(seconds: 2), () {
      final user = userProvider.user;

      if (user.profileCompleted) {
        // User has completed profile, go to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // User needs to complete profile, go to auth
        Navigator.pushReplacementNamed(context, '/auth');
      }
    });
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
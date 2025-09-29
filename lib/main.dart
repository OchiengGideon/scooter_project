import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'utils/constants.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Scooter Service',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/auth': (context) => AuthScreen(),
          '/home': (context) => MainScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
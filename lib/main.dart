// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'locator.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator(); // Initialize dependency injection
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: 'Scooter App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => SplashScreen(),
          '/auth': (context) => AuthScreen(),
          '/main': (context) => MainScreen(),
        },
        home: SplashScreen(),
      ),
    );
  }
}
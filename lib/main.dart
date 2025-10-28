// lib/main.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'locator.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'services/api_client.dart';
import 'services/location_service.dart';
import 'repositories/ride_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Run inside guarded zone to capture uncaught errors in release/dev.
  runZonedGuarded(() async {
    // Initialize DI container
    try {
      if (kDebugMode) {
        debugPrint('🚀 Initializing GetIt (locator)...');
      }
      setupLocator();

      // Test if dependencies are registered (fail fast during development)
      try {
        final apiClient = locator<ApiClient>();
        final locationService = locator<LocationService>();
        final rideRepository = locator<RideRepository>();

        if (kDebugMode) {
          debugPrint('✅ All dependencies successfully registered in GetIt!');
        }
      } catch (e, s) {
        // If DI fails, print but continue — the app will still show errors where used.
        debugPrint('❌ GetIt setup check failed: $e\n$s');
      }
    } catch (e, s) {
      debugPrint('❌ GetIt initialization error: $e\n$s');
    }

    runApp(const MyApp());
  }, (error, stack) {
    // Global error handler
    if (kDebugMode) {
      debugPrint('Unhandled error in app: $error\n$stack');
    }
    // TODO: Report to crash analytics here (Sentry/Firebase Crashlytics)
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          '/splash': (context) => const SplashScreen(),
          '/auth': (context) => const AuthScreen(),
          '/main': (context) => const MainScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}

// lib/locator.dart
import 'package:get_it/get_it.dart';
import 'services/api_client.dart';
import 'services/location_service.dart';
import 'repositories/ride_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register services as singletons
  locator.registerLazySingleton<ApiClient>(() => ApiClient());
  locator.registerLazySingleton<LocationService>(() => LocationService());

  // Register repositories as singletons - THIS IS MISSING!
  locator.registerLazySingleton<RideRepository>(() => RideRepository(
    locator<ApiClient>(),
    locator<LocationService>(),
  ));
}
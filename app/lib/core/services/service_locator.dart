import 'package:get_it/get_it.dart';
import 'api_client.dart';
import 'user_service.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  static void setup() {
    // Register API Client
    getIt.registerLazySingleton<ApiClient>(() => ApiClient());

    // Register Services
    getIt.registerLazySingleton<UserService>(() => UserService());

    // Add more services here as needed
  }

  static T get<T extends Object>() => getIt.get<T>();
}

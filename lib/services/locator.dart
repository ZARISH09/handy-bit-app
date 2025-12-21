import 'package:get_it/get_it.dart';
import 'package:handy_bit/providers/auth_provider.dart';
import 'firestore_services.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<FirestoreService>(() => FirestoreService());
  locator.registerLazySingleton<AuthProvider>(() => AuthProvider(firestoreService: locator<FirestoreService>()));
}

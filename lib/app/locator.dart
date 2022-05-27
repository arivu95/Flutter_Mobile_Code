import 'package:get_it/get_it.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/call_kit_manager.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/call_tone.dart';
import 'package:swarapp/services/connectycube_services.dart';
import 'package:swarapp/services/dynamic_link_service.dart';
import 'package:swarapp/services/iap_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/services/pushnotification_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => PreferencesService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => ConnectyCubeServices());
  locator.registerLazySingleton(() => DynamicLinkService());
  locator.registerLazySingleton(() => CallManager());
  locator.registerLazySingleton(() => CallKitManager());
  locator.registerLazySingleton(() => PushNotificationService());
  locator.registerLazySingleton(() => IapService());
  locator.registerLazySingleton(() => CallTone());
}

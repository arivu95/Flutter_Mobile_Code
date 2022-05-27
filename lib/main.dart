import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/app/router.dart' as Router1;
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("::BG:: - Native called background task: $task"); //simpleTask will be emitted here.
    await Firebase.initializeApp();
    await SharedPrefs.getPrefs();
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  FlutterError.onError = (FlutterErrorDetails details) {
    //this line prints the default flutter gesture caught exception in console
    //FlutterError.dumpErrorToConsole(details);
    print("Error From INSIDE FRAME_WORK");
    print("----------------------");
    print("Error :  ${details.exception}");
    print("StackTrace :  ${details.stack}");
  };

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runZonedGuarded(() {
      setupLocator();
      Firebase.initializeApp();
      Workmanager().initialize(callbackDispatcher, // The top level function, aka callbackDispatcher
          isInDebugMode: false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
          );
      Workmanager().registerPeriodicTask("swar", "swarPeriodicTask", existingWorkPolicy: ExistingWorkPolicy.replace, frequency: Duration(minutes: 1));
      runApp(RootRestorationScope(restorationId: 'root', child: MyApp()));
    }, (e, s) {
      print("Synchronous or Asynchronous Exception: $e (stack $s) was caught in our custom zone - redirect to Sentry or Firebase.");
    });
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SWAR',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Router1.RoutePaths.Splash,
      onGenerateRoute: Router1.Router.generateRoute,
      navigatorKey: StackedService.navigatorKey,
    );
  }
}

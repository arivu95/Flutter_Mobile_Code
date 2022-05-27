import 'package:flutter/material.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/pushnotification_service.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/communication/chat_dialog_screen.dart';
import 'package:swarapp/ui/communication/chat_list_view.dart';
import 'package:swarapp/ui/dashboard/dashboard_view.dart';
import 'package:swarapp/ui/dashboard/doctor_dashboard_view.dart';
import 'package:swarapp/ui/splash/splash_view.dart';
import 'package:swarapp/ui/startup/language_select_view.dart';
import 'package:swarapp/ui/startup/signup_view.dart';
import 'package:swarapp/ui/startup/start_view.dart';
import 'package:doctor_module/doctor_module.dart';
import 'package:swarapp/ui/startup/role_select_view.dart';
import 'package:doctor_module/src/ui/doc_signup/doc_service_view.dart';

class RoutePaths {
  static const String Splash = 'splash';
  static const String Signup = 'signup';
  static const String Start = 'start';
  static const String Dashboard = 'dashboard';
  static const String Langugage = 'language';
  static const String ChatDialog = 'chat_dialog';
  static const String ChatList = 'chat_list';
  static const String docOnboard = 'docOnboard';
  static const String RoleSelect = 'roleSelect';
  static const String DoctorDashboard = 'doctordashboard';
  static const String DocService = 'doc_service_select';
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    locator<PushNotificationService>().onNotificationClicked = (payload) {
      MaterialPageRoute pageRout = MaterialPageRoute(builder: (_) => DashboardView());
      return locator<PushNotificationService>().onNotificationSelected(payload, pageRout.subtreeContext);
    };
    switch (settings.name) {
      case RoutePaths.ChatDialog:
        Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (context) => ChatDialogScreen(args![UIHelper.USER_ARG_NAME], args[UIHelper.DIALOG_ARG_NAME]));
      case RoutePaths.ChatList:
        return MaterialPageRoute(builder: (_) => ChatListView());
      case RoutePaths.Splash:
        return MaterialPageRoute(builder: (_) => SplashView());
      case RoutePaths.Signup:
        return MaterialPageRoute(builder: (_) => SignupView());
      case RoutePaths.Dashboard:
        return MaterialPageRoute(builder: (_) => DashboardView());
      case RoutePaths.DoctorDashboard:
        return MaterialPageRoute(builder: (_) => DoctorDashboardView());
      case RoutePaths.Start:
        return MaterialPageRoute(builder: (_) => StartView());
      case RoutePaths.Langugage:
        return MaterialPageRoute(builder: (_) => LanguageSelectView());
      case RoutePaths.docOnboard:
        return MaterialPageRoute(builder: (_) => DocOnboardingSectionListView());
      case RoutePaths.RoleSelect:
        return MaterialPageRoute(builder: (_) => RoleSelectView());
      case RoutePaths.DocService:
        return MaterialPageRoute(builder: (_) => DocServicesView());

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.red,
                  ),
                  body: Center(
                    child: Text('Functionality being developed..'),
                  ),
                ));
    }
  }
}

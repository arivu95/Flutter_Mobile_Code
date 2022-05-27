import 'dart:io';
import 'package:doctor_module/src/ui/doc_subscription/membership_list_view.dart';
import 'package:doctor_module/src/ui/doc_subscription/subscribed_view.dart';
import 'package:doctor_module/src/ui/doc_subscription/subscription_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/connectycube_services.dart';
import 'package:swarapp/services/iap_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/services/pushnotification_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_profile_view.dart';
import 'package:swarapp/services/api_services.dart';

class DoctorMoreView extends StatelessWidget {
  const DoctorMoreView({Key? key}) : super(key: key);

  void _getOutOfApp() async {
    if (Platform.isIOS) {
      try {
        exit(0);
      } catch (e) {
        SystemNavigator.pop(); // for IOS, not true this, you can make comment this :)
      }
    } else {
      try {
        SystemNavigator.pop(); // sometimes it cant exit app
      } catch (e) {
        exit(0); // so i am giving crash to app ... sad :(
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    PreferencesService preferencesService = locator<PreferencesService>();
    NavigationService navigationService = locator<NavigationService>();
    ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
    IapService iapService = locator<IapService>();
    ApiService apiService = locator<ApiService>();
    return Scaffold(
      appBar: SwarAppDoctorBar(isProfileBar: false),
      body: Container(
        width: Screen.width(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
                onPressed: () async {
                  Get.to(() => DoctorProfileView());
                },
                child: Text('Profile').bold(),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(Screen.width(context) - 60, 36)),
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                )),

            ElevatedButton(
                onPressed: () async {
                  if (preferencesService.isSubscriptionMarkedInSwar() == false) {
                    Get.to(() => MembershipListView());
                  } else {
                    Get.to(() => DocSubscribedView());
                  }
                },
                child: Text('Subscription').bold(),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(Screen.width(context) - 60, 36)),
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                )),
            ElevatedButton(
                onPressed: () async {
                  Loader.show(context);
                  await locator<ConnectyCubeServices>().logoutCurrentUser();
                  String userid = preferencesService.userId;
                  String devicetoken = preferencesService.device_token;
                  await apiService.removeUserDeviceToken(userid, devicetoken);
                  await preferencesService.cleanAllPreferences();
                  SharedPreferences preferences = await SharedPreferences.getInstance();
                  await preferences.clear();
                  locator<CallManager>().destroy();

                  await locator<PushNotificationService>().unsubscribe();
                  Loader.hide();
                  await navigationService.clearStackAndShow(RoutePaths.Splash);
                },
                child: Text('Sign out').bold(),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(Screen.width(context) - 60, 36)),
                  backgroundColor: MaterialStateProperty.all(activeColor),
                )),
            UIHelper.verticalSpaceSmall,
            // ElevatedButton(
            //     onPressed: () async {
            //       // Loader.show(context);
            //       // await locator<ConnectyCubeServices>().logoutCurrentUser();
            //       // await preferencesService.cleanAllPreferences();
            //       // SharedPreferences preferences = await SharedPreferences.getInstance();
            //       // await preferences.clear();
            //       // locator<CallManager>().destroy();
            //       // await locator<PushNotificationService>().unsubscribe();
            //       // Loader.hide();
            //       // await navigationService.clearStackAndShow(RoutePaths.docOnboard);
            //     },
            //     child: Text('Pharmacy').bold(),
            //     style: ButtonStyle(
            //       minimumSize: MaterialStateProperty.all(Size(Screen.width(context) - 60, 36)),
            //       backgroundColor: MaterialStateProperty.all(Colors.purple),
            //     )),
            // UIHelper.verticalSpaceSmall,
            // ElevatedButton(
            //     onPressed: () async {
            //       // Loader.show(context);
            //       // await locator<ConnectyCubeServices>().logoutCurrentUser();
            //       // await preferencesService.cleanAllPreferences();
            //       // SharedPreferences preferences = await SharedPreferences.getInstance();
            //       // await preferences.clear();
            //       // locator<CallManager>().destroy();
            //       // await locator<PushNotificationService>().unsubscribe();
            //       // Loader.hide();

            //       // await navigationService.clearStackAndShow(RoutePaths.Dashboard);
            //     },
            //     child: Text('Lab Tech').bold(),
            //     style: ButtonStyle(
            //       minimumSize: MaterialStateProperty.all(Size(Screen.width(context) - 60, 36)),
            //       backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
            //     )),
          ],
        ),
      ),
    );
  }
}

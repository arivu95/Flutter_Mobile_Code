import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/dynamic_link_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/background_view.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/dashboard/call_test.dart';
import 'package:swarapp/ui/splash/splash_viewmodel.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = locator<NavigationService>();
    DynamicLinkService dynamicLinkService = locator<DynamicLinkService>();
    final CallManager callManager = locator<CallManager>();
    preferencesService.tempappbarIndex = 0;
    return Scaffold(
      body: ViewModelBuilder<SplashViewModel>.reactive(
          onModelReady: (model) async {
            await SharedPrefs.getPrefs();
            // navigationService.clearStackAndShow(RoutePaths.Dashboard);
            String text;
            final Directory directory = await getApplicationDocumentsDirectory();
            bool fileExists = await File('${directory.path}/swar_status.txt').exists();
            if (fileExists) {
              final File file = File('${directory.path}/swar_status.txt');
              text = await file.readAsString();
            } else {
              text = "";
            }
            bool isUserLoggedIn = await model.checkUserLoggedIn();
            await dynamicLinkService.handleDynamicLinks();
            if (isUserLoggedIn) {
              bool isUserExist = await model.checkUserExist();
              if (isUserExist) {
                // if (text == "backgroundcalls") {
                //   final File file = File('${directory.path}/swar_status.txt');
                //   await file.writeAsString("");
                //   preferencesService.isbgCall = true;
                //   Get.to(() => CallTest());
                // } else {
                //   callManager.init(context);
                //   navigationService.clearStackAndShow(RoutePaths.Dashboard);
                // }
                callManager.init(context);
                //navigationService.clearStackAndShow(RoutePaths.Dashboard);
                if (preferencesService.userInfo['login_role_id'] == "61e7a9e44c559c1530e0e562" && preferencesService.userInfo['doctor_services'].isNotEmpty) {
                  navigationService.clearStackAndShow(RoutePaths.DoctorDashboard);
                } else if (preferencesService.userInfo['login_role_id'] == "61e7a9e44c559c1530e0e562" ||
                    preferencesService.userInfo['login_role_id'] == '61e7aa154c559c1530e0e564' && preferencesService.userInfo['doctor_services'].isEmpty) {
                  navigationService.clearStackAndShow(RoutePaths.DocService);
                } else if (preferencesService.userInfo['login_role_id'] == "6128a673b71d012678336f4d") {
                  navigationService.clearStackAndShow(RoutePaths.Dashboard);
                  preferencesService.select_upload = 'upload';
                }
              } else {
                navigationService.clearStackAndShow(RoutePaths.Start);
              }
            } else {
              navigationService.clearStackAndShow(RoutePaths.Start);
            }
          },
          builder: (context, model, child) {
            return BackgroundView(
              child: Container(
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Image.asset('assets/splash_logo.png'), UIHelper.verticalSpaceLarge, Image.asset('assets/splash_message.png')],
                )),
              ),
            );
          },
          viewModelBuilder: () => SplashViewModel()),
    );
  }
}

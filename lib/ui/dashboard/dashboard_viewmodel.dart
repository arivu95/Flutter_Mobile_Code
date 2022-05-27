import 'dart:io';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/connectycube_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class DashboardViewModel extends IndexTrackingViewModel {
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  Future init() async {}

  Future<bool> checkUserExist() async {
    String oid = await preferencesService.getUserInfo('userkey');
    if (oid.length > 0) {
      final response = await apiService.checkUserExist(oid);
      return response;
    }

    return false;
  }

  Future loginToCC() async {
    //print(locator<PreferencesService>().isbgCall.toString());
    await refreshMembersList();
    String ccToken = preferencesService.userInfo['connectycube_token'];
    if (ccToken.isNotEmpty) {
      CubeUser? user = await SharedPrefs.getUser();
      if (user != null) {
        //await connectyCubeServices.loginToCC(user, saveUser: true);
        await connectyCubeServices.loginToCC(CubeUser(login: ccToken, password: '12345678'), saveUser: true);
      } else {
        await connectyCubeServices.loginToCC(CubeUser(login: ccToken, password: '12345678'), saveUser: true);
      }
      // Pull cube user again and update.
      CubeUser? useragain = await SharedPrefs.getUser();
      if (useragain != null) {
        if (useragain.id != null) {
          await apiService.updateConnectyCubeAvatat(useragain);
          preferencesService.userInfo['connectycube_id'] = useragain.id;
        }
      }
    }

    // Pushing push notification
    String token = (await FirebaseMessaging.instance.getToken())!;
    if (token.isNotEmpty) {
      preferencesService.device_token = token;
      String userid = preferencesService.userId;
      await apiService.saveUserDeviceToken(userid, token);
    }
  }

  Future checkRefId() async {
    //  String referenceId = preferencesService.RefId;
    String referenceId = await preferencesService.getRefId('refid');
    if (referenceId != "") {
      //await connectyCubeServices.loginToCC(user, saveUser: true);
      await apiService.checkRefId(preferencesService.userId, referenceId);
      await preferencesService.setRefId('refid', '');
    }
    await apiService.getalertmessageslist();
  }

  //
  // Refresh members list
  Future refreshMembersList() async {
    String userId = preferencesService.userId;
    await apiService.getUserMembersList(userId);
  }
}

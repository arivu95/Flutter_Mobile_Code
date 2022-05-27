import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:swarapp/services/connectycube_services.dart';

class SplashViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  //final CallManager callManager = locator<CallManager>();

  Future<bool> checkUserLoggedIn() async {
    return Future.delayed(const Duration(seconds: 0), () async {
      bool isLoggedIn = await preferencesService.isUserLoggedIn();
      // print("-----------00000-----"+preferencesService.isbgCall.toString());
      return isLoggedIn;
    });
  }

  Future<bool> checkUserExist() async {
    await apiService.getalertmessageslist();
    String oid = await preferencesService.getUserInfo('userkey');
    if (oid.length > 0) {
      final response = await apiService.checkUserExist(oid);
      return response;
    }

    return false;
  }

  Future loginToCC() async {
    String ccToken = preferencesService.userInfo['connectycube_token'];

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
      preferencesService.userInfo['connectycube_id'] = useragain.id;
      // await apiService.updateConnectyCubeAvatat(useragain);
    }
    // if(locator<PreferencesService>().isbgCall==false){
    //   await refreshMembersList()
    // }
    // callManager.init(BuildContext context);
    // callManager.init()

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
  }
}

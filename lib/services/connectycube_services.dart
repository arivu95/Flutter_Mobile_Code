import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/api_utils.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/frideos/streamed_list.dart';
import 'package:swarapp/services/pushnotification_service.dart';

class ConnectyCubeServices {
  bool _isLoginContinues = false;
  static const String TAG = "_LoginPageState";

  // List<CubeDialog> cubeDialogs = [];

  StreamedList<CubeDialog> cubeDialogs = StreamedList<CubeDialog>(initialData: []);

  ConnectyCubeServices() {
    // ConnectyCubeServices
  }
  Future loginToCC(CubeUser user, {bool saveUser = false}) async {
    print("_loginToCC user: $user");
    // if (_isLoginContinues) return;
    _isLoginContinues = true;

    try {
      CubeSession cubeSession = await createSession(user);
      var cuser = cubeSession.user!..password = cubeSession.token;
      // SharedPrefs prefs = await SharedPrefs.init();
      await SharedPrefs.saveNewUser(cuser);
      locator<PushNotificationService>().init();
      _loginToCubeChat(cuser);
    } catch (e) {
      _processLoginError(e);
    }
  }

  _loginToCubeChat(CubeUser user) {
    print("_loginToCubeChat user $user");
    CubeChatConnectionSettings.instance.totalReconnections = 5;
    CubeChatConnection.instance.login(user).then((cubeUser) {
      _isLoginContinues = false;
      // _goDialogScreen(context, cubeUser);
      //locator<PushNotificationService>().init();
      getCubeDialogs();
    }).catchError((error) {
      _processLoginError(error);
    });
  }

  Future getCubeDialogs() async {
    getDialogs().then((dialogs) {
      // _isDialogContinues = false;
      log("getDialogs: $dialogs", TAG);
      //
      if (dialogs?.items != null && dialogs!.items.isNotEmpty) {
        cubeDialogs.value = dialogs.items;
      }
    }).catchError((exception) {
      _processGetDialogError(exception);
      print(exception);
    });
  }

  void _processGetDialogError(exception) {
    //locator<DialogService>().showDialog(title: "Error", description: exception.toString());
  }

  void _processLoginError(exception) {
    log("Login error $exception", TAG);
    _isLoginContinues = false;
    //showDialogError(exception, context);
  }

  Future logoutCurrentUser() async {
    try {
      cubeDialogs.clear();
      CubeChatConnection.instance.destroy();
      SharedPrefs.deleteUserData();
    } catch (e) {
      print(e.toString());
    }
  }
}

import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/iap_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/app/configs.dart' as config;
import 'calltest_model.dart';

class CallTest extends StatefulWidget {
  const CallTest({Key? key}) : super(key: key);

  @override
  _callTestState createState() => _callTestState();
}

class _callTestState extends State<CallTest> with WidgetsBindingObserver {
  late StreamSubscription<ConnectivityResult> connectivityStateSubscription;
  AppLifecycleState? appState;
  final CallManager callManager = locator<CallManager>();
  final IapService iapService = locator<IapService>();
  PreferencesService preferencesService = locator<PreferencesService>();
  @override
  void initState() {
    super.initState();
    init(config.APP_ID, config.AUTH_KEY, config.AUTH_SECRET, onSessionRestore: () async {
      CubeUser? user = await SharedPrefs.getUser();
      return createSession(user);
    });

    connectivityStateSubscription = Connectivity().onConnectivityChanged.listen((connectivityType) {
      if (AppLifecycleState.resumed != appState) return;

      if (connectivityType != ConnectivityResult.none) {
        log("chatConnectionState = ${CubeChatConnection.instance.chatConnectionState}");
        bool isChatDisconnected = CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.Closed || CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.ForceClosed;

        if (isChatDisconnected && CubeChatConnection.instance.currentUser != null) {
          CubeChatConnection.instance.relogin();
        }
      }
    });

    appState = WidgetsBinding.instance!.lifecycleState;
    WidgetsBinding.instance!.addObserver(this);
    // enabling the inapp purchase
    iapService.initConnection();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
   locator<PreferencesService>().appCycleState!.value = state;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CalltestModel>.reactive(
        onModelReady: (modal) async {
          await modal.checkRefId();
          await modal.loginToCC();
          callManager.init(context);
          },
        builder: (context, model, child) {
          return Scaffold(
              body: Container(
            child: Center(
              child: UIHelper.swarPreloader(),
            ),
          )
      );
        },
        viewModelBuilder: () => CalltestModel());
  }
}

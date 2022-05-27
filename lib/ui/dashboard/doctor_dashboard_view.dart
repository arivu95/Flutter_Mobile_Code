import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/dynamic_link_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/services/pushnotification_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/keep_alive_page.dart';
import 'package:swarapp/ui/communication/doctor_chat_list_view.dart';
import 'package:swarapp/ui/dashboard/dashboard_viewmodel.dart';
import 'package:swarapp/ui/dashboard/doctor_dashboard_model.dart';
import 'package:swarapp/ui/more/more_view.dart';
import 'package:swarapp/app/configs.dart' as config;
import 'package:doctor_module/src/ui/doc_appoinment/doctor_appoinment.view.dart';
import 'package:doctor_module/src/ui/doc_onboarding/landing_page_view.dart';
import 'package:doctor_module/src/ui/patient/patients_view.dart';
import 'package:doctor_module/src/ui/doc_onboarding/clinic_manage_view.dart';
import 'package:doctor_module/src/ui/doc_availability/manage_availability_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_profile_stages_view.dart';
import 'package:doctor_module/src/ui/doc_more/doc_more_view.dart';

class DoctorDashboardView extends StatefulWidget {
  const DoctorDashboardView({Key? key}) : super(key: key);

  @override
  _DoctorDashboardViewState createState() => _DoctorDashboardViewState();
}

class _DoctorDashboardViewState extends State<DoctorDashboardView> with WidgetsBindingObserver {
  late StreamSubscription<ConnectivityResult> connectivityStateSubscription;
  AppLifecycleState? appState;
  final CallManager callManager = locator<CallManager>();
  DynamicLinkService dynamicLinkService = locator<DynamicLinkService>();
  GlobalKey bottomTab_globalKey = new GlobalKey(debugLabel: 'bottom_bar_index');
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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    locator<PreferencesService>().appCycleState!.value = state;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DoctorDashboardViewModel>.reactive(
        onModelReady: (modal) async {
          await modal.checkRefId();
          // modal.setIndex(0);
          // callManager.init(context);
          await SharedPrefs.getPrefs();
          await dynamicLinkService.handleDynamicLinks();
          bool isUserExist = await modal.checkUserExist();
          if (isUserExist) {
            callManager.init(context);
            await modal.loginToCC();
          } else {
            // navigationService.clearStackAndShow(RoutePaths.Start);
            // await locator<PreferencesService>().ShowSubscriptionPOPUP(context);
          }
        },
        builder: (context, model, child) {
          return Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              key: locator<PreferencesService>().bottomTab_globalKey,
              backgroundColor: subtleColor,
              selectedItemColor: activeColor,
              currentIndex: model.currentIndex,
              onTap: (value) {
                //appointment, patient, chat
                model.setIndex(value);
                locator<PreferencesService>().isReload.value = true;
              },
              selectedFontSize: 12,
              items: [
                BottomNavigationBarItem(icon: Icon(model.currentIndex == 0 ? Icons.home : Icons.home_outlined, color: activeColor), label: 'Home', backgroundColor: activeColor),
                BottomNavigationBarItem(icon: Icon(Icons.date_range_outlined == 1 ? Icons.date_range_outlined : Icons.date_range, color: activeColor), label: 'Appointment', backgroundColor: activeColor),
                BottomNavigationBarItem(icon: Icon(model.currentIndex == 2 ? Icons.people : Icons.people_outlined, color: activeColor), label: 'Patients', backgroundColor: activeColor),
                BottomNavigationBarItem(icon: Icon(model.currentIndex == 3 ? Icons.chat : Icons.chat_outlined, color: activeColor), label: 'Chats', backgroundColor: activeColor),
                BottomNavigationBarItem(icon: Icon(model.currentIndex == 4 ? Icons.more_horiz : Icons.more_horiz_outlined, color: activeColor), label: 'More', backgroundColor: activeColor),
              ],
            ),
            body: IndexedStack(
              index: model.currentIndex,
              children: [
                KeepAlivePage(child: ProviderLandingView()),
                KeepAlivePage(child: AppoinmentDetailView()),
                KeepAlivePage(child: PatientsView()),
                // KeepAlivePage(child: DocOnboardingClinicManageView()),
                KeepAlivePage(child: DocterChatListView()),
                KeepAlivePage(child: DoctorMoreView())
              ],
            ),
          );
        },
        viewModelBuilder: () => DoctorDashboardViewModel());
  }
}

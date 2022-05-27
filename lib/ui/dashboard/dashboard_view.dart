import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:documents_module/documents_module.dart';
import 'package:flutter/material.dart';
import 'package:member_module/member_module.dart';
import 'package:new_version/new_version.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/offers/offers_view.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/dynamic_link_service.dart';
import 'package:swarapp/services/iap_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/keep_alive_page.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:user_module/src/ui/bookings/bookings_view.dart';
import 'package:swarapp/ui/dashboard/dashboard_viewmodel.dart';
import 'package:swarapp/ui/more/more_view.dart';
import 'package:swarapp/app/configs.dart' as config;
import 'package:doctor_module/src/ui/doctor_profile/doctor_profile_stages_view.dart';
import 'package:doctor_module/src/ui/doc_onboarding/landing_page_view.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:user_module/user_module.dart';
//import 'package:bottom_sheet_bar/bottom_sheet_bar.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with WidgetsBindingObserver, RestorationMixin {
  late StreamSubscription<ConnectivityResult> connectivityStateSubscription;
  NavigationService navigationService = locator<NavigationService>();
  AppLifecycleState? appState;
  final CallManager callManager = locator<CallManager>();
  final IapService iapService = locator<IapService>();
  GlobalKey bottomTab_globalKey = new GlobalKey(debugLabel: 'bottom_bar_index');

  //bottom_navigation_key
  bool isLoading = true;
  DynamicLinkService dynamicLinkService = locator<DynamicLinkService>();
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
    // iapService.initConnection();
    checkForNewerVersion();
  }

  checkForNewerVersion() async {
    final newVersion = NewVersion(
      iOSId: 'com.kat.swarapp',
      androidId: 'com.kat.swarapp',
    );
    VersionStatus? status = await newVersion.getVersionStatus();
    if (status != null) {
      if (status.canUpdate) {
        newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          dialogTitle: 'SwarDoctor',
          dialogText: 'There\'s an update available. Please, update it so you have access to the latest features!',
          updateButtonText: 'UPDATE',
          dismissButtonText: 'IGNORE',
          dismissAction: () {
            Navigator.of(context).pop();
          },
        );
      } else {
        print('Dismissed');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // super.didChangeAppLifecycleState(state);
    // //setState(() {
    // locator<PreferencesService>().appCycleState!.value = state;
    // // print('========' + state.toString() + CubeChatConnection.instance.currentUser.toString());
    // //});
    super.didChangeAppLifecycleState(state);
    //setState(() {
    locator<PreferencesService>().appCycleState!.value = state;
    String s = preferencesService.appCycleState!.value.toString();
    // print('========' + state.toString() + CubeChatConnection.instance.currentUser.toString());
    //});
    if (s.toLowerCase().contains('applifecyclestate.resumed')) {
      String userId = preferencesService.userId;
      locator<ApiService>().getRecentFriends(userId, "60dae3e440f5032614a8d24b");
    }
  }

  Widget getViewForIndex(int index) {
    switch (index) {
      case 0:
        return KeepAlivePage(child: MembersView());
      case 1:
      // return KeepAlivePage(child: UploadsView());
      case 2:
        return KeepAlivePage(child: DownloadsView());
      case 3:
        return KeepAlivePage(child: MoreView());
      case 4:
        return KeepAlivePage(child: MoreView());
      default:
        return KeepAlivePage(child: MembersView());
    }
  }

  void showBottomSheet(String type) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        builder: (
          BuildContext context,
        ) {
          return Container(
            height: 190,
            child: ListView(
              children: [
                UIHelper.verticalSpaceSmall,
                ListTile(
                  onTap: () async {},
                  visualDensity: VisualDensity.compact,
                  //visualDensity: VisualDensity.standard,
                  // visualDensity:VisualDensity.comfortable,
                  title: Text('Preview'),
                ),
                ListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text('Camera'),
                ),
                UIHelper.hairLineWidget(),
                ListTile(),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
        onModelReady: (modal) async {
          await SharedPrefs.getPrefs();
          await dynamicLinkService.handleDynamicLinks();
          bool isUserExist = await modal.checkUserExist();
          if (isUserExist) {
            callManager.init(context);
            await modal.loginToCC();
          } else {
            navigationService.clearStackAndShow(RoutePaths.Start);
            // await locator<PreferencesService>().ShowSubscriptionPOPUP(context);
          }

          await modal.checkRefId();
        },
        builder: (context, model, child) {
          return Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              key: locator<PreferencesService>().bottomTab_globalKey,
              backgroundColor: subtleColor,
              selectedItemColor: activeColor,
              currentIndex: model.currentIndex,
              onTap: (value) async {
                //model.setIndex,
                preferencesService.current_index = value.toString();
                preferencesService.user_login = '';

                //booking,offers

                print('---------currentIndex---' + model.currentIndex.toString());
                model.setIndex(value);
                //print(model.currentIndex.toString());
                locator<PreferencesService>().isReload.value = true;

                print('---------currentIndex---' + model.currentIndex.toString());
              },
              selectedFontSize: 9,
              unselectedFontSize: 9,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
              items: [
                BottomNavigationBarItem(
                    icon: Icon(model.currentIndex == 0 ? Icons.home : Icons.home_outlined, color: activeColor
                        // size: 24,
                        ),
                    label: 'Home',
                    backgroundColor: activeColor),
                BottomNavigationBarItem(icon: Icon(model.currentIndex == 1 ? Icons.book_online : Icons.book_online_outlined, color: activeColor), label: 'Bookings', backgroundColor: activeColor),
                BottomNavigationBarItem(icon: Icon(model.currentIndex == 2 ? Icons.folder : Icons.folder_outlined, color: activeColor), label: 'Health Records', backgroundColor: activeColor),
                BottomNavigationBarItem(icon: Icon(model.currentIndex == 3 ? Icons.local_offer : Icons.local_offer_outlined, color: activeColor), label: 'Offers', backgroundColor: activeColor),
                BottomNavigationBarItem(icon: Icon(model.currentIndex == 4 ? Icons.more_horiz : Icons.more_horiz_outlined, color: activeColor), label: 'More', backgroundColor: activeColor),
              ],
            ),
            body: IndexedStack(
              index: model.currentIndex,
              children: [
                KeepAlivePage(child: MembersView()),
                KeepAlivePage(child: PatientAppointmentsView()),
                KeepAlivePage(child: ProfileView()),
                // KeepAlivePage(child: OffersView()),
                KeepAlivePage(
                  child: GestureDetector(
                    onTap: () {
                      showBottomSheet('type');
                    },
                    //child: OffersView(),
                  ),
                ),

                // KeepAlivePage(
                //   child: ElevatedButton(
                //       child: Text('Show Modal Bottom Sheet'),
                //       onPressed: () {
                //         showModalBottomSheet(
                //           context: context,
                //           builder: (context) {
                //             return Wrap(
                //               children: [
                //                 ListTile(
                //                   leading: Icon(Icons.share),
                //                   title: Text('Share'),
                //                 ),
                //                 ListTile(
                //                   leading: Icon(Icons.copy),
                //                   title: Text('Copy Link'),
                //                 ),
                //                 ListTile(
                //                   leading: Icon(Icons.edit),
                //                   title: Text('Edit'),
                //                 ),
                //               ],
                //             );
                //           },
                //         );
                //       }),
                // KeepAlivePage(
                //   child: Gesetu(
                //     child: const Text('showModalBottomSheet'),
                //     onPressed: () {
                //       showModalBottomSheet<void>(
                //         context: context,
                //         builder: (BuildContext context) {
                //           return Container(
                //             height: 200,
                //             color: Colors.amber,
                //             child: Center(
                //               child: Column(
                //                 mainAxisAlignment: MainAxisAlignment.center,
                //                 mainAxisSize: MainAxisSize.min,
                //                 children: <Widget>[
                //                   const Text('Modal BottomSheet'),
                //                   ElevatedButton(
                //                     child: const Text('Close BottomSheet'),
                //                     onPressed: () => Navigator.pop(context),
                //                   )
                //                 ],
                //               ),
                //             ),
                //           );
                //         },
                //       );
                //     },
                //   ),
                // ),
                // KeepAlivePage(child: MoreView()),
                //)
              ],
            ),
          );
        },
        viewModelBuilder: () => DashboardViewModel());
  }

  @override
  // TODO: implement restorationId
  String? get restorationId => 'dashboard_view';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // TODO: implement restoreState
    print('RESTORATION ->> dashboard_view');
  }
}

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/iap_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/subscription/subscribed_view.dart';
import 'package:swarapp/ui/subscription/subscription_view.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:member_module/src/ui/members/notification_view.dart';
import 'package:user_module/user_module.dart';

class SwarProfileAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SwarProfileAppBar({Key? key}) : super(key: key);
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(50);
  @override
  _SwarProfileAppBarState createState() => _SwarProfileAppBarState();
}

class _SwarProfileAppBarState extends State<SwarProfileAppBar> {
  String currenScreen = "";
  bool is_notification = false;
  void initState() {
    String currentScreen = Get.currentRoute.toString();
    if (currentScreen.toLowerCase().contains('notificationview')) {
      setState(() {
        is_notification = true;
      });
    }
  }

  void _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling

    // Navigator.pop on the Selection Screen.

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationView()),
    );
    preferencesService.isNotification.value = false;
    setState(() {});
    // List<dynamic> not = preferencesService.notificationListStream!.value!;
    //user  post['login_role_id'] = "6128a673b71d012678336f4d";
    final response = await locator<ApiService>().setNotifications(preferencesService.userId, "6128a673b71d012678336f4d");
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 120, // Set this height
      elevation: 0,
      leadingWidth: 0,

      bottomOpacity: 0,
      titleSpacing: 10,
      backgroundColor: subtleColor,
      title: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () async {
                  // await navigationService.clearStackAndShow(RoutePaths.Dashboard);
                  currenScreen = Get.currentRoute.toString();
                  print("*********************" + currenScreen + "****************");
                  if (currenScreen != null || currenScreen.isNotEmpty) {
                    Get.back();
                    if (Get.currentRoute.toString() != null || Get.currentRoute.toString().isNotEmpty) {
                      Get.back();
                    }
                    final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                    navigationBar.onTap!(0);
                  }
                },
                child: Text('SWAR').bold().textColor(activeColor).fontSize(19).bold()),
            UIHelper.horizontalSpaceTiny,
            StreamBuilder(
              builder: (context, snasphot) {
                return GestureDetector(
                    onTap: () {
                      if (locator<IapService>().pastPurchases.length == 0) {
                        Get.to(() => SubscriptionView());
                      } else {
                        Get.to(() => SubscribedView());
                      }
                    },
                    child: Image.asset('assets/${locator<PreferencesService>().getCurrentSubscriptionPlanImage()}'));
              },
              stream: locator<PreferencesService>().subscriptionStream.outStream,
            ),
            Expanded(child: Container(padding: EdgeInsets.fromLTRB(0, 5, 0, 5))),
            SizedBox(
              height: 50,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: StreamBuilder<String?>(
                  stream: locator<PreferencesService>().notificationStreamCount.outStream,
                  builder: (context, snapshot) => !snapshot.hasData || snapshot.data == '' || snapshot.data == '0'
                      ?

                      // GestureDetector(
                      //     onTap: () {
                      //       _navigateAndDisplaySelection(context);
                      //     },
                      //     child: Icon(is_notification ? Icons.notifications : Icons.notifications_outlined, size: 32, color: activeColor))
                      // : GestureDetector(
                      //     onTap: () {
                      //       _navigateAndDisplaySelection(context);
                      //     },
                      //     child: Badge(
                      //       elevation: 2,
                      //       badgeColor: activeColor,
                      //       //showBadge: preferencesService.notificationCount != "0" ? true : false,
                      //       badgeContent: Text(
                      //         '',
                      //         style: TextStyle(color: Colors.white, fontSize: 12.0),
                      //       ),
                      //       padding: EdgeInsets.all(5),
                      //       child: Container(
                      //         child: Icon(is_notification ? Icons.notifications : Icons.notifications_outlined, size: 32, color: activeColor),
                      //       ),
                      //     ))),

                      Padding(
                          // padding: const EdgeInsets.only(right: 8.0, top: 2, bottom: 2),
                          padding: EdgeInsets.all(1),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            height: 40,
                            width: 45,
                            child: IconButton(
                              icon: Stack(children: <Widget>[
                                new Icon(preferencesService.isNotification.value == true ? Icons.notifications : Icons.notifications_none_outlined, color: activeColor, size: 30),
                                // new Positioned(
                                //   // draw a red marble
                                //   top: 0.0,
                                //   right: 0.0,
                                //   child: new Icon(Icons.brightness_1, size: 8.0, color: activeColor),
                                // )
                              ]),
                              onPressed: () {
                                preferencesService.isNotification.value = false;
                                _navigateAndDisplaySelection(context);
                              },
                            ),
                          ),
                        )
                      : Padding(
                          // padding: const EdgeInsets.only(right: 8.0, top: 2, bottom: 2),
                          padding: EdgeInsets.all(1),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            height: 40,
                            width: 45,
                            child: IconButton(
                              icon: Stack(children: <Widget>[
                                new Icon(preferencesService.isNotification.value == true ? Icons.notifications : Icons.notifications_none_outlined, color: activeColor, size: 30),
                                new Positioned(
                                  top: 0.0,
                                  right: 0.0,
                                  child: new Icon(Icons.brightness_1, size: 8.0, color: activeColor),
                                )
                              ]),
                              onPressed: () {
                                preferencesService.notificationStreamCount.value = "0";
                                preferencesService.isNotification.value = true;
                                _navigateAndDisplaySelection(context);
                              },
                            ),
                          ),
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

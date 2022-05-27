import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/app/consts.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/iap_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:swarapp/ui/subscription/subscribed_view.dart';
import 'package:swarapp/ui/subscription/subscription_view.dart';
import 'package:user_module/src/ui/user_profile/profile_view.dart';
import 'package:member_module/src/ui/members/notification_view.dart';

class SwarAppStaticBar extends StatefulWidget implements PreferredSizeWidget {
  const SwarAppStaticBar({Key? key}) : super(key: key);
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(50);

  @override
  _SwarAppStaticBarState createState() => _SwarAppStaticBarState();
}

class _SwarAppStaticBarState extends State<SwarAppStaticBar> {
  bool is_notification = false;
  String currenScreen = "";
  final GlobalKey _one = GlobalKey();
  List getAlertmessage = [];
  String toolbar = '';
  BuildContext? myContext;
  void initState() {
    super.initState();

    String currentScreen = Get.currentRoute.toString();
    if (currentScreen.toLowerCase().contains('notificationview')) {
      setState(() {
        is_notification = true;
      });
    }
    locator<ApiService>().getNotifications(preferencesService.userId, '6128a673b71d012678336f4d');
    getAlertmessage = preferencesService.alertContentList!.where((msg) => msg['type'] == "Subscription_tooltip").toList();
    toolbar = getAlertmessage[0]['content'];
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
    //  List<dynamic> not = preferencesService.notificationListStream!.value!;

    final response = await locator<ApiService>().setNotifications(preferencesService.userId, "6128a673b71d012678336f4d");
  }

//NotificationView
  @override
  Widget build(BuildContext context) {
    print(preferencesService.dropdown_user_name);
    return SafeArea(
        child: AppBar(
            //title: Text(preferencesService.userInfo['name'], textAlign: TextAlign.center),
            title: StreamBuilder<String?>(
                stream: locator<PreferencesService>().userName.outStream,
                builder: (context, snapshotname) => !snapshotname.hasData || snapshotname.data == ''
                    ? Text(preferencesService.userInfo['name'] != null ? preferencesService.userInfo['name'] : '', textAlign: TextAlign.center).bold().textColor(Colors.black)
                    : Text(snapshotname.data!, textAlign: TextAlign.center).bold().textColor(Colors.black)),
            actions: <Widget>[
              StreamBuilder<String?>(
                stream: locator<PreferencesService>().notificationStreamCount.outStream,
                builder: (context, snapshot) => preferencesService.notificationStreamCount.value == "0"
                    ? Padding(
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
                            ]),
                            onPressed: () {
                              preferencesService.isNotification.value = false;
                              _navigateAndDisplaySelection(context);
                            },
                          ),
                        ),
                      )
                    : Padding(
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
              GestureDetector(
                onTap: () async {
                  // final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                  // navigationBar.onTap!(2);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                  navigationBar.onTap!(2);
                  // await Get.to(() => ProfileView());
                  preferencesService.user_login = '';
                  // setState(() {});
                  // locator<ApiService>().getProfile(preferencesService.userId);
                },
                child: StreamBuilder<String?>(
                  stream: locator<PreferencesService>().profileUrl.outStream,
                  builder: (context, snapshot) => !snapshot.hasData || snapshot.data == ''
                      ? Container(
                          child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                          width: 40,
                          height: 40,
                        )
                      : Container(
                          padding: EdgeInsets.all(5),
                          // decoration: UIHelper.roundedBorderWithColor(4, greyColor),
                          child: ClipRRect(borderRadius: BorderRadius.circular(80.0), child: UIHelper.getImage(snapshot.data!, 40, 40)),
                        ),
                ),
              ),
              UIHelper.horizontalSpaceSmall
            ], //<Widget>[]
            backgroundColor: subtleColor,
            centerTitle: true,
            automaticallyImplyLeading: false,
            bottomOpacity: 0.0,
            elevation: 0.0,
            leadingWidth: 110,
            leading: Container(
              //decoration: UIHelper.roundedBorderWithColor(4, greyColor),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                UIHelper.horizontalSpaceSmall,
                GestureDetector(
                    onTap: () async {
                      // await navigationService.clearStackAndShow(RoutePaths.Dashboard);
                      // currenScreen = Get.currentRoute.toString();
                      // print("*********************" + currenScreen + "****************");
                      // if (currenScreen != null || currenScreen.isNotEmpty) {
                      //   Get.back();
                      //   if (Get.currentRoute.toString() != null || Get.currentRoute.toString().isNotEmpty) {
                      //     Get.back();
                      //   }
                      //   final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                      //   navigationBar.onTap!(0);
                      // }
                      Navigator.of(context).popUntil((route) => route.isFirst);

                      final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                      navigationBar.onTap!(0);

                      //Navigator.of(context).popUntil((route) => route.popped())
                      //locator<NavigationService>().clearTillFirstAndShow(RoutePaths.Dashboard);
                      // Navigator.of(context).popUntil(ModalRoute.withName(RoutePaths.Dashboard));
                    },
                    child: Text('SWAR').bold().textColor(activeColor).fontSize(19).bold()),
                UIHelper.horizontalSpaceTiny,
                //  preferencesService.isSubscriptionMarkedInSwar() == false && preferencesService.user_login != '' && preferencesService.current_index == '0'
                GestureDetector(
                    onTap: () {
                      if (preferencesService.isSubscriptionMarkedInSwar() == false) {
                        Get.to(() => SubscriptionView());
                      } else {
                        Get.to(() => SubscribedView());
                      }
                    },
                    child: Image.asset('assets/${locator<PreferencesService>().getCurrentSubscriptionPlanImage()}', width: 30.0, height: 29.0))
              ]),
            )));

    //MaterialApp
  }
}

class SwarStaticBar extends StatefulWidget implements PreferredSizeWidget {
  const SwarStaticBar({Key? key}) : super(key: key);
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(50);
  @override
  _SwarStaticBarState createState() => _SwarStaticBarState();
}

class _SwarStaticBarState extends State<SwarStaticBar> {
  @override
  Widget build(BuildContext context) {
    print(preferencesService.dropdown_user_name);
    return AppBar(
      elevation: 0,
      leadingWidth: 5,
      leading: Container(
        color: subtleColor,
        width: 30,
        height: 30,
      ),
      bottomOpacity: 0,
      backgroundColor: subtleColor,
      title: Container(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text('SWAR').bold().textColor(activeColor)],
        ),
      ),
    );
  }
}

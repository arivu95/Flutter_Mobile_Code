import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import 'package:swarapp/ui/dashboard/doctor_dashboard_view.dart';
import 'package:swarapp/ui/dashboard/doctor_dashboard_view.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:swarapp/ui/subscription/subscribed_view.dart';
import 'package:swarapp/ui/subscription/subscription_view.dart';
import 'package:user_module/src/ui/user_profile/profile_view.dart';
import 'package:member_module/src/ui/members/notification_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_profile_view.dart';
import 'package:doctor_module/src/ui/doc_onboarding/doctor_notification_view.dart';

class SwarAppDoctorBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isProfileBar;
  const SwarAppDoctorBar({Key? key, required this.isProfileBar}) : super(key: key);
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(50);

  @override
  _SwarAppDoctorBarState createState() => _SwarAppDoctorBarState();
}

class _SwarAppDoctorBarState extends State<SwarAppDoctorBar> {
  bool is_notification = false;
  String currenScreen = "";
  void initState() {
    String currentScreen = Get.currentRoute.toString();
    if (currentScreen.toLowerCase().contains('notificationview')) {
      setState(() {
        is_notification = true;
      });
    }
    locator<ApiService>().getNotifications(preferencesService.userId, '61e7a9e44c559c1530e0e562');
  }

  void _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    preferencesService.notificationStreamCount.value = "0";
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DoctorNotificationView()),
    );
    List<dynamic> not = preferencesService.notificationListStream!.value!;
    //doctor role id "61e7a9e44c559c1530e0e562";
    //final response = await locator<ApiService>().setNotifications(preferencesService.userId, "61e7a9e44c559c1530e0e562");
  }

//NotificationView
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: AppBar(
            //title: Text(preferencesService.userInfo['name'], textAlign: TextAlign.center),
            title:StreamBuilder<String?>(
                    stream: locator<PreferencesService>().userName.outStream,
                    builder: (context, snapshotname) => !snapshotname.hasData || snapshotname.data == ''
                        ?  preferencesService.login_roleId == '61e7a9e44c559c1530e0e562'
                        ?Text('Dr.\u{00A0}'+ preferencesService.userInfo['name'], textAlign: TextAlign.center).bold().textColor(Colors.black)
                        :Text( preferencesService.userInfo['name'], textAlign: TextAlign.center).bold().textColor(Colors.black)
                      : Text( preferencesService.login_roleId == '61e7a9e44c559c1530e0e562' ?'Dr.\u{00A0}' :''
                        + snapshotname.data!, textAlign: TextAlign.center).bold().textColor(Colors.black)),
            actions: <Widget>[
              StreamBuilder<String?>(
                stream: locator<PreferencesService>().notificationStreamCount.outStream,
                //builder: (context, snapshot) => !snapshot.hasData || snapshot.data == '' || snapshot.data == '0'
                builder: (context, snapshot) => preferencesService.notificationStreamCount.value == "0"
                    // ? GestureDetector(
                    //     onTap: () {
                    //       _navigateAndDisplaySelection(context);
                    //     },
                    //     child: Icon(is_notification ? Icons.notifications : Icons.notifications_outlined, size: 32, color: activeColor))
                    // : GestureDetector(
                    //     onTap: () {
                    //       _navigateAndDisplaySelection(context);
                    //     },
                    //     child: Container(
                    //         child: Badge(
                    //       elevation: 10,
                    //       badgeColor: activeColor,
                    //       //showBadge: preferencesService.notificationCount != "0" ? true : false,
                    //       badgeContent: Text(
                    //         '',
                    //         style: TextStyle(color: Colors.white, fontSize: 8.0),
                    //       ),
                    //       padding: EdgeInsets.all(9),

                    //       child: Icon(is_notification ? Icons.notifications : Icons.notifications_outlined, size: 30, color: activeColor),
                    //     )))

                    ? Padding(
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
                              new Icon(is_notification ? Icons.notifications : Icons.notifications_none_outlined, color: activeColor, size: 30),
                              // new Positioned(
                              //   // draw a red marble
                              //   top: 0.0,
                              //   right: 0.0,
                              //   child: new Icon(Icons.brightness_1, size: 8.0, color: activeColor),
                              // )
                            ]),
                            onPressed: () {
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
                              new Icon(is_notification ? Icons.notifications : Icons.notifications_none_outlined, color: activeColor, size: 30),
                              //badge icon
                              // new Positioned(
                              //   top: 0.0,
                              //   right: 0.0,
                              //   child: new Icon(Icons.brightness_1, size: 8.0, color: activeColor),
                              // )
                            ]),
                            onPressed: () {
                              _navigateAndDisplaySelection(context);
                            },
                          ),
                        ),
                      ),
              ),
              !widget.isProfileBar
                  ? GestureDetector(
                      onTap: () async {
                        await Get.to(() => DoctorProfileView());
                        setState(() {});
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
                    )
                  : Container(),
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
                      currenScreen = Get.currentRoute.toString();
                           if(currenScreen == "/DoctorProfileStagesView"){
                       await navigationService.clearStackAndShow(RoutePaths.DoctorDashboard);
                     }  else  if (currenScreen != null || currenScreen.isNotEmpty) {
                          await navigationService.clearStackAndShow(RoutePaths.DoctorDashboard);
                         if (Get.currentRoute.toString() != null || Get.currentRoute.toString().isNotEmpty) {
                                await navigationService.clearStackAndShow(RoutePaths.DoctorDashboard);
                        }                  
                        else{
                        final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                        navigationBar.onTap!(0);
                        }
                      }

                    },
                    child: Text('SWAR').bold().textColor(activeColor).fontSize(19).bold()),
              ]),
            )
            //brightness: Brightness.dark,
            ));
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

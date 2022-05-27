import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:member_module/src/ui/members/edit_member_view.dart';
import 'package:member_module/src/ui/members/notification_model.dart';
import 'package:member_module/src/ui/members/view_member_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/app/locator.dart';

class NotificationView extends StatefulWidget {
  NotificationView({Key? key}) : super(key: key);

  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  late MembersViewmodel model;
  PreferencesService preferencesService = locator<PreferencesService>();
  List getAlertmessage_accept = [];
  List getAlertmessage_decline = [];
//getNotifications
  void initState() {
    // TODO: implement initState
    super.initState();
    getAlertmessage_accept = preferencesService.alertContentList!.where((msg) => msg['type'] == "Chat_invite_accept").toList();
    getAlertmessage_decline = preferencesService.alertContentList!.where((msg) => msg['type'] == "Chat_invite_declined").toList();
  }

  Future<void> removeConfirm(MembersViewmodel model, dynamic delinfo) async {
    String memberId = delinfo['id'];
    String name = delinfo['member_first_name'];
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete'),
            content: Text('Do you want to Delete $name Details ?'),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  Get.back(result: {'refresh': true});

                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () async {
                  Navigator.pop(context);
                  final response = await model.deletemember(memberId);
                  //locator<PreferencesService>().isReload.value = true;
                  if (response) {
                    model.isBusy ? Loader.show(context) : Loader.hide();
                    //  locator<PreferencesService>().isReload.value = true;
                    // locator<PreferencesService>().isReload.value = true;
                    // locator<PreferencesService>().isUploadReload.value = true;
                    // locator<PreferencesService>().isDownloadReload.value = true;
                    //  preferencesService.onRefreshRecentDocument!.value = true;
                    //   preferencesService.onRefreshRecentDocumentOnDownload!.value = true;
                    //    preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
                    // setState(() async {

                    Get.back(result: {'refresh': true});
                    // await  Get.to(() => MembersView());
                    // });
                  }
                },
              ),
            ],
          );
        });
  }

  Widget additionalInfoWidget(BuildContext context, String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: activeColor,
        ),
        UIHelper.horizontalSpaceSmall,
        SizedBox(
          child: Text(title).fontSize(13),
          width: Screen.width(context) / 2.5,
        ),
        Flexible(
          child: Text(value).fontSize(13),
        )
      ],
    );
  }

  void check_accept(BuildContext context, Notificationmodel model, String id, String refId, int index) async {
    Loader.show(context);
    bool getRes = await model.acceptinvite(id, refId, "accepted");
    if (getRes) {
      Loader.hide();
      model.notificationInfo.removeAt(index);
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              title: "Accepted !",
              descriptions: getAlertmessage_accept[0]['content'],
              descriptions1: "",
              text: "OK",
            );
          });
      setState(() {});
    }
  }

  void check_doctor_accept(BuildContext context, Notificationmodel model, String id, String refId, int index) async {
    Loader.show(context);
    bool getRes = await model.docacceptinvite(id, refId, "accepted");
    if (getRes) {
      Loader.hide();
      model.notificationInfo.removeAt(index);
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              title: "Accepted !",
              descriptions: getAlertmessage_accept[0]['content'],
              descriptions1: "",
              text: "OK",
            );
          });
      setState(() {});
    }
  }

  Widget notificationList(dynamic notifInfo, Notificationmodel model, int index) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 8),
      //  decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.black12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // img_url == '' || img_url.contains('null')
              //     ?
              Container(
                // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                // child: Icon(Icons.portrait),
                child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                width: 43,
                height: 43,
              ),
              //: ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(img_url, 43, 43)),
              UIHelper.horizontalSpaceSmall,
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Text(memberinfo['name'] ?? '').fontSize(15).fontWeight(FontWeight.w500),
                  Text(notifInfo['name']).fontSize(15).fontWeight(FontWeight.w500),
                  UIHelper.verticalSpaceTiny,
                  Text(notifInfo['notification_content']).fontSize(13),
                  // UIHelper.verticalSpaceMedium,
                ],
              )),
            ],
          ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 48,
              ),
              ElevatedButton(
                  onPressed: () async {
                    // Get.back(result: {'refresh': true});
                    await model.declineinvite(notifInfo["_id"], notifInfo["reference_id"], "declined");
                    // model.listmembers.removeAt(index);
                    model.notificationInfo.removeAt(index);
                    setState(() {});
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialogBox(
                            title: "Declined !",
                            descriptions: getAlertmessage_decline[0]['content'],
                            descriptions1: "",
                            text: "OK",
                          );
                        });
                    locator<PreferencesService>().isReload.value = true;
                  },
                  child: Text('Decline').textColor(Colors.white),
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(70, 28)),
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor: MaterialStateProperty.all(activeColor),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
              UIHelper.horizontalSpaceMedium,
              ElevatedButton(
                  onPressed: () async {
                    if (preferencesService.login_roleId == '6128a673b71d012678336f4d') {
                      check_accept(context, model, notifInfo["_id"], notifInfo["reference_id"], index);
                      await model.getRecentFriends();
                    } else {
                      check_doctor_accept(context, model, notifInfo["_id"], notifInfo["reference_id"], index);
                      await model.getRecentFriends();
                    }
                  },
                  child: Text('Accept').textColor(Colors.white),
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(90, 28)),
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
            ],
          ),
          UIHelper.hairLineWidget()
        ],
      ),
    );
  }

  Widget vaccinationReminder(dynamic notifInfo) {
    dynamic userNotificationInfo = notifInfo['user_Id'];
    String userProfileUrl = "";
    if (userNotificationInfo['azureBlobStorageLink'] != null && userNotificationInfo['azureBlobStorageLink'] != "") {
      String imgurl = userNotificationInfo['azureBlobStorageLink'].toString();

      userProfileUrl = '${ApiService.fileStorageEndPoint}$imgurl';
    }
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 12),
      //  decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.black12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userProfileUrl == ''
                  ? Container(
                      child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                      width: 43,
                      height: 43,
                    )
                  : ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(userProfileUrl, 43, 43)),
              UIHelper.horizontalSpaceSmall,
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userNotificationInfo['name']).fontSize(15).fontWeight(FontWeight.w500),
                  UIHelper.verticalSpaceTiny,
                  Text(notifInfo['notification_content']).fontSize(13),
                  UIHelper.verticalSpaceMedium,
                ],
              )),
            ],
          ),
          UIHelper.hairLineWidget()
        ],
      ),
    );
  }

  setViewedState() {}
  Widget list_of_Notif(BuildContext context, Notificationmodel model) {
    return Expanded(
        child: Container(
      padding: EdgeInsets.all(2),
      width: Screen.width(context),
      // decoration: UIHelper.roundedBorderWithColorWithShadow(6, fieldBgColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(widget.commentinfo['profilestatus']).fontWeight(FontWeight.w500).padding(all: 6),
          UIHelper.verticalSpaceSmall,
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: model.isBusy
                ? UIHelper.swarPreloader()
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: model.reminderDates.length,
                    itemBuilder: (context, index) {
                      String dateStr = model.reminderDates![index];
                      List notifInfoList = model.reminderSections[dateStr]!;
                      Jiffy j = Jiffy();
                      String dateSection = '';
                      DateTime checkedTime = DateTime.parse(dateStr);
                      DateTime currentTime = DateTime.now();

                      if ((currentTime.year == checkedTime.year) && (currentTime.month == checkedTime.month) && (currentTime.day == checkedTime.day)) {
                        // return "TODAY";
                        dateSection = "Today";
                      } else if ((currentTime.year == checkedTime.year) && (currentTime.month == checkedTime.month)) {
                        if ((currentTime.day - checkedTime.day) == 1) {
                          //return "YESTERDAY";
                          dateSection = "Yesterday";
                        } else if ((currentTime.day - checkedTime.day) == -1) {
                          //return "TOMORROW";
                          dateSection = "Tomorrow";
                        } else {
                          Jiffy upDt = Jiffy(dateStr);
                          dateSection = upDt.format('dd MMM yyyy').toString();
                          // return dateString;
                        }
                      }
                      return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                              child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                dateSection,
                                textAlign: TextAlign.left,
                              ).fontSize(15).fontWeight(FontWeight.w600).textColor(Colors.grey),
                              ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: notifInfoList.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    dynamic notifInfo = notifInfoList[index];
                                    return
                                        //if type invite
                                        notifInfo['notification_type'] == 'invite'
                                            ? notificationList(notifInfo, model, index)
                                            //if type vaccination reminders
                                            : vaccinationReminder(notifInfo);
                                  })
                            ]),
                          )));
                    },
                  ),
          ))
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: SwarAppBar(2),
      appBar: SwarAppStaticBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 0),
            width: Screen.width(context),
            child: ViewModelBuilder<Notificationmodel>.reactive(
                onModelReady: (model) async {
                  await model.getNotification();
                  //model.getMemberProfile(widget.memberId);
                },
                builder: (context, model, child) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    UIHelper.verticalSpaceSmall,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: UIHelper.addHeader(context, "Notification", true),
                    ),
                    UIHelper.verticalSpaceSmall,
                    UIHelper.verticalSpaceSmall,
                    list_of_Notif(context, model),
                  ]);
                },
                viewModelBuilder: () => Notificationmodel())),
      ),
    );
  }
}

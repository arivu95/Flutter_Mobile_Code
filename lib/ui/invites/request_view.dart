import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:share/share.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/connectycube_services.dart';
import 'package:swarapp/services/dynamic_link_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/timeago.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/communication/chat_dialog_screen.dart';
import 'package:swarapp/ui/communication/search_user_cc.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart';
import 'package:swarapp/ui/invites/contact_view.dart';
import 'package:swarapp/ui/invites/find_friendsList_view.dart';
import 'package:swarapp/ui/invites/requestView_model.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class RequestView extends StatefulWidget {
  RequestView({Key? key}) : super(key: key);

  @override
  _RequestViewState createState() => _RequestViewState();
}

class _RequestViewState extends State<RequestView> {
  late CubeUser currentUser;
  TextEditingController searchController = TextEditingController();
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  ApiService apiService = locator<ApiService>();
  bool isReadOnly = false;
  bool isExist = false;
  var screenSize;
  bool isInviteSearch = false;
  AppLifecycleState? appState;
  @override
  void initState() {
    super.initState();
    isExist = false;

    // bool isChatDisconnected = CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.Closed || CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.ForceClosed;
    // if (isChatDisconnected && CubeChatConnection.instance.currentUser != null) {
    //   CubeChatConnection.instance.relogin();
    // }
  }

  void navigateToSearchCCUser(bool isNew) async {
    dynamic newDialog = await Get.to(
      () => SearchUserFromCC(
        currentUser: currentUser,
        isGroup: false,
        isNew: isNew,
      ),
    );
  }

  Widget showSearchField(BuildContext context, RequestViewmodel model) {
    return SizedBox(
      height: 38,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    // model.updateOnTextSearch(value);
                    model.getInvite_search(value);

                    setState(() {
                      isInviteSearch = true;
                    });
                  },
                  style: TextStyle(fontSize: 14),
                  decoration: new InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: activeColor,
                        size: 20,
                      ),
                      suffixIcon: searchController.text.isEmpty
                          ? SizedBox()
                          : IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.black38,
                              ),
                              onPressed: () {
                                searchController.clear();
                                model.getInvite_search('');
                                setState(() {
                                  isInviteSearch = true;
                                });
                                FocusManager.instance.primaryFocus!.unfocus();
                              }),
                      contentPadding: EdgeInsets.only(left: 20),
                      enabledBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0x00CCCCCC)),
                      focusedBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Colors.white),
                      focusedErrorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Colors.white),
                      errorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "Search....       ",
                      fillColor: fieldBgColor),
                ),
              ),
            ),
            UIHelper.horizontalSpaceSmall,
          ],
        ),
      ),
    );
  }

  void check_accept(BuildContext context, RequestViewmodel model, String id, String refId, int index) async {
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
              descriptions: "Invite Accepted. Please check friend list",
              descriptions1: "",
              text: "OK",
            );
          });
      setState(() {});
    }
  }

  Widget notificationList(dynamic notifInfo, RequestViewmodel model, int index) {
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
                  Text("has send friend request").fontSize(15).fontWeight(FontWeight.w200),
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
                    Get.back(result: {'refresh': false});
                    Loader.show(context);
                    await model.declineinvite(notifInfo["_id"], notifInfo["reference_id"], "declined");
                    Loader.hide();
                    // model.listmembers.removeAt(index);
                    model.notificationInfo.removeAt(index);
                    setState(() {});
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialogBox(
                            title: "Declined !",
                            descriptions: "Invite declined",
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
                    check_accept(context, model, notifInfo["_id"], notifInfo["reference_id"], index);
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

  void inviteFriends() async {
    Loader.show(context);
    String userId = locator<PreferencesService>().userId;
    String inviteType = 'friend_invite';
    final response = await apiService.getInviteMemberRefId(userId, inviteType);
    Loader.hide();
    if (response['msg'] != null) {
      String postMessage = response['msg'];
      if (response['Invitemember'] != null) {
        dynamic inviteMember = response['Invitemember'];
        String refId = inviteMember['reference_id'];
        String inviteLink = await locator<DynamicLinkService>().createMemberInviteLink(refId);
        await Share.share(postMessage + ' ' + inviteLink);
      }
    }
  }

  Widget onEmptyChatList(BuildContext context) {
    return ListView(
      children: [
        GestureDetector(
          onTap: () {
            navigateToSearchCCUser(true);
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  color: activeColor,
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              UIHelper.horizontalSpaceSmall,
              Text('New Chat').fontWeight(FontWeight.w600).fontSize(13)
            ],
          ),
        ),
        UIHelper.hairLineWidget(),
        GestureDetector(
          onTap: () {
            inviteFriends();
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  color: activeColor,
                  width: 36,
                  height: 36,
                  child: Image.asset(
                    'assets/invite_mail.png',
                    fit: BoxFit.none,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              UIHelper.horizontalSpaceSmall,
              Text('Invite Friends').fontWeight(FontWeight.w600).fontSize(13)
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    //ischatListReload

    return Scaffold(
        //appBar: SwarAppBar(2),
        appBar: SwarAppStaticBar(),
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: Screen.width(context),
              child: ViewModelBuilder<RequestViewmodel>.reactive(
                  onModelReady: (model) async {
                    await model.getNotification();
                    //model.getMemberProfile(widget.memberId);
                  },
                  builder: (context, model, child) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // UIHelper.verticalSpaceSmall,
                      UIHelper.addHeader(context, "Requests", true),
                      UIHelper.verticalSpaceSmall,
                      //  UIHelper.hairLineWidget(),
                      // UIHelper.verticalSpaceMedium,
                      showSearchField(context, model),
                      UIHelper.verticalSpaceSmall,
                      Expanded(
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
                            child: isInviteSearch && model.SearchByInfo.length == 0 || model.notificationInfo.length == 0
                                ? Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                    Center(
                                      child: Text('No Request found'),
                                    )
                                  ])
                                : Container(
                                    child: SingleChildScrollView(
                                    physics: ScrollPhysics(),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: isInviteSearch ? model.SearchByInfo.length : model.notificationInfo.length,
                                          physics: NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (context, index) {
                                            dynamic notifInfo = isInviteSearch ? model.SearchByInfo[index] : model.notificationInfo[index];
                                            return
                                                //if type invite
                                                // notif_Info['notification_type'] == 'invite'
                                                // ?
                                                notificationList(notifInfo, model, index);
                                            //if type vaccination reminders
                                          })
                                    ]),
                                  ))),
                      ),
                      UIHelper.verticalSpaceSmall,
                    ]);
                  },
                  viewModelBuilder: () => RequestViewmodel())),
        ));
  }
}

import 'package:badges/badges.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:member_module/src/ui/members/add_member_view.dart';
import 'package:member_module/src/ui/members/members_model.dart';
import 'package:member_module/src/ui/members/view_member_view.dart';
import 'package:member_module/src/ui/members/widgets/activity_feed_widget.dart';
import 'package:share/share.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/consts.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/frideos/extended_asyncwidgets.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/dynamic_link_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/communication/chat_dialog_screen.dart';
import 'package:swarapp/ui/communication/chat_list_view.dart';
import 'package:swarapp/ui/communication/chat_dialog_screen.dart';
import 'package:jiffy/jiffy.dart';
import 'package:user_module/src/ui/user_profile/profile_view.dart';
import 'package:doctor_module/src/ui/doc_online_booking/top_specalities_view.dart';
import 'edit_member_view.dart';
import 'feed_comment_view.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';
import 'package:swarapp/shared/custom_tooltip.dart';
import 'package:swarapp/ui/subscription/subscribed_view.dart';
import 'package:swarapp/ui/subscription/subscription_view.dart';
import 'package:member_module/src/ui/members/notification_view.dart';
import 'package:swarapp/ui/communication/doctor_chat_view.dart';

class MembersView extends StatefulWidget {
  const MembersView({Key? key}) : super(key: key);

  @override
  _MembersViewState createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> with RestorationMixin {
  TextEditingController searchController = TextEditingController();
  TextEditingController _textFieldController = TextEditingController();
  PreferencesService preferencesService = locator<PreferencesService>();
  Membersmodel modelRef = Membersmodel();
  late CustomDialogBox dialogRef;
  final TooltipController _controller = TooltipController();
  bool done = false;
  String selectedTab = "Family";
  int Tab_id = 0;
  int mem_Count = 0;
  bool isDeleteModeOn = false;
  String deleteid = '';
  bool isSearch = false;
  String txt = '';
  bool visibilityTag = false;
  bool isSelectionCategory = false;
  List<dynamic>? friends_stream;
  List<dynamic>? members_stream;
  List<dynamic>? doctors_Stream;
  List<String> getAlertmessage = [];
  String subscriptionTooltip = '';
  String lookingforTooltip = '';
  @override
  void initState() {
    //Tooltip
    // if (preferencesService.isSubscriptionMarkedInSwar() == false && preferencesService.user_login != '' && preferencesService.current_index == '0') {
    _controller.onDone(() {
      setState(() {
        done = true;
      });
    });
    // } else {
    //   _controller.dispose();
    //  }
    tooltipMessages();
    // TODO: implement initState
    super.initState();

    // setStatefinal BottomNavigationBar navigationBar = preferencesService.bottom_navigation_key.currentWidget;
    //navigationBar.onTap(2);
    friends_stream = preferencesService.friendsListStream!.value!;
    members_stream = preferencesService.recentMembersListStream!.value!;
    doctors_Stream = preferencesService.doctorsListStream!.value!;
  }

  void tooltipMessages() {
    List tooltipTitle = ['Subscription_tooltip', 'Health Record', 'Friends Chat', 'SWAR Chat', 'What you are looking for?'];
    for (int i = 0; i < tooltipTitle.length; i++) {
      for (var toolTip in preferencesService.alertContentList!) {
        if (toolTip['type'] == tooltipTitle[i]) {
          getAlertmessage.add(toolTip['content']);
        }
      }
    }
  }

  void dispose() {
    if (friends_stream != null) {
      friends_stream!.clear();
    }
    if (members_stream != null) {
      members_stream!.clear();
    }
    _controller.dispose();
    super.dispose();
  }

//if app from bgstate
  void cube_connect() {
    bool isChatDisconnected = CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.Closed || CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.ForceClosed;
    if (isChatDisconnected && CubeChatConnection.instance.currentUser != null) {
      CubeChatConnection.instance.relogin();
    }
  }

  PreferredSizeWidget swarAppBar() {
    return AppBar(
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
              final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
              navigationBar.onTap!(2);
              preferencesService.user_login = '';
              setState(() {});
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
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            UIHelper.horizontalSpaceSmall,
            GestureDetector(
                onTap: () async {
                  Navigator.of(context).popUntil((route) => route.isFirst);

                  final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                  navigationBar.onTap!(0);
                },
                child: Text('SWAR').bold().textColor(activeColor).fontSize(19).bold()),
            UIHelper.horizontalSpaceTiny,
            OverlayTooltipItem(
                displayIndex: 0,
                tooltip: (controller) => Padding(
                      padding: const EdgeInsets.only(left: 15, top: 15),
                      child: MTooltip(title: getAlertmessage[0], controller: controller),
                    ),
                child: GestureDetector(
                    onTap: () {
                      if (preferencesService.isSubscriptionMarkedInSwar() == false) {
                        Get.to(() => SubscriptionView());
                      } else {
                        Get.to(() => SubscribedView());
                      }
                    },
                    child: Image.asset('assets/${locator<PreferencesService>().getCurrentSubscriptionPlanImage()}', width: 30.0, height: 29.0)))
          ]),
        ));
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

  Widget addHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        children: [
          Text(' ' + preferencesService.userInfo['name']).bold().fontSize(18),
          //Text(preferencesService.member_count.toString()).bold().fontSize(18),
          //Text(preferencesService.userInfo['name']).bold().fontSize(18),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget showSearchField(BuildContext context, Membersmodel model) {
    return SizedBox(
      height: 54,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    // model.updateOnTextSearch(value);
                    model.getMembers_search(value);

                    setState(() {
                      isSearch = true;
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
                                model.getMembers_search('');
                                setState(() {
                                  isSearch = true;
                                });
                                FocusManager.instance.primaryFocus!.unfocus();
                              }),
                      contentPadding: EdgeInsets.only(left: 20),
                      enabledBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0x00CCCCCC)),
                      focusedBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                      focusedErrorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                      errorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "Search...",
                      fillColor: fieldBgColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showGroups(BuildContext context, Membersmodel model) {
    var count = model.recentFamily.length;
    // var count = preferencesService.memebersListStream!.length;
    var countfriends = model.recentFriends.length;
    String familycount = count.toString();
    mem_Count = count;

    String friendscount = isSearch
        ? countfriends.toString()
        : friends_stream!.length.toString() == "0"
            ? preferencesService.friendsListStream!.value!.length.toString()
            : friends_stream!.length.toString();

    List<Map<String, dynamic>> groups = [
      {'image': 'assets/group_family_icon.png', 'title': 'Health Record', 'count': familycount, 'sub_content': 'Add family members'},
      {'image': 'assets/chat_bubble.png', 'title': 'Friends Chat', 'count': friendscount, 'sub_content': 'Invite friends & connect'},
      {'image': 'assets/swar_dct.png', 'title': 'SWAR Chat', 'count': '0', 'sub_content': 'Chat with Doctors  '},
    ];

    return Container(
      height: 110,
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            child: StreamedWidget<List<dynamic>?>(
                stream: preferencesService.friendsListStream!.outStream!,
                builder: (context, snapshot) {
                  return Expanded(
                    child: ListView.builder(
                        itemCount: 3,
                        scrollDirection: Axis.horizontal,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          int tooltipDisplayIndex = 1;
                          int toolcount = index + 1;
                          return OverlayTooltipItem(
                              displayIndex: tooltipDisplayIndex + index,
                              tooltip: (controller) => Padding(
                                    padding: const EdgeInsets.only(left: 15, top: 15),
                                    child: MTooltip(title: getAlertmessage[toolcount], controller: controller),
                                  ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isDeleteModeOn = false;
                                    isSelectionCategory = true;
                                    selectedTab = groups[index]['title'].toString();
                                    Tab_id = index;
                                  });
                                  if (index == 0) {
                                    // final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                                    // navigationBar.onTap!(1);
                                  } else if (index == 1) {
                                    // locator<PreferencesService>().ischatListReload.value = true;
                                    // model.unsestMsg_Bg();
                                    // Get.to(() => ChatListView());
                                  }
                                },
                                child: Container(
                                  width: Screen.width(context) / 3.4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                groups[index]['title'],
                                                textAlign: TextAlign.left,
                                              ).fontSize(13).fontWeight(FontWeight.w600),
                                              Text(groups[index]['sub_content'], textAlign: TextAlign.left).fontSize(8).fontWeight(FontWeight.w300),
                                            ],
                                          ),

                                          UIHelper.verticalSpaceTiny,
                                          //Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                          Container(
                                              child: GestureDetector(
                                            onTap: () async {},
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                    onTap: () async {
                                                      if (index == 1) {
                                                        locator<PreferencesService>().ischatListReload.value = true;
                                                        model.unsestMsg_Bg();
                                                        Get.to(() => ChatListView());
                                                      } else if (index == 2) {
                                                        locator<PreferencesService>().ischatListReload.value = true;
                                                        model.unsestMsg_Bg();
                                                        Get.to(() => DocChatListView());
                                                      }
                                                    },
                                                    child: index != 2
                                                        ? Image.asset(
                                                            groups[index]['image'],
                                                            width: 35,
                                                            height: 35,
                                                          )
                                                        : Image.asset(
                                                            groups[index]['image'],
                                                            width: 35,
                                                            height: 35,
                                                            filterQuality: FilterQuality.medium,
                                                            //color: greycolor.withOpacity(0.1),
                                                          )),
                                                // UIHelper.verticalSpaceTiny,
                                                GestureDetector(
                                                    onTap: () async {
                                                      if (index == 0) {
                                                        // Get.to(() => AddMemberView());
                                                        if ((preferencesService.member_count.isEmpty) || (preferencesService.member_count == '0')) {
                                                          preferencesService.member_count = '2';
                                                        }
                                                        //if basic plan count
                                                        if (preferencesService.member_count.toLowerCase() != "unlimited") {
                                                          if (mem_Count < int.parse(preferencesService.member_count)) {
                                                            await Get.to(() => AddMemberView());
                                                            await model.getRecentFamily();
                                                            // setState(() {});
                                                          } else {
                                                            showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return CustomDialogBox(
                                                                    title: "Info !",
                                                                    descriptions: "    You don't have plan to add more than 2 members. Please Upgrade",
                                                                    descriptions1: "PLAN REDIRECTION",
                                                                    text: "OK",
                                                                  );
                                                                });
                                                          }
                                                        } else {
                                                          //unlimited plan
                                                          await Get.to(() => AddMemberView());
                                                          model.getRecentFamily();
                                                        }
                                                        preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
                                                      } else if (index == 1) {
                                                        inviteFriends(context, model);
                                                        await model.getRecentFamily();
                                                      } else {}
                                                    },
                                                    child: Container(
                                                        height: 25,
                                                        child: Badge(
                                                            elevation: 3,
                                                            position: BadgePosition.bottomEnd(bottom: 9, end: 3),
                                                            badgeColor: activeColor,
                                                            shape: BadgeShape.square,
                                                            borderRadius: BorderRadius.circular(8.0),
                                                            padding: index == 0 ? EdgeInsets.all(6) : EdgeInsets.all(0),
                                                            badgeContent: index == 0
                                                                ? Icon(Icons.add, size: 15, color: Colors.white)
                                                                : Column(children: [
                                                                    index != 2
                                                                        ? Image.asset(
                                                                            'assets/invite_mail.png',
                                                                            //fit: BoxFit.fill,
                                                                            width: 25,
                                                                            height: 25,
                                                                          )
                                                                        : Image.asset(
                                                                            'assets/invite_mail.png',
                                                                            //fit: BoxFit.fill,
                                                                            width: 25,
                                                                            height: 25,
                                                                            filterQuality: FilterQuality.none,
                                                                            //color: greyColor2.withOpacity(0.5),
                                                                          ),
                                                                  ]),
                                                            child: Align(
                                                                alignment: Alignment.bottomRight,
                                                                child: Text(
                                                                  index != 0 ? '    Invite ' : 'Add   ',
                                                                ).fontSize(8).bold().textAlignment(TextAlign.justify))))),
                                              ],
                                            ),
                                          )),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // decoration: Tab_id == 2 ? UIHelper.roundeddisabledColor(6, commentColor) : index == Tab_id && Tab_id == 1 || Tab_id == 0 && isSelectionCategory ? UIHelper.roundedBorderWithColorWithShadow(6, fieldBgColor, borderColor: activeColor) : UIHelper.roundedBorderWithColor(6, fieldBgColor),
                                  decoration:
                                      index == Tab_id && isSelectionCategory ? UIHelper.roundedBorderWithColorWithShadow(6, fieldBgColor, borderColor: activeColor) : UIHelper.roundedBorderWithColor(6, fieldBgColor),
                                  padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                                  //padding: EdgeInsets.all(3),
                                  margin: EdgeInsets.only(right: 6),
                                ),
                              ));
                        }),
                  );
                }),
          ),
        ],
      ),
    );
  }

  void inviteFriends(BuildContext context, Membersmodel model) async {
    Loader.show(context);
    final response = await model.getInviteMemberRefId();
    Loader.hide();
    if (response['msg'] != null) {
      String postMessage = response['msg'];
      if (response['Invitemember'] != null) {
        dynamic inviteMember = response['Invitemember'];
        // String refId = inviteMember['_id'];
        String refId = inviteMember['reference_id'];
        String inviteLink = await locator<DynamicLinkService>().createMemberInviteLink(refId);
        //print(inviteLink);
        await Share.share(postMessage + ' ' + inviteLink, subject: 'SWAR Doctor');
      }
    }
  }

  Widget showTitle(BuildContext context, String title, String imgUrl, double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(title, textAlign: TextAlign.center).fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset(imgUrl, width: width, height: height)],
        )
      ],
    );
  }

  Widget addNewMemberWidget(BuildContext context, Membersmodel model) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(right: 8),
      width: 80,
      child: Column(
        children: [
          (Tab_id == 0)
              ? GestureDetector(
                  onTap: () async {
                    if ((preferencesService.member_count.isEmpty) || (preferencesService.member_count == '0')) {
                      preferencesService.member_count = '2';
                    }
                    //if basic plan count
                    if (preferencesService.member_count.toLowerCase() != "unlimited") {
                      if (mem_Count < int.parse(preferencesService.member_count)) {
                        await Get.to(() => AddMemberView());
                        await model.getRecentFamily();
                        setState(() {});
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialogBox(
                                title: "Info !",
                                descriptions: "    You don't have plan to add more than 2 members. Please Upgrade",
                                descriptions1: "PLAN REDIRECTION",
                                text: "OK",
                              );
                            });
                      }
                    } else {
                      //unlimited plan
                      await Get.to(() => AddMemberView());
                      model.getRecentFamily();
                    }
                    // preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
                  },
                  child: Column(children: [
                    //UIHelper.verticalSpaceTiny,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(21.0),
                      child: Container(width: 40, height: 40, color: activeColor, child: Icon(Icons.add, color: Colors.white)),
                    ),
                    UIHelper.verticalSpaceSmall,
                    // UIHelper.verticalSpaceTiny,
                    Text(
                      'Add',
                    ).fontSize(12).bold().textAlignment(TextAlign.center),
                    UIHelper.verticalSpaceTiny,
                    Text(
                      'Member',
                    ).fontSize(12).bold().textAlignment(TextAlign.center)
                  ]),
                )
              : Tab_id == 1
                  ?
                  //For invite
                  GestureDetector(
                      onTap: () async {
                        inviteFriends(context, model);
                        await model.getRecentFamily();
                        // setState(() {});
                      },
                      child: Column(children: [
                        Image.asset(
                          'assets/invite_mail.png',
                          fit: BoxFit.none,
                          width: 40,
                          height: 40,
                        ),
                        UIHelper.verticalSpaceTiny,
                        UIHelper.verticalSpaceTiny,
                        Text(
                          'Invite\nFriends',
                        ).fontSize(12).bold().textAlignment(TextAlign.center)
                      ]),
                    )
                  : GestureDetector(
                      onTap: () async {
                        inviteFriends(context, model);
                        await model.getRecentFamily();
                        // setState(() {});
                      },
                      child: Column(children: [
                        Image.asset(
                          'assets/invite_mail.png',
                          fit: BoxFit.none,
                          width: 40,
                          height: 40,
                        ),
                        UIHelper.verticalSpaceTiny,
                        UIHelper.verticalSpaceTiny,
                        Text(
                          'Invite\nFriends',
                        ).fontSize(12).bold().textAlignment(TextAlign.center)
                      ]),
                    )
        ],
      ),
    );
  }

  Widget showMembers(BuildContext context, Membersmodel model) {
    if (locator<PreferencesService>().isReload.value == true) {
      locator<PreferencesService>().isReload.value = false;
      // modelRef.getRecentFamily();
    }
    print(model.recentFamily.length);
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      decoration: UIHelper.roundedBorderWithColorWithShadow(6, fieldBgColor),
      height: 104,
      child: Row(
        children: [
          Expanded(
              child: (Tab_id == 0)
                  //  ? (model.recentFamily.length == 0)
                  //https://swartest.blob.core.windows.net/swardoctor/image_cropper_1642913303483_1642913306328.jpg
                  ? (preferencesService.memebersListStream!.length == 0)
                      ? Container(
                          child: Center(
                            child: Text('Members Not found'),
                          ),
                        )
                      : StreamedWidget<List<dynamic>?>(
                          stream: preferencesService.memebersListStream!.outStream!,
                          builder: (context, snapshot) {
                            return ListView.builder(
                                // itemCount: model.recentFamily.length,
                                itemCount: preferencesService.memebersListStream!.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  // dynamic memberinfo = model.recentFamily[index];
                                  dynamic getRs = preferencesService.memebersListStream!.value!;
                                  dynamic memberinfo = getRs[index];

                                  //dynamic imgurl = memberinfo['azureBlobStorageLink']!=null?memberinfo['azureBlobStorageLink'] : "";

                                  String imgUrl = '';
                                  if (memberinfo['azureBlobStorageLink'] != null) {
                                    String imgurl = memberinfo['azureBlobStorageLink'].toString();
                                    if (imgurl.isNotEmpty) {
                                      imgUrl = '${ApiService.fileStorageEndPoint}$imgurl';
                                    }
                                  }

                                  //  return model.recentFamily.length == index
                                  return preferencesService.memebersListStream!.length == index
                                      ? addNewMemberWidget(context, model)
                                      : GestureDetector(
                                          onLongPress: () {
                                            if (index != 0) {
                                              setState(() {
                                                deleteid = memberinfo['_id'];
                                                isDeleteModeOn = true;
                                              });
                                            }
                                          },
                                          onTap: () async {
                                            if (index == 0) {
                                              // await Get.to(() => ProfileView());
                                              // setState(() {});
                                              final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                                              navigationBar.onTap!(2);
                                              setState(() {});
                                            } else {
                                              String memberId = memberinfo['_id'];
                                              if (isDeleteModeOn && deleteid == memberinfo['_id']) {
                                                setState(() {
                                                  isDeleteModeOn = false;
                                                });
                                                unmemberDialog(context, memberinfo, model);
                                                return;
                                              } else if (memberId.isNotEmpty) {
                                                await Get.to(() => ViewMemberView(memberId: memberId, view_type: 'family'));
                                                setState(() {});
                                              }

                                              // await model.getRecentFamily();
                                              // setState(() {});
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            margin: EdgeInsets.only(right: 8),
                                            child: Column(
                                              children: [
                                                Stack(
                                                  children: <Widget>[
                                                    index == 0
                                                        ? StreamBuilder<String?>(
                                                            stream: locator<PreferencesService>().profileUrl.outStream,
                                                            builder: (context, uploadimg) => !uploadimg.hasData || uploadimg.data == ''
                                                                ? Container(
                                                                    child: Icon(Icons.account_circle, size: 43, color: Colors.grey),
                                                                    width: 43,
                                                                    height: 43,
                                                                  )
                                                                : ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(uploadimg.data!, 43, 43)),
                                                          )
                                                        : StreamBuilder<String?>(
                                                            stream: locator<PreferencesService>().profileUrl.outStream,
                                                            builder: (context, uploadimg) => !uploadimg.hasData || imgUrl.isEmpty
                                                                ? Container(
                                                                    child: Icon(Icons.account_circle, size: 43, color: Colors.grey),
                                                                    width: 43,
                                                                    height: 43,
                                                                  )
                                                                : ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(imgUrl, 43, 43)),
                                                          ),
                                                    (isDeleteModeOn == true && deleteid == memberinfo['_id'])
                                                        ? Container(
                                                            width: 44,
                                                            height: 44,
                                                            child: Icon(Icons.remove_circle, color: Colors.white),
                                                            decoration: UIHelper.roundedLineBorderWithColor(22, Colors.transparent, 2, borderColor: activeColor),
                                                          )
                                                        : SizedBox(),
                                                  ],
                                                ),
                                                UIHelper.verticalSpaceTiny,
                                                // Text(index == 0 ? 'You' : memberinfo['member_first_name']).fontSize(14).fontWeight(FontWeight.w500),
                                                //index == 0 ? Text(memberinfo['member_first_name']).fontSize(14).bold()
                                                index == 0
                                                    ? StreamBuilder<String?>(
                                                        stream: locator<PreferencesService>().userName.outStream,
                                                        builder: (context, snapshotname) =>
                                                            !snapshotname.hasData || snapshotname.data == '' ? Text(preferencesService.userInfo['name']).fontSize(14).bold() : Text(snapshotname.data!).fontSize(14).bold())
                                                    : Text(memberinfo['member_first_name']).fontSize(14).fontWeight(FontWeight.w500),
                                                UIHelper.verticalSpaceTiny,
                                                index == 0 ? Text('You').fontSize(12).bold() : Text(memberinfo['relation'] != null ? memberinfo['relation'] : '').fontSize(12),
                                                //       underlineText(index == 0 ? memberinfo['member_first_name'] : memberinfo['relation'] ?? '').fontSize(12),
                                              ],
                                            ),
                                          ),
                                        );
                                });
                          })
                  : Tab_id == 1
                      ? StreamedWidget<List<dynamic>?>(
                          stream: preferencesService.friendsListStream!.outStream!,
                          builder: (context, snapshot) {
                            return (snapshot.data!.length == 0)
                                ? Container(
                                    child: Center(
                                      child: Text('Friends Not found'),
                                    ),
                                  )
                                : ListView.builder(
                                    // itemCount: friends_stream.length,
                                    itemCount: isSearch ? model.recentFriends.length : snapshot.data!.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      dynamic friendinfo;
                                      isSearch ? friendinfo = model.recentFriends[index] : friendinfo = snapshot.data![index];
                                      dynamic friendImgurl = friendinfo['azureBlobStorageLink'];
                                      dynamic friendImgUrl = '${ApiService.fileStorageEndPoint}$friendImgurl';
                                      return GestureDetector(
                                        onLongPress: () {
                                          setState(() {
                                            deleteid = friendinfo['_id'];
                                            isDeleteModeOn = true;
                                          });
                                        },
                                        onTap: () async {
                                          String memberId = friendinfo['_id'];
                                          if (isDeleteModeOn && deleteid == friendinfo['_id']) {
                                            setState(() {
                                              isDeleteModeOn = false;
                                            });
                                            unfriendDialog(context, friendinfo, model);
                                            return;
                                          }

                                          CubeUser? currentUser = await SharedPrefs.getUser();
                                          if (friendinfo['connectycube_id'] != null) {
                                            Loader.show(context);
                                            cube_connect();
                                            int userid = int.parse(friendinfo['connectycube_id']);
                                            CubeDialog newDialog = CubeDialog(CubeDialogType.PRIVATE, occupantsIds: [userid]);
                                            await createDialog(newDialog).then((createdDialog) {
                                              Future.delayed(Duration(seconds: 4), () {
                                                Loader.hide();
                                              });
                                              Get.to(() => ChatDialogScreen(currentUser!, createdDialog));
                                            }).catchError((error) {
                                              Loader.hide();
                                              print(error);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.only(right: 8),
                                          child: Column(
                                            children: [
                                              Stack(
                                                children: <Widget>[
                                                  friendImgUrl == '' || friendImgUrl.contains('null')
                                                      ? Container(
                                                          child: Icon(Icons.account_circle, size: 44, color: Colors.grey),
                                                          width: 44,
                                                          height: 44,
                                                        )
                                                      : ClipRRect(borderRadius: BorderRadius.circular(22.5), child: UIHelper.getImage(friendImgUrl, 44, 44)),
                                                  (isDeleteModeOn == true && deleteid == friendinfo['_id'])
                                                      ? Container(
                                                          width: 44,
                                                          height: 44,
                                                          child: Icon(Icons.remove_circle, color: Colors.white),
                                                          decoration: UIHelper.roundedLineBorderWithColor(22, Colors.transparent, 2, borderColor: activeColor),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              ),
                                              UIHelper.verticalSpaceTiny,
                                              Text(friendinfo['member_first_name']).fontSize(14).fontWeight(FontWeight.w500),
                                              UIHelper.verticalSpaceTiny,
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                          })
                      : StreamedWidget<List<dynamic>?>(
                          stream: preferencesService.doctorsListStream!.outStream!,
                          builder: (context, snapshot) {
                            return (snapshot.data!.length == 0)
                                ? Container(
                                    child: Center(
                                      child: Text('Doctors Not found'),
                                    ),
                                  )
                                : ListView.builder(
                                    // itemCount: friends_stream.length,
                                    itemCount: isSearch ? model.recentDoctors.length : snapshot.data!.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      dynamic friendinfo;
                                      isSearch ? friendinfo = model.recentDoctors[index] : friendinfo = snapshot.data![index];
                                      dynamic friendImgurl = friendinfo['azureBlobStorageLink'];
                                      dynamic friendImgUrl = '${ApiService.fileStorageEndPoint}$friendImgurl';
                                      return GestureDetector(
                                        onLongPress: () {
                                          setState(() {
                                            deleteid = friendinfo['_id'];
                                            isDeleteModeOn = true;
                                          });
                                        },
                                        onTap: () async {
                                          String memberId = friendinfo['_id'];
                                          if (isDeleteModeOn && deleteid == friendinfo['_id']) {
                                            setState(() {
                                              isDeleteModeOn = false;
                                            });
                                            unfriendDialog(context, friendinfo, model);
                                            return;
                                          }

                                          CubeUser? currentUser = await SharedPrefs.getUser();
                                          if (friendinfo['connectycube_id'] != null) {
                                            Loader.show(context);
                                            cube_connect();
                                            int userid = int.parse(friendinfo['connectycube_id']);
                                            CubeDialog newDialog = CubeDialog(CubeDialogType.PRIVATE, occupantsIds: [userid]);
                                            await createDialog(newDialog).then((createdDialog) {
                                              Future.delayed(Duration(seconds: 4), () {
                                                Loader.hide();
                                              });
                                              Get.to(() => ChatDialogScreen(currentUser!, createdDialog));
                                            }).catchError((error) {
                                              Loader.hide();
                                              print(error);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.only(right: 8),
                                          child: Column(
                                            children: [
                                              Stack(
                                                children: <Widget>[
                                                  friendImgUrl == '' || friendImgUrl.contains('null')
                                                      ? Container(
                                                          child: Icon(Icons.account_circle, size: 44, color: Colors.grey),
                                                          width: 44,
                                                          height: 44,
                                                        )
                                                      : ClipRRect(borderRadius: BorderRadius.circular(22.5), child: UIHelper.getImage(friendImgUrl, 44, 44)),
                                                  (isDeleteModeOn == true && deleteid == friendinfo['_id'])
                                                      ? Container(
                                                          width: 44,
                                                          height: 44,
                                                          child: Icon(Icons.remove_circle, color: Colors.white),
                                                          decoration: UIHelper.roundedLineBorderWithColor(22, Colors.transparent, 2, borderColor: activeColor),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              ),
                                              UIHelper.verticalSpaceTiny,
                                              Text(friendinfo['name']).fontSize(14).fontWeight(FontWeight.w500),
                                              UIHelper.verticalSpaceTiny,
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                          })),
          addNewMemberWidget(context, model),
        ],
      ),
    );
  }

  Widget looking_widget() {
    return Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      GestureDetector(
          onTap: () {
            // Get.to(() => TopSpecialistView());
          },
          child: Container(
            width: Screen.width(context) / 4,
            padding: EdgeInsets.all(7),
            decoration: UIHelper.rightcornerRadiuswithColor(4, 20, Colors.amber.shade100),
            child: showTitle(context, 'Doctors & Specialists ', 'assets/doctor_profile.png', 35, 35),
          )),
    ]));
  }

  Widget showLooking_for(BuildContext context, Membersmodel model) {
    return Container(
        width: Screen.width(context),
        decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
        // padding: EdgeInsets.all(3),
        padding: EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 10),
        height: 180,
        child: Column(children: [
          Row(
            //mainAxisAlignment: MainAxisAlignment.left,
            children: [
              Text(
                '  What are you looking for?',
                textAlign: TextAlign.left,
              ).fontSize(14).fontWeight(FontWeight.w500).bold().padding(top: 4),
            ],
          ),
          UIHelper.verticalSpaceMedium,
          Expanded(
              child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 5, right: 5),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                    onTap: () {
                      Get.to(() => TopSpecialistView(servicetype: ""));
                    },
                    child: Container(
                      width: Screen.width(context) / 3.8,
                      padding: EdgeInsets.all(7),
                      decoration: UIHelper.rightcornerRadiuswithColor(4, 20, Colors.amber.shade100),
                      child: showTitle(context, 'Doctors & Specialists ', 'assets/doctor_profile.png', 35, 35),
                    )),
                UIHelper.horizontalSpaceTiny,
                UIHelper.horizontalSpaceTiny,
                GestureDetector(
                  onTap: () {
                    // Get.to(() => DoctorNurseView());
                    Get.to(() => TopSpecialistView(servicetype: "Home visit"));
                  },
                  child: Container(
                    width: Screen.width(context) / 3.8,
                    padding: EdgeInsets.all(7),
                    decoration: UIHelper.rightcornerRadiuswithColor(4, 20, Color(0xFFF4AFA4)),
                    child: showTitle(context, 'Home visit doctors & nurse', 'assets/home_visit.png', 35, 35),
                  ),
                ),
                UIHelper.horizontalSpaceTiny,
                UIHelper.horizontalSpaceTiny,
                GestureDetector(
                    onTap: () {
                      Get.to(() => TopSpecialistView(servicetype: "Online"));
                    },
                    child: Container(
                      width: Screen.width(context) / 3.8,
                      padding: EdgeInsets.all(4),
                      decoration: UIHelper.rightcornerRadiuswithColor(4, 20, Color(0xFFB6EFF7)),
                      child: showTitle(context, 'Online Consultation', 'assets/online_consultation.png', 35, 35),
                    )),
                UIHelper.horizontalSpaceTiny,
                UIHelper.horizontalSpaceTiny,
                GestureDetector(
                  onTap: () {
                    //  Get.to(() => DoctorProfileView());
                  },
                  child: Container(
                    width: Screen.width(context) / 3.8,
                    padding: EdgeInsets.all(7),
                    decoration: UIHelper.rightcornerRadiuswithColor(4, 20, Color(0xFFD0E1C5)),
                    child: showTitle(context, ' Pharmacy\n', 'assets/online_pharmacy.png', 35, 35),
                  ),
                ),
                UIHelper.horizontalSpaceTiny,
                UIHelper.horizontalSpaceTiny,
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: Screen.width(context) / 3.8,
                    padding: EdgeInsets.all(7),
                    decoration: UIHelper.rightcornerRadiuswithColor(4, 20, Color(0xFFC1E3E0)),
                    child: showTitle(context, 'Lab test & radiology\n ', 'assets/lab_test_radiology.png', 30, 30),
                  ),
                ),
              ],
            ),
          ))
        ]));
  }

  Future<void> unfriendDialog(BuildContext context, dynamic friendInfo, Membersmodel model) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete'),
            content: Text('Are you sure you want to delete the friend?'),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    isDeleteModeOn = false;
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Yes'),
                onPressed: () async {
                  Loader.show(context);
                  final result = await model.unFriendMember(friendInfo['_id']);
                  if (result) {
                    friends_stream!.remove(friendInfo);
                    setState(() {
                      isDeleteModeOn = false;
                    });
                    Loader.hide();
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<void> unmemberDialog(BuildContext context, dynamic memberinfo, Membersmodel model) async {
    String name = memberinfo['member_first_name'];
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
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    isDeleteModeOn = false;
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Yes'),
                onPressed: () async {
                  Loader.show(context);
                  final result = await model.deletemember(memberinfo['_id']);

                  Loader.hide();
                  if (result) {
                    if (members_stream != null) {
                      members_stream!.remove(memberinfo);
                      preferencesService.onRefreshRecentDocument!.value = true;
                      setState(() {
                        isDeleteModeOn = false;
                      });
                      // await model.getRecentFamily();
                    }
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    friends_stream = preferencesService.friendsListStream!.value!;
    doctors_Stream = preferencesService.doctorsListStream!.value!;
    if (locator<PreferencesService>().isReload.value == true) {
      locator<PreferencesService>().isReload.value = false;
      // modelRef.getRecentFamily();
    }
    return OverlayTooltipScaffold(
      overlayColor: Colors.black.withOpacity(.6),
      controller: _controller,
      startWhen: (initializedWidgetLength) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return initializedWidgetLength == 3 && !done;
      },
      builder: (context) => Scaffold(
          appBar: swarAppBar(),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDeleteModeOn = false;
                    });
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: SafeArea(
                    top: false,
                    child: Container(
                      // padding: EdgeInsets.symmetric(horizontal: 16),

                      width: Screen.width(context),
                      height: Screen.height(context) + 200,
                      child: ViewModelBuilder<Membersmodel>.reactive(
                          onModelReady: (model) async {
                            // modelRef = model;
                            // model.init();
                            // await locator<PreferencesService>().ShowSubscriptionPOPUP(context);
                            // // model.getRecentMembers();
                            // model.getRecentFamily();
                            // // model.getRecentFriends();
                            modelRef = model;
                            model.init();
                            Loader.show(context);
                            await model.getRecentFamily();
                            await model.getRecentDoctors();
                            preferencesService.current_index = '-1';
                            Future.delayed(Duration(seconds: 7), () async {
                              preferencesService.current_index = '-1';
                              await locator<PreferencesService>().showSubscriptionPopup(context);
                              setState(() {});
                            });
                            Loader.hide();
                          },
                          builder: (context, model, child) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UIHelper.verticalSpaceMedium,
                                //UIHelper.verticalSpaceSmall,
                                // addHeader(context),
                                //UIHelper.verticalSpaceSmall,
                                showSearchField(context, model),
                                // TextButton(
                                //     onPressed: () {
                                //       //_controller.start();
                                //       OverlayTooltipScaffold.of(context)?.controller.start();
                                //     },
                                //     child: const Text('Start Tooltip manually')),
                                // // UIHelper.verticalSpaceSmall,
                                showGroups(context, model),
                                UIHelper.verticalSpaceSmall,
                                isSelectionCategory ? showMembers(context, model) : Container(),
                                // UIHelper.verticalSpaceSmall,
                                OverlayTooltipItem(
                                    displayIndex: 4,
                                    tooltip: (controller) => Padding(
                                          padding: const EdgeInsets.only(left: 15, top: 15),
                                          child: MTooltip(title: getAlertmessage[4], controller: controller),
                                        ),
                                    child: showLooking_for(context, model)),
                                // showUp(context,model),
                                UIHelper.verticalSpaceSmall,
                                UIHelper.verticalSpaceSmall,
                                // showActivityFeed(context, model),
                                //   Expanded(
                                //  child: ActivityFeedWidget()),
                                ActivityFeedWidget(),
                                UIHelper.verticalSpaceSmall,
                              ],
                            );
                          },
                          viewModelBuilder: () => Membersmodel()),
                    ),
                  ),
                ),
              ])
              //)
              )),
    );
  }

  @override
  // TODO: implement restorationId
  String? get restorationId => 'members_view';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // TODO: implement restoreState
    bool isChatDisconnected = CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.Closed || CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.ForceClosed;
    if (isChatDisconnected && CubeChatConnection.instance.currentUser != null) {
      CubeChatConnection.instance.relogin();
    }
  }
}

import 'package:badges/badges.dart';
import 'package:connectycube_sdk/connectycube_calls.dart';
import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:jiffy/jiffy.dart';
import 'package:share/share.dart';
import 'package:stacked/stacked.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/frideos/extended_asyncwidgets.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/connectycube_services.dart';
import 'package:swarapp/services/dynamic_link_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/services/pushnotification_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/timeago.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/communication/chat_List_view_model.dart';
import 'package:swarapp/ui/communication/chat_dialog_screen.dart';
import 'package:swarapp/ui/communication/doctor_chat_model.dart';
import 'package:swarapp/ui/communication/search_user_cc.dart';
import 'package:swarapp/ui/invites/contact_view.dart';
import 'package:swarapp/ui/invites/find_friendsList_view.dart';
import 'package:swarapp/ui/invites/request_view.dart';

class DocterChatListView extends StatefulWidget {
  const DocterChatListView({Key? key}) : super(key: key);

  @override
  State<DocterChatListView> createState() => _DocterChatListViewState();
}

class _DocterChatListViewState extends State<DocterChatListView> {
  TextEditingController searchController = TextEditingController();
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  ApiService apiService = locator<ApiService>();
  CubeUser currentUser = CubeUser();
  bool isReadOnly = false;
  bool isExist = false;
  var screenSize;
  AppLifecycleState? appState;
  bool isInviteSearch = false;
  bool isSearch = false;
  Widget addHeader(BuildContext context, bool isBackBtnVisible) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Patients Chats').fontSize(16).fontWeight(FontWeight.w600),
          Container(
            // decoration: UIHelper.roundedLineBorderWithColor(12, fieldBgColor, 1),
            padding: EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }

  void getChatDialogs() async {
    currentUser = (await SharedPrefs.getUser())!;
    //print(currentUser.avatar);
    await connectyCubeServices.getCubeDialogs();
  }

  void navigateToSearchCCUser(bool isNew) async {
    dynamic newDialog = await Get.to(
      () => SearchUserFromCC(
        currentUser: currentUser,
        isGroup: false,
        isNew: isNew,
      ),
    );
    if (newDialog != null) {
      await Get.to(() => ChatDialogScreen(currentUser, newDialog['dialog']));
      getChatDialogs();
    }
  }
  

  void cube_connect() {
    bool isChatDisconnected = CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.Closed || CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.ForceClosed;
    if (isChatDisconnected && CubeChatConnection.instance.currentUser != null) {
      CubeChatConnection.instance.relogin();
    }
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

  Widget getBubbleItem(CubeDialog dialog) {
    String lastmessage = '';
    String lastMessageDt = '';
    String time = '';
    DateTime getTime;
    //lastmessage.lastMessageDateSentmessage = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    //print(dialog.lastMessageDateSent);
    // DateTime.now().millisecondsSinceEpoch ~/ 1000     >>> its (Unix Timestamp Conversion-integer type)
    //dialog.lastMessageDateSent
    print(dialog.toString());
    Jiffy dt = Jiffy(dialog.updatedAt);
    DateTime checkedTime = DateTime.parse(dialog.updatedAt.toString());
    DateTime currentTime = DateTime.now();

    if ((currentTime.year == checkedTime.year) && (currentTime.month == checkedTime.month) && (currentTime.day == checkedTime.day)) {
      // return "TODAY";
      lastMessageDt = "";
    } else if ((currentTime.year == checkedTime.year) && (currentTime.month == checkedTime.month)) {
      if ((currentTime.day - checkedTime.day) == 1) {
        //return "YESTERDAY";
        lastMessageDt = "YESTERDAY";
      } else if ((currentTime.day - checkedTime.day) == -1) {
        //return "TOMORROW";
        lastMessageDt = "TOMORROW";
      } else {
        Jiffy upDt = Jiffy(dialog.updatedAt);
        lastMessageDt = upDt.format('dd/MM/yyyy').toString();
        // return dateString;
      }
    }

    //for get time
    DateTime now = DateTime.now();
    DateTime justNow = DateTime.now().subtract(Duration(minutes: 1));
    if (dialog.lastMessageDateSent != null) {
      getTime = DateTime.fromMillisecondsSinceEpoch(dialog.lastMessageDateSent! * 1000);
      if (!getTime.difference(justNow).isNegative) {
        time = 'Just now';
      } else {
        getTime = DateTime.fromMillisecondsSinceEpoch(dialog.lastMessageDateSent! * 1000);
      }
    } else {
      getTime = DateTime.now();
    }

    //Time
    String dateStr = dt.format('h:mm a');
    print(dateStr);
    //dialog.lastMessage.

    if (dialog.lastMessage != null) {
      lastmessage = dialog.lastMessage!;
      // if (dialog.type == 2) {
      //   lastmessage = dialog.name! + ": " + dialog.lastMessage!;
      // }
    } else {
      lastmessage = "";
    }
    return GestureDetector(
      onTap: () async {
        Loader.show(context);
        Future.delayed(Duration(seconds: 4), () {
          Loader.hide();
        });
        await Get.to(() => ChatDialogScreen(currentUser, dialog));

        getChatDialogs();
      },
      child: Container(
        // width: Screen.width(context) - 50,
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: UIHelper.getProfileImageWithInitials(dialog.type == 2 ? dialog.photo! : getPrivateUrlForUid(dialog.photo)!, 38, 38, dialog.name!),
            ),
            UIHelper.horizontalSpaceSmall,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(dialog.name!).fontSize(14).fontWeight(FontWeight.w600),
                    Text(
                      format(dialog.updatedAt!, locale: 'en_short'),
                      style: TextStyle(color: Colors.black45, fontSize: 12.0, fontWeight: FontWeight.w600),
                    )
                    //check its today
                    // dialog.lastMessageDateSent != null && last_message_dt == ""
                    //     ? Text(
                    //         time.isNotEmpty ? time : DateFormat('h:mm a').format(get_time),
                    //         style: TextStyle(color: Colors.black45, fontSize: 12.0, fontStyle: FontStyle.italic),
                    //       )

                    //     //else
                    //     : Text(
                    //         last_message_dt,
                    //         style: TextStyle(color: Colors.black45, fontSize: 12.0, fontStyle: FontStyle.italic),
                    //       )
                  ]),
                  UIHelper.verticalSpaceTiny,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // dialog.lastMessageUserId == currentUser.id  
                      //     ?
                           Row(children: [
                              // Icon(
                              //   Icons.done_all,
                              //   size: 12.0,
                              //   color: Colors.green,
                              // ),
                              Text("You : ", style: TextStyle(color: Colors.black38, fontSize: 12.0, fontWeight: FontWeight.w800)),
                               Text(lastmessage, overflow: TextOverflow.ellipsis).fontSize(12),
                              // Text(lastmessage, overflow: TextOverflow.ellipsis).fontSize(12),
                            ]),
                          // : Flexible(child: Text(lastmessage, overflow: TextOverflow.ellipsis).fontSize(12)),
                          

                      //

                      //  dialog.lastMessageUserId==dialog.userId ?
                      //  Text("sent") : Text("Opp"),

                      //Flexible(child: Text(lastmessage, overflow: TextOverflow.ellipsis).fontSize(12)),
                      // UIHelper.tagWidget(DateFormat('dd MMMM').format(DateTime.fromMillisecondsSinceEpoch(lastmessage.dateSent! * 1000)), activeColor),
                      // Text(last_message_dt),
                      // Text(dialog.unreadMessageCount.toString()),
                      dialog.unreadMessageCount! > 0
                          ? Badge(
                              elevation: 0,
                              badgeColor: activeColor,
                              shape: BadgeShape.circle,
                              padding: EdgeInsets.all(6),
                              badgeContent: Text(
                                dialog.unreadMessageCount.toString(),
                                style: TextStyle(color: Colors.white, fontSize: 10.0),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                  UIHelper.verticalSpaceSmall,
                  Container(
                    height: 1,
                    color: Colors.black12,
                    width: Screen.width(context) - 100,
                  ),
                  UIHelper.verticalSpaceSmall,
                ],
              ),
            )
          ],
        ),
      ),
    );
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

  Widget showSearchField(BuildContext context) {
    return SizedBox(
        height: 38,
        child: Row(children: [
          Container(
            width: Screen.width(context) - 80,
            decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () async {
                      navigateToSearchCCUser(false);
                    },
                    child: TextField(
                      enabled: false,
                      controller: searchController,
                      onChanged: (value) {
                        // model.updateOnTextSearch(value);
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
                                    searchController.text = '';
                                    //model.updateOnTextSearch('');
                                    FocusManager.instance.primaryFocus!.unfocus();
                                  }),
                          filled: true,
                          hintStyle: new TextStyle(color: Colors.grey[800]),
                          hintText: "Search family & friends......",
                          fillColor: fieldBgColor),
                    ),
                  ),
                ),
                UIHelper.horizontalSpaceSmall,
                // GestureDetector(
                //   child: Image.asset('assets/add_group.png'),
                //   onTap: () async {
                //     dynamic newDialog = await Get.to(
                //       () => SearchUserFromCC(currentUser: currentUser, isGroup: true, isNew: false),
                //     );
                //     if (newDialog != null) {
                //       await Get.to(() => ChatDialogScreen(currentUser, newDialog['dialog']));
                //       getChatDialogs();
                //       return;
                //     }
                //     if (locator<PreferencesService>().isNewGroupCreated) {
                //       await Get.to(() => ChatDialogScreen(currentUser, locator<PreferencesService>().newDialog));
                //       getChatDialogs();
                //       locator<PreferencesService>().isNewGroupCreated = false;
                //     }
                //   },
                // ),
              ],
            ),
          ),
           UIHelper.horizontalSpaceSmall,
          InkWell(
            onTap: (){
                inviteFriends();
            },
            child: Image.asset(
              'assets/invite_mail.png',
              //fit: BoxFit.fill,
              width: 25,
              height: 25,
            ),
          )
//           Container(
//             //  decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.grey.shade300),
//             child: PopupMenuButton(
//                 icon: Icon(Icons.more_vert),
// //                color: Colors.yellowAccent,
//                 elevation: 20,
//                 enabled: true,
//                 onSelected: (value) async {
//                   setState(() {
//                     String _value = value.toString();
//                   });

//                   if (value.toString() == "1") {
//                     Get.to(() => RequestView());
//                   }
//                   if (value.toString() == "2") {
//                     Get.to(() => ContactView(type: "Contacts"));
//                   }
//                   if (value.toString() == "3") {
//                     Get.to(() => FriendsListView());
//                   }
//                   if (value.toString() == "4") {
//                     inviteFriends();
//                   }
//                   //inviteFriends
//                   if (value.toString() == "5") {
//                     //new group
//                     dynamic newDialog = await Get.to(
//                       () => SearchUserFromCC(currentUser: currentUser, isGroup: true, isNew: false),
//                     );
//                     if (newDialog != null) {
//                       await Get.to(() => ChatDialogScreen(currentUser, newDialog['dialog']));
//                       getChatDialogs();
//                       return;
//                     }
//                     if (locator<PreferencesService>().isNewGroupCreated) {
//                       await Get.to(() => ChatDialogScreen(currentUser, locator<PreferencesService>().newDialog));
//                       getChatDialogs();
//                       locator<PreferencesService>().isNewGroupCreated = false;
//                     }
//                   }
//                 },
//                 itemBuilder: (context) => [
//                       PopupMenuItem(
//                         child: Text("Requests"),
//                         value: 1,
//                       ),
//                       PopupMenuItem(
//                         child: Text("Contacts"),
//                         value: 2,
//                       ),
//                       PopupMenuItem(
//                         child: Text("Find friends"),
//                         value: 3,
//                       ),
//                       PopupMenuItem(
//                         child: Text("Invite a Friend"),
//                         value: 4,
//                       ),
//                       PopupMenuItem(
//                         child: Text("New Group"),
//                         value: 5,
//                       )
//                     ]),
//           ),
        ]));
  }

  void check_accept(BuildContext context, DoctorChatmodel model, String id, String refId, int index) async {
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

  Widget requestfriendsList(dynamic notifInfo) {
    return ViewModelBuilder<DoctorChatmodel>.reactive(
        onModelReady: (model) async {
          await model.getNotification();
          //model.getMemberProfile(widget.memberId);
        },
        builder: (context, model, child) {
          return isInviteSearch && model.SearchByInfo.length == 0 || model.notificationInfo.length == 0
              ? Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Center(
                    child: Text('No Request found'),
                  )
                ])
              : ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    dynamic notifInfo = isInviteSearch ? model.SearchByInfo[index] : model.notificationInfo[index];
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
                                  Text("has send friend request").fontSize(13),
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
                                  },
                                  // locator<PreferencesService>().isReload.value = true;

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
                                    await model.getRecentFriends();
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
                  },
                  shrinkWrap: true,
                  itemCount: isInviteSearch ? model.SearchByInfo.length : model.notificationInfo.length,
                  physics: ClampingScrollPhysics(),
                );
        },
        viewModelBuilder: () => DoctorChatmodel());
  }

  Widget friendsList(ChatListViewModel model) {
    return StreamedWidget<List<dynamic>?>(
        stream: preferencesService.friendsListStream!.outStream!,
        builder: (context, snapshot) {
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              dynamic friendinfo;
              isSearch ? friendinfo = model.recentFriends[index] : friendinfo = snapshot.data![index];
              dynamic friendImgurl = friendinfo['azureBlobStorageLink'];
              dynamic friendImgUrl = '${ApiService.fileStorageEndPoint}$friendImgurl';
              return InkWell(
                onTap: () async {
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
                  margin: EdgeInsets.only(bottom: 8),
                  //  decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.black12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          friendImgUrl == '' || friendImgUrl.contains('null')
                              ? Container(
                                  // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                                  // child: Icon(Icons.portrait),
                                  child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                                  width: 43,
                                  height: 43,
                                )
                              : ClipRRect(borderRadius: BorderRadius.circular(22.5), child: UIHelper.getImage(friendImgUrl, 44, 44)),
                          //: ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(img_url, 43, 43)),
                          UIHelper.horizontalSpaceSmall,
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Text(memberinfo['name'] ?? '').fontSize(15).fontWeight(FontWeight.w500),
                              Text(friendinfo['member_first_name']).fontSize(15).fontWeight(FontWeight.w500),
                              UIHelper.verticalSpaceTiny,
                              Text('')
                              // UIHelper.verticalSpaceMedium,
                            ],
                          )),
                        ],
                      ),
                      UIHelper.hairLineWidget()
                    ],
                  ),
                ),
              );
            },
            shrinkWrap: true,
            itemCount: isSearch ? model.recentFriends.length : snapshot.data!.length,
            physics: ClampingScrollPhysics(),
          );
        });
  }

  Widget tabView(BuildContext context, ChatListViewModel model) {
    return DefaultTabController(
        length: 2, // length of tabs
        initialIndex: 0,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          Container(
            child: TabBar(
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              indicatorColor: activeColor,
              tabs: [
                Tab(text: 'Patients'),
                Tab(text: 'Chats'),
              ],
            ),
          ),
          Container(
            height: Screen.height(context) / 1.59,
            child: model.isBusy
                ? CircularProgressIndicator()
                : TabBarView(children: <Widget>[
                    CustomScrollView(slivers: [
                      SliverList(
                          delegate: SliverChildListDelegate([
                        Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(top: 5, left: 15),
                              child: Text('Requests').bold(),
                            ),
                            requestfriendsList(context),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(top: 5, left: 15),
                              child: Text('Friends').bold(),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            model.recentFriends.length != 0
                                ? friendsList(model)
                                : Center(
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                      Center(
                                        child: Text('No Friends found'),
                                      )
                                    ]),
                                  )
                          ],
                        )
                      ])),
                    ]),
                    Container(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
                        child: StreamBuilder<List<CubeDialog?>?>(
                          stream: locator<ConnectyCubeServices>().cubeDialogs.outStream,
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? snapshot.data!.length > 0
                                    ? ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          CubeDialog cubeDialog = snapshot.data![index]!;
                                          return getBubbleItem(cubeDialog);
                                        })
                                    : onEmptyChatList(context)

                                //if no conversation
                                : Center(
                                    child: CircularProgressIndicator(),
                                  );
                          },
                        ),
                      ),
                    )
                  ]),
          )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppStaticBar(),
      body: SafeArea(
          top: false,
          child: ViewModelBuilder<ChatListViewModel>.reactive(
              onModelReady: (model) async {
                await model.getRecentFriends();
                //model.getMemberProfile(widget.memberId);
              },
              builder: (context, model, child) {
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    width: Screen.width(context),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // UIHelper.verticalSpaceSmall,
                      addHeader(context,  true),
                      UIHelper.verticalSpaceSmall,
                      //  UIHelper.hairLineWidget(),
                      // UIHelper.verticalSpaceMedium,
                      //   sizeshowSearchField(context),
                      showSearchField(context),
                      //  topSearchField(context),
                      UIHelper.verticalSpaceSmall,
                      tabView(context, model),
                      UIHelper.verticalSpaceSmall,
                    ]));
              },
              viewModelBuilder: () => ChatListViewModel())),
    );
  }
}

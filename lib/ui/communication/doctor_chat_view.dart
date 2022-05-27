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
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/timeago.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/communication/chat_dialog_screen.dart';
import 'package:swarapp/ui/communication/doctor_chat_model.dart';
import 'package:swarapp/ui/communication/search_user_cc.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart';
import 'package:swarapp/ui/invites/contact_view.dart';
import 'package:swarapp/ui/invites/find_doctorList_view.dart';
import 'package:swarapp/ui/invites/find_friendsList_view.dart';
import 'package:swarapp/ui/invites/request_view.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class DocChatListView extends StatefulWidget {
  DocChatListView({Key? key}) : super(key: key);

  @override
  _DocChatListViewState createState() => _DocChatListViewState();
}

class _DocChatListViewState extends State<DocChatListView> {
  late CubeUser currentUser;
  TextEditingController searchController = TextEditingController();
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  ApiService apiService = locator<ApiService>();
  bool isReadOnly = false;
  bool isExist = false;
  var screenSize;
  String network_img_url = '';
  String img_url = '';
  AppLifecycleState? appState;
  List<dynamic> requested_list = [];
  @override
  void initState() {
    super.initState();
    isExist = false;
    getUserList();
    getInviteUserList();
    // await locator<ApiService>().getRecentFriends(preferencesService.userId, "60dae3e440f5032614a8d24b");
//getAllUserList
    // bool isChatDisconnected = CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.Closed || CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.ForceClosed;
    // if (isChatDisconnected && CubeChatConnection.instance.currentUser != null) {
    //   CubeChatConnection.instance.relogin();
    // }
  }

  void getUserList() async {
    final resp = await apiService.getAllUserList();
  }

  void getInviteUserList() async {
    String userId = preferencesService.userId;
    final resp = await apiService.getInviteUserList(userId);
  }

  void getChatDialogs() async {
    currentUser = (await SharedPrefs.getUser())!;
    //print(currentUser.avatar);
    await connectyCubeServices.getCubeDialogs();
  }

  void _getUserList(String search) async {
    if (currentUser != null) {
      getUsersByFullName(search).then((users) {
        // _isDialogContinues = false;
        log(
          "getDialogs: $users",
        );
      });
    }
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

  Widget topSearchField(
    BuildContext context,
  ) {
    return SizedBox(
      height: 38,
      child: Container(
        //padding: EdgeInsets.symmetric(horizontal: 8),
        //decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                  //padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
                  height: 38,
                  child: GestureDetector(
                    onTap: () async {
                      //navigateToSearchCCUser(false);
                    },
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        // model.updateOnTextSearch(value);
                        navigateToSearchCCUser(false);
                      },
                      onTap: () async {
                        navigateToSearchCCUser(false);
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
                                    FocusManager.instance.primaryFocus!.unfocus();
                                  }),
                          contentPadding: EdgeInsets.only(left: 20),
                          enabledBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0x00CCCCCC)),
                          focusedBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Colors.white),
                          focusedErrorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Colors.white),
                          errorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                          filled: true,
                          hintStyle: new TextStyle(color: Colors.grey[800]),
                          hintText: "Search contacts....       ",
                          fillColor: fieldBgColor),
                    ),
                  )),
            ),
            UIHelper.horizontalSpaceSmall,
            PopupMenuButton(
                icon: Icon(Icons.more_vert),
//                color: Colors.yellowAccent,
                elevation: 20,
                enabled: true,
                onSelected: (value) async {
                  setState(() {
                    String _value = value.toString();
                  });

                  if (value.toString() == "1") {
                    Get.to(() => RequestView());
                  }
                  if (value.toString() == "2") {
                    Get.to(() => ContactView(type: "Contacts"));
                  }
                  if (value.toString() == "3") {
                    Get.to(() => DoctorsListView());
                  }
                  if (value.toString() == "4") {
                    inviteFriends();
                  }
                  //inviteFriends
                  if (value.toString() == "5") {
                    //new group
                    dynamic newDialog = await Get.to(
                      () => SearchUserFromCC(currentUser: currentUser, isGroup: true, isNew: false),
                    );
                    if (newDialog != null) {
                      await Get.to(() => ChatDialogScreen(currentUser, newDialog['dialog']));
                      getChatDialogs();
                      return;
                    }
                    if (locator<PreferencesService>().isNewGroupCreated) {
                      await Get.to(() => ChatDialogScreen(currentUser, locator<PreferencesService>().newDialog));
                      getChatDialogs();
                      locator<PreferencesService>().isNewGroupCreated = false;
                    }
                  }
                },
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text("Requests"),
                        value: 1,
                      ),
                      PopupMenuItem(
                        child: Text("Contacts"),
                        value: 2,
                      ),
                      PopupMenuItem(
                        child: Text("Find Doctors"),
                        value: 3,
                      ),
                      PopupMenuItem(
                        child: Text("Invite a Friend"),
                        value: 4,
                      ),
                      PopupMenuItem(
                        child: Text("New Group"),
                        value: 5,
                      )
                    ]),
          ],
        ),
      ),
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
                          // contentPadding: EdgeInsets.only(left: 12.0),
                          // border: UIHelper.getInputBorder(4, radius: 12, borderColor: Colors.transparent),
                          // enabledBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Colors.transparent),
                          // focusedBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Colors.transparent),
                          // focusedErrorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Colors.transparent),
                          // errorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                          filled: true,
                          hintStyle: new TextStyle(color: Colors.grey[800]),
                          hintText: "Find Doctors",
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
          Container(
            //  decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.grey.shade300),
            child: PopupMenuButton(
                icon: Icon(Icons.more_vert),
//                color: Colors.yellowAccent,
                elevation: 20,
                enabled: true,
                onSelected: (value) async {
                  setState(() {
                    String _value = value.toString();
                  });

                  if (value.toString() == "1") {
                    Get.to(() => RequestView());
                  }
                  if (value.toString() == "2") {
                    Get.to(() => ContactView(type: "Contacts"));
                  }
                  if (value.toString() == "3") {
                    Get.to(() => DoctorsListView());
                  }
                  if (value.toString() == "4") {
                    inviteFriends();
                  }
                  //inviteFriends
                  if (value.toString() == "5") {
                    //new group
                    dynamic newDialog = await Get.to(
                      () => SearchUserFromCC(currentUser: currentUser, isGroup: true, isNew: false),
                    );
                    if (newDialog != null) {
                      await Get.to(() => ChatDialogScreen(currentUser, newDialog['dialog']));
                      getChatDialogs();
                      return;
                    }
                    if (locator<PreferencesService>().isNewGroupCreated) {
                      await Get.to(() => ChatDialogScreen(currentUser, locator<PreferencesService>().newDialog));
                      getChatDialogs();
                      locator<PreferencesService>().isNewGroupCreated = false;
                    }
                  }
                },
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text("Requests"),
                        value: 1,
                      ),
                      PopupMenuItem(
                        child: Text("Contacts"),
                        value: 2,
                      ),
                      PopupMenuItem(
                        child: Text("Find Doctors"),
                        value: 3,
                      ),
                      PopupMenuItem(
                        child: Text("Invite a Friend"),
                        value: 4,
                      ),
                      PopupMenuItem(
                        child: Text("New Group"),
                        value: 5,
                      )
                    ]),
          ),
        ]));
  }

  Widget requestfriendsList(DoctorChatmodel model) {
    return model.RequestedInfo.length > 0
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: model.RequestedInfo.length,
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              // if (model.RequestedInfo[index]['profileData']['azureBlobStorageLink'] != null) {
              //   img_url = '${ApiService.fileStorageEndPoint}${model.RequestedInfo[index]['profileData']['azureBlobStorageLink']}';
              // } else {
              //   print("NOT UPDATEDDD");
              // }
              return Container(
                padding: EdgeInsets.all(2),
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
                        // network_img_url == ''
                        //     ? Container(
                        //         // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                        //         // child: Icon(Icons.portrait),
                        //         child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                        //         width: 43,
                        //         height: 43,
                        //       )
                        //     : ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(network_img_url, 43, 43)),

                        img_url == ''
                            ? Container(
                                // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                                // child: Icon(Icons.portrait),
                                child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                                width: 43,
                                height: 43,
                              )
                            : ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(img_url, 43, 43)),

                        //: ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(img_url, 43, 43)),
                        SizedBox(width: 5),
                        Expanded(
                            child: Container(
                                child: Row(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Text(memberinfo['name'] ?? '').fontSize(15).fontWeight(FontWeight.w500),
                              Text(
                                'Dr.' + model.RequestedInfo[index]['profileData']['name'],
                                overflow: TextOverflow.clip,
                              ).fontSize(15).fontWeight(FontWeight.w600),
                              UIHelper.verticalSpaceTiny,
                              Text(
                                model.RequestedInfo[index]['profileData']['specialization'] != "" ? model.RequestedInfo[index]['profileData']['specialization'][0] : "",
                                overflow: TextOverflow.clip,
                              ).fontSize(13),
                              // UIHelper.verticalSpaceMedium,
                            ],
                          ),
                          UIHelper.horizontalSpaceSmall,
                          ElevatedButton(
                              onPressed: () async {
                                // check_accept(context, model, notif_Info["_id"], notif_Info["reference_id"], index);
                                // await model.getRecentFriends();
                                Loader.show(context);
                                await model.CancelRequest(model.RequestedInfo[index]['_id'], model.RequestedInfo[index]['reference_id']);
                                await model.getRequestedList();
                                await model.getDoctorList();
                                setState(() {});
                                Loader.hide();
                              },
                              child: Text('Cancel Request').textColor(Colors.white),
                              style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(90, 28)),
                                  elevation: MaterialStateProperty.all(0),
                                  backgroundColor: MaterialStateProperty.all(cancelbuttonColor),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                        ]))),
                      ],
                    ),
                    UIHelper.hairLineWidget()
                  ],
                ),
              );
            },
          )
        : Center(child: Text('No Records found'));
  }

  Widget friendsList(DoctorChatmodel model) {
    return model.doctoracceptedList.length > 0
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: model.doctoracceptedList.length,
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              if (model.doctoracceptedList[index][0]['azureBlobStorageLink'] != null) {
                network_img_url = '${ApiService.fileStorageEndPoint}${model.doctoracceptedList[index][0]['azureBlobStorageLink']}';
              } else {
                print("NOT UPDATEDDD");
              }
              return Container(
                padding: EdgeInsets.all(2),
                margin: EdgeInsets.only(bottom: 8),
                //  decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.black12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        network_img_url == ''
                            ? Container(
                                // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                                // child: Icon(Icons.portrait),
                                child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                                width: 43,
                                height: 43,
                              )
                            : ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(network_img_url, 43, 43)),
                        UIHelper.horizontalSpaceSmall,
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Text(memberinfo['name'] ?? '').fontSize(15).fontWeight(FontWeight.w500),
                            Text('Dr. ' + model.doctoracceptedList[index][0]['name']).fontSize(15).fontWeight(FontWeight.w500),
                            UIHelper.verticalSpaceTiny,
                            Text(model.doctoracceptedList[index][0]['specialization'].isNotEmpty ? model.doctoracceptedList[index][0]['specialization'][0] : "").fontSize(13),
                            // UIHelper.verticalSpaceMedium,
                          ],
                        )),
                      ],
                    ),
                    UIHelper.hairLineWidget()
                  ],
                ),
              );
            },
          )
        : Center(
            child: Text('No Records Found'),
          );
  }

  Widget tabView(BuildContext context, DoctorChatmodel model) {
    return DefaultTabController(
        length: 2, // length of tabs
        initialIndex: 0,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          Container(
            child: TabBar(
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              indicatorColor: activeColor,
              tabs: [
                Tab(text: 'Doctors'),
                Tab(text: 'Chats'),
              ],
            ),
          ),
          Container(
            height: Screen.height(context) / 1.44,
            child: TabBarView(children: <Widget>[
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
                      SizedBox(
                        height: 10,
                      ),
                      requestfriendsList(model),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 5, left: 15),
                        child: Text('Doctors').bold(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      friendsList(model),
                    ],
                  )
                ])),
              ]),
              Container(
                child: Expanded(
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
                ),
              )
            ]),
          )
        ]));
  }

// bool messageIsRead(CubeDialog _cubeDialog) {
//         log("[getReadDeliveredWidget] messageIsRead");
//         if (_cubeDialog.type == CubeDialogType.PRIVATE) return message.readIds != null && (message.recipientId == null || message.readIds!.contains(message.recipientId));
//         return _cubeDialog.message.readIds != null && message.readIds!.any((int id) => id != _cubeUser.id && _occupants.keys.contains(id));
//       }

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
                      dialog.lastMessageUserId == currentUser.id
                          ? Row(children: [
                              // Icon(
                              //   Icons.done_all,
                              //   size: 12.0,
                              //   color: Colors.green,
                              // ),
                              Text("You : ", style: TextStyle(color: Colors.black38, fontSize: 12.0, fontWeight: FontWeight.w800)),
                              //  Expanded(
                              //    child:Text(lastmessage, overflow: TextOverflow.ellipsis).fontSize(12)),
                              SizedBox(width: screenSize.width - 160, child: Text(lastmessage, overflow: TextOverflow.ellipsis).fontSize(12)),
                            ])
                          : Flexible(child: Text(lastmessage, overflow: TextOverflow.ellipsis).fontSize(12)),

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

  void inviteFriends() async {
    Loader.show(context);
    String userId = locator<PreferencesService>().userId;
    String inviteType = 'patient_invite_doctor';
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

  Widget top(BuildContext context) {
    return Row(children: [
      showSearchField(context),
      PopupMenuButton(
          icon: Icon(Icons.more_vert),
//                color: Colors.yellowAccent,
          elevation: 20,
          enabled: true,
          onSelected: (value) async {
            setState(() {
              String _value = value.toString();
            });

            if (value.toString() == "1") {
              Get.to(() => RequestView());
            }
            if (value.toString() == "2") {
              Get.to(() => ContactView(type: "Contacts"));
            }
            if (value.toString() == "3") {
              Get.to(() => DoctorsListView());
            }
            if (value.toString() == "4") {
              inviteFriends();
            }
            //inviteFriends
            if (value.toString() == "5") {
              //new group
              dynamic newDialog = await Get.to(
                () => SearchUserFromCC(currentUser: currentUser, isGroup: true, isNew: false),
              );
              if (newDialog != null) {
                await Get.to(() => ChatDialogScreen(currentUser, newDialog['dialog']));
                getChatDialogs();
                return;
              }
              if (locator<PreferencesService>().isNewGroupCreated) {
                await Get.to(() => ChatDialogScreen(currentUser, locator<PreferencesService>().newDialog));
                getChatDialogs();
                locator<PreferencesService>().isNewGroupCreated = false;
              }
            }
          },
          itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("Requests"),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text("Contacts"),
                  value: 2,
                ),
                PopupMenuItem(
                  child: Text("Find Doctors"),
                  value: 3,
                ),
                PopupMenuItem(
                  child: Text("Invite a Friend"),
                  value: 4,
                ),
                PopupMenuItem(
                  child: Text("New Group"),
                  value: 5,
                )
              ]),
      UIHelper.horizontalSpaceSmall,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    //ischatListReload
    if (locator<PreferencesService>().ischatListReload.value == true) {
      locator<PreferencesService>().ischatListReload.value = false;
      getChatDialogs();
      // reloadMemberList();
    }

    return Scaffold(
        //appBar: SwarAppBar(2),
        appBar: SwarAppStaticBar(),
        backgroundColor: Colors.white,
        body: SafeArea(
            top: false,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                width: Screen.width(context),
                child: ViewModelBuilder<DoctorChatmodel>.reactive(
                    onModelReady: (model) async {
                      Loader.show(context);
                      await model.acceptedList(preferencesService.userId);
                      await model.getRequestedList();
                      Loader.hide();
                      setState(() {});
                      // await model.getUserProfile(false);
                      // await model.getCountries();
                    },
                    builder: (context, model, child) {
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // UIHelper.verticalSpaceSmall,
                        UIHelper.addHeader(context, "SWAR Chats (Doctors and other specialists)", true),
                        UIHelper.verticalSpaceSmall,
                        //  UIHelper.hairLineWidget(),
                        // UIHelper.verticalSpaceMedium,
                        //   sizeshowSearchField(context),
                        showSearchField(context),
                        //  topSearchField(context),
                        UIHelper.verticalSpaceSmall,
                        tabView(context, model),
                        UIHelper.verticalSpaceSmall,
                      ]);
                    },
                    viewModelBuilder: () => DoctorChatmodel()))));
  }
}

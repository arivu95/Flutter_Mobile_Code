import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'package:swarapp/ui/invites/requestView_model.dart';
import 'package:swarapp/ui/invites/request_view.dart';
import 'package:swarapp/ui/invites/widget/contact_list_widget.dart';
import 'package:swarapp/ui/invites/widget/find_friends_list_widget.dart';
import 'package:swarapp/ui/invites/widget/find_friends_model.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class FriendsListView extends StatefulWidget {
  FriendsListView({Key? key}) : super(key: key);

  @override
  _FriendsListViewState createState() => _FriendsListViewState();
}

class _FriendsListViewState extends State<FriendsListView> {
  late CubeUser currentUser;
  TextEditingController searchController = TextEditingController();
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  ApiService apiService = locator<ApiService>();
  bool isReadOnly = false;
  bool isgranted = false;
  var screenSize;
  bool isSearch = false;
  final ScrollController _scrollController = ScrollController();
  AppLifecycleState? appState;
  @override
  void initState() {
    super.initState();

    _askPermissions();
    // bool isChatDisconnected = CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.Closed || CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.ForceClosed;
    // if (isChatDisconnected && CubeChatConnection.instance.currentUser != null) {
    //   CubeChatConnection.instance.relogin();
    // }
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      // if (routeName != null) {
      //   Navigator.of(context).pushNamed(routeName);
      // }
      setState(() {
        isgranted = true;
      });
      // Get.to(() => ContactListPage());
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted && permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar = SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  Widget showSearchField(BuildContext context, FindFriendmodel model) {
    return SizedBox(
      height: 38,
      child: Container(
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
                    model.getUsers_search(value);

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
                                model.getUsers_search('');
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
                      hintText: "Search members & friends  ",
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

//             PopupMenuButton(
//                 icon: Icon(Icons.more_vert),
// //                color: Colors.yellowAccent,
//                 elevation: 20,
//                 enabled: true,
//                 onSelected: (value) {
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
//                     Get.to(() => FriendsListView);
//                   }
//                   if (value.toString() == "4") {
//                     Get.to(() => inviteFriends());
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
//                     ]),

            //  UIHelper.horizontalSpaceSmall,
          ],
        ),
      ),
    );
  }

  void check_accept(BuildContext context, RequestViewmodel model, String id, String refId, int index) async {
    Loader.show(context);
    var getRes = await model.acceptinvite(id, refId, "accepted");
    if (getRes == 200) {
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

  Future<void> _displayInviteDialog(BuildContext context, dynamic data, String mobileName) async {
    String motherWeight = data['mobilenumber'] != null ? data['mobilenumber'].toString() : '';
    final _textFieldController = TextEditingController();
    String imgUrl = "";
    if (data['azureBlobStorageLink'] != null) {
      imgUrl = '${ApiService.fileStorageEndPoint}${data['azureBlobStorageLink']}';
    }
    void dispose() {
      _textFieldController.dispose();
      super.dispose();
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imgUrl == '' || imgUrl.contains('null')
                    ? Container(
                        // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                        // child: Icon(Icons.portrait),
                        child: Icon(Icons.account_circle, size: 50, color: Colors.grey),
                        width: 60,
                        height: 60,
                      )
                    : ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(imgUrl, 60, 60)),
                UIHelper.horizontalSpaceSmall,
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Text(memberinfo['name'] ?? '').fontSize(15).fontWeight(FontWeight.w500),
                    Text(mobileName).fontSize(15).fontWeight(FontWeight.w500),
                    UIHelper.verticalSpaceTiny,

                    TextField(
                      keyboardType: TextInputType.number,
                      //data['mother_weight'].toString(),
                      // controller: _textFieldController..text = motherWeight,
                      onChanged: (value) {
                        // print("jbj" + value);
                        // motherWeight = value;
                        // setState(() {
                        //   motherWeight = value;
                        // });
                      },
                      // inputFormatters: [
                      //   new WhitelistingTextInputFormatter(RegExp(r'^(\d+)?\.?\d{0,2}')),
                      // ],
                      inputFormatters: [
                        // is able to enter lowercase letters

                        FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(hintText: "Email"),
                    ),

                    TextField(
                      keyboardType: TextInputType.number,
                      //data['mother_weight'].toString(),
                      controller: _textFieldController..text = motherWeight,
                      onChanged: (value) {
                        print("jbj" + value);
                        motherWeight = value;
                        setState(() {
                          motherWeight = value;
                        });
                      },
                      // inputFormatters: [
                      //   new WhitelistingTextInputFormatter(RegExp(r'^(\d+)?\.?\d{0,2}')),
                      // ],
                      inputFormatters: [
                        // is able to enter lowercase letters

                        FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(hintText: "Mobile Number"),
                    ),
                  ],
                )),
              ],
            ),
            insetPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textFieldController,
                builder: (context, value, child) {
                  return ElevatedButton(
                      onPressed: value.text.isNotEmpty
                          ? () async {
                              // print(_textFieldController.text);
                              // Navigator.pop(context);
                              // await model.updateMaternityInfo(_textFieldController.text, data, data['_id']);
                            }
                          : null,
                      child: Text('Send Invite'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (!states.contains(MaterialState.disabled)) {
                            return Colors.green;
                          }
                          return Colors.black12;
                        }),
                      ));
                },
              ),
            ],
          );
        });
  }

  Widget findfriendsList(FindFriendmodel model) {
    List<dynamic> dbUserList = isSearch ? model.searchBy_lists : preferencesService.usersListStream!.value!;
    return dbUserList != null
        ? ListTileTheme(
            contentPadding: EdgeInsets.all(2),
            iconColor: Colors.red,
            textColor: Colors.black54,
            tileColor: fieldBgColor,
            style: ListTileStyle.list,
            dense: true,
            child: Scrollbar(
              isAlwaysShown: true,
              child: ListView.builder(
                itemCount: dbUserList.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  // Contact c = db_user_list!.elementAt(index);
                  dynamic getUserData = dbUserList.elementAt(index);
                  String imgUrl = "";

                  String userid = getUserData['_id'];
                  String isAccepted = '';
                  List<dynamic> inviteList = preferencesService.userInviteListStream!.value!;
                  for (var each in inviteList) {
                    if (each['receiver_id'] != null) {
                      if (each['receiver_id'].contains(userid)) {
                        if (each['is_accepted'] == true) {
                          isAccepted = 'accepted';
                        } else if (each['is_accepted'] == false) {
                          isAccepted = 'requested';
                        } else {
                          isAccepted = 'new';
                        }
                        print("invite....person");
                      }
                    }
                  }

                  if (getUserData['azureBlobStorageLink'] != null) {
                    imgUrl = '${ApiService.fileStorageEndPoint}${getUserData['azureBlobStorageLink']}';
                  }
                  return Column(children: [
                    Card(
                        margin: EdgeInsets.all(5),
                        child: ListTile(
                          onTap: () {},
                          leading: imgUrl == '' || imgUrl.contains('null')
                              ? Container(
                                  // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                                  // child: Icon(Icons.portrait),
                                  child: Icon(Icons.account_circle, size: 53, color: Colors.grey),
                                  width: 53,
                                  height: 60,
                                )
                              :

                              // Container(
                              //     // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                              //     // child: Icon(Icons.portrait),
                              //     child: ClipRRect(borderRadius: BorderRadius.circular(40.0), child: UIHelper.getImage(img_url, 35, 50)),
                              //     width: 60,
                              //     height: 60,
                              //   ),

                              ClipRRect(borderRadius: BorderRadius.circular(30.0), child: UIHelper.getImage(imgUrl, 50, 50)),
                          title: Text(getUserData['name']).bold(),
                          trailing: isAccepted == 'accepted'
                              ? Text('Friend').textColor(Colors.green.shade500).bold()
                              : isAccepted == 'requested'
                                  ? Text('Requested').bold()
                                  : ElevatedButton(
                                      onPressed: () async {
                                        // finalList<dynamic> db = preferencesService.usersListStream!.value!;
                                        // dynamic s = c.phones;
                                        // dynamic selected_person = {};
                                        String receiverId = getUserData['_id'];
                                        Loader.show(context);
                                        await model.inviteSwarUser(receiverId);
                                        Loader.hide();
                                      },
                                      child: Text('Invite').textColor(Colors.white),
                                      style: ButtonStyle(
                                          minimumSize: MaterialStateProperty.all(Size(90, 28)),
                                          elevation: MaterialStateProperty.all(0),
                                          backgroundColor: MaterialStateProperty.all(Colors.green),
                                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                        )),
                  ]);
                },
              ),
            ))
        : Center(
            child: CircularProgressIndicator(),
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
              child: ViewModelBuilder<FindFriendmodel>.reactive(
                  onModelReady: (model) async {
                    // await model.getNotification();
                    //model.getMemberProfile(widget.memberId);
                  },
                  builder: (context, model, child) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // UIHelper.verticalSpaceSmall,
                      UIHelper.addHeader(context, "Find Friends", true),
                      UIHelper.verticalSpaceSmall,
                      //  UIHelper.hairLineWidget(),
                      // UIHelper.verticalSpaceMedium,
                      showSearchField(context, model),
                      UIHelper.verticalSpaceSmall,
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Container(
                      //       // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                      //       // child: Icon(Icons.portrait),
                      //       child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                      //       width: 43,
                      //       height: 43,
                      //     ),
                      //     UIHelper.horizontalSpaceSmall,
                      //     Expanded(
                      //         child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text("New Contact").fontSize(15).fontWeight(FontWeight.w500),
                      //       ],
                      //     )),
                      //   ],
                      // ),
                      Expanded(
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
                            // child: isSearch ? FindFriendListPage(searchby: isSearch) : FindFriendListPage(searchby: false),

                            child: findfriendsList(model)),
                      ),
                      UIHelper.verticalSpaceSmall,
                    ]);
                  },
                  viewModelBuilder: () => FindFriendmodel())),
        ));
  }
}

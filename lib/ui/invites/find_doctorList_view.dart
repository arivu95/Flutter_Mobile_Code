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
import 'package:swarapp/shared/dotted_line.dart';
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
import 'package:swarapp/ui/invites/find_doctorList_model.dart';
import 'package:swarapp/ui/invites/requestView_model.dart';
import 'package:swarapp/ui/invites/request_view.dart';
import 'package:swarapp/ui/invites/widget/contact_list_widget.dart';
import 'package:swarapp/ui/invites/widget/find_friends_list_widget.dart';
import 'package:swarapp/ui/invites/widget/find_friends_model.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class DoctorsListView extends StatefulWidget {
  DoctorsListView({Key? key}) : super(key: key);

  @override
  _DoctorsListViewState createState() => _DoctorsListViewState();
}

class _DoctorsListViewState extends State<DoctorsListView> {
  late CubeUser currentUser;
  TextEditingController searchController = TextEditingController();
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  ApiService apiService = locator<ApiService>();
  bool isReadOnly = false;
  bool isgranted = false;
  var screenSize;
  bool isSearch = false;
  String img_url = "";
  final ScrollController _scrollController = ScrollController();
  AppLifecycleState? appState;
  dynamic levelStates = ['Entry', 'Enhanced', 'Verified', 'SWAR'];
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

  Widget showSearchField(BuildContext context, FindDoctormodel model) {
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
    var getRes = await model.DoctoracceptInvite(id, refId, "accepted");
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
                img_url == '' || img_url.contains('null')
                    ? Container(
                        // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                        // child: Icon(Icons.portrait),
                        child: Icon(Icons.account_circle, size: 50, color: Colors.grey),
                        width: 60,
                        height: 60,
                      )
                    : ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(img_url, 60, 60)),
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

  Widget findfriendsList(FindDoctormodel model) {
    List<dynamic> dbUserList = isSearch ? model.searchBy_lists : model.doc_verified_list;
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
                  if (dbUserList[index]['azureBlobStorageLink'] != null) {
                    img_url = '${ApiService.fileStorageEndPoint}${dbUserList[index]['azureBlobStorageLink']}';
                  }
                  String userid = dbUserList[index]['_id'];
                  String isAccepted = '';
                  List<dynamic> inviteList = preferencesService.userInviteListStream!.value!;
                  for (var each in inviteList) {
                    if (each['receiver_id'] != null) {
                      if (each['receiver_id'].contains(userid)) {
                        if (each['is_accepted'] == true) {
                          isAccepted = 'accepted';
                        } else if (each['is_accepted'] == false) {
                          isAccepted = 'requested';
                        } else if (each['email'] != null) {
                          isAccepted = 'accepted';
                        } else {
                          isAccepted = 'new';
                        }
                        print("invite....person");
                      }
                    }
                  }
                  return Column(
                    children: [
                      GestureDetector(
                          child: Container(
                              width: Screen.width(context) - 32,
                              decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
                              child: Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(children: [
                                    img_url == ""
                                        ? Container(
                                            height: 80,
                                            width: 63,
                                            decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                                            child: Icon(Icons.person, color: Colors.black, size: 35),
                                          )
                                        : Container(height: 80, width: 63, child: UIHelper.getImage(img_url, 60, 60))
                                  ]),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                    child: Container(
                                        child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    UIHelper.verticalSpaceTiny,
                                    Text('Dr. ' + model.doc_verified_list[index]['name']).fontSize(12).fontWeight(FontWeight.w600),
                                    UIHelper.verticalSpaceTiny,
                                    Text(model.doc_verified_list[index]['specialization'].length > 0 && model.doc_verified_list[index]['specialization'][0] != null
                                            ? model.doc_verified_list[index]['specialization'][0]
                                            : '')
                                        .fontWeight(FontWeight.w600)
                                        .textColor(Colors.black38),
                                    Text('M.B.B.S, Diploma').fontSize(12).fontWeight(FontWeight.w600),
                                    UIHelper.verticalSpaceSmall,
                                    Container(
                                      width: 180,
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Container(
                                            child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 20, left: 15, right: 0, top: 10),
                                              child: DottedLine(
                                                dashColor: Colors.red,
                                                lineThickness: 2,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    model.doc_verified_list[index]['doctor_profile_id']['stage'] == 'verified'
                                                        ? Row(children: [
                                                            Container(
                                                                width: 21,
                                                                height: 21,
                                                                decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red),
                                                                child: Icon(Icons.done, size: 12, color: Colors.white)),
                                                            UIHelper.horizontalSpaceMedium,
                                                            Container(
                                                                width: 21,
                                                                height: 21,
                                                                decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red),
                                                                child: Icon(Icons.done, size: 12, color: Colors.white)),
                                                            UIHelper.horizontalSpaceMedium,
                                                            Container(
                                                                width: 21,
                                                                height: 21,
                                                                decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red),
                                                                child: Icon(Icons.done, size: 12, color: Colors.white)),
                                                            UIHelper.horizontalSpaceMedium,
                                                            Container(width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
                                                          ])
                                                        : Row(children: [
                                                            Container(
                                                                width: 21,
                                                                height: 21,
                                                                decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red),
                                                                child: Icon(Icons.done, size: 12, color: Colors.white)),
                                                            UIHelper.horizontalSpaceMedium,
                                                            Container(
                                                                width: 21,
                                                                height: 21,
                                                                decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red),
                                                                child: Icon(Icons.done, size: 12, color: Colors.white)),
                                                            UIHelper.horizontalSpaceMedium,
                                                            Container(
                                                                width: 21,
                                                                height: 21,
                                                                decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red),
                                                                child: Icon(Icons.done, size: 12, color: Colors.white)),
                                                            UIHelper.horizontalSpaceMedium,
                                                            Container(
                                                                width: 21,
                                                                height: 21,
                                                                decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red),
                                                                child: Icon(Icons.done, size: 12, color: Colors.white)),
                                                          ]),

                                                    //Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text(state).fontWeight(FontWeight.w600)
                                                    //state == gt
                                                    // preferencesService.stage_level_count! == i || preferencesService.stage_level_count! > i
                                                    //     ? Container(
                                                    //         width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red), child: Icon(Icons.done, size: 12, color: Colors.white))
                                                    //     : Container(width: 21, height: 21, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
                                                    //levelStates  dynamic levelStates = ['Entry', 'Enhanced', 'Verified', 'SWAR Dr.'];
                                                    Row(
                                                      children: [
                                                        Text('Entry ').fontWeight(FontWeight.w600).fontSize(10),
                                                        Text('Enhanced ').fontWeight(FontWeight.w600).fontSize(10),
                                                        Text('Verified ').fontWeight(FontWeight.w600).fontSize(10),
                                                        Text('SWAR Dr. ').fontWeight(FontWeight.w600).fontSize(10)
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                      ),
                                    ),
                                  ],
                                ))),
                                Column(
                                  children: [
                                    Container(
                                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                        child: Row(
                                          children: [
                                            Text('Patients visit').fontSize(10),
                                            SizedBox(width: 5),
                                            model.doc_verified_list[index]['count'] != null
                                                ? Text(model.doc_verified_list[index]['count']).fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor)
                                                : Text('0').fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor),
                                          ],
                                        )),
                                    UIHelper.verticalSpaceMedium,
                                    isAccepted == 'accepted'
                                        ? Container()
                                        : isAccepted == 'requested'
                                            ? Container(
                                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                decoration: UIHelper.roundedButtonWithGradient(10, [
                                                  Color(0xFFFC7D0D),
                                                  Color(0xFFE02A53),
                                                  Color(0xFFDA1B60),
                                                ]),
                                                child: Text('Requested').fontSize(14).bold().textColor(Colors.white),
                                              )
                                            : GestureDetector(
                                                onTap: () async {
                                                  // finalList<dynamic> db = preferencesService.usersListStream!.value!;
                                                  // dynamic s = c.phones;
                                                  // dynamic selected_person = {};

                                                  String receiverId = model.doc_verified_list[index]['_id'];
                                                  Loader.show(context);
                                                  await model.inviteSwarUser(receiverId);
                                                  await model.getRequestedList();
                                                  setState(() {});
                                                  Loader.hide();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                  decoration: UIHelper.roundedButtonWithGradient(10, [
                                                    Color(0xFFFC7D0D),
                                                    Color(0xFFE02A53),
                                                    Color(0xFFDA1B60),
                                                  ]),
                                                  child: Text('Request chat').fontSize(14).bold().textColor(Colors.white),
                                                )),
                                    UIHelper.verticalSpaceMedium,
                                  ],
                                ),
                              ]))),
                      UIHelper.verticalSpaceSmall,
                    ],
                  );
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
              padding: EdgeInsets.symmetric(horizontal: 5),
              width: Screen.width(context),
              child: ViewModelBuilder<FindDoctormodel>.reactive(
                  onModelReady: (model) async {
                    Loader.show(context);
                    await model.getDoctorList();
                    setState(() {});
                    Loader.hide();
                  },
                  builder: (context, model, child) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // UIHelper.verticalSpaceSmall,
                      UIHelper.addHeader(context, "Find Doctors", true),
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

                            // child: isSearch ? FindFriendListPage(searchby: isSearch) : FindFriendListPage(searchby: false),

                            child: findfriendsList(model)),
                      ),
                      UIHelper.verticalSpaceSmall,
                    ]);
                  },
                  viewModelBuilder: () => FindDoctormodel())),
        ));
  }
}

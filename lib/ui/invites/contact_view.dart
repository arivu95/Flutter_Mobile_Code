import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
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
import 'package:swarapp/ui/invites/find_friendsList_view.dart';
import 'package:swarapp/ui/invites/requestView_model.dart';
import 'package:swarapp/ui/invites/request_view.dart';
import 'package:swarapp/ui/invites/widget/contact_list_widget.dart';
import 'package:swarapp/ui/invites/widget/find_friends_list_widget.dart';
import 'package:swarapp/ui/invites/widget/find_friends_model.dart';

class ContactView extends StatefulWidget {
  final String type;
  ContactView({Key? key, required this.type}) : super(key: key);

  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  late CubeUser currentUser;
  TextEditingController searchController = TextEditingController();
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  ApiService apiService = locator<ApiService>();
  bool isReadOnly = false;
  bool isgranted = false;
  var screenSize;

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

  Widget showSearchField(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  // navigateToSearchCCUser(false);
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
                        color: Colors.black12,
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
                      contentPadding: EdgeInsets.only(left: 1),
                      border: UIHelper.getInputBorder(4, radius: 12, borderColor: Colors.transparent),
                      // enabledBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      // focusedBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      // focusedErrorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      // errorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "Search...           ",
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
                      UIHelper.addHeader(context, widget.type, true),
                      UIHelper.verticalSpaceSmall,
                      //  UIHelper.hairLineWidget(),
                      // UIHelper.verticalSpaceMedium,
                      // showSearchField(context),
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
                            //  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            //  decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
                            child: isgranted ? ContactListPage() : SizedBox()),
                      ),
                      UIHelper.verticalSpaceSmall,
                    ]);
                  },
                  viewModelBuilder: () => FindFriendmodel())),
        ));
  }
}

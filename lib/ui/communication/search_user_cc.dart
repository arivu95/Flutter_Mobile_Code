import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/connectycube_services.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/communication/group_info_view.dart';
import 'package:swarapp/ui/communication/search_user_ccmodel.dart';

class SearchUserFromCC extends StatefulWidget {
  final CubeUser currentUser;
  final bool isGroup;
  final bool isNew;
  SearchUserFromCC({Key? key, required this.currentUser, required this.isGroup, required this.isNew}) : super(key: key);

  @override
  _SearchUserFromCCState createState() => _SearchUserFromCCState();
}

class _SearchUserFromCCState extends State<SearchUserFromCC> {
  TextEditingController searchController = TextEditingController();
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  List<CubeUser> searchUsers = [];
  List<CubeUser> selectedGroupUsers = [];

  @override
  void initState() {
    super.initState();
    //_getUserList(searchController.text);
  }

  Widget showSearchField(BuildContext context, SearchUserCCModel model) {
    return SizedBox(
      height: 38,
      child: Container(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  // model.updateOnTextSearch(value);
                  model.filterUser(searchController.text);
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
                              model.filterUser(searchController.text);
                              FocusManager.instance.primaryFocus!.unfocus();
                            }),
                    contentPadding: EdgeInsets.only(left: 20),
                    enabledBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                    focusedBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                    focusedErrorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                    errorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                    filled: true,
                    hintStyle: new TextStyle(color: Colors.grey[800]),
                    hintText: "Search",
                    fillColor: fieldBgColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBubbleItem(CubeUser user) {
    return GestureDetector(
      onTap: () {
        if (widget.isGroup) {
          setState(() {
            if (selectedGroupUsers.contains(user)) {
              selectedGroupUsers.remove(user);
            } else {
              selectedGroupUsers.add(user);
            }
          });
        } else {
          Loader.show(context);
          CubeDialog newDialog = CubeDialog(CubeDialogType.PRIVATE, occupantsIds: [user.id!]);
          createDialog(newDialog).then((createdDialog) {
            Loader.hide();
            Get.back(result: {'dialog': createdDialog});
          }).catchError((error) {
            Loader.hide();
            print(error);
          });
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: UIHelper.getProfileImageWithInitials(getPrivateUrlForUid(user.avatar)!, 36, 36, user.fullName!),
                // Container(
                //   color: Colors.black12,
                //   width: 36,
                //   height: 36,
                //   child: Icon(Icons.portrait),
                // ),
              ),
              selectedGroupUsers.contains(user)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        color: activeColor,
                        width: 36,
                        height: 36,
                        child: Icon(Icons.done, color: Colors.white),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          UIHelper.horizontalSpaceSmall,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UIHelper.verticalSpaceSmall,
              Text(user.fullName!).fontSize(14).fontWeight(FontWeight.w600),
              UIHelper.verticalSpaceMedium,
              Container(
                height: 1,
                color: Colors.black12,
                width: Screen.width(context) - 100,
              ),
              UIHelper.verticalSpaceSmall,
            ],
          )
        ],
      ),
    );
  }

  Widget getUserListWidget(BuildContext context, SearchUserCCModel model) {
    return model.searchUsers.length == 0
        ? Center(
            child: UIHelper.tagWidget('No Member Found', Colors.black26),
          )
        : ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: model.searchUsers.length,
            itemBuilder: (context, index) {
              return getBubbleItem(model.searchUsers[index]);
            });
  }

  Widget getCreateGroupWidget(BuildContext context, SearchUserCCModel model) {
    return Column(
      children: [
        selectedGroupUsers.length > 0
            ? Container(
                height: 60,
                width: Screen.width(context),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedGroupUsers.length,
                    itemBuilder: (context, index) {
                      CubeUser user = selectedGroupUsers[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: UIHelper.getProfileImageWithInitials(getPrivateUrlForUid(user.avatar)!, 36, 36, user.fullName!),
                              // child: Container(
                              //   color: Colors.black12,
                              //   width: 36,
                              //   height: 36,
                              //   child: Icon(Icons.portrait),
                              // ),
                            ),
                            UIHelper.verticalSpaceTiny,
                            Text(user.fullName!).fontSize(11),
                          ],
                        ),
                      );
                    }),
              )
            : Text('Select users from the list').fontSize(12),
        UIHelper.hairLineWidget(borderColor: Colors.black),
        UIHelper.verticalSpaceTiny,
        Expanded(child: getUserListWidget(context, model)),
        UIHelper.verticalSpaceSmall,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: selectedGroupUsers.length == 0
                  ? null
                  : () {
                      Get.to(() => GroupInfoView(
                            participants: selectedGroupUsers,
                          ));
                    },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  color: selectedGroupUsers.length == 0 ? Colors.black26 : Colors.red,
                  width: 36,
                  height: 36,
                  child: Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ),
          ],
        )
      ],
    );
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
            padding: EdgeInsets.symmetric(horizontal: 16),
            width: Screen.width(context),
            child: ViewModelBuilder<SearchUserCCModel>.reactive(
                onModelReady: (model) async {
                  await model.getRecentMembers();
                  if (model.ccIds.length > 0) {
                    await model.getUserList('');
                  }
                  //setState(() {});
                  print(model.sourceUsers.toString());
                },
                builder: (context, model, child) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    UIHelper.verticalSpaceSmall,
                    UIHelper.addHeader(context, widget.isNew ?"New Chats" : "Chats", true),
                    UIHelper.verticalSpaceMedium,
                    showSearchField(context, model),
                    UIHelper.verticalSpaceSmall, 
                    model.isBusy
                        ? Expanded(
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
                                child: Center(
                                  child: UIHelper.swarPreloader(),
                                )),
                          )
                        : model.ccIds.length == 0
                            ? Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
                                  child: Center(
                                    child: UIHelper.tagWidget('No Member Found', Colors.black12),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
                                child: widget.isGroup ? getCreateGroupWidget(context, model) : getUserListWidget(context, model),
                              )),
                    UIHelper.verticalSpaceSmall,
                  ]);
                },
                viewModelBuilder: () => SearchUserCCModel()),
          )),
    );
  }
}

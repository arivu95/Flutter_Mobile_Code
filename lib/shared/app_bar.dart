import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/frideos/extended_asyncwidgets.dart';
import 'package:swarapp/services/iap_service.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:swarapp/ui/subscription/subscribed_view.dart';
import 'package:swarapp/ui/subscription/subscription_view.dart';
import 'package:swarapp/app/router.dart';
import 'package:documents_module/src/ui/uploads/uploads_viewmodel.dart';
import 'package:user_module/src/ui/user_profile/profile_view.dart';

class SwarAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int type_header;
  const SwarAppBar(this.type_header, {Key? key}) : super(key: key);

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(50);
  @override
  _SwarAppBarState createState() => _SwarAppBarState();
}

String dropdown_member_id = "";
List<dynamic> members = [];
UploadsViewmodel modelRef = UploadsViewmodel();

class _SwarAppBarState extends State<SwarAppBar> {
  Widget showSearchField(BuildContext context, UploadsViewmodel model) {
    preferencesService.onRefreshRecentDocumentOnUpload!.onChange((isRefresh) {
      if (isRefresh) {
        preferencesService.onRefreshRecentDocumentOnUpload!.value = false;
        model.getMembersList(false);
      }
    });
    return StreamedWidget(
        stream: preferencesService.memebersListStream!.outStream!,
        builder: (context, snapshot) {
          members = preferencesService.memebersListStream!.value!;
          return Row(
            children: <Widget>[
              UIHelper.horizontalSpaceSmall,
              members.length > 1
                  ? DropdownButtonHideUnderline(
                      child: DropdownButton(
                          value: preferencesService.dropdown_user_id != null || preferencesService.dropdown_user_id != "" ? preferencesService.dropdown_user_id : model.selectedMembers,
                          isExpanded: false,
                          items: members.map((e) {
                            return new DropdownMenuItem(
                                value: e['_id'],
                                child: new SizedBox(
                                  width: Screen.width(context) / 3 - 40,
                                  child: new Text(
                                    e['member_first_name'],
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                  ).fontSize(18).bold(),
                                ));
                          }).toList(),
                          onChanged: (value) {
                            print(value);
                            model.getMembersList(false);
                            setState(() {
                              model.selectedMembers = value.toString();
                            });
                            int found = members.indexWhere((val) => val['_id'] == model.selectedMembers);
                            print(found); // Output you will get is 1
                            String selectedMemberName = members[found]['member_first_name'];
                            String selectedMemberDob = members[found]['date_of_birth'];
                            String selectedMemberAge = members[found]['age'].toString();
                            print(selectedMemberName);
                            setState(() {
                              model.selectedMemberName = selectedMemberName;
                              model.selectedMemberDob = selectedMemberDob;
                              model.selectedMemberAge = selectedMemberAge;
                              // isChange = true;
                            });
                            dropdown_member_id = model.selectedMembers;
                            preferencesService.dropdown_user_id = model.selectedMembers;
                            preferencesService.dropdown_user_name = model.selectedMemberName;
                            preferencesService.dropdown_user_dob = model.selectedMemberDob;
                            preferencesService.dropdown_user_age = model.selectedMemberAge;
                            model.getRecentUploads();
                          }))
                  : Center(child: Row(children: [Container(alignment: Alignment.center, width: Screen.width(context) / 3 + 3, child: Text(members[0]['member_first_name'].toString()).fontSize(18).bold())])),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    String? profileurl = locator<PreferencesService>().profileUrl.value;
    print(widget.type_header.toString());
    return Scaffold(
        body: ViewModelBuilder<UploadsViewmodel>.reactive(
            onModelReady: (model) async {
              modelRef = model;
              await model.init();
              await model.getMembersList(true);
            },
            builder: (context, model, child) {
              return AppBar(
                elevation: 0,
                leadingWidth: 5,
                leading: Container(
                  color: appbarColor,
                  width: 30,
                  height: 30,
                ),
                bottomOpacity: 0,
                backgroundColor: subtleColor,
                title: Container(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                          onTap: () async {
                            await navigationService.clearStackAndShow(RoutePaths.Dashboard);
                          },
                          child: Text('SWAR').bold().textColor(activeColor)),
                      StreamBuilder(
                        builder: (context, snasphot) {
                          return GestureDetector(
                              onTap: () {
                                if (locator<IapService>().pastPurchases.length == 0) {
                                  Get.to(() => SubscriptionView());
                                } else {
                                  Get.to(() => SubscribedView());
                                }
                              },
                              child: Image.asset('assets/${locator<PreferencesService>().getCurrentSubscriptionPlanImage()}'));
                        },
                        stream: locator<PreferencesService>().subscriptionStream.outStream,
                      ),
                      Expanded(
                          child: Container(
                        alignment: Alignment.center,
                      )),
                      Expanded(
                          child: Container(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                            onTap: () async {
                              await Get.to(() => ProfileView());
                              setState(() {});
                            },
                            child: profileurl == '' || profileurl!.contains('null')
                                ? Container(
                                    child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                                    width: 40,
                                    height: 40,
                                  )
                                : ClipRRect(borderRadius: BorderRadius.circular(30.0), child: widget.type_header == 1 ? UIHelper.getImage(profileurl, 40, 40) : Container())),
                      )),
                    ],
                  ),
                ),
              );
            },
            viewModelBuilder: () => UploadsViewmodel()));
  }
}

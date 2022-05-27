import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/language_select_view.dart';
import 'package:swarapp/ui/startup/role_select_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:doctor_module/src/ui/doc_signup/role_select_view.dart';

class RoleSelectView extends StatefulWidget {
  RoleSelectView({Key? key}) : super(key: key);

  @override
  _RoleSelectViewState createState() => _RoleSelectViewState();
}

class _RoleSelectViewState extends State<RoleSelectView> {
  PreferencesService preferencesService = locator<PreferencesService>();

  String selectedTab = '';
  int Tab_id = 3;
  bool is_selected = false;

  @override
  Widget groupDataItem(BuildContext context, RoleSelectViewmodel model) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: model.loginRole.length,
        itemBuilder: (context, index) {
          String imgUrl = '${ApiService.imageStorageEndPoint}${model.loginRole[index]['role_icon']}';
          return Column(
            children: [
              GestureDetector(
                onTap: (() {
                  setState(() {
                    is_selected = true;
                    Tab_id = index;
                    if (model.loginRole[index]['_id'] == '6128a673b71d012678336f4d') {
                      preferencesService.login_roleId = model.loginRole[index]['_id'];
                    } else {
                      preferencesService.login_roleId = "";
                    }
                  });
                }),
                child: Container(
                  child: Row(
                    children: [
                      Image.network(imgUrl, width: 60, height: 60),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(model.loginRole[index]['loginrole_name']).fontSize(18).fontWeight(FontWeight.w600).textAlignment(TextAlign.left),
                      )
                    ],
                  ),
                  decoration: UIHelper.accountCardwithShadow(4, 20, Colors.white, borderColor: Tab_id == index ? activeColor : Colors.transparent),
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                  margin: EdgeInsets.only(right: 15, left: 15),
                ),
              ),
              UIHelper.verticalSpaceMedium,
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ViewModelBuilder<RoleSelectViewmodel>.reactive(
                onModelReady: (model) async {
                  await model.getLoginRole();
                },
                builder: (context, model, child) {
                  return Column(
                    children: [
                      model.isBusy
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Column(children: [
                              Image.asset(
                                'assets/swar_logo.png',
                                height: 60,
                                width: 60,
                              ),
                              UIHelper.verticalSpaceMedium,
                              Text('Select Account').fontSize(18).fontWeight(FontWeight.w600),
                              UIHelper.verticalSpaceMedium,
                              UIHelper.verticalSpaceSmall,
                              groupDataItem(context, model),
                              UIHelper.verticalSpaceLarge,
                              is_selected == false
                                  ? ElevatedButton(
                                      onPressed: () async {},
                                      child: Text('Next').fontWeight(FontWeight.w700).fontSize(20),
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(Size(150, 38)),
                                        backgroundColor: MaterialStateProperty.all(disablebtncolor),
                                      ))
                                  : ElevatedButton(
                                      onPressed: () async {
                                        if (preferencesService.login_roleId == '6128a673b71d012678336f4d') {
                                          Get.to(() => LanguageSelectView());
                                        } else {
                                          Get.to(() => DoctorroleSelectView());
                                        }
                                      },
                                      child: Text('Next').fontWeight(FontWeight.w700).fontSize(20),
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(Size(150, 38)),
                                        backgroundColor: MaterialStateProperty.all(submitBtnColor),
                                      )),
                            ]),
                    ],
                  );
                },
                viewModelBuilder: () => RoleSelectViewmodel()),
          ],
        ),
      ),
    ));
  }
}

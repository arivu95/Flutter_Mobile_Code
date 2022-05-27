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
import 'package:swarapp/ui/startup/health_provider_terms.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class DoctorroleSelectView extends StatefulWidget {
  DoctorroleSelectView({Key? key}) : super(key: key);

  @override
  _DoctorroleSelectViewState createState() => _DoctorroleSelectViewState();
}

class _DoctorroleSelectViewState extends State<DoctorroleSelectView> {
  PreferencesService preferencesService = locator<PreferencesService>();

  String selectedTab = '';
  int Tab_id = 5;
  bool is_selected = false;

  @override
  Widget roleListWidget(BuildContext context, String title, String url, Color bgcolor, int index, bool selected, String id) {
    return GestureDetector(
      onTap: (() {
       
        index == 3 || index == 4 ?
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogBox(
                title: "New Feature!",
                descriptions: "Coming soon",
                descriptions1: "Thank you for your patience",
                text: "OK",
              );
            }):
        setState(() {
          is_selected = selected;
          Tab_id = index;
          preferencesService.login_roleId = id;
        });
      }),
      child: Container(
          width: Screen.width(context) / 2.7,
          padding: EdgeInsets.all(12),
          decoration: UIHelper.accountCardwithShadow(4, 20, bgcolor, borderColor: Tab_id == index ? activeColor : Colors.transparent),
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Expanded(child: Text(title, textAlign: TextAlign.left).fontSize(14).fontWeight(FontWeight.w600).textColor(Colors.black)), Image.asset('assets/$url', width: 30, height: 30)],
          )),
    );
  }

  @override
  Widget groupDataItem(BuildContext context, RoleSelectViewmodel model) {
    return Container(
        width: Screen.width(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                roleListWidget(context, 'Doctors & Specialists', 'doctor_profile.png', Colors.amber.shade100, 1, true, '61e7a9e44c559c1530e0e562'),
                roleListWidget(context, 'Nurse', 'home_visit.png', Color(0xFFF4AFA4), 2, true, '61e7aa154c559c1530e0e564'),
              ],
            ),
            UIHelper.verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                roleListWidget(context, 'Lab test & Radiology', 'lab_test_radiology.png', Color(0xFFC1E3E0), 3, false, ''),
                roleListWidget(context, 'Pharmacy', 'online_pharmacy.png', Color(0xFFD0E1C5), 4, false, ''),
               ],
            ),
          ],
        ));
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
                onModelReady: (model) async {},
                builder: (context, model, child) {
                  return Column(
                    children: [
                      Column(children: [
                        Image.asset(
                          'assets/swar_logo.png',
                          height: 60,
                          width: 60,
                        ),
                        UIHelper.verticalSpaceMedium,
                        Text('Healthcare Service Providers').fontSize(20).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceMedium,
                        Text('Choose your Role and click next').fontSize(16).fontWeight(FontWeight.w600),
                        UIHelper.verticalSpaceMedium,
                        groupDataItem(context, model),
                        UIHelper.verticalSpaceVeryLarge,
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
                                  Get.to(() => LanguageSelectView());
                                },
                                child: Text('Next').fontWeight(FontWeight.w700).fontSize(20),
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(150, 38)),
                                  backgroundColor: MaterialStateProperty.all(submitBtnColor),
                                ))
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

import 'package:doctor_module/src/ui/doc_onboarding/landing_page_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_profile_stages_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_profile_bar.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/dotted_line.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/shared/profileStage_widget_view.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/src/navigation_service.dart';
import 'package:swarapp/ui/dashboard/doctor_dashboard_view.dart';

class DoctorProfileStagesView extends StatefulWidget {
  DoctorProfileStagesView({Key? key}) : super(key: key);

  @override
  _DoctorProfileStageViewState createState() => _DoctorProfileStageViewState();
}

class _DoctorProfileStageViewState extends State<DoctorProfileStagesView> {
  Map<String, Color> bgContainerColor = {
    "0": Color(0xFF01BE7A),
    "1": Color(0xFFE17F3E),
    "2": Color(0xFF1673FF),
    "3": Color(0xFFFF4148),
  };

  Widget docProfileTimeline(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 15,
        ),
        Expanded(
            child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 15, right: 25, top: 15),
              child: DottedLine(
                dashColor: Colors.red,
                lineThickness: 2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text('Entry').fontWeight(FontWeight.w600)],
                ),
                Column(
                  children: [Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text('Enhanced').fontWeight(FontWeight.w600)],
                ),
                Column(
                  children: [Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text('Verified').fontWeight(FontWeight.w600)],
                ),
                Column(
                  children: [Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text('SWAR Dr.').fontWeight(FontWeight.w600)],
                ),
              ],
            ),
          ],
        )),
        SizedBox(
          width: 15,
        ),
      ],
    );
  }

  Widget card_pallate(DoctorStagesViewModel model) {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: model.Stages.length,
        itemBuilder: (context, index) {
          String indexstr = index.toString();
          return Column(
            children: [
              Container(
                  width: Screen.width(context),
                  //height: 140,
                  decoration: UIHelper.rightcornerRadiuswithColor(4, 20, bgContainerColor[indexstr] != null ? bgContainerColor[indexstr]! : Colors.yellow),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.Stages[index]['title'], textAlign: TextAlign.left).fontWeight(FontWeight.w600).textColor(Colors.white),
                      UIHelper.verticalSpaceSmall,
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(model.Stages[index]['desc'], textAlign: TextAlign.left).fontSize(12.0).textColor(Colors.white),
                      )
                    ],
                  )),
              UIHelper.verticalSpaceTiny
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppDoctorBar(
        isProfileBar: false,
      ),
      backgroundColor: Colors.white,
      body: ViewModelBuilder<DoctorStagesViewModel>.reactive(
          onModelReady: (model) async {
            Loader.show(context);
            await model.getStages();
            Loader.hide();
          },
          builder: (context, model, child) {
            return SafeArea(
                top: false,
                child: Container(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    child: SingleChildScrollView(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      UIHelper.verticalSpaceSmall,
                      Container(
                        decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '     Profile Stages with SWAR',
                              textAlign: TextAlign.center,
                            ).fontWeight(FontWeight.w600),
                            UIHelper.verticalSpaceSmall,
                            docProfileTimeline(context),
                            //ProfileStageWidget(),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpaceMedium,
                      Center(child: card_pallate(model)),
                      // Expanded(
                      //     child: Column(
                      //   children: [
                      //     // Container(
                      //     //   padding: EdgeInsets.all(7),
                      //     //   decoration: UIHelper.rightcornerRadiuswithColor(4, 20, Colors.amber.shade100),
                      //     //   //child: showTitle(context, 'Doctors & Specialists ', 'assets/doctor_profile.png', 35, 35),
                      //     // )
                      //     card_pallate('asldfsd')
                      //   ],
                      // )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                await locator<NavigationService>().clearStackAndShow(RoutePaths.DoctorDashboard);
                              },
                              child: Text('Continue').bold(),
                              style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(220, 36)),
                                  backgroundColor: MaterialStateProperty.all(activeColor),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                        ],
                      ),
                      UIHelper.verticalSpaceMedium
                    ]))));
          },
          viewModelBuilder: () => DoctorStagesViewModel()),
    );
  }
}

import 'package:documents_module/src/ui/medical_records/covid_record_viewmodel.dart';
import 'package:documents_module/src/ui/medical_records/covid_widgets/covid_vaccines_widget.dart';
import 'package:documents_module/src/ui/medical_records/covid_widgets/labtest_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:get/get.dart';

class CovidRecordView extends StatefulWidget {
  final String categoryId;
  dynamic covidVaccineList;
  dynamic labTestList;
  CovidRecordView({Key? key, required this.categoryId}) : super(key: key);

  @override
  _CovidRecordViewState createState() => _CovidRecordViewState();
}

class _CovidRecordViewState extends State<CovidRecordView> {
  Widget addHeader(BuildContext context, bool isBackBtnVisible) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        children: [
          isBackBtnVisible
              ? GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 20,
                  ),
                )
              : SizedBox(),
          Text("COVID Reports").bold().fontSize(16),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SwarAppStaticBar(),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            width: Screen.width(context),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              UIHelper.verticalSpaceTiny,
              addHeader(context, true),
              UIHelper.verticalSpaceSmall,
              UIHelper.addHeader(context, locator<PreferencesService>().dropdown_user_name, false),
              UIHelper.verticalSpaceSmall,
              ViewModelBuilder<CovidRecordViewModel>.reactive(
                  onModelReady: (model) async {
                    model.memberId = locator<PreferencesService>().dropdown_user_id;
                    model.mem_name = locator<PreferencesService>().dropdown_user_name;
                    Loader.show(context);
                    await model.getMemberVaccines();
                    Loader.hide();
                  },
                  builder: (context, model, child) {
                    return Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [
                          UIHelper.verticalSpaceMedium,
                          CovidVaccinesWidget(model: model, covidVaccineList: model.vaccines),
                          UIHelper.verticalSpaceMedium,
                          CovidLabTestWidget(model: model, labTestList: model.labtest),
                          UIHelper.verticalSpaceMedium,
                        ],
                      ),
                    ));
                  },
                  viewModelBuilder: () => CovidRecordViewModel())
            ])));
  }
}

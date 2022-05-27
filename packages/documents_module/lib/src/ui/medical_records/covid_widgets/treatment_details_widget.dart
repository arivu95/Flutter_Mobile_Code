import 'package:documents_module/src/ui/medical_records/covid_record_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class CovidTreatmentDetailsWidget extends HookWidget {
  CovidRecordViewModel model;
  CovidTreatmentDetailsWidget({Key? key, required this.model}) : super(key: key);

  Future<void> getpick(BuildContext context) async {
    preferencesService.paths.clear();
    FilePickerResult result = (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx']))!;
    String path = result.files.single.path!;
    preferencesService.paths.add(path);
    if (path != '') {}
    //model.updateCovidTestInfo(data['test_result'], '', path, data, documentId);
    model.updateCovidTreatmentDetails(path);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final isSectionOpen = useState<bool>(false);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            isSectionOpen.value = !isSectionOpen.value;
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
                color: activeColor),
            padding: EdgeInsets.all(8),
            width: Screen.width(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Treatment Details').bold().textColor(Colors.white),
              ],
            ),
          ),
        ),
        isSectionOpen.value
            ? Container(
                width: Screen.width(context),
                // height: 80,
                decoration: UIHelper.roundedBorderWithColor(0, fieldBgColor, borderColor: Colors.black12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            getpick(context);
                          },
                          child: Image.asset(
                            'assets/attach_file.png',
                            width: 84,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        UIHelper.horizontalSpaceMedium,
                        Image.asset(
                          'assets/attach_camera.png',
                          width: 84,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                      ],
                    ),
                    UIHelper.verticalSpaceSmall
                  ],
                ))
            : SizedBox()
      ],
    );
  }
}

import 'dart:io';
import 'package:documents_module/src/ui/uploads/capture_upload_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/consts.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_loader.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:intl/src/intl/date_format.dart';

class CaptureUploadView extends StatefulWidget {
  // CaptureUploadView({Key? key}) : super(key: key);
  final String camera_mode;
  CaptureUploadView({Key? key, required this.camera_mode}) : super(key: key);

  @override
  _CaptureUploadViewState createState() => _CaptureUploadViewState();
}

class _CaptureUploadViewState extends State<CaptureUploadView> {
  PreferencesService preferencesService = locator<PreferencesService>();
  List getAlertmessage = [];
//Document_download
  TextEditingController fieldController = TextEditingController().obs();

  int selectedIndex = -1.obs;

  Widget showSearchField(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: fieldController,
        style: TextStyle(fontSize: 14),
        decoration: new InputDecoration(
            suffixIcon: Icon(
              Icons.edit,
              color: Colors.grey,
              size: 20,
            ),
            contentPadding: EdgeInsets.only(left: 20),
            enabledBorder: UIHelper.getInputBorder(1, radius: 2, borderColor: Color(0x00CCCCCC)),
            focusedBorder: UIHelper.getInputBorder(1, radius: 2, borderColor: Color(0x00CCCCCC)),
            focusedErrorBorder: UIHelper.getInputBorder(1, radius: 2, borderColor: Color(0x00CCCCCC)),
            errorBorder: UIHelper.getInputBorder(1, radius: 2, borderColor: Color(0x00CCCCCC)),
            filled: true,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            hintText: "Enter File Name",
            fillColor: Color(0xFFFAF2F2)),
      ),
    );
  }

  Widget recentItem(BuildContext context, int index) {
    String filePath = preferencesService.paths[index];
    String filename = filePath.split('/').last;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.file(
        File(preferencesService.paths[index]),
        fit: BoxFit.cover,
        height: 80,
        width: 80,
        errorBuilder: (context, error, stackTrace) {
          //filename
          return filename.toLowerCase().contains('.pdf')
              ? Image.asset('assets/PDF.png')
              : filename.toLowerCase().contains('.docx')
                  ? Image.asset('assets/word_icon.png')
                  : filename.toLowerCase().contains('.xxls') || filename.toLowerCase().contains('.xls')
                      ? Image.asset('assets/excel_icon.png')
                      : filename.toLowerCase().contains('.mp4')
                          ? Container(child: Center(child: Icon(Icons.smart_display, size: 60, color: greyColor)))
                          : ClipRRect(borderRadius: BorderRadius.circular(8), child: UIHelper.getImage(filePath, 80, 60)

                              // fit: BoxFit.none,
                              // height: 60,
                              // width: 80,
                              );
        },
      ),
    );
  }

  Widget showSelectedAssets(BuildContext context) {
    return Container(
      width: Screen.width(context),
      // padding: EdgeInsets.only(left: 12, right: 12),
      height: 84,
      // padding: EdgeInsets.only(left: 12, right: 12),
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: preferencesService.paths.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(right: 4, left: 4),
              width: 80,
              height: 80,
              child: Container(
                //decoration: UIHelper.roundedBorderWithColor(8, selectedIndex == index ? activeColor : Color(0xFFEFEFEF), borderColor: Colors.yellow),
                decoration: UIHelper.roundedLineBorderWithColor(10, subtleColor, 1, borderColor: Colors.black12),
                child: recentItem(context, index),
              ),
            );
          }),
    );
  }

  Widget docTypeMenuItem(String title, Widget icon, int index) {
    String filePath = preferencesService.paths[0];
    String filename = filePath.split('/').last;
    return GestureDetector(
      onTap: () {
        setState(() {
          //   selectedIndex = index;
          //  if(widget.camera_mode == "Camera"){
          //   fieldController.text = title +'_'+ DateTime.now().toString();
          //   }else{
          //   fieldController.text = filename;
          //   }
          //});
          fieldController.clear();
          List<String> numbers = ["Registration/Insurance", "Prescription", "Lab Report", "Medical Report", "Others", "C.DOC", "Maternity & Child vaccine record"];
          if (widget.camera_mode == "Camera") {
            if (fieldController.text == "") {
              fieldController.text = title + '_' + DateFormat("HH_mm_ss").format(DateTime.now());
              //DateTime.now().toString();
            }
            if (numbers.contains(fieldController.text.split('_').first)) {
              title == 'Registration/Insurance'
                  ? fieldController.text = 'Registration_Insurance' + '_' + DateFormat("yy-MM-dd_HH_mm_ss").format(DateTime.now())
                  : fieldController.text = title + '_' + DateFormat("yyyy-MM-dd_HH_mm_ss").format(DateTime.now());
            } else {
              fieldController.text;
            }
          } else {
            //fieldController.text = filename;
            //title == 'Registration/Insurance' ? fieldController.text = 'Registration_Insurance' + '_' + DateTime.now().toString() : fieldController.text = title + '_' + DateTime.now().toString();
            fieldController.text = "fileAttach";
          }
        });
        selectedIndex = index;
        //   print('++++++++++=selected index is'+selectedIndex.toString());
        // Get.to(() => VaccineMaternityListView());
        if (index == 6) {
          //Get.to(() => VaccineMaternityListView());
        }

        if (index == 5) {
          //Get.to(() => CovidRecordView());
        }
      },
      child: Row(
        children: [
          UIHelper.horizontalSpaceSmall,
          icon,
          UIHelper.horizontalSpaceSmall,
          Expanded(child: Text(title).textColor(selectedIndex == index ? activeColor : Colors.black).fontWeight(selectedIndex == index ? FontWeight.bold : FontWeight.normal)),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.black45,
          ),
          UIHelper.horizontalSpaceSmall,
        ],
      ),
    );
  }

  Widget showCategories(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(6, 20, 6, 20),
      width: Screen.width(context),
      // height: 100,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: docTypeMenuItem('Registration/Insurance', Image.asset('assets/reg_insurance_icon.png'), 0),
              ),
              Flexible(
                child: docTypeMenuItem('Prescription', Image.asset('assets/prescription_icon.png'), 1),
              ),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          UIHelper.hairLineWidget(),
          UIHelper.verticalSpaceSmall,
          Row(
            children: [
              Flexible(
                child: docTypeMenuItem('Lab Report', Image.asset('assets/lr_icon.png'), 2),
              ),
              Flexible(
                child: docTypeMenuItem('Medical Report', Image.asset('assets/mr_icon.png'), 3),
              ),
            ],
          ),
          UIHelper.verticalSpaceSmall,
          UIHelper.hairLineWidget(),
          UIHelper.verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: Screen.width(context) / 2,
                child: docTypeMenuItem('Others', Image.asset('assets/others_icon.png'), 4),
              ),
            ],
          ),
          UIHelper.verticalSpaceSmall,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getAlertmessage = preferencesService.alertContentList!.where((msg) => msg['type'] == "Document_upload").toList();
    return Scaffold(
      backgroundColor: Color(0xFFFAF2F2),
      //appBar: SwarAppBar(2),
      appBar: SwarAppStaticBar(),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 12, right: 12),
          child: ViewModelBuilder<CaptureUploadViewmodel>.reactive(
              onModelReady: (model) {
                model.getFileCategory();
              },
              builder: (context, model, child) {
                return model.isBusy
                    ? SizedBox(
                        height: 200,
                        child: Center(
                          child: UIHelper.swarPreloader(),
                        ),
                      )
                    //UIHelper.swarPreloader()
                    : Column(
                        children: [
                          UIHelper.commonTopBar('Select Category'),
                          UIHelper.verticalSpaceTiny,
                          // (widget.camera_mode == "Camera" &7 showSearchField(context) ),
                          if (widget.camera_mode == "Camera") ...[
                            showSearchField(context),
                          ],
                          UIHelper.hairLineWidget(borderColor: Colors.black12),
                          UIHelper.verticalSpaceTiny,
                          showSelectedAssets(context),
                          UIHelper.verticalSpaceTiny,
                          UIHelper.hairLineWidget(),
                          UIHelper.verticalSpaceTiny,
                          showCategories(context),
                          UIHelper.verticalSpaceMedium,
                          UIHelper.hairLineWidget(),
                          UIHelper.verticalSpaceSmall,
                          // Row(
                          //   children: [
                          //     Flexible(
                          //       child: docTypeMenuItem('COVID Record', Image.asset('assets/covid_record_icon.png'), 5),
                          //     ),
                          //     Flexible(
                          //       child: docTypeMenuItem('Maternity & child vaccine record', Image.asset('assets/mat_vac_icon.png'), 6),
                          //     ),
                          //   ],
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Container(
                                height: 54,
                                padding: EdgeInsets.all(6),
                                decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white),
                                child: GestureDetector(
                                  onTap: () {
                                    // setState(() {
                                    //   selectedIndex = 5;
                                    // });
                                    //  Get.to(() => CovidRecordView());
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Image.asset('assets/covid_record_icon.png'),
                                      // UIHelper.horizontalSpaceMedium,
                                      Flexible(
                                        // child: Text('COVID\nRecord')
                                        //     .fontSize(12)
                                        //     .textColor(selectedIndex == 5 ? activeColor : Colors.black)
                                        //     .fontWeight(selectedIndex == 5 ? FontWeight.bold : FontWeight.normal)
                                        child: docTypeMenuItem('C.DOC', Image.asset('assets/covid_record_icon.png'), 5),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                              UIHelper.horizontalSpaceSmall,
                              Expanded(
                                child: Container(
                                  height: 54,
                                  padding: EdgeInsets.all(6),
                                  // width: Screen.width(context) / 2 - 20,
                                  decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white),
                                  child: GestureDetector(
                                    onTap: () {
                                      // setState(() {
                                      //   selectedIndex = 6;
                                      // });
                                      //   Get.to(() => VaccineMaternityListView());
                                    },
                                    child: Row(
                                      children: [
                                        // Image.asset('assets/mat_vac_icon.png'),
                                        // UIHelper.horizontalSpaceSmall,
                                        Flexible(
                                          // child: Text('Maternity & child\nvaccine record')
                                          //     .fontSize(12)
                                          //     .textColor(selectedIndex == 6 ? activeColor : Colors.black)
                                          //     .fontWeight(selectedIndex == 6 ? FontWeight.bold : FontWeight.normal)
                                          child: docTypeMenuItem('Maternity & Child vaccine record', Image.asset('assets/mat_vac_icon.png'), 6),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          UIHelper.verticalSpaceSmall,
                          UIHelper.hairLineWidget(),
                          UIHelper.verticalSpaceSmall,
                          ElevatedButton(
                              onPressed: selectedIndex == -1 || fieldController.text.isEmpty
                                  ? null
                                  : () async {
                                      // print("check1 "+model.subscib_storg.toString());
                                      // print("check2 "+model.stored_tot.toString());
                                      //   print(preferencesService.subscriptionInfo['storage_size_conversion']);
                                      //check storage size........

                                      if (model.subscib_storg < model.stored_tot) {
                                        //for checking // double t=0.11;
                                        //  if(t< model.stored_tot){
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CustomDialogBox(
                                                title: "Alert !",
                                                descriptions: "You don't have enough Storage!.Please Upgrade your Plan.",
                                                descriptions1: "",
                                                text: "OK",
                                              );
                                            });
                                        return;
                                      } else {
                                        print(fieldController.text);
                                        // if(widget.camera_mode == "Attach"){
                                        if (fieldController.text.isEmpty && widget.camera_mode == "Attach") {
                                          (await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title: "Alert !",
                                                  descriptions: "Enter File Name",
                                                  descriptions1: '',
                                                  text: "OK",
                                                );
                                              }))!;
                                          return;
                                        }
                                        //}
                                        if (selectedIndex == -1) {
                                          (await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title: "Alert !",
                                                  descriptions: "Select a category",
                                                  descriptions1: "",
                                                  text: "OK",
                                                );
                                              }))!;
                                          return;
                                        }

                                        String catId = model.getCategoryId(selectedIndex);
                                        print('cat ID is=====' + catId);
                                        String mode = widget.camera_mode;
                                        if (catId.isNotEmpty && fieldController.text.isNotEmpty) {
                                          ProgressLoader.show(context);
                                          final response = await model.uploadDocuments(fieldController.text, catId, mode);
                                          ProgressLoader.hide();
                                          if (response) {
                                            await showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return CustomDialogBox(
                                                    title: "Success !  ",
                                                    descriptions: getAlertmessage[0]['content'],
                                                    descriptions1: "“We care for you”",
                                                    text: "OK",
                                                  );
                                                });
                                            locator<PreferencesService>().isDownloadReload.value = true;
                                            //Navigator.of(context).popUntil((route) => route.isFirst);
                                          }
                                        } else if (catId.isEmpty) {
                                          (await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title: "Alert !",
                                                  descriptions: "Select a valid category",
                                                  descriptions1: "",
                                                  text: "OK",
                                                );
                                              }))!;
                                        } else {
                                          (await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title: "Alert !",
                                                  descriptions: "Enter the File Name",
                                                  descriptions1: "",
                                                  text: "OK",
                                                );
                                              }))!;
                                        }
                                      }
                                    },
                              child: Column(
                                children: [
                                  Icon(Icons.check, size: 24, color: Colors.white),
                                  Text('Save').bold(),
                                ],
                              ),
                              style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(160, 50)),
                                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                                    if (!states.contains(MaterialState.disabled)) {
                                      return Colors.green;
                                    }
                                    return Colors.black12;
                                  }))),
                        ],
                      );
              },
              viewModelBuilder: () => CaptureUploadViewmodel()),
        ),
      ),
    );
  }
}

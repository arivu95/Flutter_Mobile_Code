import 'package:documents_module/src/ui/downloads/filtered_download_view.dart';
import 'package:documents_module/src/ui/medical_records/covid_record_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:get/get.dart';
import 'package:filesize/filesize.dart';

class CovidLabTestWidget extends StatefulWidget {
  CovidRecordViewModel model;
  dynamic labTestList;
  CovidLabTestWidget({Key? key, required this.model, required this.labTestList}) : super(key: key);

  @override
  _CovidLabTestViewState createState() => _CovidLabTestViewState();
}

class _CovidLabTestViewState extends State<CovidLabTestWidget> {
  String isvideo = '';
  String valueText = "";
  List<String> testTypes = ['Swab Test ', 'CT Scan', 'PCR Test'];
  bool isattach = false;
  bool isAddLabtest = true;
  bool isload = false;
  final picker = ImagePicker();
  TextEditingController _textFieldController = TextEditingController();
  List<dynamic> result_type = ["Negative", "Positive", "Pending"];
  String dropdownSource = 'Negative';
  @override
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Test Result'),
            content: DropdownButton(
                isExpanded: true,
                value: dropdownSource,
                items: result_type.map((e) {
                  return new DropdownMenuItem(value: e, child: new Text(e));
                }).toList(),
                onChanged: (value) {
                  Navigator.pop(context);
                  dropdownSource = value.toString();
                }),
          );
        });
  }

  Widget headerItem(String title, Color bgColor) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            left: BorderSide(width: 1.0, color: Colors.black12),
          ),
        ),
        height: 40,
        alignment: Alignment.center,
        child: Text(title).bold().fontSize(11).textAlignment(TextAlign.center),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, dynamic data, int index, CovidRecordViewModel model, String documentId) async {
    DateTime selectedDate = DateTime.now();
    selectedDate = (await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(1900, 1), lastDate: DateTime(DateTime.now().year + 79)))!;
    Jiffy dt = Jiffy(selectedDate);
    String dateStr = dt.format('MM-dd-yyyy');
    print(dateStr);
    preferencesService.paths.clear();
    await model.updateCovidTestInfo(data['test_result'], dateStr, data, index, documentId);
  }

  Widget getStatusItem(BuildContext context, int index, dynamic data, CovidRecordViewModel model, String documentId) {
    //bool status = data['status'].toString() == 'true' ? true : false;
    String attachRecord = "";

    if (data['attach_reports'] != null) {
      if (data['attach_reports'].length > 0) {
        attachRecord = 'data';
      }
    } else {
      attachRecord = "";
    }

    String dateStr = "";
    String dateString = "";
    if (data['taken_date'] != null) {
      Jiffy dt = Jiffy(data['taken_date']);
      dateStr = dt.format('ddMMM');
      dateString = dt.format('ddMMMyy');
    }

    String result = "";
    if (data['test_result'] != null) {
      result = data['test_result'].toString();
    }

    return Container(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : fieldBgColor,
        border: Border(
          left: BorderSide(width: 1.0, color: Colors.black12),
          bottom: BorderSide(width: 1.0, color: Colors.black12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 1.0, color: Colors.black12),
              ),
            ),
            child: Text('  ' + data['test_name']).fontSize(10).fontWeight(FontWeight.w600).textColor(activeColor),
          )),
          Expanded(
              child: GestureDetector(
            onTap: () {
              _selectDate(context, data, index, model, documentId);
            },
            child: Container(padding: EdgeInsets.symmetric(vertical: 6), decoration: UIHelper.rowRightBorder(), child: Text(dateString).fontSize(11).fontWeight(FontWeight.w600).textAlignment(TextAlign.center)),
          )),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await _displayTextInputDialog(context);
                String dateStr = '';
                if (data['taken_date'] != null) {
                  Jiffy dt = Jiffy(data['taken_date']);
                  dateStr = dt.format('MM-dd-yyyy');
                } else {
                  dateStr = '';
                }
                await model.updateCovidTestInfo(dropdownSource, dateStr, data, index, documentId);
              },
              child: Container(padding: EdgeInsets.symmetric(vertical: 6), decoration: UIHelper.rowRightBorder(), child: Text(result).fontSize(11).fontWeight(FontWeight.w600).textAlignment(TextAlign.center)),
            ),
          ),
          Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: UIHelper.rowRightBorder(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    attachRecord.isNotEmpty
                        ? GestureDetector(
                            onTap: () async {
                              await Get.to(() => FilteredDownloadDetailView(
                                    categoryId: '6093cebb7a735c0acfb77364',
                                    categoryTitle: 'Covid Test',
                                    data: {'title1': data['test_name'] + '_' + documentId},
                                  ));
                              Loader.show(context);
                              await widget.model.getMemberVaccines();
                              Loader.hide();
                            },
                            child: Icon(
                              Icons.description_outlined,
                              size: 20,
                            ))
                        : SizedBox(),
                    attachRecord.isNotEmpty ? SizedBox(width: 10) : SizedBox(),
                    GestureDetector(
                        onTap: () {
                          showFilePickerSheet(context, data, index, model, documentId);
                        },
                        child: Icon(
                          Icons.add,
                          size: 20,
                        )),
                  ],
                )),
          ),
          Expanded(
              child: GestureDetector(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Caution!'),
                      content: Text('Are you sure to delete?'),
                      actions: <Widget>[
                        FlatButton(
                          color: Colors.red,
                          textColor: Colors.white,
                          child: Text('No'),
                          onPressed: () {
                            isload = false;
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          color: Colors.green,
                          textColor: Colors.white,
                          child: Text('Yes'),
                          onPressed: () async {
                            Navigator.pop(context);
                            setState(() {
                              isload = true;
                            });
                            await model.deleteTestInfo(data['_id'], 'Covidtest_Id');
                            isload = false;
                          },
                        ),
                      ],
                    );
                  });
            },
            child: Container(
              width: 50,
              child: Icon(
                Icons.delete,
                size: 20,
              ),
            ),
          ))
        ],
      ),
    );
  }

  Widget getLabtestWidget(BuildContext context, CovidRecordViewModel model) {
    return SingleChildScrollView(
      child: Container(
        width: Screen.width(context),
        decoration: UIHelper.roundedBorderWithColor(0, fieldBgColor, borderColor: Colors.black12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                headerItem('Tests', Color(0xFFECECEC)),
                headerItem('Date', Color(0xFFF8F8F8)),
                headerItem('Result', Color(0xFFECECEC)),
                headerItem('Reports', Color(0xFFF8F8F8)),
                headerItem('Action', Color(0xFFECECEC)),
              ],
            ),
            Container(
              color: Colors.black12,
              height: 1,
            ),
            ListView.separated(
                separatorBuilder: (context, index) {
                  return SizedBox();
                },
                padding: EdgeInsets.only(top: 0),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: model.memberLabTests.length,
                itemBuilder: (context, index) {
                  dynamic data = model.memberLabTests[index];
                  return getStatusItem(context, index, data, model, data['_id']);
                }),
            UIHelper.verticalSpaceSmall,
            isload
                ? Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          onTap: () async {
                            // Loader.show(context);
                            await onShowVaccinePicker(context, model);
                            // Future.delayed(Duration(milliseconds: 2500), () async {
                            //   Loader.hide();
                            //   await onShowVaccinePicker(context, model);
                            // });
                          },
                          child: UIHelper.tagWidget('Add Test', activeColor)),
                      UIHelper.horizontalSpaceSmall
                    ],
                  ),
            UIHelper.verticalSpaceSmall,
          ],
        ),
      ),
    );
  }

  Future<void> onShowVaccinePicker(BuildContext context, CovidRecordViewModel model) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(8),
                child: Text('Select a LabTest').fontWeight(FontWeight.w600),
              ),
              Container(
                  height: 200,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.labTestList.length,
                      itemBuilder: (context, index) {
                        dynamic labTests = widget.labTestList[index];
                        return ListTile(
                          leading: new Icon(Icons.verified_outlined),
                          title: new Text(labTests['test_name']),
                          onTap: () async {
                            Navigator.pop(context);
                            setState(() {
                              isload = true;
                            });

                            await model.addNewLabTest(labTests['_id']);
                            isAddLabtest = true;
                            isload = false;
                          },
                        );
                      })),
            ],
          );
        });
  }

  Future<void> getpick(BuildContext context, dynamic data, int index, CovidRecordViewModel model, String documentId) async {
    preferencesService.paths.clear();
    List<PlatformFile>? _paths;
    _paths = (await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: true, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx']))?.files;

    if (_paths!.length < 6) {
      for (int k = 0; k < _paths.length; k++) {
        if (_paths[k].path!.toString().contains("mp4") || _paths[k].path!.toString().contains("mp3")) {
          setState(() {
            isvideo = "yes";
            preferencesService.paths.clear();
          });
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialogBox(
                  title: "Not Allowed !",
                  descriptions: "Video Files not allowed",
                  descriptions1: "",
                  text: "OK",
                );
              });
          setState(() {
            isvideo = "";
          });
          return;
        } else {
          setState(() {
            isvideo = "no";
          });
          String gt = filesize(_paths[k].size);
          double limitMb = 75.0;
          //check if  kb
          if (gt.contains('KB') || gt.contains('kb')) {
            limitMb = 75000.00;
          }
          String val = gt.replaceAll(RegExp("[a-zA-Z]"), "");
          val = val.trim();
          if (double.parse(val) <= limitMb) {
            //check limit 15mb ..
            preferencesService.paths.insert(0, _paths[k].path!);
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialogBox(
                    title: "Not Allowed !",
                    descriptions: "File size cannot be uploaded greater than 75MB.",
                    descriptions1: "",
                    text: "OK",
                  );
                });
            setState(() {
              preferencesService.paths.clear();
              isvideo = "";
            });
          }
        }
      }
      //for return to page, while choose video file
      if (isvideo == "yes") {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogBox(
                title: "Not Allowed !",
                descriptions: "Video Files not allowed",
                descriptions1: "",
                text: "OK",
              );
            });
        setState(() {
          preferencesService.paths.clear();
          isvideo = "";
        });
      } else {
        Get.back();
        String dateStr = '';
        if (data['taken_date'] != null) {
          Jiffy dt = Jiffy(data['taken_date']);
          dateStr = dt.format('MM-dd-yyyy');
        } else {
          dateStr = '';
        }
        await model.updateCovidTestInfo(data['test_result'], dateStr, data, index, documentId);
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              title: "Not Allowed !",
              descriptions: "Files can be allowed within 5",
              descriptions1: "",
              text: "OK",
            );
          });
      setState(() {
        isvideo = "";
      });
    }
  }

  void showFilePickerSheet(BuildContext context, dynamic data, int index, CovidRecordViewModel model, String documentId) async {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        builder: (BuildContext context) {
          return Container(
            height: 200,
            child: ListView(
              children: [
                UIHelper.verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Select a type')],
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () async {
                    await getcapture(
                      context,
                      data,
                      index,
                      model,
                      documentId,
                      FileType.video,
                    );
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Camera'),
                ),
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () async {
                    //  Get.back();
                    await getpick(context, data, index, model, documentId);
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Select a File'),
                ),
              ],
            ),
          );
        });
  }

  Future<void> getcapture(BuildContext context, dynamic data, int index, CovidRecordViewModel model, String documentId, FileType fileType) async {
    preferencesService.paths.clear();

    final pickedFile = (await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480))!;
    Get.back();
    String path = '';
    if (pickedFile != null) {
      await Get.to(() => ImgCropper(
          index: 0,
          imagePath: pickedFile.path,
          onCropComplete: (path) {
            path = pickedFile.path;
            preferencesService.paths.add(path);
            print(path);
          }));
    }
    String dateStr = '';
    if (data['taken_date'] != null) {
      Jiffy dt = Jiffy(data['taken_date']);
      dateStr = dt.format('MM-dd-yyyy');
    } else {
      dateStr = '';
    }

    await model.updateCovidTestInfo(data['test_result'], dateStr, data, index, documentId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isAddLabtest = !isAddLabtest;
            });
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
                color: subtleColor),
            padding: EdgeInsets.all(8),
            width: Screen.width(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lab Tests').bold().textColor(Colors.black),
                Icon(
                  Icons.expand_more,
                )
              ],
            ),
          ),
        ),
        isAddLabtest ? getLabtestWidget(context, widget.model) : SizedBox()
      ],
    );
  }
}

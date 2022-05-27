import 'package:documents_module/src/ui/downloads/filtered_download_view.dart';
import 'package:documents_module/src/ui/medical_records/covid_record_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:get/get.dart';
import 'package:filesize/filesize.dart';

class CovidVaccinesWidget extends StatefulWidget {
  CovidRecordViewModel model;
  dynamic covidVaccineList;
  CovidVaccinesWidget({Key? key, required this.model, required this.covidVaccineList}) : super(key: key);

  @override
  _CovidVaccinesViewState createState() => _CovidVaccinesViewState();
}

class _CovidVaccinesViewState extends State<CovidVaccinesWidget> {
  TextEditingController _covidtestController = TextEditingController();
  TextEditingController _covidadd_dose = TextEditingController();
  List<PlatformFile>? _paths;
  String isvideo = '';
  bool isattach = false;
  bool isload = false;
  bool isAddVaccine = true;
  final picker = ImagePicker();

  Widget headerItem(String title, Color bgColor) {
    return Expanded(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            left: BorderSide(width: 1.0, color: Colors.black12),
          ),
        ),
        child: Text(title).bold().fontSize(11).textAlignment(TextAlign.center),
      ),
    );
  }

  Widget headerItem1(String title, Color bgColor, double width) {
    return Container(
      height: 40,
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(width: 1.0, color: Colors.black12),
        ),
      ),
      child: Text(title).bold().fontSize(11).textAlignment(TextAlign.center),
    );
  }

  Widget rowItem(BuildContext context, String title, Color bgColor) {
    return Container(
      width: 70,
      padding: EdgeInsets.only(left: 4),
      child: Text(title).bold().fontSize(10).textColor(activeColor),
    );
  }

  Future<void> _New_Dose_Dialog(BuildContext context, CovidRecordViewModel model) async {
    _covidadd_dose.clear();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('COVID New Dose'),
            content: TextField(onChanged: (value) {}, controller: _covidadd_dose, decoration: InputDecoration(hintText: 'Enter a Dose Name')
                // inputFormatters: [
                //   new WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),
                // ]
                ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  isload = false;
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () async {
                  if (_covidadd_dose.text.isNotEmpty) {
                    Navigator.pop(context);
                    setState(() {
                      isload = true;
                    });
                    await model.addCoviddose(_covidadd_dose.text);
                    isload = false;
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> _selectDate(BuildContext context, dynamic data, CovidRecordViewModel model, String documentId, int index) async {
    DateTime selectedDate = DateTime.now();
    if (index == 0) {
      selectedDate = (await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(1900, 1), lastDate: DateTime(DateTime.now().year + 79)))!;
      Jiffy dt = Jiffy(selectedDate);
      String dateStr = dt.format('MM-dd-yyyy');
      preferencesService.paths.clear();
      Loader.show(context);
      await model.updateCovidVaccineInfo(data['status'], dateStr, data, documentId, '');
      await widget.model.getMemberVaccines();
      Loader.hide();
    } else if ((index != 0) && (model.memberdose[index - 1]['date']) != null && (model.memberdose[index - 1]['date']) != "") {
      var newDate = DateTime.parse(model.memberdose[index - 1]['date']);
      var getDate = new DateTime(newDate.year, newDate.month, newDate.day + 1);
      selectedDate = (await showDatePicker(context: context, initialDate: getDate, firstDate: getDate, lastDate: DateTime(DateTime.now().year + 79)))!;
      Jiffy dt = Jiffy(selectedDate);
      String dateStr = dt.format('MM-dd-yyyy');
      preferencesService.paths.clear();
      Loader.show(context);
      await model.updateCovidVaccineInfo(data['status'], dateStr, data, documentId, '');
      await widget.model.getMemberVaccines();
      Loader.hide();
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Caution!'),
              content: Text('Please Select previous Dose date'),
              actions: <Widget>[
                FlatButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text('OK'),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }
  }

  Widget getStatusItem(BuildContext context, int index, dynamic data, CovidRecordViewModel model, String documentId, String filterTitle1) {
    bool status = data['status'].toString() == 'true' ? true : false;
    String attachRecord = '';
    if (data['attach_record'] != null) {
      if (data['attach_record'].length > 0) {
        attachRecord = 'data';
      } else {
        attachRecord = "";
      }
    }
    print(data['date']);
    String dateStr = '';
    String dateString = '';
    if ((data['date'] == null) || (data['date'] == '')) {
      dateStr = "";
    } else {
      Jiffy dt = Jiffy(data['date']);
      dateStr = dt.format('ddMMM');
      dateString = dt.format('ddMMMyy');
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
            child: Text(data['dose']).textAlignment(TextAlign.center).fontSize(12).fontWeight(FontWeight.w600),
          )),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await _displayTextInputDialog(context, data, model, documentId, '');
              },
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  decoration: UIHelper.rowRightBorder(),
                  child: status
                      ? Icon(
                          Icons.done,
                          size: 20,
                          color: Colors.green,
                        )
                      : Container(
                          height: 20,
                        )),
            ),
          ),
          Expanded(
              child: GestureDetector(
            onTap: () {
              _selectDate(context, data, model, documentId, index);
            },
            child: Container(padding: EdgeInsets.symmetric(vertical: 6), decoration: UIHelper.rowRightBorder(), child: Text(dateString).fontSize(11).fontWeight(FontWeight.w600).textAlignment(TextAlign.center)),
          )),
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
                                    categoryTitle: 'Covid Vaccine',
                                    data: {'title1': filterTitle1, 'title2': data['dose']},
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
                          showFilePickerSheet(context, data, model, documentId, filterTitle1);
                        },
                        child: Icon(
                          Icons.add,
                          size: 20,
                        )),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget addDataItem(BuildContext context, int index, dynamic data, CovidRecordViewModel model) {
    List dosestatus = data['dosestatus'] ?? [];
    return Container(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : fieldBgColor,
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.black12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: rowItem(context, data['vaccination_name'] ?? '', Colors.white),
          ),
          Expanded(
            child: ListView.separated(
                separatorBuilder: (context, index) {
                  return SizedBox();
                },
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: dosestatus.length,
                itemBuilder: (context, index) {
                  return getStatusItem(context, index, dosestatus[index], model, data['_id'], data['vaccination_name']);
                }),
          ),
          GestureDetector(
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
                            setState(() {
                              isload = true;
                            });
                            Navigator.pop(context);
                            await model.deleteCovidInfo(data['_id'], 'covidVaccination_Id');
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
          ),
        ],
      ),
    );
  }

  Widget showRecordHeader(BuildContext context, CovidRecordViewModel model) {
    return Container(
      width: Screen.width(context),
      decoration: UIHelper.roundedBorderWithColor(0, Colors.white, borderColor: Colors.black12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              headerItem1('Vaccine', Color(0xFFECECEC), 70),
              headerItem('Dose', fieldBgColor),
              headerItem('Status', Color(0xFFECECEC)),
              headerItem('Date', fieldBgColor),
              headerItem('Records', Color(0xFFECECEC)),
              headerItem1('Action', fieldBgColor, 50),
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
              itemCount: model.memberVaccines.length,
              itemBuilder: (context, index) {
                return addDataItem(context, index, model.memberVaccines[index], model);
              }),
          UIHelper.verticalSpaceSmall,
          isload
              ? Center(child: CircularProgressIndicator())
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    model.memberVaccines.length == 0
                        ? GestureDetector(
                            onTap: () {
                              onShowVaccinePicker(context, model);
                            },
                            child: UIHelper.tagWidget('Add Vaccine', activeColor))
                        : GestureDetector(
                            onTap: () async {
                              await _New_Dose_Dialog(context, model);
                            },
                            child: UIHelper.tagWidget('Add Dose', activeColor)),
                    UIHelper.horizontalSpaceSmall
                  ],
                ),
          UIHelper.verticalSpaceSmall,
        ],
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context, dynamic data, CovidRecordViewModel model, String documentId, String filterTitle1) async {
    if (data['status'] == false) {
      String dateStr = '';
      if (data['date'] != null) {
        Jiffy dt = Jiffy(data['date']);
        dateStr = dt.format('MM-dd-yyyy');
      } else {
        dateStr = '';
      }
      String attachRecord = '';
      if (data['attach_record'] != null) {
        if (data['attach_record'].length > 0) {
          attachRecord = 'data';
        } else {
          data['attach_record'] = "";
        }
      } else {
        data['attach_record'] = "";
      }
      preferencesService.paths.clear();

      Loader.show(context);
      await model.updateCovidVaccineInfo(!data['status'], dateStr, data, documentId, filterTitle1);
      await widget.model.getMemberVaccines();
      Loader.hide();

      // model.updateCovidVaccineInfo(data['status'], dateStr, data, documentId, filter_title1);
    } else
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Caution!'),
              content: Text('Do you want to Change Covid Status?'),
              actions: <Widget>[
                FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text('Yes'),
                  onPressed: () async {
                    String dateStr = '';
                    if (data['date'] != null) {
                      Jiffy dt = Jiffy(data['date']);
                      dateStr = dt.format('MM-dd-yyyy');
                    } else {
                      dateStr = '';
                    }
                    Loader.show(context);
                    await model.updateCovidVaccineInfo(!data['status'], dateStr, data, documentId, filterTitle1);
                    await widget.model.getMemberVaccines();
                    Loader.hide();

                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
  }

  void showFilePickerSheet(BuildContext context, dynamic data, CovidRecordViewModel model, String documentId, String filterTitle1) {
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
                  onTap: () {
                    Get.back();
                    getcapture(
                      context,
                      data,
                      model,
                      documentId,
                      filterTitle1,
                      FileType.video,
                    );
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Camera'),
                ),
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () {
                    //  Get.back();
                    getpick(context, data, model, documentId, filterTitle1);
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Select a File'),
                ),
              ],
            ),
          );
        });
  }

  Future<void> getcapture(BuildContext context, dynamic data, CovidRecordViewModel model, String documentId, String filterTitle1, FileType fileType) async {
    preferencesService.paths.clear();
    String path = '';
    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);

    if (pickedFile != null) {
      await Get.to(() => ImgCropper(
          index: 0,
          imagePath: pickedFile.path,
          onCropComplete: (path) {
            path = pickedFile.path;
            preferencesService.paths.add(path);
            print(path);
          }));
      String dateStr = '';
      if (data['date'] != null) {
        Jiffy dt = Jiffy(data['date']);
        dateStr = dt.format('MM-dd-yyyy');
      } else {
        dateStr = '';
      }
      model.updateCovidVaccineInfo(data['status'], dateStr, data, documentId, filterTitle1);
    }
  }

  Future<void> getpick(BuildContext context, dynamic data, CovidRecordViewModel model, String documentId, String filterTitle1) async {
    preferencesService.paths.clear();
    List<PlatformFile>? _paths;
    _paths = (await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: true, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx']))?.files;
    if (_paths != null) {
      if (_paths.length < 6) {
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
            isvideo = "";
          });
        } else {
          Get.back();
          String dateStr = '';
          if (data['date'] != null) {
            Jiffy dt = Jiffy(data['date']);
            dateStr = dt.format('MM-dd-yyyy');
          } else {
            dateStr = '';
          }

          await model.updateCovidVaccineInfo(data['status'], dateStr, data, documentId, filterTitle1);
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
  }

  void onShowVaccinePicker(BuildContext context, CovidRecordViewModel model) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(8),
                child: Text('Select a vaccine').fontWeight(FontWeight.w600),
              ),
              Container(
                  height: 200,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.covidVaccineList.length,
                      itemBuilder: (context, index) {
                        dynamic vaccine = widget.covidVaccineList[index];
                        return ListTile(
                          leading: new Icon(Icons.verified_outlined),
                          title: new Text(vaccine['vaccination_name']),
                          onTap: () async {
                            setState(() {
                              isload = true;
                            });
                            Navigator.pop(context);
                            await model.addMoreVaccine(vaccine['_id']);
                            isAddVaccine = true;
                            isload = false;
                          },
                        );
                      })),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isAddVaccine = !isAddVaccine;
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
                Text('COVID Vaccine').bold().textColor(Colors.black),
                Text('').textColor(Colors.black),
                Icon(
                  Icons.expand_more,
                )
              ],
            ),
          ),
        ),
        isAddVaccine ? showRecordHeader(context, widget.model) : SizedBox()
      ],
    );
  }
}

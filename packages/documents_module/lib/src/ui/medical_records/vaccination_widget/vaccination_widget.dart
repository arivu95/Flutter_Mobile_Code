import 'package:documents_module/src/ui/downloads/filtered_download_view.dart';
import 'package:documents_module/src/ui/medical_records/vaccination_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:documents_module/src/ui/medical_records/vaccination_viewmodel.dart';
import '../show_vaccination_view.dart';
import 'package:filesize/filesize.dart';

class VaccinationWidget extends StatefulWidget {
  VaccinationWidget({Key? key}) : super(key: key);

  @override
  _VaccinationWidgetState createState() => _VaccinationWidgetState();
}

var new_date;
var get_date;
var first_dose_date;

class _VaccinationWidgetState extends State<VaccinationWidget> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  PreferencesService preferencesService = locator<PreferencesService>();
  String doc_Id = '';
  List<dynamic> date_id = [];
  bool isNewStatus = true;
  final picker = ImagePicker();
  String isvideo = '';
  TextEditingController _textFieldController = TextEditingController();
  Widget headerItem(String title, Color bgColor) {
    return Expanded(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        color: bgColor,
        child: Text(title).bold().fontSize(11).textAlignment(TextAlign.center),
      ),
    );
  }

  Widget headerItem1(String title, Color bgColor) {
    return Container(
      height: 40,
      width: 60,
      alignment: Alignment.center,
      color: bgColor,
      child: Text(title).bold().fontSize(11).textAlignment(TextAlign.center),
    );
  }

  Widget rowItem(String title, Color bgColor) {
    return Container(
      width: 60,
      padding: EdgeInsets.only(left: 4),
      child: Text(title).bold().fontSize(9),
    );
  }

  Future<void> _selectDate(BuildContext context, dynamic data, VaccineViewmodel model, String documentId) async {
    DateTime selectedDate = DateTime.now();
    bool dateIsEmpty = false;
    for (var i = 0; i < model.date_list.length; i++) {
      if (model.date_list[i]['_id'] == data['_id']) {
        if (model.date_list[0]['_id'] != data['_id']) {
          if ((model.date_list[i - 1]['date'] != null) && (preferencesService.vac_date_is_empty == false)) {
            new_date = DateTime.parse(model.date_list[i - 1]['date']);
            get_date = new DateTime(new_date.year, new_date.month, new_date.day + 1);
          } else {
            setState(() {
              dateIsEmpty = true;
            });

            preferencesService.vac_date_is_empty = true;
            break;
          }
        } else if (model.date_list[0]['_id'] == data['_id']) {
          first_dose_date = model.date_list[0]['_id'];
        }
      }
    }

    if ((dateIsEmpty) && (preferencesService.vac_date_is_empty == true)) {
      setState(() {
        dateIsEmpty = false;
      });
      preferencesService.vac_date_is_empty = false;
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Caution!'),
              content: Text('Please select previous Record Date'),
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
    } else if (first_dose_date == data['_id']) {
      selectedDate = (await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(1900, 1), lastDate: DateTime(DateTime.now().year + 79)))!;
      Jiffy dt = Jiffy(selectedDate);
      String dateStr = dt.format('MM-dd-yyyy');
      doc_Id = documentId;
      Loader.show(context);
      await model.tableupdateVaccination(data['status'], dateStr, data, documentId, '');
      Loader.hide();
    } else {
      selectedDate = (await showDatePicker(context: context, initialDate: get_date, firstDate: get_date, lastDate: DateTime(DateTime.now().year + 79)))!;
      Jiffy dt = Jiffy(selectedDate);
      String dateStr = dt.format('MM-dd-yyyy');
      doc_Id = documentId;
      Loader.show(context);
      await model.tableupdateVaccination(data['status'], dateStr, data, documentId, '');
      Loader.hide();
    }
  }

  Future<void> _displayTextInputDialog(BuildContext context, dynamic data, VaccineViewmodel model, String documentId) async {
    print(data['status'].toString());
    print(model.isNewtable.toString());

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Caution!'),
            content: Text('Are you sure to change record status?'),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('No'),
                onPressed: () {
                  if (model.isNewtable) {
                    isNewStatus = true;
                  }
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Yes'),
                onPressed: () {
                  String dateStr = '';
                  if (model.isNewtable) {
                    isNewStatus = false;
                  }
                  if (data['date'] != null) {
                    Jiffy dt = Jiffy(data['date']);
                    dateStr = dt.format('MM-dd-yyyy');
                  } else {
                    dateStr = '';
                  }
                  model.tableupdateVaccination(!data['status'], dateStr, data, documentId, '');
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void showFilePickerSheet(BuildContext context, dynamic data, VaccineViewmodel model, String rootDocId, String filterTitle1) {
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
                      model,
                      rootDocId,
                      filterTitle1,
                      FileType.video,
                    );
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Camera'),
                ),
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () async {
                    await getpick(context, data, model, rootDocId, filterTitle1);
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Select a File'),
                ),
              ],
            ),
          );
        });
  }

  Future<void> getcapture(BuildContext context, dynamic data, VaccineViewmodel model, String documentId, String filterTitle1, FileType fileType) async {
    preferencesService.paths.clear();
    doc_Id = documentId;
    String dateStr = '';
    if (data['date'] != null) {
      Jiffy dt = Jiffy(data['date']);
      dateStr = dt.format('MM-dd-yyyy');
    } else {
      dateStr = '';
    }
    String path = '';
    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
    Get.back();
    if (pickedFile != null) {
      await Get.to(() => ImgCropper(
          index: 0,
          imagePath: pickedFile.path,
          onCropComplete: (path) {
            preferencesService.paths.add(path);
            path = pickedFile.path;
            print(path);
          }));
      //  Loader.show(context);
      await model.tableupdateVaccination(data['status'], dateStr, data, documentId, filterTitle1);
    }
    //  Loader.hide();
  }

  Future<void> getpick(BuildContext context, dynamic data, VaccineViewmodel model, String documentId, String filterTitle1) async {
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
            preferencesService.paths.clear();
          });
        } else {
          Get.back();
          doc_Id = documentId;
          String dateStr = '';
          if (data['date'] != null) {
            Jiffy dt = Jiffy(data['date']);
            dateStr = dt.format('MM-dd-yyyy');
          } else {
            dateStr = '';
          }
          //  Loader.show(context);
          model.tableupdateVaccination(data['status'], dateStr, data, documentId, filterTitle1);
          //   Loader.hide();
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

  Widget getVaccineItem(BuildContext context, int index, dynamic data, VaccineViewmodel model, String rootDocId, String filterTitle1) {
    bool status = data['status'];
    print(data['status']);
    doc_Id = rootDocId;
    String dateStr = '';
    String dateString = '';
    print(data['date']);
    if (data['date'] == null || data['date'] == '') {
      dateStr = "";
    } else {
      Jiffy dt = Jiffy(data['date']);
      dateStr = dt.format('dd-MM-yy');
      dateString = dt.format('ddMMMyy');
    }

    String attachRecord = '';
    if (data['attach_record'] != null) {
      if (data['attach_record'].length > 0) {
        attachRecord = 'data';
      }
    } else {
      attachRecord = "";
    }
    return Container(
        decoration: BoxDecoration(
          color: index % 2 == 0 ? Colors.white : fieldBgColor,
          border: Border(
            left: BorderSide(width: 1.0, color: Colors.black12),
            bottom: BorderSide(width: 1.0, color: Colors.black12),
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(vertical: 17),
            decoration: UIHelper.rowRightBorder(),
            child: Row(
              children: [
                Container(
                  child: Flexible(
                    child: Text(
                      data['vaccine_name'],
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.justify,
                    ).fontSize(9).fontWeight(FontWeight.w600),
                  ),
                )
              ],
            ),
          )),
          Expanded(
              child: GestureDetector(
            onTap: () async {
              await _selectDate(context, data, model, rootDocId);
            },
            child: Container(padding: EdgeInsets.symmetric(vertical: 17), decoration: UIHelper.rowRightBorder(), child: Text(dateString).fontSize(11).fontWeight(FontWeight.w600).textAlignment(TextAlign.center)),
          )),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                String dateStr = '';
                if (data['date'] != null) {
                  Jiffy dt = Jiffy(data['date']);
                  dateStr = dt.format('MM-dd-yyyy');
                } else {
                  dateStr = '';
                }

                if (data['status'] == true) {
                  await _displayTextInputDialog(context, data, model, rootDocId);
                } else {
                  print(data['status']);
                  model.tableupdateVaccination(!data['status'], dateStr, data, rootDocId, filterTitle1);
                }
              },
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
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
                                    categoryId: '6093ceff7a735c0acfb77365',
                                    categoryTitle: 'Vaccination',
                                    data: {'title1': filterTitle1, 'title2': data['vaccine_name']},
                                  ));
                              Loader.show(context);
                              await model.getUserVaccine();
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
                          showFilePickerSheet(context, data, model, rootDocId, filterTitle1);
                          //  getpick(context, data, model, rootDocId);
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
                // *** view vaccination ****
                await Get.to(() => ShowVaccinationView(vaccineData: data, userVaccineData: model.userVaccineData, docId: rootDocId, date_is_empty: false));
                Loader.show(context);
                await model.getUserVaccine();
                Loader.hide();
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(2, 8, 0, 8),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(width: 1.0, color: Colors.black12),
                  ),
                ),
                child: Text('Edit / View').fontSize(9).fontWeight(FontWeight.w600),
              ),
            ),
          )
        ]));
  }

  Widget addDataItem(BuildContext context, int index, dynamic data, VaccineViewmodel model) {
    List vaccinestatus = data['vaccine_name'] ?? [];
    return Container(
      color: index % 2 == 0 ? Colors.white : fieldBgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          rowItem(data['age'], Colors.white),
          Expanded(
            child: ListView.separated(
                separatorBuilder: (context, index) {
                  return SizedBox();
                },
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: vaccinestatus.length,
                itemBuilder: (context, index) {
                  return getVaccineItem(context, index, vaccinestatus[index], model, data['_id'], data['age']);
                }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: Screen.width(context),
        decoration: UIHelper.roundedBorderWithColor(8, fieldBgColor, borderColor: Colors.black12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 30,
              decoration: UIHelper.roundedBorderWithColor(6, subtleColor, borderColor: Colors.black12),
              width: Screen.width(context),
              alignment: Alignment.center,
              child: Text('Manage Child Records').textColor(Colors.black).bold(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                headerItem1('Age', Color(0xFFECECEC)),
                headerItem('Record type', fieldBgColor),
                headerItem('Date', Color(0xFFECECEC)),
                headerItem('Status', fieldBgColor),
                headerItem('Records', Color(0xFFECECEC)),
                headerItem('Add more details', fieldBgColor),
              ],
            ),
            Container(
              color: Colors.black12,
              height: 1,
            ),
            ViewModelBuilder<VaccineViewmodel>.reactive(
                onModelReady: (model) {
                  model.getUserVaccine();
                },
                builder: (context, model, child) {
                  return ListView.separated(
                      separatorBuilder: (context, index) {
                        return SizedBox();
                      },
                      padding: EdgeInsets.only(top: 0),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: model.userVaccine.length,
                      itemBuilder: (context, index) {
                        return addDataItem(context, index, model.userVaccine[index], model);
                      });
                },
                viewModelBuilder: () => VaccineViewmodel()),
          ],
        ),
      ),
    );
  }
}

import 'package:documents_module/src/ui/downloads/filtered_download_view.dart';
import 'package:documents_module/src/ui/medical_records/maternity_widget/maternity_widgetmodel.dart';
import 'package:documents_module/src/ui/medical_records/maternity_widget/show_maternity_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:filesize/filesize.dart';

class MaternityWidget extends StatefulWidget {
  MaternityWidget({Key? key}) : super(key: key);

  @override
  _MaternityWidgetState createState() => _MaternityWidgetState();
}

class _MaternityWidgetState extends State<MaternityWidget> {
  TextEditingController _textFieldController = TextEditingController();
  PreferencesService preferencesService = locator<PreferencesService>();
  String isvideo = '';
  final picker = ImagePicker();

  Future<void> _displayTextInputDialog(BuildContext context, MaternityWidgetModel model, dynamic data) async {
    String motherWeight = data['mother_weight'] != null ? data['mother_weight'].toString() : '';
    final _textFieldController = TextEditingController();
    void dispose() {
      _textFieldController.dispose();
      super.dispose();
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Mother’s Weight'),
            content: TextField(
              keyboardType: TextInputType.number,
              //data['mother_weight'].toString(),
              controller: _textFieldController..text = motherWeight,
              onChanged: (value) {
                print("jbj" + value);
                motherWeight = value;
                setState(() {
                  motherWeight = value;
                });
              },
              // inputFormatters: [
              //   new WhitelistingTextInputFormatter(RegExp(r'^(\d+)?\.?\d{0,2}')),
              // ],
              inputFormatters: [
                // is able to enter lowercase letters

                FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
              ],
              decoration: InputDecoration(hintText: "Enter in kilogram (kg)"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textFieldController,
                builder: (context, value, child) {
                  return ElevatedButton(
                      onPressed: value.text.isNotEmpty
                          ? () async {
                              print(_textFieldController.text);
                              Navigator.pop(context);
                              await model.updateMaternityInfo(_textFieldController.text, data, data['_id']);
                            }
                          : null,
                      child: Text('Ok'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (!states.contains(MaterialState.disabled)) {
                            return Colors.green;
                          }
                          return Colors.black12;
                        }),
                      ));
                },
              ),
            ],
          );
        });
  }

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

  Widget addMatDataItem(BuildContext context, int index, MaternityWidgetModel model, dynamic data, String rootDocId) {
    String attachRecord = '';
    if (data['attach_record'] != null) {
      if (data['attach_record'].length > 0) {
        attachRecord = 'data';
      }
    } else {
      attachRecord = "";
    }

    return Container(
      color: index % 2 == 0 ? Colors.white : fieldBgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 17),
            decoration: UIHelper.rowRightBorder(),
            child: Text(data['pregnancy_week']).fontSize(11).fontWeight(FontWeight.w600).textColor(activeColor),
          )),
          Expanded(
              child: GestureDetector(
            onTap: () async {
              _textFieldController.text = '';
              await _displayTextInputDialog(context, model, data);
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 17),
              decoration: UIHelper.rowRightBorder(),
              child: Text(data['mother_weight'] ?? '').fontSize(11).fontWeight(FontWeight.w600),
            ),
          )),
          Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 13),
                decoration: UIHelper.rowRightBorder(),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  attachRecord.isNotEmpty
                      ? GestureDetector(
                          onTap: () async {
                            await Get.to(() => FilteredDownloadDetailView(
                                  categoryId: '6093ceff7a735c0acfb77365',
                                  categoryTitle: 'Maternity',
                                  data: {'title1': data['pregnancy_week'] + ' Week'},
                                ));
                            Loader.show(context);
                            await model.getUserMaternity();
                            Loader.hide();
                          },
                          child: Icon(
                            Icons.description_outlined,
                            size: 20,
                          ))
                      : SizedBox(
                          height: 20,
                        ),
                  attachRecord.isNotEmpty ? SizedBox(width: 10) : SizedBox(),
                  GestureDetector(
                      onTap: () {
                        showFilePickerSheet(context, data, model, rootDocId);
                      },
                      child: Icon(
                        Icons.add,
                        size: 20,
                      ))
                ])),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                bool isVideo = false;
                await Get.to(() => ShowMaternityView(
                      maternityinfo: data,
                      documentModelid: model.userMaternityData,
                    ));
                Loader.show(context);
                await model.getUserMaternity();
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
        ],
      ),
    );
  }

  void showFilePickerSheet(BuildContext context, dynamic data, MaternityWidgetModel model, String rootDocId) {
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
                      data['_id'],
                      FileType.video,
                    );
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Camera'),
                ),
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () async {
                    await getpick(context, data, model, data['_id']);
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Select a File'),
                ),
              ],
            ),
          );
        });
  }

  Future<void> getcapture(BuildContext context, dynamic data, MaternityWidgetModel model, String documentId, FileType fileType) async {
    preferencesService.paths.clear();
    String path = '';
    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
    Get.back();
    if (pickedFile != null) {
      await Get.to(() => ImgCropper(
          index: 0,
          imagePath: pickedFile.path,
          onCropComplete: (path) {
            path = pickedFile.path;
            preferencesService.paths.add(path);
            print(path);
          }));
      //Loader.show(context);
      await model.updateMaternityInfo(data['mother_weight'], data, documentId);
      //Loader.hide();
    }
  }

  Future<void> getpick(BuildContext context, dynamic data, MaternityWidgetModel model, String documentId) async {
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
                preferencesService.paths.clear();
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
          if (data['date'] != null) {
            Jiffy dt = Jiffy(data['date']);
            dateStr = dt.format('MM-dd-yyyy');
          } else {
            dateStr = '';
          }
          //Loader.show(context);
          await model.updateMaternityInfo(_textFieldController.text == "" ? data['mother_weight'] : _textFieldController.text, data, documentId);
          //Loader.hide();

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: Screen.width(context),
        decoration: UIHelper.roundedBorderWithColor(6, Colors.transparent, borderColor: Colors.black12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 30,
              decoration: UIHelper.roundedBorderWithColor(6, subtleColor, borderColor: Colors.black12),
              width: Screen.width(context),
              alignment: Alignment.center,
              child: Text('Manage Maternity').textColor(Colors.black).bold(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                headerItem('Pregnancy\nWeek', Color(0xFFECECEC)),
                headerItem('Mother Weight', fieldBgColor),
                headerItem('Records', Color(0xFFECECEC)),
                headerItem('Add more\ndetails', fieldBgColor),
              ],
            ),
            Container(
              color: Colors.black12,
              height: 1,
            ),
            ViewModelBuilder<MaternityWidgetModel>.reactive(
                onModelReady: (model) {
                  model.getUserMaternity();
                },
                builder: (context, model, child) {
                  return ListView.separated(
                      separatorBuilder: (context, index) {
                        return SizedBox();
                      },
                      padding: EdgeInsets.only(top: 0),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: model.userMaternity.length,
                      itemBuilder: (context, index) {
                        return addMatDataItem(context, index, model, model.userMaternity[index], '');
                      });
                },
                viewModelBuilder: () => MaternityWidgetModel())
          ],
        ),
      ),
    );
  }
}

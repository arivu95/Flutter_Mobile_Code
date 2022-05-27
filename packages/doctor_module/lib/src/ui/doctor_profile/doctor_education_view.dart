import 'package:doctor_module/src/ui/doctor_profile/doctor_education_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/custom_switch_widget.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/shared/image_cropper.dart';

class DoctorEducationView extends StatefulWidget {
  String doc_id;
  bool isEditMode;
  bool deleteMode;
  dynamic education_data;

  DoctorEducationView({
    Key? key,
    required this.isEditMode,
    required this.deleteMode,
    required this.doc_id,
    this.education_data,
  }) : super(key: key);
  @override
  _DoctorEducationViewState createState() => _DoctorEducationViewState();
}

class _DoctorEducationViewState extends State<DoctorEducationView> {
  PreferencesService preferencesService = locator<PreferencesService>();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  TextEditingController fileController = TextEditingController();
  TextEditingController collegeController = TextEditingController();
  bool educational_privacy = false;
  String isvideo = '';
  final picker = ImagePicker();

  void initState() {
    super.initState();
    setState(() {
      if (widget.isEditMode) {
        if (widget.education_data['educational_privacy'] == 'true') {
          educational_privacy = true;
        }
      }
    });
  }

  Widget titleCard(BuildContext context, String title) {
    return Container(
        decoration: UIHelper.roundedBorderWithColor(10, Colors.white),
        width: Screen.width(context) / 3.3,
        height: 47,
        padding: EdgeInsets.only(left: 5, right: 2, top: 2, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title).fontSize(13).fontWeight(FontWeight.w500),
          ],
        ));
  }

  Widget addInputFieldControl(String controlName, String hintText, bool numberOnly) {
    return FormBuilderTextField(
      style: loginInputTitleStyle,
      name: controlName,
      autocorrect: false,
      textCapitalization: TextCapitalization.sentences,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {},
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 5),
        hintText: hintText,
        hintStyle: loginInputHintTitleStyle,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: UIHelper.getInputBorder(1),
        focusedBorder: UIHelper.getInputBorder(1),
        focusedErrorBorder: UIHelper.getInputBorder(1),
        errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
      ),
      keyboardType: numberOnly ? TextInputType.number : TextInputType.text,
    );
  }

  Widget addDropdownFieldControl(String controlName, String hintText, bool isRequired, DoctorEducationInfoViewModel model) {
    return FormBuilderDropdown(
        decoration: InputDecoration(
          hintStyle: loginInputHintTitleStyle,
          contentPadding: EdgeInsets.only(left: 10),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: UIHelper.getInputBorder(1),
          focusedBorder: UIHelper.getInputBorder(1),
          focusedErrorBorder: UIHelper.getInputBorder(1),
          errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
        ),
        validator: isRequired
            ? FormBuilderValidators.compose([
                FormBuilderValidators.required(context, errorText: "This field cannot be empty"),
                FormBuilderValidators.max(context, 20),
              ])
            : null,
        name: controlName,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        hint: Text(hintText).fontSize(16),
        items: controlName == "specializations"
            ? model.specializations.map((value) {
                return new DropdownMenuItem(
                  value: value['name'],
                  child: new Text(value['name']).fontSize(16),
                );
              }).toList()
            : controlName == "level_of_graduation"
                ? model.levels.map((value) {
                    return new DropdownMenuItem(
                      value: value['name'],
                      child: new Text(value['name']).fontSize(16),
                    );
                  }).toList()
                : controlName == "qualification"
                    ? model.qualifications.map((value) {
                        return new DropdownMenuItem(
                          value: value['name'],
                          child: new Text(value['name']).fontSize(16),
                        );
                      }).toList()
                    : controlName == "country"
                        ? model.countries.map((value) {
                            return new DropdownMenuItem(
                              value: value['country'],
                              child: new Text(value['country']).fontSize(16),
                            );
                          }).toList()
                        : model.year
                            .map((deg) => DropdownMenuItem(
                                  value: deg,
                                  child: Text(deg).fontSize(16),
                                ))
                            .toList(),
        onChanged: (value) => {
              setState(() {
                controlName == "country" ? model.getColleges(value) : null;
              })
            });
  }

  Widget eductionInfoSection(BuildContext context, DoctorEducationInfoViewModel model) {
    String fileUrl = fileController.text.split('/').last;
    String fileTrimurl = fileUrl.split('_').last;

    return Container(
        padding: EdgeInsets.all(10),
        decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Color(0xFFF5F3F3)),
        child: FormBuilder(
          key: _fbKey,
          initialValue: widget.isEditMode
              ? {
                  'level_of_graduation': widget.education_data['level_of_graduation'] ?? null,
                  'qualification': widget.education_data['qualification'] ?? null,
                  'specializations': widget.education_data['specializations'][0] ?? null,
                  'country': widget.education_data['country'] ?? null,
                  'startyear': widget.education_data['startyear'] ?? null,
                  'endyear': widget.education_data['endyear'] ?? null,
                }
              : {},
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [titleCard(context, 'Level*'), SizedBox(width: 5), Expanded(child: Container(child: addDropdownFieldControl('level_of_graduation', 'Select Level', true, model)))]),
            UIHelper.verticalSpaceTiny,
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [titleCard(context, 'Degree* '), SizedBox(width: 5), Expanded(child: Container(child: addDropdownFieldControl('qualification', 'Qualification (e.g.MBBS,)', true, model)))]),
            UIHelper.verticalSpaceTiny,
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [titleCard(context, 'Specialization* '), SizedBox(width: 5), Expanded(child: Container(child: addDropdownFieldControl('specializations', 'Select Specialization', true, model)))]),
            UIHelper.verticalSpaceTiny,
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [titleCard(context, 'Country'), SizedBox(width: 5), Expanded(child: Container(child: addDropdownFieldControl('country', 'Country', false, model)))]),
            UIHelper.verticalSpaceTiny,
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              titleCard(context, 'College/\ninstitute'),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: FormBuilderTypeAhead<String>(
                    suggestionsCallback: (pattern) {
                      return model.colleges.map((e) => e['name'].toString()).toList();
                    },
                    itemBuilder: (context, place) {
                      return ListTile(
                        title: Text(place).fontSize(14),
                      );
                    },
                    onChanged: (value) {
                      setState(() {
                        var collegeText = value!;
                        collegeController.text = collegeText;
                      });
                    },
                    name: "college_institute",
                    controller: collegeController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 5),
                      hintText: model.isBusy ? 'Loading....' : "College/institute",
                      hintStyle: loginInputHintTitleStyle,
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: UIHelper.getInputBorder(1),
                      focusedBorder: UIHelper.getInputBorder(1),
                      focusedErrorBorder: UIHelper.getInputBorder(1),
                      errorBorder: UIHelper.getInputBorder(1),
                    ),
                  ),
                ),
              ),

              // Expanded(
              //   child: Container(child: addInputFieldControl('college_institute','College/institute', false)),
              // ),
            ]),
            UIHelper.verticalSpaceTiny,
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              titleCard(context, 'Start year'),
              SizedBox(width: 5),
              Expanded(
                child: Container(child: addDropdownFieldControl('startyear', 'Start year', false, model)),
              ),
            ]),
            UIHelper.verticalSpaceTiny,
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              titleCard(context, 'End year or\nexpected'),
              SizedBox(width: 5),
              Expanded(
                child: Container(child: addDropdownFieldControl('endyear', 'End year or expected', false, model)),
              ),
            ]),
            UIHelper.verticalSpaceMedium,
            Text('Upload document').fontWeight(FontWeight.w600),
            UIHelper.verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () async {
                      await getcapture(context, model, FileType.video);
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.white),
                      child: Icon(
                        Icons.photo_camera,
                        size: 30,
                      ),
                    )),
                SizedBox(
                  width: 30,
                ),
                GestureDetector(
                    onTap: () async {
                      await getpick(context, model);
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.white),
                      child: Icon(
                        Icons.attachment,
                        size: 30,
                      ),
                    ))
              ],
            ),
            UIHelper.verticalSpaceMedium,
            fileController.text.isNotEmpty
                ? Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        SizedBox(
                          width: 100,
                          child: recentItem(context),
                        ),
                        SizedBox(width: 10),
                        Flexible(child: Text(fileTrimurl))
                      ])
                : SizedBox(),
            UIHelper.verticalSpaceMedium,
          ]),
        ));
  }

  Future<void> getcapture(BuildContext context, DoctorEducationInfoViewModel model, FileType fileType) async {
    preferencesService.paths.clear();
    String path = '';
    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
    if (pickedFile != null) {
      path = pickedFile.path;

      await Get.to(() => ImgCropper(
          index: 0,
          imagePath: pickedFile.path,
          onCropComplete: (path) {
            String st = path;
            print(path);
            setState(() {
              preferencesService.paths.add(path);
              fileController.text = path;
            });
          }));
    }
  }

  Future<void> getpick(
    BuildContext context,
    DoctorEducationInfoViewModel model,
  ) async {
    preferencesService.paths.clear();
    FilePickerResult result = (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx']))!;
    String path = result.files.single.path!;
    preferencesService.paths.add(path);
    setState(() {
      fileController.text = path;
    });
    if (preferencesService.paths.toString().contains("mp4") || preferencesService.paths.toString().contains("mp3")) {
      setState(() {
        isvideo = "yes";
        fileController.text = "";
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
    } else {}
  }

  Widget recentItem(BuildContext context) {
    String filePath = fileController.text;
    String filename = filePath.split('/').last;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.file(
        File(fileController.text),
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
                      : ClipRRect(borderRadius: BorderRadius.circular(8), child: UIHelper.getImage(filePath, 80, 80));
        },
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context, DoctorEducationInfoViewModel model) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you Want to Delete ?'),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Ok'),
                onPressed: () async {
                  await model.deleteDoctorEducation(widget.doc_id, widget.education_data['information_Id']);
                  setState(() {
                    Navigator.pop(context);
                    Get.back();
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppDoctorBar(isProfileBar: true),
      backgroundColor: Colors.white,
      body: ViewModelBuilder<DoctorEducationInfoViewModel>.reactive(
          onModelReady: (model) async {
            Loader.show(context);
            await model.getSpecialization();

            if (widget.isEditMode) {
              if (widget.education_data['certificate'] != null) {
                if (widget.education_data['certificate'].length > 0) {
                  setState(() {
                    fileController.text = '${ApiService.fileStorageEndPoint}${widget.education_data['certificate'][0].toString()}';
                  });
                }
                if (widget.education_data['college_institute'] != null) {
                  collegeController.text = widget.education_data['college_institute'];
                }
                if (widget.education_data['country'] != null && widget.education_data['country'] != " ") {
                  await model.getColleges(widget.education_data['country']);
                }
              }
            }

            Loader.hide();
            preferencesService.paths.clear();
          },
          builder: (context, model, child) {
            return SafeArea(
                top: false,
                child: Container(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      UIHelper.verticalSpaceSmall,
                      Row(
                        children: [
                          Expanded(
                            child: UIHelper.addHeader(context, "Profile", true),
                          ),
                          CustomSwitchWidget(
                            value: educational_privacy,
                            onChanged: (value) {
                              educational_privacy = value;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      UIHelper.verticalSpaceMedium,
                      Text('Education').fontWeight(FontWeight.w600),
                      UIHelper.verticalSpaceSmall,
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              UIHelper.verticalSpaceSmall,
                              eductionInfoSection(context, model),
                              UIHelper.verticalSpaceSmall,
                              widget.isEditMode && widget.deleteMode
                                  ? GestureDetector(
                                      onTap: () async {
                                        await _displayTextInputDialog(context, model);
                                      },
                                      child: Text('Delete').fontWeight(FontWeight.w600),
                                    )
                                  : SizedBox(),
                              UIHelper.verticalSpaceSmall,
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                bool isValue = false;
                                if (_fbKey.currentState!.saveAndValidate()) {
                                  Map<String, dynamic> postParams = Map.from(_fbKey.currentState!.value);
                                  postParams['educational_privacy'] = educational_privacy;
                                  postParams['profile_information'] = "educational_information";
                                  postParams['college_institute'] = collegeController.text;
                                  int diff = 0;
                                  if (postParams['endyear'] != null && postParams['startyear'] != null) {
                                    diff = int.parse(postParams['endyear']) - int.parse(postParams['startyear']);
                                  }

                                  if (diff < 0) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Alert !",
                                            descriptions: "Invalid start date or end date.",
                                            descriptions1: "",
                                            text: "OK",
                                          );
                                        });
                                  } else {
                                    Loader.show(context);
                                    if (widget.isEditMode) {
                                      postParams['information_Id'] = widget.education_data['information_Id'];
                                      await model.editDoctorEducation(widget.doc_id, postParams);
                                    } else {
                                      await model.addDoctorDetails(widget.doc_id, postParams);
                                    }
                                    Loader.hide();
                                    //Get.back();
                                    Get.back(result: {'refresh': true});
                                  }
                                }
                              },
                              child: Text('Save').bold(),
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(220, 36)),
                                backgroundColor: MaterialStateProperty.all(Color(0xFF00C064)),
                              )),
                        ],
                      ),
                      UIHelper.verticalSpaceMedium
                    ])));
          },
          viewModelBuilder: () => DoctorEducationInfoViewModel()),
    );
  }
}

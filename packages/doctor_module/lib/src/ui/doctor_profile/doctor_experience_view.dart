import 'package:doctor_module/src/ui/doctor_profile/doctor_experience_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_profile_bar.dart';
import 'package:jiffy/jiffy.dart';
import 'package:swarapp/shared/custom_year_picker.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/shared/image_cropper.dart';

class DoctorExperienceView extends StatefulWidget {
  String doc_id;
  bool isEditMode;
  dynamic experience_data;
  DoctorExperienceView({
    Key? key,
    required this.isEditMode,
    required this.doc_id,
    this.experience_data,
  }) : super(key: key);

  @override
  _DoctorExperienceViewState createState() => _DoctorExperienceViewState();
}

class _DoctorExperienceViewState extends State<DoctorExperienceView> {
  PreferencesService preferencesService = locator<PreferencesService>();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  TextEditingController fileController = TextEditingController();
  CustomYearContoller start_year = CustomYearContoller();
  CustomYearContoller end_year = CustomYearContoller();
  String isvideo = '';
  bool working_role = false;
  Jiffy startexpe = Jiffy();
  Jiffy endexpe = Jiffy();
  final picker = ImagePicker();
  List employment_type = ['Full Time', 'Part Time'];

  void initState() {
    super.initState();
    setState(() {
      if (widget.isEditMode) {
        if (widget.experience_data['currently_working'] == "true") {
          working_role = true;
        }
        if (widget.experience_data['startyear'] != null && widget.experience_data['startyear'] != "") {
          startexpe = Jiffy(widget.experience_data['startyear']);
        }
        if (widget.experience_data['endyear'] != null && widget.experience_data['endyear'] != "") {
          endexpe = Jiffy(widget.experience_data['endyear']);
        }
      }
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context, DoctorExperienceViewModel model) async {
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
                  await model.deleteDoctorExprience(widget.doc_id, widget.experience_data['experience_Id']);
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

  Widget addInputFieldControl(String controlName, String hintText, bool isRequired) {
    return FormBuilderTextField(
      style: loginInputTitleStyle,
      name: controlName,
      textCapitalization: TextCapitalization.sentences,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autocorrect: false,
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
      inputFormatters: [
        new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),
      ],
      validator: isRequired
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(context, errorText: "This field cannot be empty"),
              FormBuilderValidators.max(context, 20),
            ])
          : null,
    );
  }

  Widget addDropdownFieldControl(String controlName, String hintText, DoctorExperienceViewModel model) {
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
      name: controlName,
      hint: Text(hintText).fontSize(14),
      items: controlName == "employment_type"
          ? employment_type.map((deg) => DropdownMenuItem(
                    value: deg,
                    child: Text(deg).fontSize(14),
                  ))
              .toList()
          : model.year
              .map((deg) => DropdownMenuItem(
                    value: deg,
                    child: Text(deg).fontSize(14),
                  ))
              .toList(),
    );
  }

  Future<void> getcapture(BuildContext context, DoctorExperienceViewModel model, FileType fileType) async {
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
    DoctorExperienceViewModel model,
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

  Widget registrationInfoSection(BuildContext context, DoctorExperienceViewModel model) {
    String fileUrl = fileController.text.split('/').last;
    String fileTrimurl = fileUrl.split('_').last;

    return Container(
        padding: EdgeInsets.all(10),
        decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Color(0xFFF5F3F3)),
        child: FormBuilder(
            key: _fbKey,
            initialValue: widget.isEditMode
                ? {
                    'title': widget.experience_data['title'] ?? '',
                    'employment_type': widget.experience_data['employment_type'] ?? null,
                    'organization': widget.experience_data['organization'] ?? '',
                    'location': widget.experience_data['location'] ?? '',
                  }
                : {},
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Title*'),
                SizedBox(width: 5),
                Expanded(
                  child: Container(
                    child: addInputFieldControl('title', 'e.g. Senior heart surgeon', true),
                  ),
                ),
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Organization'),
                SizedBox(width: 5),
                Expanded(
                  child: Container(
                    child: addInputFieldControl('organization', 'e.g. SWAR Clinic', false),
                  ),
                ),
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Employment Type'),
                SizedBox(width: 5),
                Expanded(
                  child: Container(
                    child: addDropdownFieldControl('employment_type', 'Employment Type', model),
                  ),
                ),
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Start year'),
                SizedBox(width: 5),
                Expanded(
                    child: CustomYearPicker(
                        controller: start_year,
                        initialDate: widget.isEditMode && widget.experience_data['startyear'] != "" ? startexpe.dateTime : null,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2050),
                        onChanged: (date) {})),
              ]),
              FormBuilderCheckbox(
                name: 'currently_working',
                initialValue: working_role,
                activeColor: Colors.transparent,
                checkColor: Colors.black,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 5),
                  enabledBorder: UIHelper.getInputBorder(1),
                  focusedBorder: UIHelper.getInputBorder(1),
                  focusedErrorBorder: UIHelper.getInputBorder(1),
                  errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                ),
                title: Text('I am currently working in this role'),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      working_role = true;
                    } else {
                      working_role = false;
                    }
                  });
                },
              ),
              working_role
                  ? SizedBox()
                  : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      titleCard(context, 'End year'),
                      SizedBox(width: 5),
                      Expanded(
                          child: CustomYearPicker(
                        controller: end_year,
                        initialDate: widget.isEditMode && widget.experience_data['endyear'] != "" ? endexpe.dateTime : null,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2050),
                        onChanged: (date) {},
                      )),
                    ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Location'),
                SizedBox(width: 5),
                Expanded(
                  child: Container(
                    child: addInputFieldControl('location', 'Location', false),
                  ),
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
                      //   mainAxisAlignment: MainAxisAlignment.center,
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
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppDoctorBar(isProfileBar: true),
      backgroundColor: Colors.white,
      body: ViewModelBuilder<DoctorExperienceViewModel>.reactive(
          onModelReady: (model) async {
            Loader.show(context);
            await model.yearsGenerate();
            Loader.hide();
            preferencesService.paths.clear();
            if (widget.isEditMode) {
              if (widget.experience_data['certificate'] != null) {
                if (widget.experience_data['certificate'].length > 0) {
                  setState(() {
                    fileController.text = '${ApiService.fileStorageEndPoint}${widget.experience_data['certificate'][0].toString()}';
                  });
                }
              }
            }
          },
          builder: (context, model, child) {
            return SafeArea(
                top: false,
                child: Container(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      UIHelper.verticalSpaceSmall,
                      UIHelper.addHeader(context, "Profile", true),
                      UIHelper.verticalSpaceMedium,
                      Text('Experience').fontWeight(FontWeight.w600),
                      UIHelper.verticalSpaceSmall,
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(children: [
                          registrationInfoSection(context, model),
                          UIHelper.verticalSpaceSmall,
                          widget.isEditMode
                              ? Center(
                                  child: GestureDetector(
                                    onTap: () async {
                                      await _displayTextInputDialog(context, model);
                                    },
                                    child: Text('Delete').fontWeight(FontWeight.w600),
                                  ),
                                )
                              : SizedBox(),
                          UIHelper.verticalSpaceSmall,
                        ]),
                      )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                String getStartdate = start_year.current_date.toString();
                                String getEnddate = end_year.current_date.toString();
                                String differenceMonth = '';
                                int diff = 0;

                                if (getStartdate.isNotEmpty && getEnddate.isNotEmpty) {
                                  var tempDate1 = Jiffy(getStartdate).format("MM-dd-yyyy");
                                  var tempDate2 = Jiffy(getEnddate).format("MM-dd-yyyy");
                                  var date2 = Jiffy(tempDate2, "MM-dd-yyyy");
                                  var date1 = Jiffy(tempDate1, "MM-dd-yyyy");
                                  differenceMonth = date2.diff(date1, Units.MONTH).toString();
                                  diff = int.parse(differenceMonth);
                                }

                                if (getStartdate.isNotEmpty && getEnddate.isEmpty) {
                                  var tempDate1 = Jiffy(getStartdate).format("MM-dd-yyyy");
                                  var now = new DateTime.now();
                                  var tempDate2 = Jiffy(now).format("MM-dd-yyyy");
                                  var date2 = Jiffy(tempDate2, "MM-dd-yyyy");
                                  var date1 = Jiffy(tempDate1, "MM-dd-yyyy");
                                  differenceMonth = date2.diff(date1, Units.MONTH).toString();
                                  diff = int.parse(differenceMonth);
                                }

                                if (_fbKey.currentState!.saveAndValidate()) {
                                  Map<String, dynamic> postParams = Map.from(_fbKey.currentState!.value);

                                  if (getStartdate != null && getStartdate.isNotEmpty) {
                                    Jiffy fromDate_ = Jiffy(getStartdate);
                                    postParams['startyear'] = fromDate_.format('MM-dd-yyyy');
                                  }

                                  if (getEnddate != null && getEnddate.isNotEmpty) {
                                    Jiffy fromDate_ = Jiffy(getEnddate);
                                    postParams['endyear'] = fromDate_.format('MM-dd-yyyy');
                                  }
                                  postParams['work_experience'] = differenceMonth;
                                  postParams['profile_information'] = "experience";

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
                                      postParams['experience_Id'] = widget.experience_data['experience_Id'];
                                      await model.editDoctorExprience(widget.doc_id, postParams);
                                    } else {
                                      await model.addDoctorExperience(widget.doc_id, postParams);
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
          viewModelBuilder: () => DoctorExperienceViewModel()),
    );
  }
}

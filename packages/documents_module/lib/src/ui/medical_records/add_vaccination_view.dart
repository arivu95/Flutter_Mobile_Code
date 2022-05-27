import 'package:documents_module/src/ui/medical_records/vaccination_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:intl/intl.dart';

class AddVaccinationView extends StatefulWidget {
  dynamic vaccineData;
  dynamic userVaccineData;
  String docId;
  bool date_is_empty;

  AddVaccinationView({Key? key, this.vaccineData, this.userVaccineData, required this.docId, required this.date_is_empty}) : super(key: key);

  @override
  _AddVaccinationViewState createState() => _AddVaccinationViewState();
}

class _AddVaccinationViewState extends State<AddVaccinationView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  PreferencesService preferencesService = locator<PreferencesService>();
  TextEditingController vaccineController = TextEditingController();
  TextEditingController attachController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  VaccineViewmodel modelRef = VaccineViewmodel();

  String selectedRadio = '';

  int _radioValue = 0;
  int value = 0;
  var new_date;
  var get_date;
  var first_dose;
  String isvideo = '';
  bool isattach = false;
  final picker = ImagePicker();
  String attach_file = '';
  String localPath = '';
  String attach = '';
  List<PlatformFile>? _paths;
  @override
  void initState() {
    super.initState();
    print(widget.docId);
    List<dynamic> vaccineDateList = [];

    dynamic vaccinationList = widget.userVaccineData['vaccination'];

    if (vaccinationList != null) {
      for (var i = 0; i < vaccinationList.length; i++) {
        for (var j = 0; j < vaccinationList[i]['vaccine_name'].length; j++) {
          vaccineDateList.add(vaccinationList[i]['vaccine_name'][j]);
        }
      }
      for (var i = 0; i < vaccineDateList.length; i++) {
        if (vaccineDateList[i]['_id'] == widget.vaccineData['_id']) {
          if (vaccineDateList[0]['_id'] != widget.vaccineData['_id']) {
            if (vaccineDateList[i - 1]['date'] != null) {
              new_date = DateTime.parse(vaccineDateList[i - 1]['date']);
              get_date = new DateTime(new_date.year, new_date.month, new_date.day + 1);
            }
          } else if (vaccineDateList[0]['_id'] == widget.vaccineData['_id']) {
            first_dose = vaccineDateList[0]['_id'];
          }
        }
      }
    }

    preferencesService.paths.clear();
  }

  Future<void> _displayTextInputDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Caution!'),
            content: Text('Please select previous Vaccine date'),
            actions: <Widget>[
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void _handleRadioValueChange(String value) {
    setState(() {
      selectedRadio = value;
      switch (selectedRadio) {
        case "1":
          break;
        case "0":
          break;
      }
    });
  }

  bool isAutoValidate = false;
  Widget addInputFormControl(String nameField, String hintText, Widget icon) {
    return Column(children: [
      Container(
        alignment: Alignment.topLeft,
        // padding: EdgeInsets.only(left: 8),
        child: Text(
          hintText,
        ).fontSize(15).textColor(Colors.grey).fontWeight(FontWeight.w600),
      ),
      UIHelper.verticalSpaceSmall,
      FormBuilderTextField(
        style: loginInputTitleStyle,
        name: nameField,
        autocorrect: false,
        readOnly: nameField == 'vaccine' || nameField == 'age' || nameField == 'name' ? true : false,
        onChanged: (value) {
          print(value);
        },
        controller: nameField == 'vaccine'
            ? vaccineController
            : nameField == 'age'
                ? ageController
                : null,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 10, right: 10),
          suffixIcon: icon,
          suffixText: nameField == "height"
              ? "Cm"
              : nameField == "weight"
                  ? "Kg"
                  : nameField == "temperature"
                      ? "°C"
                      : nameField == "spo2"
                          ? "%"
                          : nameField == "blood_pressure"
                              ? "mmHg"
                              : "",
          hintText: hintText,
          hintStyle: loginInputHintTitleStyle,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: UIHelper.getInputBorder(1),
          focusedBorder: UIHelper.getInputBorder(1),
          focusedErrorBorder: UIHelper.getInputBorder(1),
          errorBorder: UIHelper.getInputBorder(1),
        ),
        keyboardType: nameField == 'height' || nameField == 'weight' || nameField == 'temperature' || nameField == 'spo2' || nameField == 'blood_pressure' ? TextInputType.number : TextInputType.text,
        // inputFormatters: [
        //   new WhitelistingTextInputFormatter(RegExp("[0-9.]")),
        //   if (nameField == 'height' || nameField == 'weight' || nameField == 'temperature' || nameField == 'spo2' || nameField == 'blood_pressure') new WhitelistingTextInputFormatter(RegExp(r'^(\d+)?\.?\d{0,2}')),
        // ],
        inputFormatters: [
          // is able to enter lowercase letters

          FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
          if (nameField == 'height' || nameField == 'weight' || nameField == 'temperature' || nameField == 'spo2' || nameField == 'blood_pressure') new FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
        ],
      )
    ]);
  }

  Widget iconItem(IconData icon) {
    return Icon(
      icon,
      color: activeColor,
    );
  }

  //for

  Future getImage(String type, FileType fileType) async {
    String path = '';
    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
    if (pickedFile != null) {
      path = pickedFile.path;
      preferencesService.paths.add(path);
      setState(() {
        attachController.text = preferencesService.paths.toString();
        attach_file = preferencesService.paths.toString();
        if (path != '') {
          isattach = true;
        }
      });
    }
    print(path);
  }

  void showFilePickerSheet(String type) {
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
                    getImage(type, FileType.video);
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Camera'),
                ),
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () {
                    Get.back();
                    getpick(context);
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Select a File'),
                ),
              ],
            ),
          );
        });
  }

  Future<void> getpick(BuildContext context) async {
    preferencesService.paths.clear();
    attach = "";
    FilePickerResult result = (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx']))!;
    String path = result.files.single.path!;
    preferencesService.paths.add(path);
    // print(widget.vaccineData['attach_record'].toString());
    // if (path != '') {
    //   isattach = true;
    // }
    // setState(() {
    //   attachController.text = preferencesService.paths.toString();
    // });
    setState(() {
      attachController.text = preferencesService.paths.toString();
      //attach_file = attachController.text;
      attach = preferencesService.paths.toString();
      if (path != '') {
        isattach = true;
      }
    });
  }

  Widget imageItem(String asset) {
    return Image.asset(
      asset,
      height: 24,
    );
  }
  //for radio onchange

  Widget formControls(BuildContext context) {
    DateTime? givenDateStr;
    DateTime? nextDate;
    String nxtDt = '';
    String gvn = '';
    String dob = '';
    DateTime? onlyDate;
    Jiffy givendate;
    if (widget.vaccineData['vaccine_date'] == null) {
      nextDate = widget.vaccineData['vaccine_date'];
    } else if (widget.vaccineData['vaccine_date'] != "") {
      Jiffy nextdate = Jiffy(widget.vaccineData['vaccine_date']);
      nextDate = nextdate.dateTime;
      // nxt_dt=nextdate.format('dd/MM/yyyy');
    }

    // print(widget.vaccineData['date'].toString());
    // if (widget.vaccineData['date'] == null) {
    //   given_dateStr = widget.vaccineData['date'];
    // } else if (widget.vaccineData['date'] != "") {
    //   Jiffy givendate = Jiffy(widget.vaccineData['date']);
    //   given_dateStr = givendate.dateTime;
    // }
    print(widget.vaccineData['date'].toString());
    if (widget.vaccineData['date'] == null) {
      givenDateStr = widget.vaccineData['date'];
    } else if (widget.vaccineData['date'] != "") {
      Jiffy givendate = Jiffy(widget.vaccineData['date']);
      givenDateStr = givendate.dateTime;
    }

//for attached file
    setState(() {
      if (isattach) {
        attachController.text = preferencesService.paths.toString();
        attach = preferencesService.paths.toString();
        // widget.vaccineData['attach_record'] = attach;
        isattach = false;
      } else {
        //  attachController.text = widget.vaccineData['attach_record'] != null ? widget.vaccineData['attach_record'].toString() : " ";
        //  attach = attachController.text;
      }
    });

    vaccineController.text = widget.vaccineData['vaccine_name'].toString();
    String age = preferencesService.dropdown_user_age;
    ageController.text = age;
    if (preferencesService.dropdown_user_dob != "") {
      // Jiffy date_birth = Jiffy( preferencesService.dropdown_user_dob);
      // dob = date_birth.format('dd/MM/yyyy');
      dob = preferencesService.dropdown_user_dob;
    } else if (preferencesService.dropdown_user_dob == null || preferencesService.dropdown_user_dob == "") {
      dob = "";
    }
    // if (preferencesService.memberInfo['date_of_birth'] == null) {
    //   dob = "";
    // } else {
    //   Jiffy date_birth = Jiffy(preferencesService.memberInfo['date_of_birth']);
    //   dob = date_birth.format('dd/MM/yyyy');
    // }
    // print(preferencesService.memberInfo.toString());

//radio button status

//_handleRadioValueChange(widget.vaccineData['status'] ? '1' :'0');

    //setState(() {
    // if(widget.vaccineData['status']=="true"){
    //   selectedRadio="1";
    // }else{
    //   selectedRadio="0";
    // }
    // });
    return Padding(
      padding: const EdgeInsets.only(left: 1, right: 1),
      child: Container(
        padding: EdgeInsets.all(12),
        width: Screen.width(context),
        decoration: UIHelper.roundedBorderWithColor(8, subtleColor, borderColor: Color(0xFFE2E2E2)),
        child: FormBuilder(
            initialValue: {
              'vaccine_date': givenDateStr,
              'status': widget.vaccineData['status'] ?? '',
              'height': widget.vaccineData['height'] ?? '',
              'weight': widget.vaccineData['weight'] ?? '',
              'temperature': widget.vaccineData['temperature'] ?? '',
              'spo2': widget.vaccineData['spo2'] ?? '',
              'blood_pressure': widget.vaccineData['blood_pressure'] ?? '',
              'notes': widget.vaccineData['notes'] ?? '',
              'attach': attach,
              //'attach': widget.vaccineData['attach_record'] ?? '',
            },
            autovalidateMode: isAutoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            key: _fbKey,
            child: Column(
              children: [
                UIHelper.verticalSpaceSmall,
                Column(children: [
                  Container(
                    alignment: Alignment.topLeft,
                    // padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Vaccination Date",
                    ).fontSize(15).textColor(Colors.grey).fontWeight(FontWeight.w600),
                  ),
                  UIHelper.verticalSpaceSmall,
                  Theme(
                    data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                      primary: activeColor, //constant Color(0xFF16A5A6)
                    )),
                    child: first_dose == widget.vaccineData['_id']
                        ? FormBuilderDateTimePicker(
                            // initialDate: beginDate.add(Duration(days: 1)),
                            name: "vaccine_date",
                            initialDate: givenDateStr,
                            firstDate: DateTime(1900),
                            inputType: InputType.date,
                            format: DateFormat("dd/MM/yyyy"),
                            // validators: [FormBuilderValidators.required()],
                            decoration: InputDecoration(
                              hintText: "Vaccination date",
                              contentPadding: EdgeInsets.only(left: 10),
                              prefixIcon: imageItem('assets/vacdate.png'),
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: activeColor,
                              ),
                              filled: true,
                              fillColor: Colors.white70,
                              enabledBorder: UIHelper.getInputBorder(1),
                              focusedBorder: UIHelper.getInputBorder(1),
                              focusedErrorBorder: UIHelper.getInputBorder(1),
                              errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                            ),
                            // validator: FormBuilderValidators.compose([
                            //   FormBuilderValidators.required(context),
                            // ]),
                          )
                        : get_date != null
                            ? FormBuilderDateTimePicker(
                                onChanged: (value) {
                                  preferencesService.vac_date_is_empty = false;
                                },
                                // initialDate: beginDate.add(Duration(days: 1)),
                                name: "vaccine_date",
                                initialDate: get_date,
                                firstDate: get_date,
                                inputType: InputType.date,
                                format: DateFormat("dd/MM/yyyy"),
                                // validators: [FormBuilderValidators.required()],
                                decoration: InputDecoration(
                                  hintText: "Vaccination date",
                                  contentPadding: EdgeInsets.only(left: 10),
                                  prefixIcon: imageItem('assets/vacdate.png'),
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: activeColor,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white70,
                                  enabledBorder: UIHelper.getInputBorder(1),
                                  focusedBorder: UIHelper.getInputBorder(1),
                                  focusedErrorBorder: UIHelper.getInputBorder(1),
                                  errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                                ),
                                // validator: FormBuilderValidators.compose([
                                //   FormBuilderValidators.required(context),
                                // ]),
                              )
                            : FormBuilderTextField(
                                //style: loginInputTitleStyle,
                                name: "vaccine_date",
                                // enableInteractiveSelection: false,
                                readOnly: true,
                                onChanged: (value) {
                                  setState(() {
                                    _displayTextInputDialog();
                                  });
                                },

                                decoration: InputDecoration(
                                  hintText: "Vaccination date",
                                  contentPadding: EdgeInsets.only(left: 10),
                                  prefixIcon: imageItem('assets/vacdate.png'),
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: activeColor,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white70,
                                  enabledBorder: UIHelper.getInputBorder(1),
                                  focusedBorder: UIHelper.getInputBorder(1),
                                  focusedErrorBorder: UIHelper.getInputBorder(1),
                                  errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                                ),
                              ),

                    // FormBuilderTextField(
                    //     //style: loginInputTitleStyle,
                    //     name: "vaccine_date",
                    //     // enableInteractiveSelection: false,
                    //     readOnly: true,
                    //     onChanged: (value) {
                    //       setState(() {
                    //         _displayTextInputDialog();
                    //       });
                    //     },

                    //     decoration: InputDecoration(
                    //       hintText: "Vaccination date",
                    //       contentPadding: EdgeInsets.only(left: 10),
                    //       prefixIcon: imageItem('assets/vacdate.png'),
                    //       suffixIcon: Icon(
                    //         Icons.calendar_today,
                    //         color: activeColor,
                    //       ),
                    //       filled: true,
                    //       fillColor: Colors.white70,
                    //       enabledBorder: UIHelper.getInputBorder(1),
                    //       focusedBorder: UIHelper.getInputBorder(1),
                    //       focusedErrorBorder: UIHelper.getInputBorder(1),
                    //       errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                    //     ),
                    //   ),
                  ),
                ]),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('height', 'Height', imageItem('assets/apgr_rec_icon.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('weight', 'Weight', imageItem('assets/bweight.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('temperature', 'Temperature', imageItem('assets/apgr_rec_icon.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('spo2', 'SpO2', imageItem('assets/mbgroup.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('blood_pressure', 'Blood Pressure', imageItem('assets/mbgroup.png')),
                UIHelper.verticalSpaceSmall,
                // addInputFormControl('notes', 'Notes', imageItem('assets/mr_icon.png')),
                Column(children: [
                  Container(
                    alignment: Alignment.topLeft,
                    // padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Notes",
                    ).fontSize(15).textColor(Colors.grey).fontWeight(FontWeight.w600),
                  ),
                  UIHelper.verticalSpaceSmall,
                  FormBuilderTextField(
                    style: loginInputTitleStyle,
                    name: "notes",
                    autocorrect: false,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10, right: 10),
                      suffixIcon: imageItem('assets/mr_icon.png'),
                      hintText: "Notes",
                      hintStyle: loginInputHintTitleStyle,
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: UIHelper.getInputBorder(1),
                      focusedBorder: UIHelper.getInputBorder(1),
                      focusedErrorBorder: UIHelper.getInputBorder(1),
                      errorBorder: UIHelper.getInputBorder(1),
                    ),
                  ),
                ]),

                UIHelper.verticalSpaceMedium,
                // Column(children: [
                //   Container(
                //     alignment: Alignment.topLeft,
                //     // padding: EdgeInsets.only(left: 8),
                //     child: Text(
                //       "Attach File",
                //     ).fontSize(15).textColor(Colors.grey).fontWeight(FontWeight.w600),
                //   ),
                //   UIHelper.verticalSpaceSmall,
                //   FormBuilderTextField(
                //     //style: loginInputTitleStyle,
                //     name: "attach",
                //     controller: attachController,
                //     enableInteractiveSelection: false,
                //     autocorrect: false,
                //     showCursor: false,
                //     onChanged: (value) {
                //       setState(() {
                //         attachController.text = attach;
                //       });
                //     },
                //     onTap: () async {
                //       showFilePickerSheet('type');
                //     },
                //     decoration: InputDecoration(
                //       contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                //       // prefixIcon: iconItem(Icons.person),
                //       prefixIcon: imageItem('assets/attach_member.png'),
                //       suffixIcon: imageItem('assets/attach_member_icon.png'),
                //       hintText: "Attach Record",
                //       hintStyle: loginInputHintTitleStyle,
                //       filled: true,
                //       fillColor: Colors.white,
                //       enabledBorder: UIHelper.getInputBorder(1),
                //       focusedBorder: UIHelper.getInputBorder(1),
                //       focusedErrorBorder: UIHelper.getInputBorder(1),
                //       errorBorder: UIHelper.getInputBorder(1),
                //       //contentPadding: const EdgeInsets.symmetric(vertical: 40.0),
                //     ),
                //   ),
                // ]),
                UIHelper.verticalSpaceMedium,
                ViewModelBuilder<VaccineViewmodel>.reactive(
                    builder: (context, model, child) {
                      return model.isBusy
                          ? CircularProgressIndicator()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      //widget.vaccineData['attach_record']=
                                      // if (preferencesService.paths.isEmpty) {
                                      //   widget.vaccineData['attach_record'] = "";
                                      // }
                                      preferencesService.paths.clear();
                                      Get.back(result: {'refresh': true});
                                    },
                                    child: Text('CANCEL').textColor(Colors.white),
                                    style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(Size(80, 32)),
                                        elevation: MaterialStateProperty.all(0),
                                        backgroundColor: MaterialStateProperty.all(activeColor),
                                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                                ElevatedButton(
                                    onPressed: () async {
                                      if (_fbKey.currentState!.saveAndValidate()) {
                                        Map<String, dynamic> postParams = Map.from(_fbKey.currentState!.value);
                                        String dateStr = "";
                                        if ((get_date != null) || (first_dose == widget.vaccineData['_id'])) {
                                          if (_fbKey.currentState!.value['vaccine_date'] != null) {
                                            DateTime? vaccineDate = _fbKey.currentState!.value['vaccine_date'];
                                            dateStr = vaccineDate.toString();
                                            Jiffy fromDate_ = Jiffy(vaccineDate);
                                            postParams['date'] = fromDate_.format('MM-dd-yyyy');
                                          }
                                        }
                                        String userId = preferencesService.userId;
                                        postParams['vaccine_Id'] = widget.vaccineData['_id'];
                                        postParams['vaccinationMaster_Id'] = widget.docId;

                                        widget.vaccineData['status'] == true ? postParams['status'] = 1 : postParams['status'] = 0;

                                        String doc = widget.userVaccineData['_id'];
                                        Loader.show(context);
                                        final response = await model.updateVaccinationRecord(postParams, doc, isattach);

                                        Loader.hide();
                                        setState(() {
                                          widget.vaccineData['name'] = postParams['name'];
                                          widget.vaccineData['medical_record_no'] = postParams['medical_record_no'];
                                          widget.vaccineData['age'] = postParams['age'];
                                          // postParams['status'] = widget.vaccineData['status'];

                                          widget.vaccineData['date'] = dateStr;
                                          widget.vaccineData['height'] = postParams['height'];
                                          widget.vaccineData['weight'] = postParams['weight'];
                                          widget.vaccineData['temperature'] = postParams['temperature'];
                                          widget.vaccineData['spo2'] = postParams['spo2'];
                                          widget.vaccineData['blood_pressure'] = postParams['blood_pressure'];
                                          widget.vaccineData['notes'] = postParams['notes'];
                                          // if (preferencesService.paths.isNotEmpty) {
                                          //   widget.vaccineData['attach_record'] = postParams['attach'];
                                          // }
                                          //widget.vaccineData['attach_record'] = postParams['attach'];
                                        });
                                        preferencesService.paths.clear();
                                        Get.back(result: {'refresh': true});
                                      }
                                    },
                                    child: Text('SAVE'),
                                    style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(Size(80, 32)),
                                        backgroundColor: MaterialStateProperty.all(Colors.green),
                                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                              ],
                            );
                    },
                    viewModelBuilder: () => VaccineViewmodel()),
              ],
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: SwarAppStaticBar(),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            width: Screen.width(context),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // UIHelper.verticalSpaceMedium,
              // UIHelper.verticalSpaceSmall,
              UIHelper.verticalSpaceSmall,
              UIHelper.addHeader(context, "Edit Vaccination", true),
              UIHelper.verticalSpaceMedium,

              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [formControls(context), UIHelper.verticalSpaceMedium],
                ),
              ))
            ])));
  }
}

import 'package:documents_module/src/ui/medical_records/vaccination_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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

class AddBirthDetailsView extends StatefulWidget {
  dynamic vaccineData;
  dynamic userVaccineData;
  String docId;

  AddBirthDetailsView({Key? key, this.vaccineData, this.userVaccineData, required this.docId}) : super(key: key);

  @override
  _AddBirthDetailsViewState createState() => _AddBirthDetailsViewState();
}

class _AddBirthDetailsViewState extends State<AddBirthDetailsView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  PreferencesService preferencesService = locator<PreferencesService>();
  TextEditingController vaccineController = TextEditingController();
  TextEditingController attachController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  String selectedRadio = '';

  int _radioValue = 0;
  int value = 0;
  String isvideo = '';
  bool isattach = false;
  String attach = '';
  List<PlatformFile>? _paths;
  List getAlertmessage = [];
  @override
  void initState() {
    super.initState();
    getAlertmessage = preferencesService.alertContentList!.where((msg) => msg['type'] == "Child_record_update").toList();
    print(widget.docId);
    setState(() {});
    preferencesService.paths.clear();
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
          contentPadding: EdgeInsets.only(left: 10),
          suffixIcon: icon,
          suffixText: nameField == "TSH"
              ? "mIU/L"
              : nameField == "G6PD"
                  ? "U/g Hb"
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
        //keyboardType: nameField == 'birth_weight' || nameField == 'length_at_birth' || nameField == 'head_circumference' ? TextInputType.number : TextInputType.text,
        keyboardType:
            nameField == 'birth_weight' || nameField == 'length_at_birth' || nameField == 'head_circumference' || nameField == 'gestational_Age' || nameField == 'apgar_score' || nameField == 'TSH' || nameField == 'G6PD'
                ? TextInputType.number
                : TextInputType.text,
        // inputFormatters: [
        //   if (nameField == 'gestational_Age') new WhitelistingTextInputFormatter(RegExp("[0-9]")),
        //   if (nameField == 'birth_weight' || nameField == 'length_at_birth' || nameField == 'head_circumference' || nameField == 'apgar_score' || nameField == 'TSH' || nameField == 'G6PD')
        //     new WhitelistingTextInputFormatter(RegExp(r'^(\d+)?\.?\d{0,2}')),
        // ],
        inputFormatters: [
          // is able to enter lowercase letters
          if (nameField == 'gestational_Age') new FilteringTextInputFormatter.allow(RegExp("[0-9]")),
          if (nameField == 'birth_weight' || nameField == 'length_at_birth' || nameField == 'head_circumference' || nameField == 'apgar_score' || nameField == 'TSH' || nameField == 'G6PD')
            new FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
          //if (control_name == 'mobilenumber') FilteringTextInputFormatter.allow(RegExp("[0-9]")),
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

//_handleRadioValueChange(widget.userVaccineData['status'] ? '1' :'0');

    //setState(() {
    // if(widget.userVaccineData['status']=="true"){
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
          child: StreamBuilder<String?>(
            stream: locator<PreferencesService>().userName.outStream,
            builder: (context, snapshotname) => FormBuilder(
                initialValue: {
                  'name': preferencesService.dropdownuserName.value! ?? '',
                  'dob': dob,
                  'age': age ?? '',
                  'medical_record_no': widget.userVaccineData['medical_record_no'] ?? '',
                  'date': givenDateStr,
                  'next_vaccine_date': nextDate,
                  'mode_of_delivery': widget.userVaccineData['mode_of_delivery'] ?? null,
                  'status': widget.userVaccineData['status'] ?? null,
                  'baby_blood_group': widget.userVaccineData['baby_blood_group'] ?? null,
                  'mother_Blood_group': widget.userVaccineData['mother_Blood_group'] ?? null,
                  'apgar_score': widget.userVaccineData['apgar_score'] ?? null,
                  'gestational_Age': widget.userVaccineData['gestational_Age'] ?? '',
                  'birth_weight': widget.userVaccineData['birth_weight'] ?? '',
                  'length_at_birth': widget.userVaccineData['length_at_birth'] ?? '',
                  'head_circumference': widget.userVaccineData['head_circumference'] ?? '',
                  'TSH': widget.userVaccineData['TSH'] ?? '',
                  'G6PD': widget.userVaccineData['G6PD'] ?? '',
                },
                autovalidateMode: isAutoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                key: _fbKey,
                child: Column(
                  children: [
                    addInputFormControl('name', 'Name', iconItem(Icons.person)),
                    UIHelper.verticalSpaceSmall,
                    addInputFormControl('dob', 'Date of Birth', imageItem('assets/ch_up.png')),
                    UIHelper.verticalSpaceSmall,
                    addInputFormControl('medical_record_no', 'Medical Record No', imageItem('assets/ch_up.png')),
                    UIHelper.verticalSpaceSmall,
                    addInputFormControl('gestational_Age', 'Gestational Age', imageItem('assets/age_icon.png')),
                    UIHelper.verticalSpaceSmall,
                    Column(children: [
                      Container(
                        alignment: Alignment.topLeft,
                        // padding: EdgeInsets.only(left: 8),
                        child: Text(
                          "Mode of delivery",
                        ).fontSize(15).textColor(Colors.grey).fontWeight(FontWeight.w600),
                      ),
                      UIHelper.verticalSpaceSmall,
                      FormBuilderDropdown(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10),
                          suffixIcon: imageItem('assets/cil_pregnant.png'),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: UIHelper.getInputBorder(1),
                          focusedBorder: UIHelper.getInputBorder(1),
                          focusedErrorBorder: UIHelper.getInputBorder(1),
                          errorBorder: UIHelper.getInputBorder(1),
                        ),
                        name: "mode_of_delivery",
                        // key: UniqueKey(),
                        hint: Text('Mode of delivery'),
                        items: ['NVD', 'CS', 'Instrumentation']
                            .map((grp) => DropdownMenuItem(
                                  //value: grp,
                                  value: grp,
                                  child: Text("$grp").textColor(Colors.black).fontSize(16),
                                ))
                            .toList(),
                      ),
                    ]),
                    UIHelper.verticalSpaceSmall,
                    addInputFormControl('birth_weight', 'Birth Weight', imageItem('assets/bweight.png')),
                    UIHelper.verticalSpaceSmall,
                    addInputFormControl('apgar_score', 'APGAR Score', imageItem('assets/apgr_rec_icon.png')),
                    UIHelper.verticalSpaceSmall,
                    addInputFormControl('length_at_birth', 'Length at birth', imageItem('assets/lb.png')),
                    UIHelper.verticalSpaceSmall,
                    // // addInputFormControl('address', 'Address', Icons.location_on),
                    // //GestureDetector( onTap: () async { await Get.to(() => ProfileView()); setState(() {}); },z
                    addInputFormControl('head_circumference', 'Head Circumference', imageItem('assets/head_cir.png')),
                    UIHelper.verticalSpaceSmall,
                    addInputFormControl('TSH', 'TSH', imageItem('assets/tsh.png')),
                    UIHelper.verticalSpaceSmall,
                    addInputFormControl('G6PD', 'G6PD', imageItem('assets/g6pd.png')),
                    UIHelper.verticalSpaceSmall,
                    Column(children: [
                      Container(
                        alignment: Alignment.topLeft,
                        // padding: EdgeInsets.only(left: 8),
                        child: Text(
                          "Baby Blood Group",
                        ).fontSize(15).textColor(Colors.grey).fontWeight(FontWeight.w600),
                      ),
                      UIHelper.verticalSpaceSmall,
                      FormBuilderDropdown(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10),
                          suffixIcon: imageItem('assets/mbgroup.png'),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: UIHelper.getInputBorder(1),
                          focusedBorder: UIHelper.getInputBorder(1),
                          focusedErrorBorder: UIHelper.getInputBorder(1),
                          errorBorder: UIHelper.getInputBorder(1),
                        ),
                        name: "baby_blood_group",
                        // key: UniqueKey(),
                        hint: Text('Baby Blood Group'),
                        items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                            .map((grp) => DropdownMenuItem(
                                  //value: grp,
                                  value: grp,
                                  child: Text("$grp").textColor(Colors.black).fontSize(16),
                                ))
                            .toList(),
                      ),
                    ]),
                    UIHelper.verticalSpaceSmall,
                    Column(children: [
                      Container(
                        alignment: Alignment.topLeft,
                        // padding: EdgeInsets.only(left: 8),
                        child: Text(
                          "Mother\'s Blood Group",
                        ).fontSize(15).textColor(Colors.grey).fontWeight(FontWeight.w600),
                      ),
                      UIHelper.verticalSpaceSmall,
                      FormBuilderDropdown(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10),
                          suffixIcon: imageItem('assets/mbgroup.png'),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: UIHelper.getInputBorder(1),
                          focusedBorder: UIHelper.getInputBorder(1),
                          focusedErrorBorder: UIHelper.getInputBorder(1),
                          errorBorder: UIHelper.getInputBorder(1),
                        ),
                        name: "mother_Blood_group",
                        // key: UniqueKey(),
                        hint: Text('Mother\'s Blood Group'),
                        items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                            .map((grp) => DropdownMenuItem(
                                  //value: grp,
                                  value: grp,
                                  child: Text("$grp").textColor(Colors.black).fontSize(16),
                                ))
                            .toList(),
                      ),
                    ]),
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
                                          Get.back(result: {'refresh': false});
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

                                            // String userId = preferencesService.userId;
                                            // postParams['status'] = selectedRadio == "1" ? true : false;
                                            String vacc = widget.userVaccineData['_id'];
                                            Loader.show(context);
                                            await model.birthdetails(postParams, vacc);
                                            Loader.hide();
                                            setState(() {
                                              widget.userVaccineData['name'] = postParams['name'];
                                              widget.userVaccineData['medical_record_no'] = postParams['medical_record_no'];
                                              widget.userVaccineData['age'] = postParams['age'];
                                              widget.userVaccineData['gestational_Age'] = postParams['gestational_Age'];
                                              widget.userVaccineData['mode_of_delivery'] = postParams['mode_of_delivery'];
                                              widget.userVaccineData['birth_weight'] = postParams['birth_weight'];
                                              widget.userVaccineData['apgar_score'] = postParams['apgar_score'];
                                              widget.userVaccineData['length_at_birth'] = postParams['length_at_birth'];
                                              widget.userVaccineData['head_circumference'] = postParams['head_circumference'];
                                              widget.userVaccineData['TSH'] = postParams['TSH'];
                                              widget.userVaccineData['G6PD'] = postParams['G6PD'];
                                              widget.userVaccineData['baby_blood_group'] = postParams['baby_blood_group'];
                                              widget.userVaccineData['mother_Blood_group'] = postParams['mother_Blood_group'];
                                            });
                                            preferencesService.paths.clear();

                                            await showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return CustomDialogBox(
                                                    title: "Excellent!",
                                                    descriptions: getAlertmessage[0]['content'],
                                                    descriptions1: "",
                                                    text: "OK",
                                                  );
                                                });
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
        ));
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
              UIHelper.addHeader(context, "Edit Birth Details", true),
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

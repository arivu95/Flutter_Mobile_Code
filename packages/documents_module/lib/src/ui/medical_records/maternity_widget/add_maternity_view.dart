import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/app/locator.dart';
import 'add_maternity_viewmodel.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AddMaternityView extends StatefulWidget {
  dynamic editmaternity;
  dynamic documentModel;
  dynamic mainDocId;
  bool isEditMode;
  AddMaternityView({
    Key? key,
    required this.isEditMode,
    this.editmaternity,
    this.documentModel,
    this.mainDocId,
  }) : super(key: key);

  @override
  _AddMaternityViewState createState() => _AddMaternityViewState();
}

class _AddMaternityViewState extends State<AddMaternityView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool isAutoValidate = false;
  bool isattach = false;
  String attach_file = '';
  final picker = ImagePicker();
  PreferencesService preferencesService = locator<PreferencesService>();

  TextEditingController mrecordController = TextEditingController();
  TextEditingController gageController = TextEditingController();
  TextEditingController bloodgroupController = TextEditingController();
  TextEditingController babybloodgroupController = TextEditingController();
  TextEditingController babyweightController = TextEditingController();
  TextEditingController motherweightController = TextEditingController();
  TextEditingController bpmController = TextEditingController();
  TextEditingController hcgController = TextEditingController();
  TextEditingController circumferenceController = TextEditingController();
  TextEditingController clicnicnameController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController attachController = TextEditingController();
  List getAlertmessage = [];
  @override
  void initState() {
    super.initState();
    preferencesService.paths.clear();
    getAlertmessage = preferencesService.alertContentList!.where((msg) => msg['type'] == "Maternity_record_update").toList();
  }

  Widget addInputFormControl(String nameField, String hintText, Widget icon) {
    bool isEnabled = false;
    if (nameField == 'mobile' || nameField == 'email') {
      isEnabled = true;
    }
    //motherweightController
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
        onChanged: (value) {
          print(value);
        },
        //  controller: nameField == 'mother_weight'
        //   ? motherweightController: null,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 10, right: 10),
          suffixIcon: icon,
          suffixText: nameField == "height"
              ? "Cm"
              : nameField == "mother_weight"
                  ? "Kg"
                  : nameField == "temperature"
                      ? "°C"
                      : nameField == "spo2"
                          ? "%"
                          : nameField == "mother_BP"
                              ? "mmHg"
                              : nameField == "blood_sugar"
                                  ? "mg/dl"
                                  : nameField == "mother_blood_group"
                                      ? "mg/dl"
                                      : nameField == "glucose_level"
                                          ? "mg/dl"
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
        keyboardType:
            nameField == 'mother_weight' || nameField == 'mother_BP' || nameField == 'glucose_level' || nameField == 'blood_sugar' || nameField == 'mother_blood_group' || nameField == 'temperature' || nameField == 'spo2'
                ? TextInputType.number
                : TextInputType.text,
        // inputFormatters: [
        //   if (nameField == 'doctor_name' || nameField == 'clinic_name') new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
        //   if (nameField == 'mother_weight' ||
        //       nameField == 'mother_BP' ||
        //       nameField == 'blood_sugar' ||
        //       nameField == 'glucose_level' ||
        //       nameField == 'temperature' ||
        //       nameField == 'spo2' ||
        //       nameField == 'mother_blood_group')
        //     new WhitelistingTextInputFormatter(RegExp(r'^(\d+)?\.?\d{0,2}')),
        // ],
        inputFormatters: [
          // is able to enter lowercase letters
          if (nameField == 'doctor_name' || nameField == 'clinic_name') new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
          if (nameField == 'mother_weight' ||
              nameField == 'mother_BP' ||
              nameField == 'blood_sugar' ||
              nameField == 'glucose_level' ||
              nameField == 'temperature' ||
              nameField == 'spo2' ||
              nameField == 'mother_blood_group')
            FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
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

  Future<void> getpick(BuildContext context) async {
    preferencesService.paths.clear();
    attach_file = "";
    FilePickerResult result = (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx']))!;
    String path = result.files.single.path!;
    preferencesService.paths.add(path);

    setState(() {
      attachController.text = preferencesService.paths.toString();
      //attach_file = attachController.text;
      attach_file = preferencesService.paths.toString();
      if (path != '') {
        isattach = true;
      }
    });
    // if (path != '') {
    //   isattach = true;
    // }
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

  Widget formControls(BuildContext context) {
    DateTime? checkupDate;
    if (widget.editmaternity['checkup_date'] == null) {
      checkupDate = widget.editmaternity['checkup_date'];
    } else {
      Jiffy chck = Jiffy(widget.editmaternity['checkup_date']);
      checkupDate = chck.dateTime;
    }

    DateTime? lastCheckupDate;
    if (widget.editmaternity['last_checkup_date'] == null) {
      lastCheckupDate = widget.editmaternity['last_checkup_date'];
    } else {
      Jiffy lstDate = Jiffy(widget.editmaternity['last_checkup_date']);
      lastCheckupDate = lstDate.dateTime;
    }

    DateTime? nextCheckupDate;
    if (widget.editmaternity['next_checkup_date'] == null) {
      nextCheckupDate = widget.editmaternity['next_checkup_date'];
    } else {
      Jiffy nxtDate = Jiffy(widget.editmaternity['next_checkup_date']);
      nextCheckupDate = nxtDate.dateTime;
    }

    DateTime? expectedDueDate;
    if (widget.editmaternity['expected_due_date'] == null) {
      expectedDueDate = widget.editmaternity['expected_due_date'];
    } else {
      Jiffy dueDate = Jiffy(widget.editmaternity['expected_due_date']);
      expectedDueDate = dueDate.dateTime;
    }

    //  String attach='';
    //   if(preferencesService.paths.isNotEmpty){
    // attach= preferencesService.paths.toString();
    // }else{
    // attach = widget.editmaternity['attach_record'].toString();
    // }
    // print("WIDGETSSSSSSSSSSSSS"+widget.editmaternity['attach_record'].toString());

    setState(() {
      if (isattach) {
        // attach = preferencesService.paths.toString();
        attachController.text = preferencesService.paths.toString();
        //attach_file = attachController.text;
        attach_file = preferencesService.paths.toString();
        //  widget.editmaternity['attach_record'] = attach_file;
        isattach = false;
      } else {
        //  attachController.text= widget.editmaternity['attach_record'].toString();
        // attachController.text = widget.editmaternity['attach_record'] != null ? widget.editmaternity['attach_record'].toString() : " ";
        // attach_file = attachController.text;
      }
    });

    return Padding(
      padding: const EdgeInsets.only(left: 1, right: 1),
      child: Container(
        padding: EdgeInsets.all(12),
        width: Screen.width(context),
        decoration: UIHelper.roundedBorderWithColor(8, subtleColor, borderColor: Color(0xFFE2E2E2)),
        child: FormBuilder(
            initialValue: {
              'pregnancy_week': widget.editmaternity['pregnancy_week'] ?? '',
              'mother_weight': widget.editmaternity['mother_weight'] ?? '',
              'baby_weight': widget.editmaternity['baby_weight'] ?? '',
              'member_medical_id': widget.editmaternity['member_medical_id'] ?? '',
              'checkup_date': checkupDate,
              'last_checkup_date': lastCheckupDate,
              'next_checkup_date': nextCheckupDate,
              'expected_due_date': expectedDueDate,
              'mother_BP': widget.editmaternity['mother_BP'] ?? '',
              'baby_blood_group': widget.editmaternity['baby_blood_group'] ?? null,
              'glucose_level': widget.editmaternity['glucose_level'] ?? '',
              'blood_sugar': widget.editmaternity['blood_sugar'] ?? '',
              'mother_blood_group': widget.editmaternity['mother_blood_group'] ?? '',
              'temperature': widget.editmaternity['temperature'] ?? '',
              'spo2': widget.editmaternity['spo2'] ?? '',
              'doctor_name': widget.editmaternity['doctor_name'] ?? '',
              'baby_BPM': widget.editmaternity['baby_BPM'] ?? '',
              'baby_HCG_level': widget.editmaternity['baby_HCG_level'] ?? '',
              'clinic_name': widget.editmaternity['clinic_name'] ?? '',
              'note': widget.editmaternity['note'] ?? '',
              'baby_head_circumference': widget.editmaternity['baby_head_circumference'] ?? '',
              'attach': attach_file,
            },
            autovalidateMode: isAutoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            key: _fbKey,
            child: Column(
              children: [
                addInputFormControl('member_medical_id', 'Member Medical ID ', imageItem('assets/apgr_rec_icon.png')),
                UIHelper.verticalSpaceSmall,
                Column(children: [
                  Container(
                    alignment: Alignment.topLeft,
                    // padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Checkup Date",
                    ).fontSize(15).textColor(Colors.grey).fontWeight(FontWeight.w600),
                  ),
                  UIHelper.verticalSpaceSmall,
                  Theme(
                    data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                      primary: activeColor, //constant Color(0xFF16A5A6)
                    )),
                    child: FormBuilderDateTimePicker(
                      // initialDate: beginDate.add(Duration(days: 1)),
                      name: "checkup_date",
                      initialDate: DateTime(DateTime.now().year - 0, DateTime.now().month, DateTime.now().day),
                      firstDate: DateTime(1900),
                      inputType: InputType.date,
                      format: DateFormat("dd/MM/yyyy"),
                      decoration: InputDecoration(
                        hintText: 'Checkup Date',
                        contentPadding: EdgeInsets.only(left: 20),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: activeColor,
                        ),
                        prefixIcon: imageItem('assets/ch_up.png'),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: UIHelper.getInputBorder(1),
                        focusedBorder: UIHelper.getInputBorder(1),
                        focusedErrorBorder: UIHelper.getInputBorder(1),
                        errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                        // hintText: "Date of Birth",
                      ),
                    ),
                  ),
                ]),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('pregnancy_week', 'Pregnancy Week', imageItem('assets/cil_pregnant.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('mother_weight', 'Mother Weight ', imageItem('assets/bweight.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('mother_BP', 'Mother BP ', imageItem('assets/bbgroup.png')),
                UIHelper.verticalSpaceSmall,
                //******** changed  Text baby blood group into Mother *** */
                Column(children: [
                  Container(
                    alignment: Alignment.topLeft,
                    // padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Mother Blood Group",
                    ).fontSize(15).textColor(Colors.grey).fontWeight(FontWeight.w600),
                  ),
                  UIHelper.verticalSpaceSmall,
                  FormBuilderDropdown(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10),
                      suffixIcon: imageItem('assets/bbgroup.png'),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: UIHelper.getInputBorder(1),
                      focusedBorder: UIHelper.getInputBorder(1),
                      focusedErrorBorder: UIHelper.getInputBorder(1),
                      errorBorder: UIHelper.getInputBorder(1),
                    ),
                    name: "baby_blood_group",
                    // key: UniqueKey(),
                    hint: Text('Mother BloodGroup'),
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
                addInputFormControl('glucose_level', 'Glucose level', imageItem('assets/bp.png')),
                UIHelper.verticalSpaceSmall,
                // addInputFormControl('baby_weight', 'Baby Weight ',
                //     imageItem('assets/bweight.png')),
                // UIHelper.verticalSpaceSmall,
                // addInputFormControl(
                //     'baby_BPM', 'Baby BPM', imageItem('assets/bpm.png')),
                // UIHelper.verticalSpaceSmall,
                // addInputFormControl('baby_HCG_level', 'baby_HCG_level',
                //     imageItem('assets/apgr_rec_icon.png')),
                // UIHelper.verticalSpaceSmall,
                // addInputFormControl(
                //     'baby_head_circumference',
                //     'Baby Head Circumference',
                //     imageItem('assets/head_cir.png')),
                // UIHelper.verticalSpaceSmall,

                addInputFormControl('blood_sugar', 'Blood Sugar Fast', imageItem('assets/bbgroup.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('mother_blood_group', 'Blood Sugar Random', imageItem('assets/bbgroup.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('temperature', 'Temperature', imageItem('assets/bp.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('spo2', 'SpO2', imageItem('assets/bbgroup.png')),
                UIHelper.verticalSpaceSmall,
                addInputFormControl(
                  'doctor_name',
                  'Doctor Name',
                  Icon(
                    Icons.person_outlined,
                    color: activeColor,
                  ),
                ),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('clinic_name', 'Clinic Name ', imageItem('assets/clinic_name.png')),
                UIHelper.verticalSpaceSmall,
                //pregnancy_date
                //  Theme(
                //   data: ThemeData.light().copyWith(
                //       colorScheme: ColorScheme.light(
                //     primary: activeColor, //constant Color(0xFF16A5A6)
                //   )),
                //   child: FormBuilderDateTimePicker(
                //     name: "pregnancy_date",
                //    initialDate: DateTime(DateTime.now().year - 0,
                //         DateTime.now().month, DateTime.now().day),
                //     firstDate: DateTime(1900),
                //     inputType: InputType.date,
                //     format: DateFormat("dd/MM/yyyy"),
                //     decoration: InputDecoration(
                //       hintText: 'Pregnancy Date',
                //       contentPadding: EdgeInsets.only(left: 20),
                //       suffixIcon: Icon(
                //         Icons.calendar_today,
                //         color: activeColor,
                //       ),
                //       prefixIcon: imageItem('assets/ch_up.png'),
                //       filled: true,
                //       fillColor: Colors.white70,
                //       enabledBorder: UIHelper.getInputBorder(1),
                //       focusedBorder: UIHelper.getInputBorder(1),
                //       focusedErrorBorder: UIHelper.getInputBorder(1),
                //       errorBorder:
                //           UIHelper.getInputBorder(1, borderColor: activeColor),
                //       // hintText: "Date of Birth",
                //     ),
                //     validator: FormBuilderValidators.compose([
                //       FormBuilderValidators.required(context),
                //     ]),
                //   ),
                // ),
                //  UIHelper.verticalSpaceSmall,
                // Theme(
                //   data: ThemeData.light().copyWith(
                //       colorScheme: ColorScheme.light(
                //     primary: activeColor, //constant Color(0xFF16A5A6)
                //   )),
                //   child: FormBuilderDateTimePicker(
                //     name: "last_checkup_date",
                //    initialDate: DateTime(DateTime.now().year - 0,
                //         DateTime.now().month, DateTime.now().day),
                //     firstDate: DateTime(1900),
                //     inputType: InputType.date,
                //     format: DateFormat("dd/MM/yyyy"),
                //     decoration: InputDecoration(
                //       hintText: 'Last Checkup Date',
                //       contentPadding: EdgeInsets.only(left: 20),
                //       suffixIcon: Icon(
                //         Icons.calendar_today,
                //         color: activeColor,
                //       ),
                //       prefixIcon: imageItem('assets/ch_up.png'),
                //       filled: true,
                //       fillColor: Colors.white70,
                //       enabledBorder: UIHelper.getInputBorder(1),
                //       focusedBorder: UIHelper.getInputBorder(1),
                //       focusedErrorBorder: UIHelper.getInputBorder(1),
                //       errorBorder:
                //           UIHelper.getInputBorder(1, borderColor: activeColor),
                //       // hintText: "Date of Birth",
                //     ),
                //     validator: FormBuilderValidators.compose([
                //       FormBuilderValidators.required(context),
                //     ]),
                //   ),
                // ),
                // UIHelper.verticalSpaceSmall,
                // Theme(
                //   data: ThemeData.light().copyWith(
                //       colorScheme: ColorScheme.light(
                //     primary: activeColor, //constant Color(0xFF16A5A6)
                //   )),
                //   child: FormBuilderDateTimePicker(
                //     // initialDate: beginDate.add(Duration(days: 1)),
                //     name: "next_checkup_date",
                //     initialDate: DateTime(DateTime.now().year - 0,
                //         DateTime.now().month, DateTime.now().day),
                //     firstDate: DateTime(1900),
                //     inputType: InputType.date,
                //     format: DateFormat("dd/MM/yyyy"),
                //     decoration: InputDecoration(
                //       hintText: 'Next Checkup Date',
                //       contentPadding: EdgeInsets.only(left: 20),
                //       suffixIcon: Icon(
                //         Icons.calendar_today,
                //         color: activeColor,
                //       ),
                //       prefixIcon: imageItem('assets/ch_up.png'),
                //       filled: true,
                //       fillColor: Colors.white70,
                //       enabledBorder: UIHelper.getInputBorder(1),
                //       focusedBorder: UIHelper.getInputBorder(1),
                //       focusedErrorBorder: UIHelper.getInputBorder(1),
                //       errorBorder:
                //           UIHelper.getInputBorder(1, borderColor: activeColor),
                //       // hintText: "Date of Birth",
                //     ),
                //     validator: FormBuilderValidators.compose([
                //       FormBuilderValidators.required(context),
                //     ]),
                //   ),
                // ),
                // UIHelper.verticalSpaceSmall,
                // Theme(
                //   data: ThemeData.light().copyWith(
                //       colorScheme: ColorScheme.light(
                //     primary: activeColor, //constant Color(0xFF16A5A6)
                //   )),
                //   child: FormBuilderDateTimePicker(
                //     name: "expected_due_date",
                //     initialDate: DateTime(DateTime.now().year - 0,
                //         DateTime.now().month, DateTime.now().day),
                //     firstDate: DateTime(1900),
                //     inputType: InputType.date,
                //     format: DateFormat("dd/MM/yyyy"),
                //     decoration: InputDecoration(
                //       hintText: 'Expected Checkup Date ',
                //       contentPadding: EdgeInsets.only(left: 20),
                //       suffixIcon: Icon(
                //         Icons.calendar_today,
                //         color: activeColor,
                //       ),
                //       prefixIcon: imageItem('assets/ch_up.png'),
                //       filled: true,
                //       fillColor: Colors.white70,
                //       enabledBorder: UIHelper.getInputBorder(1),
                //       focusedBorder: UIHelper.getInputBorder(1),
                //       focusedErrorBorder: UIHelper.getInputBorder(1),
                //       errorBorder:
                //           UIHelper.getInputBorder(1, borderColor: activeColor),
                //       // hintText: "Date of Birth",
                //     ),
                //     validator: FormBuilderValidators.compose([
                //       FormBuilderValidators.required(context),
                //     ]),
                //   ),
                // ),
                // UIHelper.verticalSpaceSmall,
                addInputFormControl('note', 'Note', imageItem('assets/apgr_rec_icon.png')),
                UIHelper.verticalSpaceMedium,
                // Column(children: [
                //   Container(
                //     alignment: Alignment.topLeft,
                //     // padding: EdgeInsets.only(left: 8),
                //     child: Text(
                //       "Attach Record",
                //     ).fontSize(15).textColor(Colors.grey).fontWeight(FontWeight.w600),
                //   ),
                //   UIHelper.verticalSpaceSmall,
                //   FormBuilderTextField(
                //     style: loginInputTitleStyle,
                //     name: "attach",
                //     controller: attachController,
                //     enableInteractiveSelection: false,
                //     autocorrect: false,
                //     showCursor: false,
                //     onChanged: (value) {
                //       setState(() {
                //         attachController.text = attach_file;
                //       });
                //     },
                //     onTap: () async {
                //       //  getpick(context);
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

                ViewModelBuilder<updateMaternityViewmodel>.reactive(
                    builder: (context, model, child) {
                      return model.isBusy
                          ?
                          //CircularProgressIndicator()
                          Center(
                              child: CircularProgressIndicator(),
                            )
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
                                        String selectedDropdownid = preferencesService.dropdown_user_id;
                                        postParams['member_id'] = selectedDropdownid;
                                        postParams['maternity_Id'] = widget.editmaternity['_id'];
                                        String userMaternityDataid = widget.mainDocId['_id'];
                                        Loader.show(context);
                                        await model.updateMaternityInfo(postParams, userMaternityDataid);
                                        Loader.hide();
                                        setState(() {
                                          widget.editmaternity['member_medical_id'] = postParams['member_medical_id'];
                                          widget.editmaternity['checkup_date'] = postParams['checkup_date'];
                                          widget.editmaternity['mother_weight'] = postParams['mother_weight'];
                                          widget.editmaternity['mother_BP'] = postParams['mother_BP'];
                                          widget.editmaternity['baby_blood_group'] = postParams['baby_blood_group'];
                                          widget.editmaternity['glucose_level'] = postParams['glucose_level'];
                                          widget.editmaternity['blood_sugar'] = postParams['blood_sugar'];
                                          widget.editmaternity['mother_blood_group'] = postParams['mother_blood_group'];
                                          widget.editmaternity['temperature'] = postParams['temperature'];
                                          widget.editmaternity['spo2'] = postParams['spo2'];
                                          widget.editmaternity['doctor_name'] = postParams['doctor_name'];
                                          widget.editmaternity['baby_weight'] = postParams['baby_weight'];
                                          widget.editmaternity['baby_BPM'] = postParams['baby_BPM'];
                                          widget.editmaternity['baby_HCG_level'] = postParams['baby_HCG_level'];
                                          widget.editmaternity['baby_head_circumference'] = postParams['baby_head_circumference'];
                                          widget.editmaternity['note'] = postParams['note'];
                                          widget.editmaternity['clinic_name'] = postParams['clinic_name'];
                                          widget.editmaternity['last_checkup_date'] = postParams['last_checkup_date'];
                                          widget.editmaternity['next_checkup_date'] = postParams['next_checkup_date'];
                                          widget.editmaternity['expected_due_date'] = postParams['expected_due_date'];
                                          widget.editmaternity['pregnancy_date'] = postParams['pregnancy_date'];
                                          //widget.editmaternity['attach_record'] = postParams['attach'];
                                          // if (preferencesService.paths.isNotEmpty) {
                                          //   widget.editmaternity['attach_record'] = attach_file;
                                          // }
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
                                      } else {
                                        setState(() {
                                          if (preferencesService.paths.isNotEmpty) {
                                            if (widget.editmaternity['checkup_date'] == null || widget.editmaternity['checkup_date'] == "") {
                                              //  widget.editmaternity['attach_record'] = attach_file;
                                            }
                                          }
                                          isAutoValidate = true;
                                        });
                                      }
                                    },
                                    child: Text('SAVE'),
                                    style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(Size(80, 32)),
                                        backgroundColor: MaterialStateProperty.all(Colors.green),
                                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                              ],
                            ); //
                    },
                    viewModelBuilder: () => updateMaternityViewmodel()),
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
            // UIHelper.addHeader(context, "Edit Maternity", true),
            // UIHelper.verticalSpaceSmall,
            // UIHelper.verticalSpaceMedium,
            // UIHelper.verticalSpaceSmall,
            UIHelper.verticalSpaceSmall,
            UIHelper.addHeader(context, "Edit Maternity", true),
            UIHelper.verticalSpaceMedium,

            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: [formControls(context), UIHelper.verticalSpaceMedium],
              ),
            ))
          ]),
        ));
  }
}

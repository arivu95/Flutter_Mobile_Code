import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:member_module/src/ui/members/add_memberView_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_date_picker.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/services/email_validator.dart';
import 'package:member_module/src/ui/members/edit_member_view.dart';
import 'package:intl/intl.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class AddMemberView extends StatefulWidget {
  AddMemberView({Key? key}) : super(key: key);

  @override
  _AddMemberViewState createState() => _AddMemberViewState();
}

const APIKeys = "AIzaSyA_76M-Sca9mXdpkJKVHSeUkFRgvvQ3icI";

class _AddMemberViewState extends State<AddMemberView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  PreferencesService preferencesService = locator<PreferencesService>();
  NavigationService navigationService = locator<NavigationService>();
  bool isAutoValidate = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  CustomDropDownContoller dateofbirth = CustomDropDownContoller();
  TextEditingController bloodgroupController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController altermobileController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController allergictoController = TextEditingController();
  TextEditingController mobilecodeController = TextEditingController();
  TextEditingController altercodeController = TextEditingController();
  TextEditingController insuranceNameController = TextEditingController();
  TextEditingController insuranceNumberController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String validityDate = '';
  bool Date = false;
  String localPath = '';
  String network_img_url = '';
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);
  PickResult? selectedPlace;

  List countries = [];
  int mobile_min_length = 7;
  int mobile_max_length = 15;
  int alter_mobile_min_length = 7;
  int alter_mobile_max_length = 15;
  List getAlertmessage = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    //addmember
    getAlertmessage = preferencesService.alertContentList!.where((msg) => msg['type'] == "Add_member").toList();
    setState(() {
      this.loadJsonData();
    });
  }

  Future<String> loadJsonData() async {
    var jsonText = await rootBundle.loadString('assets/countries.json');
    setState(() => countries = json.decode(jsonText));

    return 'success';
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selected != null && selected != selectedDate)
      setState(() {
        selectedDate = selected;
        validityDate = selected.toString();
      });
  }

  Future getImage(String type, FileType fileType) async {
    String path = '';
    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
    if (pickedFile != null) {
      await Get.to(() => ImgCropper(
          index: 0,
          imagePath: pickedFile.path,
          onCropComplete: (path) {
            String st = path;
            print(path);
            setState(() {
              localPath = path;
            });
          }));
      Loader.show(context);

      Loader.hide();

      print(path);
    }
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
                    getImage(type, FileType.image);
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Photo Library'),
                ),
              ],
            ),
          );
        });
  }

  Widget addInputFormControl(String nameField, String hintText, IconData iconData) {
    bool isEnabled = false;

    return Column(children: [
      Container(
        alignment: Alignment.topLeft,
        child: Text(
          hintText,
        ).fontSize(15).textColor(Colors.grey).fontWeight(FontWeight.w600),
      ),
      UIHelper.verticalSpaceSmall,
      FormBuilderTextField(
        style: loginInputTitleStyle,
        readOnly: nameField == 'age' ? true : false,
        name: nameField,
        autocorrect: false,
        controller: nameField == 'member_first_name'
            ? nameController
            : nameField == 'member_mail'
                ? mailController
                : nameField == 'relation'
                    ? roleController
                    : nameField == 'date_of_birth'
                        ? dateController
                        : nameField == 'age'
                            ? ageController
                            : nameField == 'gender'
                                ? genderController
                                : nameField == 'blood_group'
                                    ? bloodgroupController
                                    : nameField == 'insurance_name'
                                        ? insuranceNameController
                                        : nameField == 'insurance_number'
                                            ? insuranceNumberController
                                            : nameField == 'country'
                                                ? countryController
                                                : nameField == 'city'
                                                    ? cityController
                                                    : nameField == 'zipcode'
                                                        ? zipController
                                                        : nameField == 'member_mobile_number'
                                                            ? mobileController
                                                            : nameField == 'member_mobileno_countryCode'
                                                                ? mobilecodeController
                                                                : null,
        onChanged: (value) {
          print(value);
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 10),
          suffixIcon: Icon(
            iconData,
            color: activeColor,
            size: 30,
          ),
          hintText: hintText,
          hintStyle: loginInputHintTitleStyle,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: UIHelper.getInputBorder(1),
          focusedBorder: UIHelper.getInputBorder(1),
          focusedErrorBorder: UIHelper.getInputBorder(1),
          errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
        ),
        keyboardType: nameField == 'alternate_mobile_number' || nameField == 'member_mobile_number' || nameField == 'zipcode' ? TextInputType.number : TextInputType.text,
        // inputFormatters: [
        //   if (nameField == 'member_first_name') new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
        //   // RegExp(r'^[a-zA-Z0-9]+$');
        // ],
        inputFormatters: [
          // is able to enter lowercase letters
          if (nameField == 'member_first_name') FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
        ],
        validator: FormBuilderValidators.compose([
          if (nameField == 'member_first_name') FormBuilderValidators.required(context),
          if (nameField == 'alternate_mobile_number')
            FormBuilderValidators.compose([
              // FormBuilderValidators.required(context),
              FormBuilderValidators.minLength(context, alter_mobile_min_length, allowEmpty: true, errorText: "Invalid Number"),
              FormBuilderValidators.maxLength(context, alter_mobile_max_length, errorText: "Invalid Number"),
              FormBuilderValidators.numeric(context),
            ]),
        ]),
      )
    ]);
  }

  Widget formControls(BuildContext context, AddMemberViewmodel model) {
    return Padding(
      padding: const EdgeInsets.only(left: 1, right: 1),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(12),
        width: Screen.width(context),
        decoration: UIHelper.roundedBorderWithColor(8, subtleColor, borderColor: Color(0xFFE2E2E2)),
        child: FormBuilder(
            initialValue: {},
            autovalidateMode: isAutoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            key: _fbKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    showFilePickerSheet('type');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: localPath.isNotEmpty
                            ? Image.file(
                                File(localPath),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : network_img_url == ''
                                ? CircleAvatar(
                                    backgroundColor: Colors.black12,
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 30,
                                      color: Colors.black38,
                                    ),
                                  )
                                : UIHelper.getImage(network_img_url, 60, 60),
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpaceNormal,
                Column(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        height: 47,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text('Name'),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(6), // radius
                          ),
                        ),
                        // height: 47,
                        padding: EdgeInsets.only(left: 2),
                        width: MediaQuery.of(context).size.width / 1.78,
                        child: FormBuilderTextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: nameController,
                          style: loginInputTitleStyle,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          name: 'member_first_name',
                          // inputFormatters: [
                          //   new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
                          // ],
                          inputFormatters: [
                            // is able to enter lowercase letters

                            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                          ],
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context, errorText: "This field cannot be empty"),
                            FormBuilderValidators.max(context, 20),
                          ]),
                          // autocorrect: false,
                          onChanged: (value) {
                            print(value);
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
                            hintText: 'Name*(Mandatory)',
                            hintStyle: loginInputHintTitleStyle,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UIHelper.getInputBorder(1),
                            focusedBorder: UIHelper.getInputBorder(1),
                            focusedErrorBorder: UIHelper.getInputBorder(1),
                            errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      )
                    ],
                  ),
                ]),
                UIHelper.verticalSpaceNormal,
                Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Optional',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text('-', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    SizedBox(
                      width: 2,
                    ),
                    Text('Could help you in emergency', style: TextStyle(fontSize: 16, color: Colors.grey))
                  ],
                )),
                UIHelper.verticalSpaceNormal,
                Column(children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        height: 47,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
//                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text('Insurance Name'),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        height: 47,
                        padding: EdgeInsets.only(left: 2),
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5), // radius
                          ),
                        ),
                        width: MediaQuery.of(context).size.width / 1.78,
                        child: FormBuilderTextField(
                          style: loginInputTitleStyle,
                          textCapitalization: TextCapitalization.sentences,
                          name: 'insurance_name',
                          // inputFormatters: [
                          //   new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
                          // ],
                          inputFormatters: [
                            // is able to enter lowercase letters

                            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                          ],
                          autocorrect: false,
                          onChanged: (value) {
                            print(value);
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
//
                            hintText: 'e.g. Bupamax',
                            hintStyle: loginInputHintTitleStyle,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UIHelper.getInputBorder(1),
                            focusedBorder: UIHelper.getInputBorder(1),
                            focusedErrorBorder: UIHelper.getInputBorder(1),
                            errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                          ),
                          // validator: FormBuilderValidators.compose([
                          //   FormBuilderValidators.required(context),
                          // ]),
                          keyboardType: TextInputType.text,
                        ),
                      )
                    ],
                  ),
                ]),
                UIHelper.verticalSpaceNormal,
                Column(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        height: 47,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
//                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text('Insurance No.'),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 2),
                        // height: 47,
                        width: MediaQuery.of(context).size.width / 1.78,
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5), // radius
                          ),
                        ),
                        child: FormBuilderTextField(
                          style: loginInputTitleStyle,
                          name: 'insurance_number',
                          // inputFormatters: [
                          //   new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
                          // ],
                          autocorrect: false,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (value) {
                            print(value);
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
//                      suffixIcon: Icon(
//                        Icons.person,
//                        color: activeColor,
//                      ),
                            hintText: 'e.g. 01234596',
                            hintStyle: loginInputHintTitleStyle,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UIHelper.getInputBorder(1),
                            focusedBorder: UIHelper.getInputBorder(1),
                            focusedErrorBorder: UIHelper.getInputBorder(1),
                            errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.minLength(context, 7, allowEmpty: true, errorText: "Invalid Insurance number"),
                            FormBuilderValidators.maxLength(context, 16, errorText: "Invalid Insurance number"),
                            FormBuilderValidators.numeric(context),
                          ]),
                          keyboardType: TextInputType.number,
                          // inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]"))],
                          inputFormatters: [
                            // is able to enter lowercase letters

                            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                          ],
                        ),
                      )
                    ],
                  ),
                ]),
                UIHelper.verticalSpaceNormal,
                Column(children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        height: 47,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
//                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text('Validity'),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        height: 47,
                        padding: EdgeInsets.only(left: 2),
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5), // radius
                          ),
                        ),
                        // color:Colors.white,
                        width: MediaQuery.of(context).size.width / 1.78,
                        child: FormBuilderDateTimePicker(
                            name: "insurance_validitydate",
                            // initialDate: widget.memberinfo['insurance_validitydate'],
                            inputType: InputType.date,
                            format: DateFormat("dd/MM/yyyy"),
                            onChanged: (DateTime? value) {
                              print(value);
                              Jiffy newDate = Jiffy(value);
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 5),
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.black38,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: UIHelper.getInputBorder(1),
                              focusedBorder: UIHelper.getInputBorder(1),
                              focusedErrorBorder: UIHelper.getInputBorder(1),
                              errorBorder: UIHelper.getInputBorder(1),
                              hintText: "Expired date",
                              hintStyle: loginInputHintTitleStyle,
                            )),
                      )
                      // Container(
                      //     height: 47,
                      //      padding: EdgeInsets.only(left: 10,right: 5),
                      //     decoration: const BoxDecoration(
                      //        color: Colors.white,
                      //       borderRadius: BorderRadius.all(
                      //         Radius.circular(10), // radius
                      //       ),
                      //     ),
                      //     // color:Colors.white,
                      //     width: MediaQuery.of(context).size.width / 1.78,
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Container(
                      //           child: Date
                      //               ? Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}')
                      //               : Text(
                      //                   'Expired Date',
                      //                   style: TextStyle(
                      //                     color: Colors.grey,
                      //                   ),
                      //                 ),
                      //         ),
                      //         Spacer(),
                      //         InkWell(
                      //           child: Icon(
                      //             Icons.calendar_today,
                      //             color: Colors.grey,
                      //             size: 15,
                      //           ),
                      //           onTap: () {
                      //             _selectDate(context);
                      //             Date = true;
                      //           },
                      //         ),
                      //         UIHelper.horizontalSpaceSmall,
                      //       ],
                      //     ))
                    ],
                  ),
                ]),
                UIHelper.verticalSpaceNormal,
                Column(children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        height: 47,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
//                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text('Blood Group'),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        height: 47,
                        padding: EdgeInsets.only(left: 2),
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5), // radius
                          ),
                        ),
                        // color:Colors.white,
                        width: MediaQuery.of(context).size.width / 1.78,
                        child: FormBuilderDropdown(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UIHelper.getInputBorder(1),
                            focusedBorder: UIHelper.getInputBorder(1),
                            focusedErrorBorder: UIHelper.getInputBorder(1),
                            errorBorder: UIHelper.getInputBorder(1),
                          ),
                          name: "blood_group",
                          hint: Text('Blood Group'),
                          items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                              .map((grp) => DropdownMenuItem(
                                    value: grp,
                                    child: Text("$grp").textColor(Colors.black).fontSize(16),
                                  ))
                              .toList(),
                        ),
                      )
                    ],
                  )
                ]),
                UIHelper.verticalSpaceNormal,
                Column(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        height: 47,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
//                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text('Date of Birth'),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        // height: 35,
                        // color: Colors.white,
                        padding: EdgeInsets.only(left: 1),
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
                        width: MediaQuery.of(context).size.width / 1.78,
                        child: Theme(
                            data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                              primary: activeColor,
                            )),
                            child: CustomDatePicker(
                              controller: dateofbirth,
                              // initialDate: widget.memberinfo['date_of_birth'] != null ? dob.dateTime : null,
                              // screen_type: 'member',
                              firstDate: DateTime(1900),
                              lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                              onChanged: (date) {
                                Jiffy newDate = Jiffy(date);
                                final diff = Jiffy().diff(newDate, Units.YEAR);
                                print(diff);
                                if (diff > 0) {
                                  ageController.text = diff.toString();
                                }

                                // print('99999999' + date.toString());
                              },
                            )),
                      )
                    ],
                  )
                ]),
                UIHelper.verticalSpaceNormal,
                Column(children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        height: 47,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
//                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text('Gender'),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        height: 47,
                        padding: EdgeInsets.only(left: 2),
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5), // radius
                          ),
                        ),
                        // color:Colors.white,
                        width: MediaQuery.of(context).size.width / 1.78,
                        child: FormBuilderDropdown(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UIHelper.getInputBorder(1),
                            focusedBorder: UIHelper.getInputBorder(1),
                            focusedErrorBorder: UIHelper.getInputBorder(1),
                            errorBorder: UIHelper.getInputBorder(1),
                          ),
                          name: "gender",
                          hint: Text('Gender'),
                          items: ['Male', 'Female']
                              .map((grp) => DropdownMenuItem(
                                    value: grp,
                                    child: Text("$grp").textColor(Colors.black).fontSize(16),
                                  ))
                              .toList(),
                        ),
                      )
                    ],
                  )
                ]),
                UIHelper.verticalSpaceNormal,
                Column(children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        height: 47,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
//                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text('Relation'),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      // UIHelper.horizontalSpaceSmall,
                      Container(
                        height: 47,
                        padding: EdgeInsets.only(left: 2),
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5), // radius
                          ),
                        ),
                        // color:Colors.white,
                        width: MediaQuery.of(context).size.width / 1.78,
                        child: FormBuilderDropdown(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UIHelper.getInputBorder(1),
                            focusedBorder: UIHelper.getInputBorder(1),
                            focusedErrorBorder: UIHelper.getInputBorder(1),
                            errorBorder: UIHelper.getInputBorder(1),
                          ),
                          name: "relation",
                          hint: Text('Select'),
                          items: model.relations
                              .map((value) => DropdownMenuItem(
                                    value: value['name'],
                                    child: Text(value['name']).textColor(Colors.black).fontSize(16),
                                  ))
                              .toList(),
                        ),
                      )
                    ],
                  )
                ]),
                UIHelper.verticalSpaceNormal,
                Column(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        height: 47,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
//                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text('Email Id'),
                      ),
                      // UIHelper.horizontalSpaceSmall,
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        // height: 47,
                        padding: EdgeInsets.only(left: 2),
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5), // radius
                          ),
                        ),
                        width: MediaQuery.of(context).size.width / 1.78,
                        child: FormBuilderTextField(
                          style: loginInputTitleStyle,
                          name: 'member_email',
                          // inputFormatters: [
                          //   new WhitelistingTextInputFormatter(RegExp("[-a-zA-Z-0-9-_@\.]")),
                          // ],
                          inputFormatters: [
                            // is able to enter lowercase letters

                            FilteringTextInputFormatter.allow(RegExp("[-a-zA-Z-0-9-_@\.]")),
                          ],
                          autocorrect: false,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (value) {
                            print(value);
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
//                      suffixIcon: Icon(
//                        Icons.person,
//                        color: activeColor,
//                      ),
                            hintText: 'e.g. test@gmail.com',
                            hintStyle: loginInputHintTitleStyle,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UIHelper.getInputBorder(1),
                            focusedBorder: UIHelper.getInputBorder(1),
                            focusedErrorBorder: UIHelper.getInputBorder(1),
                            errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                          ),
                          validator: EmailValidators.compose([
                            EmailValidators.email(context),
                          ]),
                          // validator: FormBuilderValidators.compose([
                          //   FormBuilderValidators.required(context),
                          // ]),
                          keyboardType: TextInputType.text,
                        ),
                      )
                    ],
                  ),
                ]),
                UIHelper.verticalSpaceNormal,
                Column(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        height: 47,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
//                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text('Mobile No.'),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      // UIHelper.horizontalSpaceSmall,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 47,
                            padding: EdgeInsets.only(left: 2),
                            decoration: const BoxDecoration(
                              // color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(5), // radius
                              ),
                            ),
                            // color:Colors.white,
                            width: Screen.width(context) / 4.4,
                            child: FormBuilderDropdown(
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: UIHelper.getInputBorder(1),
                                focusedBorder: UIHelper.getInputBorder(1),
                                focusedErrorBorder: UIHelper.getInputBorder(1),
                                errorBorder: UIHelper.getInputBorder(1),
                              ),
                              name: "member_mobileno_countryCode",
                              hint: Text('Code'),
                              items: model.countries
                                  .map<DropdownMenuItem<String>>((altercode) => new DropdownMenuItem<String>(
                                        value: altercode['countryCode_digits'],
                                        child: Text(altercode['countryCode_digits']).textColor(Colors.black).fontSize(16),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                for (var each in countries) {
                                  if (each['countryCode_digits'] == value) {
                                    setState(() {
                                      mobile_min_length = int.parse(each['min_length']);
                                      mobile_max_length = int.parse(each['max_length']);
                                    });
                                    _fbKey.currentState!.patchValue({'member_mobile_number': _fbKey.currentState!.value['member_mobile_number']});
                                    _fbKey.currentState!.saveAndValidate();
                                  }
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3.1,
                            decoration: const BoxDecoration(
                              // color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(5), // radius
                              ),
                            ),
                            child: FormBuilderTextField(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: loginInputTitleStyle,
                              name: 'member_mobile_number',
                              // inputFormatters: [
                              //   new WhitelistingTextInputFormatter(RegExp("[0-9]")),
                              // ],
                              inputFormatters: [
                                // is able to enter lowercase letters

                                FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                              ],
                              autocorrect: false,
                              onChanged: (value) {
                                print(value);
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                hintText: '12345678902',
                                hintStyle: loginInputHintTitleStyle,
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: UIHelper.getInputBorder(1),
                                focusedBorder: UIHelper.getInputBorder(1),
                                focusedErrorBorder: UIHelper.getInputBorder(1),
                                errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.minLength(context, mobile_min_length, allowEmpty: true, errorText: "Invalid Number"),
                                FormBuilderValidators.maxLength(context, mobile_max_length, errorText: "Invalid Number"),
                                FormBuilderValidators.numeric(context),
                              ]),
                              keyboardType: TextInputType.number,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ]),
                UIHelper.verticalSpaceNormal,
                Column(children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        height: 47,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
//                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text('Country'),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      // UIHelper.horizontalSpaceSmall,
                      Container(
                        height: 47,
                        padding: EdgeInsets.only(left: 2),
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5), // radius
                          ),
                        ),
                        // color:Colors.white,
                        width: MediaQuery.of(context).size.width / 1.78,
                        child: FormBuilderDropdown(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UIHelper.getInputBorder(1),
                            focusedBorder: UIHelper.getInputBorder(1),
                            focusedErrorBorder: UIHelper.getInputBorder(1),
                            errorBorder: UIHelper.getInputBorder(1),
                          ),
                          name: "country",
                          hint: Text('Select'),
                          items: model.countries
                              .map((value) => DropdownMenuItem(
                                    value: value['country'],
                                    child: Text(value['country'].toString()).textColor(Colors.black).fontSize(14),
                                  ))
                              .toList(),
                        ),
                      )
                    ],
                  )
                ]),
                UIHelper.verticalSpaceNormal,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      child: ElevatedButton(
                          onPressed: () async {
                            Get.back(result: {'refresh': false});
                          },
                          child: Text('Cancel').bold(),
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(160, 36)),
                            backgroundColor: MaterialStateProperty.all(activeColor),
                          )),
                    ),
                    UIHelper.horizontalSpaceMedium,
                    UIHelper.horizontalSpaceMedium,
                    Container(
                      width: 100,
                      child: ElevatedButton(
                          onPressed: () async {
                            String getDatecontroll = dateofbirth.current_date.toString();

                            if (_fbKey.currentState!.saveAndValidate()) {
                              String oid = await preferencesService.getUserInfo('oid');
                              print(_fbKey.currentState!.value);

                              Map<String, dynamic> postParams = Map.from(_fbKey.currentState!.value);
                              if (getDatecontroll != null && getDatecontroll != "") {
                                Jiffy fromDate_ = Jiffy(getDatecontroll);
                                postParams['date_of_birth'] = fromDate_.format('MM/dd/yyyy');
                                final diff = Jiffy().diff(fromDate_, Units.YEAR);
                                if (diff > 0) {
                                  postParams['age'] = diff.toString();
                                }
                              }

                              if (validityDate != null && validityDate != "") {
                                Jiffy validityDate_ = Jiffy(selectedDate);
                                postParams['insurance_validitydate'] = validityDate_.format('MM/dd/yyyy');
                              }

                              print("**************************************");
                              print(validityDate);
                              String userId = preferencesService.userId;
                              postParams['user_Id'] = userId;
                              postParams['member_role_Id'] = "60c381bc36cf932d305a572b";

                              print(postParams['country']);

                              if (nameController.text.isEmpty) {
                                setState(() {
                                  isAutoValidate = true;
                                });
                              }

                              Loader.show(context);
                              final response = await model.registerMember(postParams, localPath);

                              print(response);
                              Future.delayed(Duration(seconds: 2), () {
                                Loader.hide();
                              });

                              if (response) {
                                locator<PreferencesService>().isReload.value = true;
                                locator<PreferencesService>().isUploadReload.value = true;
                                locator<PreferencesService>().isDownloadReload.value = true;
                                preferencesService.onRefreshRecentDocument!.value = true;
                                // setState(() async {

                                await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialogBox(
                                        title: "Excellent!",
                                        descriptions: getAlertmessage[0]['content'],
                                        descriptions1: "“We care for you”",
                                        text: "OK",
                                      );
                                    });

                                Get.back(result: {'refresh': true});

                                return;
                              }
                              // }
                            }
                          },
                          child: Text('Save').bold(),
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(160, 36)),
                            backgroundColor: MaterialStateProperty.all(leafgreen),
                          )),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: SwarAppBar(2),
      appBar: SwarAppStaticBar(),
      backgroundColor: Colors.white,
      body: ViewModelBuilder<AddMemberViewmodel>.reactive(
          onModelReady: (model) async {
            await model.getRelations();
          },
          builder: (context, model, child) {
            return SafeArea(
                top: false,
                child: model.isBusy
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        width: Screen.width(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            UIHelper.verticalSpaceSmall,
                            UIHelper.addHeader(context, "Add Member", true),
                            UIHelper.verticalSpaceNormal,
                            Expanded(
                                child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  formControls(context, model),
                                ],
                              ),
                            ))
                          ],
                        ),
                      ));
          },
          viewModelBuilder: () => AddMemberViewmodel()),
    );
  }
}

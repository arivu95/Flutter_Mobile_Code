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
import 'package:member_module/src/ui/members/edit_member_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/email_validator.dart';
import 'package:swarapp/services/preferences_service.dart';
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
import 'package:intl/intl.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class EditMemberView extends StatefulWidget {
  dynamic memberinfo;
  final String memberId;
  EditMemberView({Key? key, this.memberinfo, required this.memberId}) : super(key: key);

  @override
  _EditMemberViewState createState() => _EditMemberViewState();
}

const APIKeys = "AIzaSyA_76M-Sca9mXdpkJKVHSeUkFRgvvQ3icI";

class _EditMemberViewState extends State<EditMemberView> {
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
  bool Date = false;
  String localPath = '';
  String network_img_url = '';
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);
  PickResult? selectedPlace;
  late EditMemberViewmodel model;
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
    getAlertmessage = preferencesService.alertContentList!.where((msg) => msg['type'] == "Update_member").toList();
    this.loadJsonData();

    setState(() {
      if (widget.memberinfo['azureBlobStorageLink'] != null) {
        network_img_url = '${ApiService.fileStorageEndPoint}${widget.memberinfo['azureBlobStorageLink']}';
      }
      if (widget.memberinfo['member_first_name'] != null) {
        nameController.text = widget.memberinfo['member_first_name'].toString();
      }
      if (widget.memberinfo['member_email'] != null) {
        mailController.text = widget.memberinfo['member_email'].toString();
      }
      if (widget.memberinfo['date_of_birth'] != null) {
        dateController.text = widget.memberinfo['date_of_birth'].toString();
      }
      if (widget.memberinfo['member_mobile_number'] != null) {
        mobileController.text = widget.memberinfo['member_mobile_number'].toString();
      }
      if (widget.memberinfo['alternate_mobile_number'] != null) {
        altermobileController.text = widget.memberinfo['alternate_mobile_number'].toString();
      }
      if (widget.memberinfo['insurance_name'] != null) {
        insuranceNameController.text = widget.memberinfo['insurance_name'].toString();
      }
      if (widget.memberinfo['insurance_number'] != null) {
        insuranceNumberController.text = widget.memberinfo['insurance_number'].toString();
      }
      if (widget.memberinfo['gender'] != null) {
        genderController.text = widget.memberinfo['gender'].toString();
      }
      if (widget.memberinfo['blood_group'] != null) {
        bloodgroupController.text = widget.memberinfo['blood_group'].toString();
      }
      if (widget.memberinfo['relation'] != null) {
        roleController.text = widget.memberinfo['relation'].toString();
      }

      if (widget.memberinfo['age'] != null) {
        ageController.text = widget.memberinfo['age'].toString();
      }
      if (widget.memberinfo['address'] != null) {
        addressController.text = widget.memberinfo['address'].toString();
      }
      if (widget.memberinfo['country'] != null) {
        countryController.text = widget.memberinfo['country'].toString();
      }
      if (widget.memberinfo['state'] != null) {
        stateController.text = widget.memberinfo['state'].toString();
      }
      if (widget.memberinfo['city'] != null) {
        cityController.text = widget.memberinfo['city'].toString();
      }
      if (widget.memberinfo['zipcode'] != null) {
        zipController.text = widget.memberinfo['zipcode'].toString();
      }
      if (widget.memberinfo['allergicto'] != null) {
        print(widget.memberinfo['allergicto'].toString());
        String getAllergic = widget.memberinfo['allergicto'].toString();
        String filterAllergic = getAllergic.replaceAll(RegExp('[^A-Za-z0-9]'), '');
        allergictoController.text = filterAllergic;
      }
    });
  }

  Future<String> loadJsonData() async {
    var jsonText = await rootBundle.loadString('assets/countries.json');
    setState(() => countries = json.decode(jsonText));

    return 'success';
  }

  // Future getImage(String type, FileType fileType) async {
  //   String path = '';
  //   final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 240);
  //   if (pickedFile != null) {
  //     path = pickedFile.path;
  //     setState(() {
  //       localPath = path;
  //     });
  //   }
  //   print(path);
  // }
  Widget ImageDialog(BuildContext context, String getImg) {
    String setImg = getImg;
    return Dialog(
        backgroundColor: Color.fromRGBO(105, 105, 105, 0.5),
        insetPadding: EdgeInsets.all(15),
        child: Container(
          child: Stack(
            // child: SingleChildScrollView(
            children: [
              PinchZoom(
                // image:DecorationImage(),
                image: Image.network(setImg),
                zoomedBackgroundColor: Colors.black.withOpacity(0.5),
                resetDuration: const Duration(milliseconds: 100),
                maxScale: 2.5,
                onZoomStart: () {
                  print('Start zooming');
                },
                onZoomEnd: () {
                  print('Stop zooming');
                },
              ),
              Positioned(
                right: 0.0,
                top: 0.5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      radius: 14.0,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
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
      // Loader.show(context);
      // await model.updateMemberProfile(widget.memberId, widget.memberinfo, localPath, '');
      // // await model.getMemberProfile(widget.memberId);
      // Loader.hide();
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
                network_img_url != ""
                    ? ListTile(
                        onTap: () async {
                          // Get.back();
                          // getImage(type, FileType.image);
                          String profile = network_img_url;
                          await showDialog(
                              context: context,
                              //https://swarstage.blob.core.windows.net/swardoctor/scaled_image_picker8539268485450644726_1621533729545.jpg
                              builder: (_) => ImageDialog(context, profile));
                        },
                        visualDensity: VisualDensity.compact,
                        //visualDensity: VisualDensity.standard,
                        // visualDensity:VisualDensity.comfortable,
                        title: Text('Preview'),
                      )
                    : Container(),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [Text('Select a type')],
                // ),
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

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate)
      setState(() {
        selectedDate = selected;
      });
  }

  Widget addInputFormControl(String nameField, String hintText, IconData iconData) {
    bool isEnabled = false;
    if (nameField == 'mobile_number' || nameField == 'member_email') {
      isEnabled = true;
    }
    if (nameField == 'alternate_mobile_number') {
      return Column(
        children: [
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
                                                : nameField == 'state'
                                                    ? stateController
                                                    : nameField == 'country'
                                                        ? countryController
                                                        : nameField == 'city'
                                                            ? cityController
                                                            : nameField == 'zipcode'
                                                                ? zipController
                                                                : nameField == 'member_mobile_number'
                                                                    ? mobileController
                                                                    : nameField == 'alternate_mobile_number'
                                                                        ? altermobileController
                                                                        : nameField == 'allergicto'
                                                                            ? allergictoController
                                                                            : nameField == 'member_mobileno_countryCode'
                                                                                ? mobilecodeController
                                                                                : nameField == 'member_alternateno_countryCode'
                                                                                    ? altercodeController
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
            //   if (nameField == 'zipcode' || nameField == 'alternate_mobile_number' || nameField == 'member_mobile_number') new WhitelistingTextInputFormatter(RegExp("[0-9]")),
            //   if (nameField == 'allergicto') new WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),
            //   if (nameField == 'member_first_name') new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
            //   //RegExp(r'^[a-zA-Z0-9]+$');
            // ],
            inputFormatters: [
              if (nameField == 'zipcode' || nameField == 'alternate_mobile_number' || nameField == 'member_mobile_number') new FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              if (nameField == 'allergicto') new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
              if (nameField == 'member_first_name') new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
              // is able to enter lowercase letters

              FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
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
        ],
      );
    }

    return Column(
      children: [
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
                                              : nameField == 'state'
                                                  ? stateController
                                                  : nameField == 'country'
                                                      ? countryController
                                                      : nameField == 'city'
                                                          ? cityController
                                                          : nameField == 'zipcode'
                                                              ? zipController
                                                              : nameField == 'member_mobile_number'
                                                                  ? mobileController
                                                                  : nameField == 'alternate_mobile_number'
                                                                      ? altermobileController
                                                                      : nameField == 'allergicto'
                                                                          ? allergictoController
                                                                          : nameField == 'member_mobileno_countryCode'
                                                                              ? mobilecodeController
                                                                              : nameField == 'member_alternateno_countryCode'
                                                                                  ? altercodeController
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
            errorBorder: UIHelper.getInputBorder(1),
          ),
          keyboardType: nameField == 'alternate_mobile_number' || nameField == 'member_mobile_number' || nameField == 'zipcode' ? TextInputType.number : TextInputType.text,
          // inputFormatters: [
          //   if (nameField == 'zipcode' || nameField == 'alternate_mobile_number' || nameField == 'member_mobile_number') new WhitelistingTextInputFormatter(RegExp("[0-9]")),
          //   if (nameField == 'allergicto') new WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),
          //   if (nameField == 'member_first_name') new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
          //   //RegExp(r'^[a-zA-Z0-9]+$');
          // ],
          inputFormatters: [
            if (nameField == 'zipcode' || nameField == 'alternate_mobile_number' || nameField == 'member_mobile_number') new FilteringTextInputFormatter.allow(RegExp("[0-9]")),
            if (nameField == 'allergicto') new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
            if (nameField == 'member_first_name') new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
            // is able to enter lowercase letters

            FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
          ],
          validator: FormBuilderValidators.compose([
            if (nameField == 'member_first_name') FormBuilderValidators.required(context),
            if (nameField == 'alternate_mobile_number')
              FormBuilderValidators.compose([
                // FormBuilderValidators.required(context),
                FormBuilderValidators.minLength(context, 7, allowEmpty: true, errorText: "Invalid Number"),
                FormBuilderValidators.maxLength(context, 15, errorText: "Invalid Number"),
                FormBuilderValidators.numeric(context),
              ]),
          ]),
        )
      ],
    );
  }

  Widget formControls(BuildContext context, EditMemberViewmodel model) {
    DateTime? expiredDate;

    if (widget.memberinfo['insurance_validitydate'] == null) {
      expiredDate = widget.memberinfo['insurance_validitydate'];
    } else {
      Jiffy chck = Jiffy(widget.memberinfo['insurance_validitydate']);
      expiredDate = chck.dateTime;
    }
    Jiffy dob = Jiffy(widget.memberinfo['date_of_birth']);

    if (widget.memberinfo['date_of_birth'] != null) {
      Jiffy dob = Jiffy(widget.memberinfo['date_of_birth']);
    }
    // Jiffy expire_dt = Jiffy(widget.memberinfo['insurance_validitydate']);
    String allergic = '';
    if (widget.memberinfo['allergicto'] != null) {
      List<dynamic> al = widget.memberinfo['allergicto'];
      allergic = al.join(', ');
    }

    return Padding(
      padding: const EdgeInsets.only(left: 1, right: 1),
      child: Container(
          padding: EdgeInsets.all(12),
          width: Screen.width(context),
          decoration: UIHelper.roundedBorderWithColor(8, subtleColor, borderColor: Color(0xFFE2E2E2)),
          child: FormBuilder(
              initialValue: {
                'member_first_name': nameController.text,
                'insurance_name': insuranceNameController.text,
                'insurance_number': insuranceNumberController.text,
                'insurance_validitydate': expiredDate,
                'relation': widget.memberinfo['relation'] ?? null,
                'member_email': mailController.text,
                'date_of_birth': dob.dateTime,
                'age': ageController.text,
                'gender': widget.memberinfo['gender'],
                'blood_group': widget.memberinfo['blood_group'] ?? null,
                'member_mobile_number': mobileController.text,
                'alternate_mobile_number': altermobileController,
                'country': widget.memberinfo['country'] ?? null,
                'state': stateController.text,
                'city': cityController.text,
                'zipcode': zipController.text,
                'allergicto': allergictoController.text,
                'member_mobileno_countryCode': widget.memberinfo['member_mobileno_countryCode'] ?? null,
                'member_alternateno_countryCode': widget.memberinfo['member_alternateno_countryCode'] ?? null,
              },
              autovalidateMode: isAutoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
              key: _fbKey,
              child: Column(children: [
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
                          style: loginInputTitleStyle,
                          name: 'member_first_name',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            hintText: 'First Name',
                            hintStyle: loginInputHintTitleStyle,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UIHelper.getInputBorder(1),
                            focusedBorder: UIHelper.getInputBorder(1),
                            focusedErrorBorder: UIHelper.getInputBorder(1),
                            errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context, errorText: "This field cannot be empty"),
                            FormBuilderValidators.max(context, 20),
                          ]),
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
//                      suffixIcon: Icon(
//                        Icons.person,
//                        color: activeColor,
//                      ),
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
                          //inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]"))
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
                        padding: EdgeInsets.only(left: 1),
                        decoration: const BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10), // radius
                          ),
                        ),
                        // height: 47,
                        // color:Colors.white,
                        width: MediaQuery.of(context).size.width / 1.78,
                        child: Theme(
                            data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                              primary: activeColor,
                            )),
                            child: CustomDatePicker(
                              controller: dateofbirth,
                              initialDate: widget.memberinfo['date_of_birth'] != null ? dob.dateTime : null,
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
                          items: model.relationship
                              .map((dynamic value) => DropdownMenuItem(
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
                            padding: EdgeInsets.only(left: 2),
                            height: 47,
                            decoration: const BoxDecoration(
                              // color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(5), // radius
                              ),
                            ),
                            // color:Colors.white,
                            width: Screen.width(context) / 4.4,
                            child: FormBuilderDropdown(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                              hint: Text(
                                'Code',
                                // style: TextStyle(fontSize: 14),
                              ),
                              items: model.countries
                                  .map<DropdownMenuItem<String>>((altercode) => new DropdownMenuItem<String>(
                                        value: altercode['countryCode_digits'],
                                        child: Text(altercode['countryCode_digits']).textColor(Colors.black).fontSize(14),
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
                              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                Column(
                  children: [
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
                                .map((dynamic value) => DropdownMenuItem(
                                      value: value['country'],
                                      child: Text(value['country'].toString()).textColor(Colors.black).fontSize(13),
                                    ))
                                .toList(),
                          ),
                        )
                      ],
                    ),
                    // UIHelper.verticalSpaceSmall,
                    model.isBusy
                        ? CircularProgressIndicator()
                        :
                        //**************editmember***************
                        Row(
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
                                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))))),
                              ElevatedButton(
                                  onPressed: () async {
                                    String mobileNumber = mobileController.text.toString();
                                    String alternumber = altermobileController.text.toString();
                                    String alergc = allergictoController.text;
                                    final alergicvalidate = RegExp(r'^[a-zA-Z0-9]+$');
                                    final validCharacters = RegExp(r'^[0-9]+$');

                                    if (_fbKey.currentState!.saveAndValidate()) {
                                      print(_fbKey.currentState!.value);
                                      Map<String, dynamic> postParams = Map.from(_fbKey.currentState!.value);
                                      String getDatecontroll = dateofbirth.current_date;
                                      if (getDatecontroll != null && getDatecontroll.isNotEmpty) {
                                        Jiffy fromDate_ = Jiffy(getDatecontroll);
                                        postParams['date_of_birth'] = fromDate_.format('MM/dd/yyyy');
                                        // Calculating Age
                                        final diff = Jiffy().diff(fromDate_, Units.YEAR);
                                        if (diff > 0) {
                                          postParams['age'] = diff;
                                        }
                                      }

                                      String memberId = widget.memberinfo['id'];
                                      String userId = preferencesService.userId;
                                      postParams['user_Id'] = userId;

                                      //allergicto field validation
                                      // if (!alergicvalidate.hasMatch(alergc) && alergc.isNotEmpty) {
                                      //   showDialog(
                                      //       context: context,
                                      //       builder: (BuildContext context) {
                                      //         return CustomDialogBox(
                                      //           title: "Alert !",
                                      //           descriptions: "Invalid details of allergicto",
                                      //           descriptions1: "",
                                      //           text: "OK",
                                      //         );
                                      //       });
                                      //   return;
                                      // }

                                      //alternatemobile_number

                                      // if (alternumber.isNotEmpty) {
                                      //   if (alternumber.length < 7 || alternumber.length > 15 || !validCharacters.hasMatch(alternumber)) {
                                      //     showDialog(
                                      //         context: context,
                                      //         builder: (BuildContext context) {
                                      //           return CustomDialogBox(
                                      //             title: "Alert !",
                                      //             descriptions: "Invalid Mobile Number. Enter a valid mobile number",
                                      //             descriptions1: "",
                                      //             text: "OK",
                                      //           );
                                      //         });
                                      //     return;
                                      //   }
                                      // }

                                      //mobile_number

                                      // if (mobile_number.isNotEmpty) {
                                      //   if (mobile_number.length < 7 || mobile_number.length > 15 || !validCharacters.hasMatch(mobile_number)) {
                                      //     showDialog(
                                      //         context: context,
                                      //         builder: (BuildContext context) {
                                      //           return CustomDialogBox(
                                      //             title: "Alert !",
                                      //             descriptions: "Invalid Mobile Number. Enter a valid mobile number",
                                      //             descriptions1: "",
                                      //             text: "OK",
                                      //           );
                                      //         });
                                      //     return;
                                      //   }
                                      // }
                                      // }
                                      // if (postParams['member_first_name'].isEmpty) {
                                      //   showDialog(
                                      //       context: context,
                                      //       builder: (BuildContext context) {
                                      //         return CustomDialogBox(
                                      //           title: "Alert !",
                                      //           descriptions: "Require Name",
                                      //           descriptions1: "",
                                      //           text: "OK",
                                      //         );
                                      //       });
                                      // } else {
                                      // } else if (postParams['member_mobile_number'].isNotEmpty && (postParams['member_mobile_number']) == (postParams['alternate_mobile_number'])) {
                                      //   showDialog(
                                      //       context: context,
                                      //       builder: (BuildContext context) {
                                      //         return CustomDialogBox(
                                      //           title: "Alert !",
                                      //           descriptions: "Mobile Number should not be equal to Alternate Mobile Number",
                                      //           descriptions1: "",
                                      //           text: "OK",
                                      //         );
                                      //       });
                                      //   return;
                                      // } else {
                                      Loader.show(context);
                                      final response = await model.updateMemberProfile(memberId, postParams, localPath, '');

                                      if (preferencesService.dropdown_user_id == memberId) {
                                        preferencesService.dropdown_user_name = postParams['member_first_name'];
                                        preferencesService.dropdown_user_age = postParams['age'].toString();
                                      }
                                      if (!model.isBusy) {
                                        Loader.hide();

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
                                      }
                                      // }
                                      // } else {
                                      //   setState(() {
                                      //     isAutoValidate = true;
                                      //   });
                                    }
                                  },
                                  child: Text('SAVE'),
                                  style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(Size(80, 32)),
                                      backgroundColor: MaterialStateProperty.all(Colors.green),
                                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))))),
                            ],
                          )
                  ],
                )
              ]))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: SwarAppBar(),
      appBar: SwarAppStaticBar(),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 2),
          width: Screen.width(context),
          child: ViewModelBuilder<EditMemberViewmodel>.reactive(
              onModelReady: (model) async {
                await model.getRelationship();
                await model.getCountries();
                if (widget.memberinfo['member_mobileno_countryCode'] != null) {
                  mobilecodeController.text = widget.memberinfo['member_mobileno_countryCode'].toString();
                  for (var each in countries) {
                    if (each['countryCode_digits'] == widget.memberinfo['member_mobileno_countryCode']) {
                      setState(() {
                        mobile_min_length = int.parse(each['min_length']);
                        mobile_max_length = int.parse(each['max_length']);
                      });
                    }
                  }
                }
                if (widget.memberinfo['member_alternateno_countryCode'] != null) {
                  altercodeController.text = widget.memberinfo['member_alternateno_countryCode'].toString();
                  for (var each in countries) {
                    if (each['countryCode_digits'] == widget.memberinfo['member_alternateno_countryCode']) {
                      setState(() {
                        alter_mobile_min_length = int.parse(each['min_length']);
                        alter_mobile_max_length = int.parse(each['max_length']);
                      });
                    }
                  }
                }
              },
              builder: (context, model, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UIHelper.verticalSpaceSmall,
                    UIHelper.addHeader(context, 'Edit Member', true),
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [formControls(context, model), UIHelper.verticalSpaceMedium],
                      ),
                    ))
                  ],
                );
              },
              viewModelBuilder: () => EditMemberViewmodel())),
    );
  }
}

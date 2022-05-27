import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/email_validator.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_profile_bar.dart';
import 'package:swarapp/shared/custom_date_picker.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:user_module/src/ui/user_profile/edit_profile_viewmodel.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:user_module/src/ui/user_profile/profile_view.dart';
import 'package:intl/intl.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class EditProfileView extends StatefulWidget {
  dynamic userinfo;
  EditProfileView({Key? key, this.userinfo}) : super(key: key);

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

const APIKeys = "AIzaSyA_76M-Sca9mXdpkJKVHSeUkFRgvvQ3icI";

class _EditProfileViewState extends State<EditProfileView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  TextEditingController ageController = TextEditingController();
  PreferencesService preferencesService = locator<PreferencesService>();
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  CustomDropDownContoller dateofbirth_get = CustomDropDownContoller();
  CustomDropDownContoller expireddate = CustomDropDownContoller();
  TextEditingController insutancename = TextEditingController();
  TextEditingController dateController = TextEditingController();
  bool isAutoValidate = false;
  final picker = ImagePicker();
  String localPath = '';
  String cover_localPath = '';
  String network_img_url = '';
  String date_picker_value = '';
  String email = '';
  String mobilenumber = '';
  bool isMobileValidate = true;
  bool emailValidate = false;
  bool is_editable_email = false;
  bool is_editable_mobile = false;
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);
  List countries = [];
  int min_length = 7;
  int max_length = 15;
  List getAlertmessage = [];
  PickResult? selectedPlace;
  static final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    this.loadJsonData();
//Update_Profile
    getAlertmessage = preferencesService.alertContentList!.where((msg) => msg['type'] == "Update_Profile").toList();
    setState(() {
      email = preferencesService.email;
      mobilenumber = preferencesService.phone;
      if (widget.userinfo['img_url'] != null) {
        network_img_url = widget.userinfo['img_url'];
      }

      if (widget.userinfo['azureBlobStorageLink'] != null) {
        network_img_url = '${ApiService.fileStorageEndPoint}${widget.userinfo['azureBlobStorageLink']}';
      }
      if (widget.userinfo['name'] != null) {
        ageController.text = widget.userinfo['name'].toString();
      }
      if (widget.userinfo['insurance_number'] != null) {
        insutancename.text = widget.userinfo['insurance_number'].toString();
      }
      if (widget.userinfo['state'] != null) {
        stateController.text = widget.userinfo['state'].toString();
      }
      if (widget.userinfo['city'] != null) {
        cityController.text = widget.userinfo['city'].toString();
      }
      if (widget.userinfo['zipcode'] != null) {
        zipController.text = widget.userinfo['zipcode'].toString();
      }
      if (widget.userinfo['profilestatus'] != null) {
        statusController.text = widget.userinfo['profilestatus'].toString();
      }
      if (widget.userinfo['dateofbirth'] != null) {
        dateController.text = widget.userinfo['dateofbirth'].toString();
      }
      // if (widget.userinfo['insurance_validitydate'] != null) {
      //   statusController.text = widget.userinfo['insurance_validitydate'].toString();
      // }
      if (widget.userinfo['email'] != null) {
        emailController.text = widget.userinfo['email'].toString();
      }
    });
  }

  Future<String> loadJsonData() async {
    var jsonText = await rootBundle.loadString('assets/countries.json');
    setState(() => countries = json.decode(jsonText));

    return 'success';
  }

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

  Widget addInputFieldControl(String control_name, String hint_text) {
    return FormBuilderTextField(
      style: loginInputTitleStyle,
      name: control_name,
      textCapitalization: TextCapitalization.sentences,
      autocorrect: false,
      onChanged: (value) {
        print(value);
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 5),
        hintText: hint_text,
        hintStyle: loginInputHintTitleStyle,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: UIHelper.getInputBorder(1),
        focusedBorder: UIHelper.getInputBorder(1),
        focusedErrorBorder: UIHelper.getInputBorder(1),
        errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
      ),
      // readOnly: true,
      // validator: control_name == 'name'
      validator: control_name == 'name'
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(context, errorText: "This field cannot be empty"),
              FormBuilderValidators.max(context, 20),
            ])
          : FormBuilderValidators.compose([]),
      // inputFormatters: [
      //   control_name == 'insurance_no' ? new WhitelistingTextInputFormatter(RegExp("[0-9]")) : new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
      // ],
      inputFormatters: [
        // is able to enter lowercase letters
        control_name == 'insurance_no' ? new FilteringTextInputFormatter.allow(RegExp("[0-9]")) : new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
        //if (control_name == 'mobilenumber') FilteringTextInputFormatter.allow(RegExp("[0-9]")),
      ],
      keyboardType: control_name == 'insurance_no' ? TextInputType.number : TextInputType.text,
    );
  }

  Widget fieldname(BuildContext context, String title) {
    return Expanded(
        child: Container(
            decoration: UIHelper.roundedBorderWithColor(10, Colors.white),
            height: 47,
            padding: EdgeInsets.only(left: 5, right: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title).fontSize(13).fontWeight(FontWeight.w500),
              ],
            )));
  }

  Widget googleAddressPickControl(Jiffy dob, DateTime? expired_date) {
    var emailValidators = EmailValidators;
    bool isemailEnabled = false;
    if (preferencesService.isEmailLogin == true) {
      isemailEnabled = true;
    }
    bool isphoneEnabled = false;
    if (preferencesService.isPhoneLogin == true) {
      isphoneEnabled = true;
    }
    return Container(
      padding: EdgeInsets.all(1),
      width: Screen.width(context),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          fieldname(context, 'First Name'),
          SizedBox(width: 5),
          Container(
            width: Screen.width(context) / 1.8,
            child: Container(
              width: Screen.width(context) / 1.8,
              child: FormBuilderTextField(
                style: loginInputTitleStyle,
                textCapitalization: TextCapitalization.sentences,
                name: 'name',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                // inputFormatters: [
                //   new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
                // ],
                inputFormatters: [
                  // is able to enter lowercase letters
                  new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                  //if (control_name == 'mobilenumber') FilteringTextInputFormatter.allow(RegExp("[0-9]")),
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
            ),
          )
        ]),
        UIHelper.verticalSpaceSmall,
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          fieldname(context, 'Last Name'),
          SizedBox(width: 5),
          Container(
            width: Screen.width(context) / 1.8,
            child: addInputFieldControl('lastname', 'Last Name'),
          )
        ]),
        UIHelper.verticalSpaceSmall,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Optional').fontSize(15).fontWeight(FontWeight.w700).textColor(Colors.black26), Text(' - Could help you in emergency ').fontSize(15).fontWeight(FontWeight.w600).textColor(Colors.black26)],
        ),
        UIHelper.verticalSpaceSmall,
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          fieldname(context, 'Insurance Name'),
          SizedBox(width: 5),
          Container(
            width: Screen.width(context) / 1.8,
            child: addInputFieldControl('insurance_name', 'Insurance Name'),
          )
        ]),
        UIHelper.verticalSpaceSmall,
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          fieldname(context, 'Number'),
          SizedBox(width: 5),
          Container(
            width: Screen.width(context) / 1.8,
            child: FormBuilderTextField(
              style: loginInputTitleStyle,
              name: 'insurance_number',
              controller: insutancename,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autocorrect: false,
              onChanged: (value) {
                print(value);
              },
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 5),
                hintText: 'Number',
                hintStyle: loginInputHintTitleStyle,
                filled: true,
                fillColor: Colors.white,
                enabledBorder: UIHelper.getInputBorder(1),
                focusedBorder: UIHelper.getInputBorder(1),
                focusedErrorBorder: UIHelper.getInputBorder(1),
                errorBorder: UIHelper.getInputBorder(1),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.minLength(context, 7, allowEmpty: true, errorText: "Invalid Insurance number"),
                FormBuilderValidators.maxLength(context, 16, errorText: "Invalid Insurance number"),
                FormBuilderValidators.numeric(context),
              ]),
              keyboardType: TextInputType.number,
              //inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]"))],
              inputFormatters: [
                // is able to enter lowercase letters
                new FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                //if (control_name == 'mobilenumber') FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              ],
            ),
          )
        ]),
        UIHelper.verticalSpaceSmall,
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          fieldname(context, 'Validity'),
          SizedBox(width: 5),
          Container(
            width: Screen.width(context) / 1.8,
            child: FormBuilderDateTimePicker(
              // initialDate: beginDate.add(Duration(days: 1)),
              name: "insurance_validitydate",
              inputType: InputType.date,
              format: DateFormat("dd/MM/yyyy"),
              onChanged: (DateTime? value) {
                Jiffy newDate = Jiffy(value);
              },
              // initialValue: widget.userinfo['insurance_validitydate'].dateTime,
              initialValue: widget.userinfo['insurance_validitydate'] != null ? null : null,
              initialDate: DateTime(DateTime.now().year - 0, DateTime.now().month, DateTime.now().day),
              firstDate: DateTime(1900),
              decoration: InputDecoration(
                hintText: 'Validity Date',
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
                errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                // hintText: "Date of Birth",
              ),
            ),
          )
        ]),
        UIHelper.verticalSpaceSmall,
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          fieldname(context, 'Blood Group'),
          SizedBox(width: 5),
          Container(
            width: Screen.width(context) / 1.8,
            child: addDropdownFieldControl('bloodgroup', 'Blood Group', ''),
          )
        ]),
        UIHelper.verticalSpaceSmall,
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          fieldname(context, 'Date of Birth'),
          SizedBox(width: 5),
          Container(
            width: Screen.width(context) / 1.8,
            // color:Colors.white,
            child: Theme(
                data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                  primary: activeColor,
                )),
                child: CustomDatePicker(
                  controller: dateofbirth_get,
                  initialDate: widget.userinfo['dateofbirth'] != null ? dob.dateTime : null,
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
        ]),
        UIHelper.verticalSpaceSmall,
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          fieldname(context, 'Gender'),
          SizedBox(width: 5),
          Container(width: Screen.width(context) / 1.8, child: addDropdownFieldControl('gender', 'Gender', '')),
        ]),
        UIHelper.verticalSpaceSmall,
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          fieldname(context, 'Email Id'),
          SizedBox(width: 5),
          Container(
            width: Screen.width(context) / 1.8,
            child: FormBuilderTextField(
              style: loginInputTitleStyle,
              name: 'email',
              controller: emailController,
              readOnly: isemailEnabled ? true : false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autocorrect: false,
              onChanged: (value) {
                is_editable_email = true;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 5),
                hintText: 'Email Id',
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
              // inputFormatters: [
              //   new WhitelistingTextInputFormatter(RegExp("[-a-zA-Z-0-9-_@\.]")),
              // ],
              inputFormatters: [
                // is able to enter lowercase letters
                new FilteringTextInputFormatter.allow(RegExp("[-a-zA-Z-0-9-_@\.]")),
                //if (control_name == 'mobilenumber') FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              ],
            ),
          ),
        ]),
        UIHelper.verticalSpaceSmall,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fieldname(context, 'Mobile No.'),
            SizedBox(width: 5),
            Container(
              width: Screen.width(context) / 1.8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
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
                      name: "code",
                      hint: Text('Code'),
                      items: countries.map<DropdownMenuItem<String>>((altercode) => new DropdownMenuItem<String>(
                                value: altercode['countryCode_digits'],
                                child: Text(altercode['countryCode_digits']).textColor(Colors.black).fontSize(16),
                              ))
                          .toList(),
                      onChanged: (value) {
                        for (var each in countries) {
                          if (each['countryCode_digits'] == value) {
                            setState(() {
                              min_length = int.parse(each['min_length']);
                              max_length = int.parse(each['max_length']);
                            });
                          }
                        }
                      },
                    ),

                    //  FormBuilderTextField(
                    //   style: loginInputTitleStyle,
                    //   name: 'code',
                    //   autocorrect: false,
                    //   readOnly: true,
                    //   onChanged: (value) {
                    //     print(value);
                    //   },
                    //   decoration: InputDecoration(
                    //     hintText: 'code',
                    //     contentPadding: EdgeInsets.only(left: 10),
                    //     hintStyle: loginInputHintTitleStyle,
                    //     filled: true,
                    //     fillColor: Colors.white70,
                    //     enabledBorder: UIHelper.getInputBorder(1),
                    //     focusedBorder: UIHelper.getInputBorder(1),
                    //     focusedErrorBorder: UIHelper.getInputBorder(1),
                    //     errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                    //   ),
                    // ),
                  ),
                  SizedBox(width: 5),
                  Flexible(
                    child: FormBuilderTextField(
                      style: loginInputTitleStyle,
                      name: 'mobilenumber',
                      autocorrect: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      readOnly: isphoneEnabled ? true : false,
                      onChanged: (value) {
                        setState(() {
                          is_editable_mobile = true;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 5),
                        hintText: 'Mobile No.',
                        hintStyle: loginInputHintTitleStyle,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: UIHelper.getInputBorder(1),
                        focusedBorder: UIHelper.getInputBorder(1),
                        focusedErrorBorder: UIHelper.getInputBorder(1),
                        errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.minLength(context, min_length, allowEmpty: true, errorText: "Invalid number"),
                        FormBuilderValidators.maxLength(context, max_length, errorText: "Invalid number"),
                        FormBuilderValidators.numeric(context),
                      ]),
                      keyboardType: TextInputType.number,
                      // inputFormatters: [
                      //   new WhitelistingTextInputFormatter(RegExp("[0-9]")),
                      // ]),
                      inputFormatters: [
                        // is able to enter lowercase letters
                        new FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                        //if (control_name == 'mobilenumber') FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        UIHelper.verticalSpaceSmall,
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          fieldname(context, 'Country'),
          SizedBox(width: 5),
          Container(
            width: Screen.width(context) / 1.8,
            child: FormBuilderTextField(
              style: loginInputTitleStyle,
              name: 'country',
              autocorrect: false,
              readOnly: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (value) {
                print(value);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 5),
                hintText: 'Country',
                hintStyle: loginInputHintTitleStyle,
                filled: true,
                fillColor: Colors.white,
                enabledBorder: UIHelper.getInputBorder(1),
                focusedBorder: UIHelper.getInputBorder(1),
                focusedErrorBorder: UIHelper.getInputBorder(1),
                errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
              ),
            ),
          )
        ]),
      ]),
    );
  }

  // Widget addCountryMobileDropdownControl(String fields_nametype, String hint_text, EditProfileViewmodel model) {
  //   return Container(
  //     child: Column(
  //       children: [
  //         UIHelper.verticalSpaceSmall,
  //         Container(
  //           alignment: Alignment.topLeft,
  //           child: Text(
  //             hint_text,
  //           ).fontSize(15).textColor(Colors.grey).fontWeight(FontWeight.w600),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget CountryCodeForm(String nameField, String hintText) {
    bool isEnabled = false;
    if (nameField == 'mobile') {
      isEnabled = true;
    }
    if (nameField == 'alternatemobilenumber') {
      return Column(
        children: [
          FormBuilderTextField(
            readOnly: nameField == 'code',
            style: loginInputTitleStyle,
            name: nameField,
            autocorrect: false,
            onChanged: (value) {
              print(value);
            },
          ),
          Container(),
        ],
      );
    }
    return Column(
      children: [
        Container(
          child: FormBuilderTextField(
            readOnly: nameField == 'code',
            style: loginInputTitleStyle,
            name: nameField,
            autocorrect: false,
            onChanged: (value) {
              print(value);
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 10),
              hintText: hintText,
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
      ],
    );
  }

  Widget addDropdownFieldControl(String control_name, String hint_text, dynamic data) {
    List bg_List = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    List gendr = ['Male', 'Female'];
    List itm = control_name == "bloodgroup" ? bg_List : gendr;
    return FormBuilderDropdown(
      decoration: InputDecoration(
        hintStyle: loginInputHintTitleStyle,
        contentPadding: EdgeInsets.only(left: 10),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: UIHelper.getInputBorder(1),
        focusedBorder: UIHelper.getInputBorder(1),
        focusedErrorBorder: UIHelper.getInputBorder(1),
        errorBorder: UIHelper.getInputBorder(1),
      ),
      name: control_name,
      hint: Text(hint_text).fontSize(14),
      items: itm
          .map((deg) => DropdownMenuItem(
                value: deg,
                child: Text(deg).textColor(Colors.black).fontSize(14),
              ))
          .toList(),
    );
  }

  // Widget getFields() {
  //   // currentForm = currentForm[0]['form'];
  //   // Jiffy dob = Jiffy(widget.userinf['dateofbirth']);
  //   // String date_value = dob.date.toString();
  //   // String month_value = dob.month.toString();
  //   // String year_value = dob.year.toString();
  //   // String allergic = '';
  //   // if (widget.userinfo['allergicto'] != null) {
  //   //   List al = widget.userinfo['allergicto'];
  //   //   allergic = al.join(', ');
  //   //   //print('---usrinfo0000000000'+widget.userinfo['bloodgroup']);
  //   // }

  //   // return Padding(
  //   //     padding: const EdgeInsets.only(left: 16, right: 16),
  //   //     child: );
  // }

  Widget getFields(EditProfileViewmodel model) {
    DateTime? expired_date;

    if (widget.userinfo['insurance_validitydate'] == null) {
      expired_date = widget.userinfo['insurance_validitydate'];
    } else {
      Jiffy chck = Jiffy(widget.userinfo['insurance_validitydate']);
      expired_date = chck.dateTime;
    }

    Jiffy dob = Jiffy(widget.userinfo['dateofbirth']);

    if (widget.userinfo['dateofbirth'] != null) {
      Jiffy dob = Jiffy(widget.userinfo['dateofbirth']);
    }
    return Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Container(
            padding: EdgeInsets.all(1),
            width: Screen.width(context),
            child: FormBuilder(
              initialValue: {
                'name': widget.userinfo['name'] ?? '',
                'lastname': widget.userinfo['lastname'] ?? '',
                'email': widget.userinfo['email'] ?? '',
                // insurance_validitydate
                'insurance_validitydate': expired_date,
                'insurance_name': widget.userinfo['insurance_name'] ?? '',
                'insurance_number': widget.userinfo['insurance_number'] ?? '',
                'dateofbirth': dob.dateTime,
                'gender': widget.userinfo['gender'] ?? null,
                'mobilenumber': widget.userinfo['mobilenumber'] ?? '',
                'code': widget.userinfo['countryCode_digits'] ?? "",
                'bloodgroup': widget.userinfo['bloodgroup'] ?? null,
                'country': widget.userinfo['country'] ?? '',
                // 'allergicto': allergic,
              },
              autovalidateMode: isAutoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
              key: _fbKey,
              child: Column(
                children: [
                  Column(children: [
                    googleAddressPickControl(dob, expired_date),
                    UIHelper.verticalSpaceSmall,
                  ]),
                  ViewModelBuilder<EditProfileViewmodel>.reactive(
                      builder: (context, model, child) {
                        return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                          ElevatedButton(
                              onPressed: () {
                                Get.back(result: {'refresh': false});
                              },
                              child: Text('CANCEL').textColor(Colors.white),
                              style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(80, 32)),
                                  elevation: MaterialStateProperty.all(0),
                                  backgroundColor: MaterialStateProperty.all(activeColor),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ))),
                          ElevatedButton(
                              onPressed: () async {
                                String get_datecontroll = dateofbirth_get.current_date;
                                if (get_datecontroll == "Wrong Date") {
                                  print('please check...');
                                } else if (_fbKey.currentState!.saveAndValidate()) {
                                  String born_date = '';
                                  String birth_date = '';
                                  Map<String, dynamic> userInfo = Map.from(_fbKey.currentState!.value);
                                  String get_datecontroll = dateofbirth_get.current_date;
                                  if (get_datecontroll != null && get_datecontroll.isNotEmpty) {
                                    Jiffy fromDate_ = Jiffy(get_datecontroll);
                                    userInfo['dateofbirth'] = fromDate_.format('MM/dd/yyyy');
                                    born_date = fromDate_.format('yyyy-MM-dd');
                                    birth_date = DateTime.parse(born_date).toString();

                                    // Calculating Age
                                    final diff = Jiffy().diff(fromDate_, Units.YEAR);
                                    if (diff > 0) {
                                      userInfo['age'] = diff;
                                    }
                                  }

                                  if ((is_editable_mobile == false) && (is_editable_email == false)) {
                                    userInfo.remove('email');
                                    userInfo.remove('mobilenumber');
                                    setState(() {
                                      widget.userinfo['bloodgroup'] = userInfo['bloodgroup'];
                                      widget.userinfo['insurance_name'] = userInfo['insurance_name'];
                                      widget.userinfo['name'] = userInfo['name'];
                                      widget.userinfo['lastname'] = userInfo['lastname'];
                                      widget.userinfo['insurance_number'] = userInfo['insurance_number'];
                                      widget.userinfo['insurance_validitydate'] = userInfo['insurance_validitydate'];
                                      widget.userinfo['dateofbirth'] = birth_date != "" ? birth_date : null;
                                      widget.userinfo['gender'] = userInfo['gender'];
                                      widget.userinfo['age'] = userInfo['age'];
                                    });
                                    Loader.show(context);
                                    await model.updateUserProfile(userInfo, localPath, cover_localPath);
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
                                    // setState(() {});

                                    Get.back(result: {'refresh': true});

                                    child:
                                    Text('SAVE').textColor(Colors.white);

                                    style:
                                    ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(Size(80, 32)),
                                        backgroundColor: MaterialStateProperty.all(Colors.green),
                                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                                  } else if (is_editable_email == true) {
                                    userInfo.remove('mobilenumber');
                                    setState(() {
                                      widget.userinfo['bloodgroup'] = userInfo['bloodgroup'];
                                      widget.userinfo['insurance_name'] = userInfo['insurance_name'];
                                      widget.userinfo['name'] = userInfo['name'];
                                      widget.userinfo['insurance_number'] = userInfo['insurance_number'];
                                      widget.userinfo['insurance_validitydate'] = userInfo['insurance_validitydate'];
                                      widget.userinfo['dateofbirth'] = birth_date != "" ? birth_date : null;
                                      widget.userinfo['gender'] = userInfo['gender'];
                                      widget.userinfo['email'] = userInfo['email'];
                                      widget.userinfo['age'] = userInfo['age'];
                                    });
                                    Loader.show(context);
                                    await model.updateUserProfile(userInfo, localPath, cover_localPath);
                                    Loader.hide();
                                    if (model.res == "email already exist") {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CustomDialogBox(
                                              title: "Alert !",
                                              descriptions: "Email already exist",
                                              descriptions1: "",
                                              text: "OK",
                                            );
                                          });
                                      return;
                                    } else {
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
                                    }
                                    ;

                                    Get.back(result: {'refresh': true});

                                    child:
                                    Text('SAVE').textColor(Colors.white);
                                    ;
                                    style:
                                    ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(Size(80, 32)),
                                        backgroundColor: MaterialStateProperty.all(Colors.green),
                                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                                  } else {
                                    userInfo.remove('email');
                                    setState(() {
                                      widget.userinfo['bloodgroup'] = userInfo['bloodgroup'];
                                      widget.userinfo['insurance_name'] = userInfo['insurance_name'];
                                      widget.userinfo['name'] = userInfo['name'];
                                      widget.userinfo['insurance_number'] = userInfo['insurance_number'];
                                      widget.userinfo['insurance_validitydate'] = userInfo['insurance_validitydate'];
                                      widget.userinfo['dateofbirth'] = birth_date != "" ? birth_date : null;
                                      widget.userinfo['gender'] = userInfo['gender'];
                                      widget.userinfo['mobilenumber'] = userInfo['mobilenumber'];
                                      widget.userinfo['age'] = userInfo['age'];
                                    });
                                    Loader.show(context);
                                    await model.updateUserProfile(userInfo, localPath, cover_localPath);
                                    Loader.hide();
                                    if (model.res == "mobilenumber already exist") {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CustomDialogBox(
                                              title: "Alert !",
                                              descriptions: "Mobile number already exists",
                                              descriptions1: "",
                                              text: "OK",
                                            );
                                          });
                                      return;
                                    } else {
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
                                    }
                                    ;

                                    Get.back(result: {'refresh': true});
                                  }
                                }
                              },
                              child: Text('SAVE').textColor(Colors.white),
                              style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(80, 32)),
                                  backgroundColor: MaterialStateProperty.all(Colors.green),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                        ]);
                      },
                      viewModelBuilder: () => EditProfileViewmodel()),
                ],
              ),
            )));
  }

  Future getImage(String type, FileType fileType) async {
    String path = '';
    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
    await Get.to(() => ImgCropper(
        index: 0,
        imagePath: pickedFile!.path,
        onCropComplete: (path) {
          String st = path;
          print(path);
          setState(() {
            localPath = path;
          });
        }));

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
                    getImage(type, FileType.image);
                  },
                  visualDensity: VisualDensity.compact,
                  //visualDensity: VisualDensity.standard,
                  // visualDensity:VisualDensity.comfortable,
                  title: Text('Photo Library'),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarProfileAppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Container(
          width: Screen.width(context),
          child: ViewModelBuilder<EditProfileViewmodel>.reactive(
              onModelReady: (model) async {
                await model.getCountries();
              },
              builder: (context, model, child) {
                return Column(
                  children: [
                    UIHelper.commonTopBar(' Edit Profile'),
                    UIHelper.verticalSpaceSmall,
                    Expanded(
                        child: SingleChildScrollView(
                      child: Container(
                        decoration: UIHelper.roundedBorderWithColor(20, subtleColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            UIHelper.verticalSpaceSmall,
                            GestureDetector(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(200.0),
                                // width: 200,
                                child: localPath.isNotEmpty
                                    ? Image.file(
                                        File(localPath),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : network_img_url == ''
                                        ? Container(
                                            color: subtleColor,
                                            child: Icon(
                                              Icons.account_circle,
                                              size: 30,
                                              color: Colors.black38,
                                            ),
                                            width: 60,
                                            height: 60,
                                          )
                                        : UIHelper.getImage(network_img_url, 60, 60),
                              ),
                              onTap: () async {
                                // print('**IMG IS ***' + model.img_url);
                                if (network_img_url != "") {
                                  await showDialog(
                                      context: context,
                                      //https://swarstage.blob.core.windows.net/swardoctor/scaled_image_picker8539268485450644726_1621533729545.jpg
                                      builder: (_) => ImageDialog(context, network_img_url));
                                }
                              },
                            ),
                            UIHelper.verticalSpaceMedium,
                            getFields(model),
                          ],
                        ),
                      ),
                    )),
                  ],
                );
              },
              viewModelBuilder: () => EditProfileViewmodel()),
        ),
      ),
    );
  }
}

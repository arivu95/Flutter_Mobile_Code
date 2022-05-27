import 'dart:convert';
import 'dart:io';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:doctor_module/src/ui/doc_signup/doc_signup_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/email_validator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_date_picker.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/signup_viewmodel.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:doctor_module/src/ui/doc_signup/doc_service_view.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class DocSignupView extends StatefulWidget {
  DocSignupView({Key? key}) : super(key: key);

  @override
  _DocSignupViewState createState() => _DocSignupViewState();
}

class _DocSignupViewState extends State<DocSignupView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  PreferencesService preferencesService = locator<PreferencesService>();
  NavigationService navigationService = locator<NavigationService>();
  CustomDropDownContoller dateofbirth = CustomDropDownContoller();
  bool isAutoValidate = false;
  bool emailValidate = false;
  String email = '';
  String phone = '';
  String code = '';
  String country = '';
  final picker = ImagePicker();
  String localPath = '';
  String network_img_url = '';
  dynamic selectedCountry;
  List getAlertmessage = [];

  List countries = [];
  int mobile_min_length = 7;
  int mobile_max_length = 15;

  @override
  void initState() {
    super.initState();
    this.loadJsonData();
    //getAlertmessage = preferencesService.alertContentList!.where((msg) => msg['type'] == "Doctor_Profile_Creation").toList();
    getAlertmessage = preferencesService.alertContentList!.where((msg) => msg['type'] == "Register").toList();
    setState(() {
      email = preferencesService.email;
      phone = preferencesService.phone;
      code = preferencesService.user_country_degit;
      country = preferencesService.user_country;
    });
  }

  Future<String> loadJsonData() async {
    var jsonText = await rootBundle.loadString('assets/countries.json');
    setState(() => countries = json.decode(jsonText));

    return 'success';
  }

  Widget titleCard(BuildContext context, String title) {
    return Container(
        decoration: UIHelper.roundedBorderWithColor(10, Colors.white),
        width: Screen.width(context) / 3.3,
        height: 47,
        padding: EdgeInsets.only(left: 5, right: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title).fontSize(13).fontWeight(FontWeight.w500),
          ],
        ));
  }

  Widget addDropdownFieldControl(String controlName, String hintText) {
    List bgList = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    List gendr = ['Male', 'Female'];
    List itm = controlName == "bloodgroup" ? bgList : gendr;
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
      name: controlName,
      hint: Text(hintText).fontSize(14),
      items: itm
          .map((deg) => DropdownMenuItem(
                value: deg,
                child: Text(deg).textColor(Colors.black).fontSize(14),
              ))
          .toList(),
    );
  }

  Widget addInputFieldControl(String controlName, String hintText, bool isEnabled) {
    return FormBuilderTextField(
      style: loginInputTitleStyle,
      name: controlName,
      textCapitalization: TextCapitalization.sentences,
      autocorrect: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: isEnabled,
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
      validator: controlName == 'name'
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(context, errorText: "This field cannot be empty"),
              FormBuilderValidators.max(context, 20),
            ])
          : FormBuilderValidators.compose([]),
      inputFormatters: [
        controlName == 'insurance_number' ? new FilteringTextInputFormatter.allow(RegExp("[0-9]")) : new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
      ],
      keyboardType: controlName == 'insurance_number' ? TextInputType.number : TextInputType.text,
    );
  }

  Widget formControls(BuildContext context) {
    bool isemailEnabled = false;
    if (preferencesService.email != "") {
      isemailEnabled = true;
    }
    bool isphoneEnabled = false;
    if (preferencesService.phone != "") {
      isphoneEnabled = true;
    }

    if (preferencesService.user_country_degit != null) {
      for (var each in countries) {
        if (each['countryCode_digits'] == preferencesService.user_country_degit) {
          setState(() {
            mobile_min_length = int.parse(each['min_length']);
            mobile_max_length = int.parse(each['max_length']);
          });
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: FormBuilder(
          initialValue: {'email': email, 'mobilenumber': phone, 'lastname': '', 'insurance_name': '', 'countryCode_digits': code, 'country': country},
          autovalidateMode: isAutoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          key: _fbKey,
          child: Column(
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'First Name'),
                SizedBox(width: 5),
                Expanded(
                    child: Container(
                  child: addInputFieldControl('name', 'First name*', false),
                ))
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Last Name'),
                SizedBox(width: 5),
                Expanded(
                    child: Container(
                  child: addInputFieldControl('lastname', 'Last Name', false),
                ))
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Email id'),
                SizedBox(width: 5),
                Expanded(
                    child: Container(
                  child: FormBuilderTextField(
                    style: loginInputTitleStyle,
                    name: 'email',
                    autocorrect: false,
                    readOnly: isemailEnabled ? true : false,
                    onChanged: (value) {
                      setState(() {
                        if (value!.isEmpty) {
                          emailValidate = false;
                        } else {
                          emailValidate = true;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 5),
                      hintText: 'Email id',
                      hintStyle: loginInputHintTitleStyle,
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: UIHelper.getInputBorder(1),
                      focusedBorder: UIHelper.getInputBorder(1),
                      focusedErrorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                      errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                    ),
                    validator: emailValidate
                        ? EmailValidators.compose([
                            EmailValidators.email(context),
                          ])
                        : FormBuilderValidators.compose([]),
                    inputFormatters: [
                      new FilteringTextInputFormatter.allow(RegExp("[-a-zA-Z-0-9-_@\.]")),
                    ],
                  ),
                ))
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Gender'),
                SizedBox(width: 5),
                Expanded(child: Container(child: addDropdownFieldControl('gender', 'Gender'))),
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Date of birth'),
                SizedBox(width: 5),
                Expanded(
                    child: Container(
                  child: Theme(
                      data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                        primary: activeColor,
                      )),
                      child: CustomDatePicker(
                        controller: dateofbirth,
                        initialDate: null,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                        onChanged: (date) {},
                      )),
                ))
              ]),
              UIHelper.verticalSpaceTiny,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleCard(context, 'Mobile'),
                  SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(width: 60, child: addInputFieldControl('countryCode_digits', '+00', true)),
                              SizedBox(width: 5),
                              Flexible(
                                child: FormBuilderTextField(
                                    style: loginInputTitleStyle,
                                    name: 'mobilenumber',
                                    autocorrect: false,
                                    readOnly: isphoneEnabled ? true : false,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) {},
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 5),
                                      hintText: 'Mobile Number',
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
                                    inputFormatters: [
                                      new FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Country'),
                SizedBox(width: 5),
                Expanded(
                    child: Container(
                  child: addInputFieldControl('country', 'Country', true),
                ))
              ]),
              UIHelper.verticalSpaceLarge,
              ViewModelBuilder<DocSignupViewmodel>.reactive(
                  builder: (context, model, child) {
                    return model.isBusy
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              String getDatecontroll = dateofbirth.current_date.toString();

                              if (getDatecontroll == "Wrong Date") {
                                print('please check...');
                              } else {
                                if (_fbKey.currentState!.saveAndValidate()) {
                                  Map<String, dynamic> postParams = Map.from(_fbKey.currentState!.value);
                                  if (getDatecontroll != null && getDatecontroll.isNotEmpty) {
                                    Jiffy fromDate_ = Jiffy(getDatecontroll);
                                    postParams['dateofbirth'] = fromDate_.format('MM-dd-yyyy');
                                    final diff = Jiffy().diff(fromDate_, Units.YEAR);
                                    if (diff > 0) {
                                      postParams['age'] = diff;
                                    }
                                  }

                                  if (postParams['insurance_validitydate'] != null) {
                                    Jiffy validityDate_ = Jiffy(postParams['insurance_validitydate']);
                                    postParams['insurance_validitydate'] = validityDate_.format('MM-dd-yyyy');
                                  }
                                  postParams['login_role_id'] = preferencesService.login_roleId;
                                  postParams['countryCode_digits'] = preferencesService.user_country_degit;
                                  postParams['language'] = preferencesService.language;

                                  if (postParams['email'].isEmpty) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Email is needed for account recovery purpose. Do you want to continue without email?').fontSize(13),
                                            actions: <Widget>[
                                              FlatButton(
                                                color: Colors.red,
                                                textColor: Colors.white,
                                                child: Text('No'),
                                                onPressed: () {
                                                  setState(() {
                                                    emailValidate = true;
                                                    Navigator.pop(context);
                                                  });
                                                },
                                              ),
                                              FlatButton(
                                                color: Colors.green,
                                                textColor: Colors.white,
                                                child: Text('Yes'),
                                                onPressed: () async {
                                                  Loader.show(context);
                                                  final response = await model.registerDoctor(postParams, localPath);
                                                  Loader.hide();
                                                  setState(() {
                                                    isAutoValidate = true;
                                                  });
                                                  if (response) {
                                                    if (model.res == "mobilenumber already exist") {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return CustomDialogBox(
                                                              title: "Alert !",
                                                              descriptions: "Mobile number already exists in our record.Proceed to login if you are an existing user",
                                                              descriptions1: "",
                                                              text: "OK",
                                                            );
                                                          });
                                                      return;
                                                    } else if (model.res == "email already exist") {
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
                                                              title: "Success!",
                                                              descriptions: getAlertmessage[0]['content'],
                                                              descriptions1: "“We care for you”",
                                                              text: "OK",
                                                            );
                                                          });
                                                      navigationService.clearStackAndShow(RoutePaths.DocService);
                                                    }
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  } else {
                                    Loader.show(context);
                                    final response = await model.registerDoctor(postParams, localPath);
                                    Loader.hide();
                                    print("------response-----" + response.toString());

                                    setState(() {
                                      isAutoValidate = true;
                                    });
                                    if (response) {
                                      if (model.res == "mobilenumber already exist") {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CustomDialogBox(
                                                title: "Alert !",
                                                descriptions: "Mobile number already exists in our record.Proceed to login if you are an existing user",
                                                descriptions1: "",
                                                text: "OK",
                                              );
                                            });
                                        return;
                                      } else if (model.res == "email already exist") {
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
                                                title: "Success!",
                                                descriptions: getAlertmessage[0]['content'],
                                                descriptions1: "“We care for you”",
                                                text: "OK",
                                              );
                                            });
                                        navigationService.clearStackAndShow(RoutePaths.DocService);
                                      }
                                    }
                                  }
                                }
                              }
                            },
                            child: Text('Create').fontWeight(FontWeight.w700).fontSize(20),
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(Size(150, 38)),
                              backgroundColor: MaterialStateProperty.all(submitBtnColor),
                            ));
                  },
                  viewModelBuilder: () => DocSignupViewmodel()),
              UIHelper.verticalSpaceMedium,
            ],
          )),
    );
  }

  Future getImage(String type, FileType fileType) async {
    String path = '';
    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 240);

    if (pickedFile != null) {
      await Get.to(() => ImgCropper(
          index: 0,
          imagePath: pickedFile.path,
          onCropComplete: (path) {
            // String st = path;
            setState(() {
              localPath = path;
            });
          }));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarStaticBar(),
      backgroundColor: Colors.white,
      body: Container(
        width: Screen.width(context),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 0, 20),
              child: UIHelper.addHeader(context, "Profile", true),
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Container(
                decoration: UIHelper.roundedBorderWithColor(20, subtleColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UIHelper.verticalSpaceSmall,
                    GestureDetector(
                      onTap: () {
                        showFilePickerSheet('type');
                      },
                      child: Container(
                        child: localPath.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(36.0),
                                child: Image.file(
                                  File(localPath),
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 72,
                                height: 72,
                                decoration: UIHelper.roundedBorderWithColor(36, camerabgColor),
                                child: Icon(Icons.camera_alt, size: 30, color: Colors.black38),
                              ),
                      ),
                    ),
                    UIHelper.verticalSpaceMedium,
                    formControls(context)
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

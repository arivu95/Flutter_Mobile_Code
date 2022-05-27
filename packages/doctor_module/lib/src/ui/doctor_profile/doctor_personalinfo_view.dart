import 'package:doctor_module/src/ui/doctor_profile/doctor_personalinfo_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/email_validator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:swarapp/shared/custom_date_picker.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/custom_multiselect_dropdown.dart';
import 'package:swarapp/shared/custom_switch_widget.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:jiffy/jiffy.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:stacked_services/stacked_services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:getwidget/getwidget.dart' as dropWidget;

class DoctorPersonalInfoView extends StatefulWidget {
  DoctorPersonalInfoView({Key? key}) : super(key: key);

  @override
  _DoctorPersonalInfoViewState createState() => _DoctorPersonalInfoViewState();
}

const APIKeys = "AIzaSyA_76M-Sca9mXdpkJKVHSeUkFRgvvQ3icI";

class _DoctorPersonalInfoViewState extends State<DoctorPersonalInfoView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  CustomDropDownContoller dateofbirth = CustomDropDownContoller();
  PreferencesService preferencesService = locator<PreferencesService>();
  TextEditingController addressController = TextEditingController();
  TextEditingController fileController = TextEditingController();
  bool emailValidate = false;
  bool isAutoValidate = false;
  bool contact_privacy = false;
  List<String> selected_specialization = [];
  List<String> selected_languages = [];
  PickResult? selectedPlace;
  final picker = ImagePicker();
  String isvideo = '';
  bool speciality_validate = true;
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);
  bool isemailEnabled = false;
  bool isphoneEnabled = false;
  bool is_editable_email = false;
  bool is_editable_mobile = false;

  List countries = [];
  int mobile_min_length = 7;
  int mobile_max_length = 15;

  @override
  void initState() {
    super.initState();
    this.loadJsonData();
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

  Widget addInputFieldControl(String controlName, String hintText, bool isEnabled, bool isRequired) {
    return FormBuilderTextField(
      style: loginInputTitleStyle,
      name: controlName,
      textCapitalization: TextCapitalization.sentences,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autocorrect: false,
      readOnly: isEnabled,
      onChanged: (value) {
        setState(() {
          controlName == "mobilenumber" ? is_editable_mobile = true : null;
        });
      },
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
      validator: isRequired
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(context, errorText: "This field cannot be empty."),
              FormBuilderValidators.max(context, 20),
            ])
          : controlName == 'mobilenumber'
              ? FormBuilderValidators.compose([
                  FormBuilderValidators.minLength(context, mobile_min_length, allowEmpty: true, errorText: "Invalid Number"),
                  FormBuilderValidators.maxLength(context, mobile_max_length, errorText: "Invalid Number"),
                  FormBuilderValidators.numeric(context),
                ])
              : FormBuilderValidators.compose([]),
      inputFormatters: [
        controlName == 'mobilenumber'
            ? new FilteringTextInputFormatter.allow(RegExp("[0-9]"))
            : controlName == 'address'
                ? new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
                : new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
      ],
      keyboardType: controlName == 'mobilenumber' ? TextInputType.phone : TextInputType.text,
    );
  }

  Widget addDropdownFieldControl(String controlName, String hintText, bool isRequired, DoctorPersonalinfoViewModel model) {
    List gendr = ['Male', 'Female'];
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
              FormBuilderValidators.required(context, errorText: "This field cannot be empty."),
              FormBuilderValidators.max(context, 20),
            ])
          : null,
      name: controlName,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      hint: Text(hintText).fontSize(14),
      items: controlName == "gender"
          ? gendr
              .map((deg) => DropdownMenuItem(
                    value: deg,
                    child: Text(deg).textColor(Colors.black).fontSize(15),
                  ))
              .toList()
          : controlName == "country"
              ? model.countries.map((dynamic value) {
                  return new DropdownMenuItem(
                    value: value['country'],
                    child: new Text(value['country']).fontSize(15),
                  );
                }).toList()
              : model.languages.map((dynamic value) {
                  return new DropdownMenuItem(
                    value: value['languageknown'],
                    child: new Text(value['languageknown']).fontSize(15),
                  );
                }).toList(),
    );
  }

  Widget multiselectDropdownField(String hintText, DoctorPersonalinfoViewModel model) {
    return DropDownMultiSelect(
      onChanged: (List<String> x) {
        setState(() {
          if (hintText == 'Specialization') {
            selected_specialization = x;
            speciality_validate = true;
          } else {
            selected_languages = x;
          }
        });
      },
      options: hintText == 'Specialization' ? model.specialization : model.languages,
      selectedValues: hintText == 'Specialization' ? selected_specialization : selected_languages,
      whenEmpty: hintText,
      decoration: InputDecoration(
        // hintText: 'select...',
        suffixIcon: IconButton(icon: const Icon(Icons.keyboard_arrow_down), onPressed: () => {}),
      ),
    );
  }

  Widget formControls(BuildContext context, DoctorPersonalinfoViewModel model) {
    dynamic userinfo = model.user;
    if (preferencesService.isEmailLogin == true) {
      isemailEnabled = true;
    }
    if (preferencesService.isPhoneLogin == true) {
      isphoneEnabled = true;
    }
    if (userinfo['contact_privacy'] == true) {
      contact_privacy = true;
    }

    String languageKnown = '';
    if (userinfo['language_known'] != null) {
      if (userinfo['language_known'].length > 0) {
        languageKnown = userinfo['language_known'][0];
      }
    }

    DateTime? dob;
    if (userinfo['dateofbirth'] == null) {
      dob = userinfo['dateofbirth'];
    } else {
      Jiffy dobCheck = Jiffy(userinfo['dateofbirth']);
      dob = dobCheck.dateTime;
    }
    String fileUrl = fileController.text.split('/').last;
    String fileTrimurl = fileUrl.split('_').last;
    return Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: FormBuilder(
            initialValue: {
              'name': userinfo['name'] ?? '',
              'lastname': userinfo['lastname'] ?? '',
              'gender': userinfo['gender'] ?? null,
              'language_known': languageKnown != '' ? languageKnown : null,
              'country': userinfo['country'] ?? null,
              'mobilenumber': userinfo['mobilenumber'] ?? '',
              'email': userinfo['email'] ?? '',
              'countryCode_digits': userinfo['countryCode_digits'] ?? null,
              //  'address': userinfo['address'] ?? '',
            },
            autovalidateMode: isAutoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            key: _fbKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'First Name*'),
                SizedBox(width: 5),
                Expanded(
                    child: Container(
                  child: addInputFieldControl('name', 'First Name', false, true),
                ))
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Last Name'),
                SizedBox(width: 5),
                Expanded(
                  child: Container(child: addInputFieldControl('lastname', 'Last Name', false, false)),
                )
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Specialization*'),
                SizedBox(width: 5),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(decoration: UIHelper.roundedBorderWithColor(10, speciality_validate ? Colors.transparent : Colors.red), child: multiselectDropdownField('Specialization', model)),
                    speciality_validate ? SizedBox() : Container(padding: const EdgeInsets.fromLTRB(5, 7, 5, 3), child: Text('This field cannot be empty.').fontSize(12).textColor(activeColor))
                  ],
                ))
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [titleCard(context, 'Gender*'), SizedBox(width: 5), Expanded(child: Container(child: addDropdownFieldControl('gender', 'Gender', true, model)))]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Date of Birth'),
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
                        initialDate: userinfo['dateofbirth'] != null ? dob : null,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                        onChanged: (date) {},
                      )),
                ))
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [titleCard(context, 'Languages'), SizedBox(width: 5), Expanded(child: Container(child: multiselectDropdownField('Languages known', model)))]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [titleCard(context, 'Country*'), SizedBox(width: 5), Expanded(child: Container(child: addInputFieldControl('country', 'Country', true, true)))]),
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
                  ? Row(children: [
                      SizedBox(
                        width: 100,
                        child: recentItem(context),
                      ),
                      SizedBox(width: 10),
                      Flexible(child: Text(fileTrimurl))
                    ])
                  : SizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Contact').fontWeight(FontWeight.w600),
                  CustomSwitchWidget(
                    value: contact_privacy,
                    onChanged: (bool value) {
                      print(value);
                      contact_privacy = value;
                      userinfo['contact_privacy'] = value;
                      setState(() {});
                    },
                  ),
                ],
              ),
              UIHelper.verticalSpaceSmall,
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
                              Container(
                                width: 80,
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
                                  name: "countryCode_digits",
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
                                          mobile_min_length = int.parse(each['min_length']);
                                          mobile_max_length = int.parse(each['max_length']);
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 5),
                              Flexible(
                                child: addInputFieldControl('mobilenumber', 'Mobile Number', isphoneEnabled, false),
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
                titleCard(context, 'Email Id'),
                SizedBox(width: 5),
                Expanded(
                    child: Container(
                  child: FormBuilderTextField(
                    style: loginInputTitleStyle,
                    name: 'email',
                    autocorrect: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    readOnly: isemailEnabled ? true : false,
                    onChanged: (value) {
                      setState(() {
                        is_editable_email = true;
                        if (value!.isEmpty) {
                          emailValidate = false;
                        } else {
                          emailValidate = true;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 5),
                      hintText: 'Email Id',
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
                titleCard(context, 'Address'),
                SizedBox(width: 5),
                Expanded(
                    child: Container(
                  child:
                      // addInputFieldControl('address', 'Address', false, false)
                      FormBuilderTextField(
                    style: loginInputTitleStyle,
                    name: "address",
                    autocorrect: false,
                    controller: addressController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 5),
                      suffixIcon: GestureDetector(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.black38,
                        ),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PlacePicker(
                                  apiKey: APIKeys,
                                  initialPosition: _DoctorPersonalInfoViewState.kInitialPosition,
                                  useCurrentLocation: true,
                                  selectInitialPosition: true,
                                  //usePlaceDetailSearch: true,
                                  onPlacePicked: (result) {
                                    selectedPlace = result;
                                    Navigator.of(context).pop();
                                    setState(() {
                                      final routeArgs = selectedPlace!.formattedAddress;
                                      String vals = routeArgs.toString();
                                      String getzip = "";
                                      String getstate = "";
                                      String getcountry = "";
                                      vals.split(",");
                                      String addrs = vals.split(",")[0];
                                      vals = vals.replaceAll('$addrs, ', '');
                                      addressController.text = vals;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        },
                      ),
                      hintText: "Address",
                      hintStyle: loginInputHintTitleStyle,
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: UIHelper.getInputBorder(1),
                      focusedBorder: UIHelper.getInputBorder(1),
                      focusedErrorBorder: UIHelper.getInputBorder(1),
                      errorBorder: UIHelper.getInputBorder(1),
                    ),
                  ),
                ))
              ]),
              UIHelper.verticalSpaceTiny,
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppDoctorBar(isProfileBar: true),
      backgroundColor: Color(0xFFE5E5E5),
      body: ViewModelBuilder<DoctorPersonalinfoViewModel>.reactive(
          onModelReady: (model) async {
            Loader.show(context);
            await model.getSpecialization();
            Loader.hide();
            preferencesService.paths.clear();

            setState(() {
              if (model.user['address'] != null) {
                addressController.text = model.user['address'];
              }
              if (model.user['doctor_certificate'] != null && model.user['doctor_certificate'] != "") {
                fileController.text = '${ApiService.fileStorageEndPoint}${model.user['doctor_certificate'].toString()}';
              }
              if (model.user['specialization'] != null) {
                if (model.user['specialization'].length > 0) {
                  selected_specialization = List<String>.from(model.user['specialization']);
                }
              }

              if (model.user['language_known'] != null) {
                if (model.user['language_known'].length > 0) {
                  selected_languages = new List<String>.from(model.user['language_known']);
                }
              }
              if (model.user['countryCode_digits'] != null) {
                for (var each in countries) {
                  if (each['countryCode_digits'] == model.user['countryCode_digits']) {
                    setState(() {
                      mobile_min_length = int.parse(each['min_length']);
                      mobile_max_length = int.parse(each['max_length']);
                    });
                  }
                }
              }
            });
          },
          builder: (context, model, child) {
            return SafeArea(
                top: false,
                child: model.isBusy
                    ? SizedBox()
                    : Container(
                        padding: EdgeInsets.only(left: 12, right: 12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                          UIHelper.verticalSpaceSmall,
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: UIHelper.addHeader(context, "Profile", true),
                          ),
                          UIHelper.verticalSpaceMedium,
                          Text('Personal').fontWeight(FontWeight.w600),
                          UIHelper.verticalSpaceSmall,
                          Expanded(child: SingleChildScrollView(child: formControls(context, model))),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    String getDatecontroll = dateofbirth.current_date.toString();
                                    if (getDatecontroll == "Wrong Date") {
                                      print('please check...');
                                    } else if (_fbKey.currentState!.saveAndValidate()) {
                                      Map<String, dynamic> postParams = Map.from(_fbKey.currentState!.value);
                                      if (getDatecontroll != null && getDatecontroll.isNotEmpty) {
                                        Jiffy fromDate_ = Jiffy(getDatecontroll);
                                        postParams['dateofbirth'] = fromDate_.format('MM-dd-yyyy');
                                        final diff = Jiffy().diff(fromDate_, Units.YEAR);
                                        if (diff > 0) {
                                          postParams['age'] = diff;
                                        }
                                      }

                                      postParams['contact_privacy'] = contact_privacy;
                                      postParams['language'] = preferencesService.language;
                                      postParams['specialization'] = selected_specialization;
                                      postParams['language_known'] = selected_languages;

                                      if (selected_specialization.length == 0) {
                                        setState(() {
                                          speciality_validate = false;
                                        });
                                      } else if (postParams['email'].isEmpty) {
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
                                                      if (is_editable_email == false) {
                                                        postParams.remove('email');
                                                      }

                                                      if (is_editable_mobile == false) {
                                                        postParams.remove('mobilenumber');
                                                      }
                                                      await model.registerUser(postParams);
                                                      Loader.hide();
                                                      setState(() {
                                                        Navigator.pop(context);
                                                        Get.back();
                                                      });
                                                    },
                                                  ),
                                                ],
                                              );
                                            });
                                      } else {
                                        print(postParams);
                                        Loader.show(context);
                                        if (is_editable_email == false) {
                                          postParams.remove('email');
                                        }

                                        if (is_editable_mobile == false) {
                                          postParams.remove('mobilenumber');
                                        }
                                        await model.registerUser(postParams);
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
                                        } else if (model.res == "mobilenumber already exist") {
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
                                          setState(() {});
                                          return;
                                        }
                                        Get.back(result: {'refresh': true});
                                        setState(() {
                                          isAutoValidate = true;
                                        });
                                      }
                                    } else {
                                      if (selected_specialization.length == 0) {
                                        setState(() {
                                          speciality_validate = false;
                                        });
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
          viewModelBuilder: () => DoctorPersonalinfoViewModel()),
    );
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

  Future<void> getpick(
    BuildContext context,
    DoctorPersonalinfoViewModel model,
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

  Future<void> getcapture(BuildContext context, DoctorPersonalinfoViewModel model, FileType fileType) async {
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
}

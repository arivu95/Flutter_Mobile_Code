import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/health_provider_signup_viewmodel.dart';

class HealthProviderView extends StatefulWidget {
  HealthProviderView({Key? key}) : super(key: key);

  @override
  _HealthProviderViewState createState() => _HealthProviderViewState();
}

class _HealthProviderViewState extends State<HealthProviderView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  PreferencesService preferencesService = locator<PreferencesService>();
  NavigationService navigationService = locator<NavigationService>();
  bool isAutoValidate = false;
  String email = '';
  String phone = '';
  final picker = ImagePicker();
  String localPath = '';
  String network_img_url = '';

  @override
  void initState() {
    super.initState();
    print(preferencesService.phone);
    setState(() {
      email = preferencesService.email;
      phone = preferencesService.phone;
    });
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
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: FormBuilder(
          initialValue: {'email': email, 'mobilenumber': phone, 'lastname': '', 'middlename': ''},
          autovalidateMode: isAutoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          key: _fbKey,
          child: Column(
            children: [
              FormBuilderTextField(
                style: loginInputTitleStyle,
                name: 'name',
                autocorrect: false,
                onChanged: (value) {
                  print(value);
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  prefixIcon: Icon(
                    Icons.person,
                    color: activeColor,
                  ),
                  hintText: 'First Name',
                  hintStyle: loginInputHintTitleStyle,
                  filled: true,
                  fillColor: Colors.white70,
                  enabledBorder: UIHelper.getInputBorder(1),
                  focusedBorder: UIHelper.getInputBorder(1),
                  focusedErrorBorder: UIHelper.getInputBorder(1),
                  errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(context),
                  FormBuilderValidators.max(context, 20),
                ]),
                keyboardType: TextInputType.text,
              ),
              UIHelper.verticalSpaceSmall,
              FormBuilderTextField(
                style: loginInputTitleStyle,
                name: 'middlename',
                autocorrect: false,
                onChanged: (value) {
                  print(value);
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  prefixIcon: Icon(
                    Icons.person,
                    color: activeColor,
                  ),
                  hintText: 'Middle Name',
                  hintStyle: loginInputHintTitleStyle,
                  filled: true,
                  fillColor: Colors.white70,
                  enabledBorder: UIHelper.getInputBorder(1),
                  focusedBorder: UIHelper.getInputBorder(1),
                  focusedErrorBorder: UIHelper.getInputBorder(1),
                  errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                ),
              ),
              UIHelper.verticalSpaceSmall,
              FormBuilderTextField(
                style: loginInputTitleStyle,
                name: 'lastname',
                autocorrect: false,
                onChanged: (value) {
                  print(value);
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  prefixIcon: Icon(
                    Icons.person,
                    color: activeColor,
                  ),
                  hintText: 'Last Name',
                  hintStyle: loginInputHintTitleStyle,
                  filled: true,
                  fillColor: Colors.white70,
                  enabledBorder: UIHelper.getInputBorder(1),
                  focusedBorder: UIHelper.getInputBorder(1),
                  focusedErrorBorder: UIHelper.getInputBorder(1),
                  errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                ),
              ),
              UIHelper.verticalSpaceSmall,
              FormBuilderTextField(
                style: loginInputTitleStyle,
                name: 'email',
                autocorrect: false,
                readOnly: isemailEnabled ? true : false,
                onChanged: (value) {
                  print(value);
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  prefixIcon: Icon(
                    Icons.email,
                    color: activeColor,
                  ),
                  hintText: 'Email Id',
                  hintStyle: loginInputHintTitleStyle,
                  filled: true,
                  fillColor: Colors.white70,
                  enabledBorder: UIHelper.getInputBorder(1),
                  focusedBorder: UIHelper.getInputBorder(1),
                  focusedErrorBorder: UIHelper.getInputBorder(1),
                  errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(context),
                  FormBuilderValidators.email(context),
                ]),
              ),
              UIHelper.verticalSpaceSmall,
              FormBuilderDropdown(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  prefixIcon: Icon(
                    Icons.person_outlined,
                    color: activeColor,
                  ),
                  filled: true,
                  fillColor: Colors.white70,
                  enabledBorder: UIHelper.getInputBorder(1),
                  focusedBorder: UIHelper.getInputBorder(1),
                  focusedErrorBorder: UIHelper.getInputBorder(1),
                  errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                ),
                name: "specialization",
                hint: Text('Specialization'),
                items: ['Cardiology', 'pediatrics', 'Dermatology', 'Respiratory', 'Orthopedic', 'General physician', 'Nephrologist', 'General Surgeon', 'Plastic Surgeon', 'Neuro Surgeon', 'Ayurveda', 'Covid - 19']
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text("$cat").textColor(Colors.black).fontSize(16),
                        ))
                    .toList(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(context),
                ]),
              ),
              UIHelper.verticalSpaceSmall,
              FormBuilderDropdown(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  prefixIcon: Icon(
                    Icons.person_outlined,
                    color: activeColor,
                  ),
                  filled: true,
                  fillColor: Colors.white70,
                  enabledBorder: UIHelper.getInputBorder(1),
                  focusedBorder: UIHelper.getInputBorder(1),
                  focusedErrorBorder: UIHelper.getInputBorder(1),
                  errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                ),
                name: "gender",
                hint: Text('Gender'),
                items: ['Male', 'Female']
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text("$cat").textColor(Colors.black).fontSize(16),
                        ))
                    .toList(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(context),
                ]),
              ),
              UIHelper.verticalSpaceSmall,
              FormBuilderTextField(
                style: loginInputTitleStyle,
                name: 'mobilenumber',
                autocorrect: false,
                onChanged: (value) {
                  print(value);
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  prefixIcon: Icon(
                    Icons.phone_android_outlined,
                    color: activeColor,
                  ),
                  hintText: 'Mobile Number',
                  hintStyle: loginInputHintTitleStyle,
                  filled: true,
                  fillColor: Colors.white70,
                  enabledBorder: UIHelper.getInputBorder(1),
                  focusedBorder: UIHelper.getInputBorder(1),
                  focusedErrorBorder: UIHelper.getInputBorder(1),
                  errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(context),
                  FormBuilderValidators.minLength(context, 7),
                  FormBuilderValidators.maxLength(context, 10),
                  FormBuilderValidators.numeric(context),
                ]),
                keyboardType: TextInputType.number,
              ),
              UIHelper.verticalSpaceSmall,
              FormBuilderTextField(
                style: loginInputTitleStyle,
                name: 'city',
                autocorrect: false,
                onChanged: (value) {
                  print(value);
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
                  prefixIcon: Icon(
                    Icons.add_location,
                    color: activeColor,
                  ),
                  hintText: 'City',
                  hintStyle: loginInputHintTitleStyle,
                  filled: true,
                  fillColor: Colors.white70,
                  enabledBorder: UIHelper.getInputBorder(1),
                  focusedBorder: UIHelper.getInputBorder(1),
                  focusedErrorBorder: UIHelper.getInputBorder(1),
                  errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                ),
              ),
              UIHelper.verticalSpaceMedium,
              ViewModelBuilder<HealthProviderViewmodel>.reactive(
                  builder: (context, model, child) {
                    return model.isBusy
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              if (_fbKey.currentState!.saveAndValidate()) {
                                String oid = await preferencesService.getUserInfo('oid');
                                print(_fbKey.currentState!.value);
                                print('888888888');
                                Map<String, dynamic> postParams = Map.from(_fbKey.currentState!.value);
                                postParams['object_id'] = oid;
                                postParams['dateofbirth'] = "05-22-1995";
                                postParams['age'] = "22";
                                navigationService.clearStackAndShow(RoutePaths.docOnboard);
                                setState(() {
                                  isAutoValidate = true;
                                });
                              }
                            },
                            child: Text('Create').bold(),
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(Size(160, 36)),
                              backgroundColor: MaterialStateProperty.all(activeColor),
                            ));
                  },
                  viewModelBuilder: () => HealthProviderViewmodel()),
            ],
          )),
    );
  }

  Future getImage(String type, FileType fileType) async {
    String path = '';

    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
    if (pickedFile != null) {
      path = pickedFile.path;
      setState(() {
        localPath = path;
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
      backgroundColor: subtleColor,
      body: Container(
        width: Screen.width(context),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 0, 0),
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                    ),
                    Text('Profile').bold(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 72,
                    ),
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
                                decoration: UIHelper.roundedBorderWithColor(36, activeColor),
                                child: Icon(Icons.camera_alt, size: 30, color: Colors.white),
                              ),
                      ),
                    ),
                    UIHelper.verticalSpaceMedium,
                    formControls(context)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

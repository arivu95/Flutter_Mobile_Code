import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_profile_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:user_module/src/ui/user_profile/edit_profile_viewmodel.dart';

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
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  bool isAutoValidate = false;
  final picker = ImagePicker();
  String localPath = '';
  String network_img_url = '';
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);

  PickResult? selectedPlace;

  @override
  void initState() {
    super.initState();
    setState(() {
      // if (widget.userinfo['img_url'] != null) {
      //   network_img_url = widget.userinfo['img_url'];
      // }

      if (widget.userinfo['azureBlobStorageLink'] != null) {
        network_img_url = '${ApiService.fileStorageEndPoint}${widget.userinfo['azureBlobStorageLink']}';
      }
      if (widget.userinfo['age'] != null) {
        ageController.text = widget.userinfo['age'].toString();
      }
      if (widget.userinfo['address'] != null) {
        addressController.text = widget.userinfo['address'].toString();
      }
      if (widget.userinfo['country'] != null) {
        countryController.text = widget.userinfo['country'].toString();
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
    });
  }

  Widget addInputFormControl(String nameField, String hintText, IconData iconData) {
    bool isEnabled = false;
    if (nameField == 'mobile' || nameField == 'email') {
      isEnabled = true;
    }
    return FormBuilderTextField(
      readOnly: nameField == 'age' || nameField == 'email' || nameField == 'mobile' ? true : false,
      controller: nameField == 'age'
          ? ageController
          : nameField == 'state'
              ? stateController
              : nameField == 'country'
                  ? countryController
                  : nameField == 'city'
                      ? cityController
                      : nameField == 'zipcode'
                          ? zipController
                          : nameField == 'status'
                              ? statusController
                              : null,
      style: loginInputTitleStyle,
      name: nameField,
      autocorrect: false,
      onChanged: (value) {
        print(value);
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 20),
        prefixIcon: Icon(
          iconData,
          color: activeColor,
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
      keyboardType: nameField == 'alternatemobilenumber' || nameField == 'mobile' || nameField == 'emergency_doctor_number' || nameField == 'emergency_clinic_number' || nameField == 'zipcode'
          ? TextInputType.number
          : TextInputType.text,
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

  Widget formControls(BuildContext context) {
    Jiffy dob = Jiffy(widget.userinfo['dateofbirth']);
    String allergic = '';
    if (widget.userinfo['allergicto'] != null) {
      List al = widget.userinfo['allergicto'];
      allergic = al.join(', ');
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
        padding: EdgeInsets.all(12),
        width: Screen.width(context),
        decoration: UIHelper.roundedBorderWithColor(8, subtleColor, borderColor: Color(0xFFE2E2E2)),
        child: FormBuilder(
            initialValue: {
              'name': widget.userinfo['name'] ?? '',
              'middlename': widget.userinfo['middlename'] ?? '',
              'lastname': widget.userinfo['lastname'] ?? '',
              'email': widget.userinfo['email'] ?? '',
              'dateofbirth': dob.dateTime,
              'gender': widget.userinfo['gender'] ?? null,
              'mobile': widget.userinfo['mobilenumber'] ?? '',
              'alternatemobilenumber': widget.userinfo['alternatemobilenumber'] ?? '',
              'emergency_doctor_number': widget.userinfo['emergency_doctor_number'] ?? '',
              'emergency_clinic_number': widget.userinfo['emergency_clinic_number'] ?? '',
              'profilestatus': widget.userinfo['profilestatus'] ?? '',
              'bloodgroup': widget.userinfo['bloodgroup'] ?? null,
              'address': widget.userinfo['address'] ?? '',
              'country': widget.userinfo['country'] ?? '',
              'state': widget.userinfo['state'] ?? '',
              'city': widget.userinfo['city'] ?? '',
              'zipcode': widget.userinfo['zipcode'] ?? '',
              'age': widget.userinfo['age'] != null ? widget.userinfo['age'].toString() : '',
              'allergicto': allergic,
            },
            autovalidateMode: isAutoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            key: _fbKey,
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                addInputFormControl('name', 'First Name', Icons.person),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('middlename', 'Middle Name', Icons.person),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('lastname', 'Last Name', Icons.person),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('email', 'Email Id', Icons.email),
                UIHelper.verticalSpaceSmall,
                Theme(
                  data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                    primary: activeColor, //constant Color(0xFF16A5A6)
                  )),
                  child: FormBuilderDateTimePicker(
                      name: "dateofbirth",
                      lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                      inputType: InputType.date,
                      format: DateFormat("dd/MM/yyyy"),
                      onChanged: (DateTime? value) {
                        print(value);
                        Jiffy newDate = Jiffy(value);
                        final diff = Jiffy().diff(newDate, Units.YEAR);
                        print(diff);
                        if (diff > 0) {
                          ageController.text = diff.toString();
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 20),
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: activeColor,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: UIHelper.getInputBorder(1),
                        focusedBorder: UIHelper.getInputBorder(1),
                        focusedErrorBorder: UIHelper.getInputBorder(1),
                        errorBorder: UIHelper.getInputBorder(1),
                        hintText: "Date of Birth",
                      )),
                ),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('age', 'Age', Icons.person_outline),
                UIHelper.verticalSpaceSmall,
                FormBuilderDropdown(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 20),
                    prefixIcon: Icon(
                      Icons.person_outlined,
                      color: activeColor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: UIHelper.getInputBorder(1),
                    focusedBorder: UIHelper.getInputBorder(1),
                    focusedErrorBorder: UIHelper.getInputBorder(1),
                    errorBorder: UIHelper.getInputBorder(1),
                  ),
                  name: "gender",
                  hint: Text('Gender'),
                  //key: UniqueKey(),
                  items: ['Male', 'Female']
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text("$cat").textColor(Colors.black).fontSize(16),
                          ))
                      .toList(),
                ),
                UIHelper.verticalSpaceSmall,
                FormBuilderDropdown(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 20),
                    prefixIcon: Image.asset(
                      'assets/mbgroup.png',
                      height: 24,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: UIHelper.getInputBorder(1),
                    focusedBorder: UIHelper.getInputBorder(1),
                    focusedErrorBorder: UIHelper.getInputBorder(1),
                    errorBorder: UIHelper.getInputBorder(1),
                  ),
                  name: "bloodgroup",
                  hint: Text('BloodGroup'),
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map((grp) => DropdownMenuItem(
                            value: grp,
                            child: Text("$grp").textColor(Colors.black).fontSize(16),
                          ))
                      .toList(),
                ),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('allergicto', 'Allergies', Icons.drag_handle),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('mobile', 'Mobile Number', Icons.phone_android_outlined),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('alternatemobilenumber', 'Alternate Number', Icons.phone_android_outlined),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('emergency_doctor_number', 'Doctor Number', Icons.phone_android_outlined),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('emergency_clinic_number', 'Clinic Number', Icons.phone_android_outlined),
                UIHelper.verticalSpaceSmall,
                FormBuilderTextField(
                  style: loginInputTitleStyle,
                  name: "address",
                  autocorrect: false,
                  controller: addressController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 20),
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: activeColor,
                    ),
                    suffixIcon: GestureDetector(
                      child: Icon(
                        Icons.search,
                        color: activeColor,
                      ),
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return PlacePicker(
                                apiKey: APIKeys,
                                initialPosition: _EditProfileViewState.kInitialPosition,
                                useCurrentLocation: true,
                                selectInitialPosition: true,
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
                                    int le = vals.split(",").length;
                                    String addrs = vals.split(",")[0] + "," + vals.split(",")[1];
                                    addressController.text = addrs;
                                    getzip = vals.split(",")[le - 2];
                                    countryController.text = vals.split(",")[le - 1];
                                    getstate = getzip.replaceAll(RegExp(r'[0-9]'), '');
                                    stateController.text = getstate;
                                    cityController.text = vals.split(",")[le - 3];
                                    zipController.text = getzip.replaceAll(RegExp('[^0-9]'), '');
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
                UIHelper.verticalSpaceSmall,
                addInputFormControl('country', 'Country', Icons.language),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('state', 'State', Icons.location_city),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('city', 'City', Icons.location_city),
                UIHelper.verticalSpaceSmall,
                addInputFormControl('zipcode', 'ZIP', Icons.location_city),
                UIHelper.verticalSpaceMedium,
                ViewModelBuilder<EditProfileViewmodel>.reactive(
                    builder: (context, model, child) {
                      return Row(
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
                                _fbKey.currentState!.save();
                                print(_fbKey.currentState!.value);
                                Map<String, dynamic> userInfo = Map.from(_fbKey.currentState!.value);
                                userInfo.removeWhere((key, value) => key == null || value == null);
                                String mobile = userInfo['mobile'];
                                String alternumber = userInfo['alternatemobilenumber'];
                                String dctrnumbr = userInfo['emergency_doctor_number'];
                                String clinicnumbr = userInfo['emergency_clinic_number'];
                                String alergc = userInfo['allergicto'];
                                // userInfo['connectycube_id']=preferencesService.userInfo['connectycube_id'];
                                final alergicvalidate = RegExp(r'^[a-zA-Z0-9]+$');
                                final validCharacters = RegExp(r'^[0-9]+$');
                                if (alternumber.isNotEmpty) {
                                  if (alternumber.length < 10 || alternumber.length > 12 || !validCharacters.hasMatch(alternumber)) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Alert !",
                                            descriptions: "Invalid Mobile Number. Enter a valid mobile number",
                                            descriptions1: "",
                                            text: "OK",
                                          );
                                        });
                                    return;
                                  } else if (mobile == (alternumber)) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Alert !",
                                            descriptions: "Mobile Number should not be equal to Alternate Mobile Number",
                                            descriptions1: "",
                                            text: "OK",
                                          );
                                        });
                                    return;
                                  }
                                }

                                //doctor number
                                if (dctrnumbr.isNotEmpty) {
                                  if (dctrnumbr.length < 10 || dctrnumbr.length > 12 || !validCharacters.hasMatch(dctrnumbr)) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Alert !",
                                            descriptions: "Invalid Mobile Number. Enter a valid mobile number",
                                            descriptions1: "",
                                            text: "OK",
                                          );
                                        });
                                    return;
                                  }
                                }

                                //clinicnumbr number
                                if (clinicnumbr.isNotEmpty) {
                                  if (clinicnumbr.length < 10 || clinicnumbr.length > 12 || !validCharacters.hasMatch(clinicnumbr)) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Alert !",
                                            descriptions: "Invalid Mobile Number. Enter a valid mobile number",
                                            descriptions1: "",
                                            text: "OK",
                                          );
                                        });
                                    return;
                                  } else if (dctrnumbr == (clinicnumbr)) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Alert !",
                                            descriptions: "Please Provide unique docotor and Clinic number",
                                            descriptions1: "",
                                            text: "OK",
                                          );
                                        });
                                    return;
                                  }
                                }

                                if (!alergicvalidate.hasMatch(alergc) && alergc.isNotEmpty) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomDialogBox(
                                          title: "Alert !",
                                          descriptions: "Invalid details of allergicto",
                                          descriptions1: "",
                                          text: "OK",
                                        );
                                      });
                                  return;
                                }

                                Jiffy newDate = Jiffy(userInfo['dateofbirth']);
                                userInfo['dateofbirth'] = newDate.format('MM/dd/yyyy');
                                Loader.show(context);
                                await model.updateUserProfile(userInfo, localPath,'');
                                Loader.hide();
                                Get.back(result: {'refresh': true});
                              },
                              child: Text('SAVE'),
                              style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(80, 32)),
                                  backgroundColor: MaterialStateProperty.all(Colors.green),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                        ],
                      );
                    },
                    viewModelBuilder: () => EditProfileViewmodel())
              ],
            )),
      ),
    );
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
          child: Column(
            children: [
              UIHelper.commonTopBar('Profile'),
              Expanded(
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          formControls(context),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          showFilePickerSheet('type');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30.0),
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
                                            Icons.camera_alt,
                                            size: 30,
                                            color: Colors.black38,
                                          ),
                                          width: 60,
                                          height: 60,
                                        )
                                      : UIHelper.getImage(network_img_url, 60, 60),
                            ),
                            SizedBox(
                              width: 40,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

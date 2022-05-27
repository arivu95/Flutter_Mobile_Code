import 'package:doctor_module/src/ui/doctor_profile/doctor_clinicinfo_viewmodel.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_medical_registration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_profile_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:stacked_services/stacked_services.dart';
import 'package:extended_image/extended_image.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:filesize/filesize.dart';

class DoctorClinicView extends StatefulWidget {
  String doc_id;
  bool isEditMode;
  dynamic clinic_data;

  DoctorClinicView({
    Key? key,
    required this.isEditMode,
    required this.doc_id,
    this.clinic_data,
  }) : super(key: key);

  @override
  _DoctorClinicViewState createState() => _DoctorClinicViewState();
}

const APIKeys = "AIzaSyA_76M-Sca9mXdpkJKVHSeUkFRgvvQ3icI";

class _DoctorClinicViewState extends State<DoctorClinicView> {
  PreferencesService preferencesService = locator<PreferencesService>();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  TextEditingController fileController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  // TextEditingController clinicName = TextEditingController();
  String isvideo = '';
  final picker = ImagePicker();
  bool clinic_privacy = false;
  List<String> upload_files = [];
  List<String> clinic_images = [];
  List clinic_Ref_images = [];
  PickResult? selectedPlace;
  bool btnEnable = false;
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);
  void initState() {
    super.initState();
    setState(() {
      if (widget.isEditMode) {
        if (widget.clinic_data['clinic_privacy'] == "true") {
          clinic_privacy = true;
        }
        if (widget.clinic_data['clinic_images'] != null) {
          if (widget.clinic_data['clinic_images'].length > 0) {
            List clinicPaths = widget.clinic_data['clinic_images'];

            for (var i = 0; i < clinicPaths.length; i++) {
              String filename = '${ApiService.fileStorageEndPoint}${widget.clinic_data['clinic_images'][i].toString()}';
              clinic_Ref_images.add(filename);
            }
          }
        }
        addressController.text = widget.clinic_data['address'];
        if (widget.clinic_data['id_proof_file'] != null) {
          if (widget.clinic_data['id_proof_file'].length > 0) {
            fileController.text = '${ApiService.fileStorageEndPoint}${widget.clinic_data['id_proof_file'][0].toString()}';
          }
        }
      }
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context, DoctorClinicViewModel model) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you Want to Delete ?'),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Ok'),
                onPressed: () async {
                  await model.deleteClinicDetails(widget.doc_id, widget.clinic_data['information_Id']);
                  setState(() {
                    Navigator.pop(context);
                    Get.back();
                  });
                },
              ),
            ],
          );
        });
  }

  Widget titleCard(BuildContext context, String title) {
    return Container(
        decoration: UIHelper.roundedBorderWithColor(10, Colors.white),
        width: Screen.width(context) / 3.3,
        height: 47,
        padding: EdgeInsets.only(left: 5, right: 2, top: 2, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title).fontSize(13).fontWeight(FontWeight.w500),
          ],
        ));
  }

  Widget addInputFieldControl(String controlName, String hintText, bool isNumberOnly) {
    return FormBuilderTextField(
      style: loginInputTitleStyle,
      name: controlName,
      textCapitalization: TextCapitalization.sentences,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autocorrect: false,
      onChanged: (value) {
        if (value!.length >= 1) {
          setState(() {
            btnEnable = true;
          });
        }
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
      inputFormatters: [
        controlName == 'clinic_name' ? new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")) : new FilteringTextInputFormatter.allow(RegExp("[0-9]")),
      ],
      validator: controlName == "phone_number"
          ? FormBuilderValidators.compose([
              FormBuilderValidators.minLength(context, 7, allowEmpty: true, errorText: "Invalid Number"),
              FormBuilderValidators.maxLength(context, 15, errorText: "Invalid Number"),
              FormBuilderValidators.numeric(context),
            ])
          : controlName == "clinic_registration_no"
              ? FormBuilderValidators.compose([
                  FormBuilderValidators.minLength(context, 5, allowEmpty: true, errorText: "Invalid Number"),
                  FormBuilderValidators.maxLength(context, 25, errorText: "Invalid Number"),
                  FormBuilderValidators.numeric(context),
                ])
              : FormBuilderValidators.compose([]),
      keyboardType: isNumberOnly ? TextInputType.phone : TextInputType.text,
    );
  }

  Future<void> getcapture(BuildContext context, DoctorClinicViewModel model, FileType fileType, String title) async {
    if (title == "documents") {
      upload_files.clear();
    }

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
              if (title == "documents") {
                upload_files.add(path);
                fileController.text = path;
              }
              if (title == "clinic_images") {
                clinic_images.add(path);
                clinic_Ref_images.add(path);
              }
              btnEnable = true;
            });
          }));
    }
  }

  Future<void> getpick(BuildContext context, DoctorClinicViewModel model) async {
    upload_files.clear();

    FilePickerResult result = (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx']))!;
    String path = result.files.single.path!;
    setState(() {
      if (path.toString().contains("mp4") || path.toString().contains("mp3")) {
      } else {
        upload_files.add(path);
        fileController.text = path;
        btnEnable = true;
      }
    });
    if (path.toString().contains("mp4") || path.toString().contains("mp3")) {
      setState(() {
        isvideo = "yes";
        fileController.text = "";
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

  Future<void> getmultiplepick(BuildContext context, DoctorClinicViewModel model) async {
    List<PlatformFile>? _paths;
    _paths = (await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: true, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx']))?.files;

    if (_paths!.length < 6) {
      for (int k = 0; k < _paths.length; k++) {
        if (_paths[k].path!.toString().contains("mp4") || _paths[k].path!.toString().contains("mp3")) {
          setState(() {
            isvideo = "yes";
            clinic_images.clear();
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
          setState(() {
            isvideo = "";
          });
          return;
        } else {
          setState(() {
            isvideo = "no";
          });
          String gt = filesize(_paths[k].size);
          double limitMb = 15.0;
          //check if  kb
          if (gt.contains('KB') || gt.contains('kb')) {
            limitMb = 120000.00;
          }
          String val = gt.replaceAll(RegExp("[a-zA-Z]"), "");
          val = val.trim();
          if (double.parse(val) <= limitMb) {
            //check limit 15mb ..
            clinic_images.insert(0, _paths[k].path!);
            clinic_Ref_images.insert(0, _paths[k].path!);
            btnEnable = true;
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialogBox(
                    title: "Not Allowed !",
                    descriptions: "File size cannot be uploaded greater than 15MB.",
                    descriptions1: "",
                    text: "OK",
                  );
                });
            setState(() {
              clinic_images.clear();
              isvideo = "";
            });
          }
        }
      }
      //for return to page, while choose video file
      if (isvideo == "yes") {
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
        setState(() {
          isvideo = "";
        });
      } else {}
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              title: "Not Allowed !",
              descriptions: "Files can be allowed within 5",
              descriptions1: "",
              text: "OK",
            );
          });
      setState(() {
        isvideo = "";
      });
    }
  }

  Widget recentItem(BuildContext context, String filePath) {
    String filename = filePath.split('/').last;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.file(
        File(filePath),
        fit: BoxFit.cover,
        height: 70,
        width: 70,
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

  Widget fileSelection(BuildContext context, DoctorClinicViewModel model, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
            onTap: () async {
              await getcapture(context, model, FileType.video, title);
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
              title == "documents" ? await getpick(context, model) : await getmultiplepick(context, model);
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
    );
  }

  Widget clinicInfoSection(BuildContext context, DoctorClinicViewModel model) {
    String fileUrl = fileController.text.split('/').last;
    String fileTrimurl = fileUrl.split('_').last;

    return Container(
        padding: EdgeInsets.all(10),
        decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Color(0xFFF5F3F3)),
        child: FormBuilder(
            key: _fbKey,
            initialValue: widget.isEditMode
                ? {
                    'clinic_name': widget.clinic_data['clinic_name'] ?? '',
                    'phone_number': widget.clinic_data['phone_number'] ?? '',
                    'address': widget.clinic_data['address'] ?? '',
                    'clinic_registration_no': widget.clinic_data['clinic_registration_no'] ?? '',
                  }
                : {},
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Clinic Name'),
                SizedBox(width: 5),
                Expanded(
                  child: Container(
                    child: addInputFieldControl('clinic_name', 'Clinic Name', false),
                  ),
                ),
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Address'),
                SizedBox(width: 5),
                Expanded(
                  child: Container(
                    child: FormBuilderTextField(
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
                                    initialPosition: _DoctorClinicViewState.kInitialPosition,
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
                                        btnEnable = true;
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
                  ),
                ),
              ]),
              UIHelper.verticalSpaceTiny,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Phone Number'),
                SizedBox(width: 5),
                Expanded(
                  child: Container(
                    child: addInputFieldControl('phone_number', 'Phone Number', true),
                  ),
                ),
              ]),
              UIHelper.verticalSpaceTiny,

              //Row(crossAxisAlignment: CrossAxisAlignment.start, children: [titleCard(context, 'State'), SizedBox(width: 5), Expanded(child: Container(child: addDropdownFieldControl('state', 'State', false, model)))]),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titleCard(context, 'Registration No.'),
                SizedBox(width: 5),
                Expanded(
                  child: Container(
                    child: addInputFieldControl('clinic_registration_no', 'Registration No.', true),
                  ),
                ),
              ]),

              UIHelper.verticalSpaceMedium,
              Text('Upload documents').fontWeight(FontWeight.w600),
              UIHelper.verticalSpaceMedium,
              fileSelection(context, model, "documents"),
              UIHelper.verticalSpaceMedium,
              fileController.text.isNotEmpty
                  ? Row(children: [
                      SizedBox(
                        width: 100,
                        child: recentItem(context, fileController.text),
                      ),
                      SizedBox(width: 10),
                      Flexible(child: Text(fileTrimurl))
                    ])
                  : SizedBox(),
              UIHelper.verticalSpaceMedium,
              Text('Clinic Photos').fontWeight(FontWeight.w600),
              UIHelper.verticalSpaceMedium,
              fileSelection(context, model, "clinic_images"),
              UIHelper.verticalSpaceMedium,

              ListView.builder(
                  shrinkWrap: true,
                  itemCount: clinic_Ref_images.length,
                  itemBuilder: (context, index) {
                    String clinicFileUrl = clinic_Ref_images[index].split('/').last;
                    String clinicFileTrimurl = clinicFileUrl.split('_').last;

                    return Column(
                      children: [
                        Row(children: [
                          SizedBox(
                            width: 100,
                            child: recentItem(context, clinic_Ref_images[index]),
                          ),
                          SizedBox(width: 10),
                          Flexible(child: Text(clinicFileTrimurl))
                        ]),
                        UIHelper.verticalSpaceSmall,
                      ],
                    );
                  }),

              UIHelper.verticalSpaceMedium,
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppDoctorBar(isProfileBar: true),
      backgroundColor: Colors.white,
      body: ViewModelBuilder<DoctorClinicViewModel>.reactive(
          onModelReady: (model) async {},
          builder: (context, model, child) {
            return SafeArea(
                top: false,
                child: Container(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      UIHelper.verticalSpaceSmall,
                      Row(
                        children: [
                          Expanded(
                            child: UIHelper.addHeader(context, "Profile", true),
                          ),
                          CustomSwitchWidget(
                            value: clinic_privacy,
                            onChanged: (value) {
                              clinic_privacy = value;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      UIHelper.verticalSpaceMedium,
                      Text('Clinic or hospital').fontWeight(FontWeight.w600),
                      UIHelper.verticalSpaceSmall,
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(children: [
                          clinicInfoSection(context, model),
                          UIHelper.verticalSpaceSmall,
                          widget.isEditMode
                              ? Center(
                                  child: GestureDetector(
                                    onTap: () async {
                                      await _displayTextInputDialog(context, model);
                                    },
                                    child: Text('Delete').fontWeight(FontWeight.w600),
                                  ),
                                )
                              : SizedBox(),
                          UIHelper.verticalSpaceSmall,
                        ]),
                      )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          btnEnable
                              ? ElevatedButton(
                                  onPressed: () async {
                                    if (_fbKey.currentState!.saveAndValidate()) {
                                      Map<String, dynamic> postParams = Map.from(_fbKey.currentState!.value);
                                      postParams['clinic_privacy'] = clinic_privacy;
                                      Loader.show(context);
                                      if (widget.isEditMode) {
                                        postParams['information_Id'] = widget.clinic_data['information_Id'];
                                        await model.updateDoctorClinicDetails(widget.doc_id, postParams, upload_files, clinic_images);
                                      } else {
                                        print(clinic_images.toString());
                                        await model.addClinicDetails(widget.doc_id, postParams, upload_files, clinic_images);
                                      }
                                      await locator<ApiService>().getProfile(preferencesService.userId);
                                      setState(() {});
                                      Loader.hide();
                                      //Get.back();
                                      Get.back(result: {'refresh': true});
                                    }
                                  },
                                  child: Text('Save').bold(),
                                  style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(Size(220, 36)),
                                    backgroundColor: MaterialStateProperty.all(Color(0xFF00C064)),
                                  ))
                              : ElevatedButton(
                                  onPressed: () async {},
                                  child: Text('Save').bold(),
                                  style: ButtonStyle(minimumSize: MaterialStateProperty.all(Size(220, 36)), backgroundColor: MaterialStateProperty.all(disablebtncolor)),
                                )
                        ],
                      ),
                      UIHelper.verticalSpaceMedium
                    ])));
          },
          viewModelBuilder: () => DoctorClinicViewModel()),
    );
  }
}

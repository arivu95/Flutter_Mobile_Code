import 'dart:io';
import 'dart:ui';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:doctor_module/src/ui/doc_onboarding/clinic_manage_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_about_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_achievementinfo_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_clinicinfo_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_education_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_experience_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_medical_registration_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_payment_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_personalinfo_view.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_profile_viewmodel.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_service_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:file_picker/file_picker.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_profile_bar.dart';
import 'package:swarapp/shared/dotted_line.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/pdf_viewer.dart';
import 'package:swarapp/shared/profileStage_widget_view.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:swarapp/shared/inappbrowser.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorProfileView extends StatefulWidget {
  dynamic doctor_data;
  DoctorProfileView({Key? key, this.doctor_data}) : super(key: key);

  @override
  _DoctorProfileViewState createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  TextEditingController _doctorFieldController = TextEditingController();
  TextEditingController _clinicFieldController = TextEditingController();
  ProfileViewmodel modelRef = ProfileViewmodel();
  Map<String, dynamic> userInfo = {};
  List<int> expandedIndexs = [];
  final MyInAppBrowser browser = new MyInAppBrowser();
  final picker = ImagePicker();
  String localPath = '';
  String network_img_url = '';
  var options = InAppBrowserClassOptions(
      crossPlatform: InAppBrowserOptions(hideUrlBar: false),
      inAppWebViewGroupOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              clearCache: true,
              useShouldInterceptAjaxRequest: true,
              useShouldOverrideUrlLoading: true,
              useShouldInterceptFetchRequest: true,
              javaScriptCanOpenWindowsAutomatically: true,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true)));

//personal data set
  List<Map<String, dynamic>> dataset = [
    {'about me': 'about'},
    {'Gender': 'gender', 'Date of Birth': 'dateofbirth', 'Languages Known': 'language_known', 'Uploaded document': 'doctor_certificate'},
    {'Email Id': 'email', 'Mobile': 'mobilenumber', 'Address': 'address', 'Country': 'country'},
  ];

  static get doctor_data => doctor_data;

  Widget ImageDialog(BuildContext context, String getImg) {
    String setImg = getImg;
    return Dialog(
        backgroundColor: Color.fromRGBO(105, 105, 105, 0.5),
        insetPadding: EdgeInsets.all(15),
        child: Container(
          child: Stack(
            children: [
              PinchZoom(
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

  Future<void> _displayTextInputDialog(BuildContext context, ProfileViewmodel model, String title, int type) async {
    TextEditingController _textFieldController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              ClipRRect(),
              UIHelper.horizontalSpaceSmall,
              Text(title),
            ],
          ),
          content: TextField(
            onChanged: (value) {},
            controller: _textFieldController,
            decoration: InputDecoration(
                hintText: type == 0
                    ? "Write something here..."
                    : type == 1
                        ? "Prefered Doctor number"
                        : "Prefered clinic number"),
          ),
          actions: <Widget>[
            FlatButton(
              color: Colors.red,
              textColor: Colors.white,
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              color: Colors.green,
              textColor: Colors.white,
              child: Text('OK'),
              onPressed: () async {
                if (_textFieldController.text.isNotEmpty) {
                  Navigator.pop(context);

                  print(_textFieldController.text);
                  model.addStatus(_textFieldController.text);
                  await model.getUserProfile(false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget docProfileTimeline(BuildContext context, ProfileViewmodel model) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 15,
        ),
        Expanded(
            child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 15, right: 25, top: 15),
              child: DottedLine(
                dashColor: Colors.red,
                lineThickness: 2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    model.stage_level == "Enhanced"
                        ? Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red), child: Icon(Icons.done, size: 20, color: Colors.white))
                        : Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
                    Text('Entry').fontWeight(FontWeight.w600)
                  ],
                ),
                Column(
                  children: [
                    model.stage_level == "Enhanced"
                        ? Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red), child: Icon(Icons.done, size: 20, color: Colors.white))
                        : Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
                    Text('Enhanced').fontWeight(FontWeight.w600)
                  ],
                ),
                Column(
                  children: [
                    model.stage_level == "verified"
                        ? Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red), child: Icon(Icons.done, size: 20, color: Colors.white))
                        : Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
                    Text('Verified').fontWeight(FontWeight.w600)
                  ],
                ),
                Column(
                  children: [Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text('SWAR Dr.').fontWeight(FontWeight.w600)],
                ),
              ],
            ),
          ],
        )),
        SizedBox(
          width: 15,
        ),
      ],
    );
  }

  void showFilePickerSheet(String type, ProfileViewmodel model) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        builder: (
          BuildContext context,
        ) {
          return Container(
            height: 210,
            child: ListView(
              children: [
                UIHelper.verticalSpaceSmall,
                model.img_url != ""
                    ? ListTile(
                        onTap: () async {
                          //Get.back();
                          // getImage(type, FileType.image);
                          String profileImg = model.img_url;
                          await showDialog(
                              context: context,
                              //https://swarstage.blob.core.windows.net/swardoctor/scaled_image_picker8539268485450644726_1621533729545.jpg
                              builder: (_) => ImageDialog(context, profileImg));
                        },
                        visualDensity: VisualDensity.compact,
                        //visualDensity: VisualDensity.standard,
                        // visualDensity:VisualDensity.comfortable,
                        title: Text('Preview'),
                      )
                    : Container(),
                model.img_url != "" ? UIHelper.hairLineWidget() : Container(),
                ListTile(
                  onTap: () async {
                    Get.back();
                    await getProfile(type, FileType.video, model);
                    // if (localPath.isNotEmpty) {
                    //   // model.profile_Info['profileimage'] = localPath;
                    //   model.img_url = '${ApiService.fileStorageEndPoint}${localPath}';
                    // }
                    // Loader.show(context);
                    // await model.updatePreferdNumber(userInfo, localPath);
                    // Loader.hide();
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Camera'),
                ),
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () async {
                    Get.back();
                    await getProfile(type, FileType.image, model);
                    // if (localPath.isNotEmpty) {
                    //   //model.profile_Info['profileimage'] = localPath;
                    //   model.img_url = '${ApiService.fileStorageEndPoint}${localPath}';
                    // }
                    // Loader.show(context);
                    // await model.updatePreferdNumber(userInfo, localPath);
                    // Loader.hide();
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

  Future getProfile(String type, FileType fileType, model) async {
    String path = '';
    Map<String, dynamic> doctorInfo = {};
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

      await model.updateProfile(localPath, doctorInfo);
      //  await model.updateMemberProfile(widget.memberId, model.profileInfo, localPath, cover_localPath);
      Loader.hide();
      print(path);

      print(path);
    }
  }

  Widget addHeader(BuildContext context, ProfileViewmodel model) {
    TextEditingController _textFieldController = TextEditingController();
    _doctorFieldController.text = model.profile_Info['emergency_doctor_number'] != null ? model.profile_Info['emergency_doctor_number'] : '';
    _clinicFieldController.text = model.profile_Info['emergency_clinic_number'] != null ? model.profile_Info['emergency_clinic_number'] : '';
    String special = '';
    if (model.profile_Info['specialization'] != null) {
      List al = model.profile_Info['specialization'];
      // special = al.join(', ');
      special = al.join('| ');
    }
    if (model.profile_Info['azureBlobStorageLink'] != null) {
      network_img_url = '${ApiService.fileStorageEndPoint}${model.profile_Info['azureBlobStorageLink']}';
      print("=================network image" + network_img_url.toString());
    }
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.all(12),
              width: Screen.width(context),
              // height: 100,
              decoration: UIHelper.roundedBorderWithColorWithShadow(8, subtleColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  model.profile_Info['swar_Id'] != "" && model.profile_Info['swar_Id'] != null
                      ? GestureDetector(
                          onTap: () async {
                            // final response = await Get.to(() => EditProfileView(userinfo: model.profile_Info, getwidgetType: ""));
                            // if (response != null) {
                            //   if (response['refresh'] == true) {
                            //     model.getUserProfile(true);
                            //     setState(() {});
                            //   }
                            // }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              UIHelper.horizontalSpaceLarge,
                              UIHelper.horizontalSpaceSmall,
                              Text('SWAR ID').textColor(activeColor).fontSize(14).fontWeight(FontWeight.w600),
                              SizedBox(
                                width: 5,
                              ),
                              Text(model.profile_Info['swar_Id']).textColor(Colors.black).fontSize(14).fontWeight(FontWeight.w600),
                            ],
                          ),
                        )
                      : Container(child: UIHelper.verticalSpaceMedium),
                  UIHelper.verticalSpaceMedium,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Text(model.profile_Info['name'] != null ? model.profile_Info['name'] : '').textColor(Colors.black).fontSize(15).fontWeight(FontWeight.w600),
                          // UIHelper.horizontalSpaceSmall,
                          // Row(
                          //   children: [for (var len in model.educational_list) Text(len != null ? len['qualification'] + ',' : '').fontSize(13)],
                          // )
                          Wrap(
                            direction: Axis.horizontal, //Vertical || Horizontal
                            children: <Widget>[
                              Text(model.profile_Info['name'] != null ? model.profile_Info['name'] : '').textColor(Colors.black).fontSize(15).fontWeight(FontWeight.w600),
                              UIHelper.horizontalSpaceSmall,
                              Row(
                                children: [for (var len in model.educational_list) Text(len != null || len != "" ? len['qualification'] + ',' : '').fontSize(13)],
                              )
                            ],
                          ),
                        ],
                      ),
                      UIHelper.verticalSpaceTiny,
                      model.profile_Info['specialization'] != null
                          ?
                          // Column(
                          //     crossAxisAlignment: CrossAxisAlignment.end,
                          //     children: [
                          //       Text(special != null ? special : '').fontSize(13),
                          //       // model.profile_Info['specialization'] != null ? model.profile_Info['specialization'] : '').textColor(Colors.black).fontSize(12),
                          //       Row(
                          //         children: [
                          //           Text(model.profile_Info['medical_practice'] != null && model.profile_Info['medical_practice'] != "" ? "- " + model.profile_Info['medical_practice'] : 'Allopathy')
                          //               .textColor(Colors.black)
                          //               .fontSize(12),
                          //         ],
                          //       ),
                          //     ],
                          //   )
                          // : Container(),
                          Wrap(direction: Axis.horizontal, //Vertical || Horizontal
                              children: <Widget>[
                                  Text(special != null ? special : '').fontSize(13).fontWeight(FontWeight.w300),
                                  Text(
                                    model.profile_Info['medical_practice'] != null && model.profile_Info['medical_practice'] != "" ? "- " + model.profile_Info['medical_practice'] : ' - Allopathy',
                                  ).textColor(Colors.black)
                                ])
                          : Container(),
                      UIHelper.horizontalSpaceSmall,
                      model.workExperience != '' ? Text(model.workExperience) : SizedBox(),

                      UIHelper.verticalSpaceTiny,
                      UIHelper.hairLineWidget(),
                      // UIHelper.verticalSpaceTiny,
                      // docProfileTimeline(context, model)
                      ProfileStageWidget(isContainer: false)
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Stack(children: [
              GestureDetector(
                // child: ClipRRect(
                //   borderRadius: BorderRadius.circular(30.0),
                //   child: localPath.isNotEmpty
                //       ? Image.file(
                //           File(localPath),
                //           width: 60,
                //           height: 60,
                //           fit: BoxFit.cover,
                //         )
                //       : model.img_url == ''
                //           ? Container(
                //               // color: transparentColor,
                //               child: Icon(
                //                 Icons.account_circle_rounded,
                //                 size: 60,
                //                 color: Colors.grey,
                //               ),
                //               width: 60,
                //               height: 60,
                //             )
                //           : UIHelper.getImage(model.img_url, 60, 60),
                // ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: localPath.isNotEmpty
                        ? Image.file(
                            File(localPath),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        :
                        //model.img_url == ''
                        network_img_url == ''
                            ? Container(
                                width: 72,
                                height: 72,
                                decoration: UIHelper.roundedBorderWithColor(36, camerabgColor),
                                child: Icon(Icons.camera_alt, size: 30, color: Colors.black38),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                child: UIHelper.getImage(network_img_url, 60, 60),
                              )),
                onTap: () async {
                  if (model.img_url != '' || localPath.isNotEmpty) {
                    String profileImg = model.img_url;
                    await showDialog(context: context, builder: (_) => ImageDialog(context, profileImg));
                  }
                },
              ),
              Positioned(
                  // left: 85,
                  // top: 135,
                  right: 0.0,
                  bottom: 0.0,
                  child: InkWell(
                    child: Icon(
                      Icons.photo_camera_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onTap: () {
                      showFilePickerSheet('type', model);
                      // removeConfirm(model, model.profileInfo);
                    },
                  )),
            ])),
      ],
    );
  }

  Widget getPersonalInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        children: [
          SizedBox(width: Screen.width(context) / 2.5, child: Text(title).fontSize(13)),
          Flexible(child: Text(value).fontSize(13)),
        ],
      ),
    );
  }

  Widget getPersonalInfoItem_Static(
    String title,
    String value,
    ProfileViewmodel model,
  ) {
    Jiffy dob_ = Jiffy(model.profile_Info['dateofbirth']);
    String dob = dob_.format('dd.MM.yyyy');

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: value == "language_known"
          ? Row(
              children: [
                SizedBox(width: Screen.width(context) / 2.5, child: Text(title).fontSize(13)),
                Flexible(
                    child: Wrap(children: [
                  for (var len in model.language_known)
                    Text(
                      len != null ? len + ',' : '',
                    ).fontSize(13)
                ]))
              ],
            )
          : Row(
              children: [
                SizedBox(width: Screen.width(context) / 2.5, child: Text(title).fontSize(13)),
                //Flexible(child: Text(model.profile_Info['$value'] != null ? model.profile_Info['$value'] : '').fontSize(13)),
                title == "Uploaded document"
                    ? model.profile_Info['doctor_certificate'] == null || model.profile_Info['doctor_certificate'] == ''
                        ? SizedBox()
                        : Flexible(
                            child: InkWell(
                            child: Container(
                                child: Text(
                              model.profile_Info['doctor_certificate'].toString().split('_').last,
                              style: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
                            ).bold()),
                            onTap: () async {
                              String imgUrl = '${ApiService.fileStorageEndPoint}${model.profile_Info['doctor_certificate'].toString()}';
                              print("-------------image url-------" + imgUrl);
                              (imgUrl.toLowerCase().contains('.pdf'))
                                  ? launch(
                                      'https://docs.google.com/viewer?url=$imgUrl',
                                      forceSafariVC: true,
                                      forceWebView: true,
                                      webOnlyWindowName: '_blank',
                                    )
                                  : (imgUrl.toLowerCase().contains('.docx')) || (imgUrl.toLowerCase().contains('.xxls')) || (imgUrl.toLowerCase().contains('.xls'))
                                      // ? await canLaunch(img_url)
                                      ?
                                      //
                                      launch(
                                          'https://docs.google.com/viewer?url=$imgUrl',
                                          forceSafariVC: true,
                                          forceWebView: true,
                                          webOnlyWindowName: '_blank',
                                        )
                                      //: throw 'Could not launch $img_url'
                                      : await showDialog(
                                          context: context,
                                          builder: (_) => ImageDialog(context, imgUrl),
                                        );
                              // (file_url.toLowerCase().contains('.pdf'))
                              //     ? await Get.to(
                              //         () => PdfViewr(url: img_url, file_name: file_url))
                              //     : (file_url.toLowerCase().contains('.docx')) ||
                              //             (file_url.toLowerCase().contains('.xls')) ||
                              //             (file_url.toLowerCase().contains('.xlsx'))
                              //         ? await showDialog(
                              //             context: context,
                              //             builder: (_) => ImagesDialog(context, file_url),
                              //           )
                              //         : null;
                            },
                          ))
                    : Container(
                        child: Flexible(
                            child: Text(model.profile_Info['$value'] != null
                                    ? value == "dateofbirth"
                                        ? dob
                                        : model.profile_Info['$value']
                                    : '')
                                .fontSize(13)),
                      )
              ],
            ),
    );
  }

  Widget fileViewerWidget(String title, String fileUrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        children: [
          SizedBox(width: Screen.width(context) / 2.5, child: Text(title).fontSize(13)),
          fileUrl == ''
              ? SizedBox()
              : Flexible(
                  child: InkWell(
                    child: Container(
                        width: 150,
                        child: Text(
                          fileUrl.toString().split('_').last,
                          style: TextStyle(decoration: TextDecoration.underline),
                        ).bold()),
                    onTap: () async {
                      String imgUrl = '${ApiService.fileStorageEndPoint}${fileUrl.toString()}';
                      (fileUrl.toLowerCase().contains('.pdf'))
                          ? await Get.to(() => PdfViewr(url: imgUrl, file_name: fileUrl))
                          : (fileUrl.toLowerCase().contains('.docx')) || (fileUrl.toLowerCase().contains('.xls')) || (fileUrl.toLowerCase().contains('.xlsx'))
                              ? launchExternalDoc('https://docs.google.com/viewer?url=$imgUrl&time=${DateTime.now()}')
                              : await showDialog(
                                  context: context,
                                  builder: (_) => ImagesDialog(context, fileUrl),
                                );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget getTitleWidget(String title, int index, ProfileViewmodel model, bool editOnly) {
    return Column(
      children: [
        UIHelper.verticalSpaceTiny,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
                onTap: () {
                  if (expandedIndexs.contains(index)) {
                    expandedIndexs.remove(index);
                  } else {
                    expandedIndexs.add(index);
                  }
                  setState(() {});
                },
                child: Container(
                  decoration: UIHelper.rightcornerRadiuswithColor(1, 1, fieldBgColor),
                  height: 20,
                  width: Screen.width(context) / 1.3,
                  child: Text(
                    title,
                  ).fontSize(13).fontWeight(FontWeight.w600),
                )),
            GestureDetector(
              onTap: () async {
                if (expandedIndexs.contains(index)) {
                  print('Already index here....');
                } else {
                  expandedIndexs.add(index);
                }
                switch (index) {
                  case 3:
                    await Get.to(() => DoctorMedicalRegistrationView(
                          isEditMode: false,
                          deleteMode: false,
                          doc_id: model.doctorDetails['_id'],
                        ));
                    model.getDoctorDetails();
                    //  setState(() {});
                    break;
                  case 4:
                    await Get.to(() => DoctorEducationView(
                          isEditMode: false,
                          deleteMode: false,
                          doc_id: model.doctorDetails['_id'],
                        ));
                    model.getDoctorDetails();
                    //setState(() {});
                    break;
                  case 5:
                    await Get.to(() => DoctorExperienceView(
                          isEditMode: false,
                          doc_id: model.doctorDetails['_id'],
                        ));
                    model.getDoctorDetails();
                    //setState(() {});
                    break;

                  case 6:
                    await Get.to(() => DoctorAchievementView(
                          isEditMode: false,
                          doc_id: model.doctorDetails['_id'],
                        ));
                    await model.getDoctorDetails();
                    // setState(() {});
                    break;
                  case 7:
                    await Get.to(() => DoctorClinicView(
                          isEditMode: false,
                          doc_id: model.doctorDetails['_id'],
                        ));
                    model.getDoctorDetails();
                    // setState(() {});
                    break;
                  default:
                }
              },
              child: editOnly
                  ? GestureDetector(
                      onTap: () {
                        if (expandedIndexs.contains(index)) {
                          expandedIndexs.remove(index);
                        } else {
                          expandedIndexs.add(index);
                        }
                        setState(() {});
                      },
                      child: Icon(
                        Icons.expand_more,
                        size: 20,
                      ))
                  : Icon(
                      Icons.add,
                      size: 20,
                    ),
            )
          ],
        ),
        UIHelper.verticalSpaceTiny,
        index == 0
            ? SizedBox()
            : index == 3
                ? medicalRegistrationWidget(index, model)
                : index == 4
                    ? educationalWidget(index, model)
                    : index == 5
                        ? experienceWidget(index, model)
                        : index == 6
                            ? achievementWidget(index, model)
                            : index == 7
                                ? clinicListWidget(index, model)
                                : index == 8
                                    ? getPaymentWidget(index, model)
                                    : index == 9
                                        ? getServiceList(index, model)
                                        : getGeneralTitle(index, model),
      ],
    );
  }

  Widget getPersonalTitle(int index, ProfileViewmodel model) {
    return expandedIndexs.contains(index)
        ? Column(
            children: [
              UIHelper.verticalSpaceSmall,
              SizedBox(
                width: Screen.width(context),
                child: Container(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                    decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.white),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(model.profile_Info['aboutme'] != null ? model.profile_Info['aboutme'] : '').fontSize(13),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                            onTap: () async {
                              await Get.to(() => DoctorAboutView(
                                    personal_data: model.profile_Info,
                                  ));
                              model.getUserProfile(false);
                            },
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: activeColor,
                            )),
                      ],
                    )),
              ),
              UIHelper.verticalSpaceSmall,
            ],
          )
        : SizedBox();
  }

  Widget getGeneralTitle(int index, ProfileViewmodel model) {
    Map<String, dynamic> data = dataset[index];
    return expandedIndexs.contains(index)
        ? Container(
            decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.white),
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Column(
                children: index > 2
                    ? data.entries.map((e) {
                        return getPersonalInfoItem(e.key, e.value);
                      }).toList()
                    : data.entries.map((e) {
                        return getPersonalInfoItem_Static(e.key, e.value, model);
                      }).toList(),
              )),
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                  onTap: () async {
                    await Get.to(() => DoctorPersonalInfoView());
                    model.getUserProfile(false);
                    //setState setState(() {});
                  },
                  child: Icon(
                    Icons.edit,
                    size: 16,
                    color: activeColor,
                  )),
            ]))
        : SizedBox();
  }

  // Widget personalWidget(int index, ProfileViewmodel model) {
  //   List<dynamic> personal_list = model.profile_Info;
  //   return expandedIndexs.contains(index)
  //       ? ListView.builder(
  //           shrinkWrap: true,
  //           physics: NeverScrollableScrollPhysics(),
  //           itemCount: personal_list.length,
  //           itemBuilder: (context, index) {
  //             String certificate = '';
  //             if (personal_list[index]['certificate'] != null) {
  //               if (educational_list[index]['certificate'].length > 0) {
  //                 certificate = educational_list[index]['certificate'][0];
  //               }
  //             }
  //             return Column(
  //               children: [
  //                 Container(
  //                     decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.white),
  //                     padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
  //                     child: Column(
  //                       children: [
  //                         Row(
  //                           children: [
  //                             Expanded(
  //                               child: getPersonalInfoItem('Level', educational_list[index]['level_of_graduation'] != null ? educational_list[index]['level_of_graduation'] : ''),
  //                             ),
  //                             GestureDetector(
  //                                 onTap: () async {
  //                                   await Get.to(() => DoctorEducationView(
  //                                         isEditMode: true,
  //                                         doc_id: model.doctorDetails['_id'],
  //                                         education_data: educational_list[index],
  //                                       ));
  //                                   model.getDoctorDetails();
  //                                 },
  //                                 child: Icon(
  //                                   Icons.edit,
  //                                   size: 16,
  //                                   color: activeColor,
  //                                 )),
  //                           ],
  //                         ),
  //                         getPersonalInfoItem('Degree', educational_list[index]['qualification'] != null ? educational_list[index]['qualification'] : ''),
  //                         getPersonalInfoItem('College Name', educational_list[index]['college_institute'] != null ? educational_list[index]['college_institute'] : ''),
  //                         getPersonalInfoItem('Country', educational_list[index]['country'] != null ? educational_list[index]['country'] : ''),
  //                         getPersonalInfoItem('Year of Completion', educational_list[index]['endyear'] != null ? educational_list[index]['endyear'] : ''),
  //                         fileViewerWidget('Uploaded document', certificate),
  //                       ],
  //                     )),
  //                 UIHelper.verticalSpaceSmall,
  //               ],
  //             );
  //           })
  //       : SizedBox();
  // }

  Widget educationalWidget(int index, ProfileViewmodel model) {
    List<dynamic> educationalList = model.educational_list;
    bool isdel = true;
    if (educationalList.length == 1) {
      isdel = false;
    }
    return expandedIndexs.contains(index)
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: educationalList.length,
            itemBuilder: (context, index) {
              String certificate = '';
              if (educationalList[index]['certificate'] != null) {
                if (educationalList[index]['certificate'].length > 0) {
                  certificate = educationalList[index]['certificate'][0];
                }
              }
              return Column(
                children: [
                  Container(
                      decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.white),
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: getPersonalInfoItem('Level', educationalList[index]['level_of_graduation'] != null ? educationalList[index]['level_of_graduation'] : ''),
                              ),
                              GestureDetector(
                                  onTap: () async {
                                    await Get.to(() => DoctorEducationView(
                                          isEditMode: true,
                                          deleteMode: isdel,
                                          doc_id: model.doctorDetails['_id'],
                                          education_data: educationalList[index],
                                        ));
                                    await model.getDoctorDetails();
                                    //setState(() {});
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: activeColor,
                                  )),
                            ],
                          ),
                          getPersonalInfoItem('Degree', educationalList[index]['qualification'] != null ? educationalList[index]['qualification'] : ''),
                          getPersonalInfoItem('Specialization', educationalList[index]['specializations'][0] != null ? educationalList[index]['specializations'][0] : ''),
                          getPersonalInfoItem('College / Institute', educationalList[index]['college_institute'] != null ? educationalList[index]['college_institute'] : ''),
                          getPersonalInfoItem('Country', educationalList[index]['country'] != null ? educationalList[index]['country'] : ''),
                          getPersonalInfoItem('End Year or expected', educationalList[index]['endyear'] != null ? educationalList[index]['endyear'] : ''),
                          fileViewerWidget('Uploaded document', certificate),
                        ],
                      )),
                  UIHelper.verticalSpaceSmall,
                ],
              );
            })
        : SizedBox();
  }

  Widget medicalRegistrationWidget(int index, ProfileViewmodel model) {
    List<dynamic> medicalList = model.medicalRegistration_list;
    bool isdel = true;
    if (medicalList.length == 1) {
      isdel = false;
    }
    return expandedIndexs.contains(index)
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: medicalList.length,
            itemBuilder: (context, index) {
              String certificate = '';
              String startDate = '';
              String endDate = '';
              String imgUrl = '';
              if (medicalList[index]['certificate'] != null) {
                if (medicalList[index]['certificate'].length > 0) {
                  certificate = medicalList[index]['certificate'][0];
                  imgUrl = '${ApiService.fileStorageEndPoint}${certificate.toString()}';
                }
              }

              if (medicalList[index]['issue_date'] != null && medicalList[index]['issue_date'] != "") {
                Jiffy dt = Jiffy(medicalList[index]['issue_date']);
                startDate = dt.format('MMM-yyyy');
              }
              if (medicalList[index]['renewal_date'] != null && medicalList[index]['renewal_date'] != "") {
                Jiffy dt = Jiffy(medicalList[index]['renewal_date']);
                endDate = dt.format('MMM-yyyy');
              }

              return Column(
                children: [
                  Container(
                      decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.white),
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: getPersonalInfoItem('Name', medicalList[index]['name'] != null ? medicalList[index]['name'] : ''),
                              ),
                              GestureDetector(
                                  onTap: () async {
                                    await Get.to(() => DoctorMedicalRegistrationView(
                                          isEditMode: true,
                                          deleteMode: isdel,
                                          doc_id: model.doctorDetails['_id'],
                                          registration_data: medicalList[index],
                                        ));
                                    await model.getDoctorDetails();
                                    //  setState(() {});
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: activeColor,
                                  )),
                            ],
                          ),
                          getPersonalInfoItem('Credential ID', medicalList[index]['credential_Id'] != null ? medicalList[index]['credential_Id'] : ''),
                          getPersonalInfoItem('Organization ', medicalList[index]['organization'] != null ? medicalList[index]['organization'] : ''),
                          getPersonalInfoItem('State', medicalList[index]['state'] != null ? medicalList[index]['state'] : ''),
                          getPersonalInfoItem('Country', medicalList[index]['country'] != null ? medicalList[index]['country'] : ''),
                          getPersonalInfoItem('Issue date', startDate),
                          getPersonalInfoItem('Expiration date', endDate),
                          getPersonalInfoItem('Credential URL', medicalList[index]['credential_url'] != null ? medicalList[index]['credential_url'] : ''),
                          fileViewerWidget('Uploaded document', certificate),
                        ],
                      )),
                  UIHelper.verticalSpaceSmall,
                ],
              );
            })
        : SizedBox();
  }

  Widget experienceWidget(int index, ProfileViewmodel model) {
    List<dynamic> ecperienceList = model.experience_list;

    return expandedIndexs.contains(index)
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: ecperienceList.length,
            itemBuilder: (context, index) {
              String certificate = '';
              String startYear = '';
              String endYear = '';
              String workExperience = '';
              if (ecperienceList[index]['certificate'] != null) {
                if (ecperienceList[index]['certificate'].length > 0) {
                  certificate = ecperienceList[index]['certificate'][0];
                }
              }

              if (ecperienceList[index]['startyear'] != null && ecperienceList[index]['startyear'] != "") {
                Jiffy dt = Jiffy(ecperienceList[index]['startyear']);
                startYear = dt.format('yyyy');
              }
              if (ecperienceList[index]['endyear'] != null && ecperienceList[index]['endyear'] != "") {
                Jiffy dt = Jiffy(ecperienceList[index]['endyear']);
                endYear = dt.format('yyyy');
              }

              if (ecperienceList[index]['work_experience'] != null && ecperienceList[index]['work_experience'] != "") {
                int experInt = int.parse(ecperienceList[index]['work_experience']);
                if (experInt < 12) {
                  workExperience = '$experInt  month';
                } else {
                  double exper = experInt / 12;
                  String workExperience = exper.toStringAsFixed(2).toString();
                  workExperience = '$workExperience year';
                }
              }
              return Column(
                children: [
                  Container(
                      decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.white),
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: getPersonalInfoItem('Title', ecperienceList[index]['title'] != null ? ecperienceList[index]['title'] : ''),
                              ),
                              GestureDetector(
                                  onTap: () async {
                                    await Get.to(() => DoctorExperienceView(
                                          isEditMode: true,
                                          doc_id: model.doctorDetails['_id'],
                                          experience_data: ecperienceList[index],
                                        ));
                                    await model.getDoctorDetails();
                                    //  setState(() {});
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: activeColor,
                                  )),
                            ],
                          ),
                          getPersonalInfoItem('Organization', ecperienceList[index]['organization'] != null ? ecperienceList[index]['organization'] : ''),
                          getPersonalInfoItem('Employment Type', ecperienceList[index]['employment_type'] != null ? ecperienceList[index]['employment_type'] : ''),
                          getPersonalInfoItem('Start year', startYear),
                          getPersonalInfoItem('End year', endYear),
                          getPersonalInfoItem('Experience', workExperience),
                          getPersonalInfoItem('Location', ecperienceList[index]['location'] != null ? ecperienceList[index]['location'] : ''),
                          fileViewerWidget('Uploaded document', certificate),
                        ],
                      )),
                  UIHelper.verticalSpaceSmall,
                ],
              );
            })
        : SizedBox();
  }

  Widget achievementWidget(int index, ProfileViewmodel model) {
    List<dynamic> achievementList = model.achievement_list;

    return expandedIndexs.contains(index)
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: achievementList.length,
            itemBuilder: (context, index) {
              String certificate = '';
              String startDate = '';
              String endDate = '';
              String imgUrl = '';
              if (achievementList[index]['certificate'] != null) {
                if (achievementList[index]['certificate'].length > 0) {
                  certificate = achievementList[index]['certificate'][0];
                  imgUrl = '${ApiService.fileStorageEndPoint}${certificate.toString()}';
                }
              }

              if (achievementList[index]['issue_date'] != null && achievementList[index]['issue_date'] != "") {
                Jiffy dt = Jiffy(achievementList[index]['issue_date']);
                startDate = dt.format('MMM-yyyy');
              }
              if (achievementList[index]['renewal_date'] != null && achievementList[index]['renewal_date'] != "") {
                Jiffy dt = Jiffy(achievementList[index]['renewal_date']);
                endDate = dt.format('MMM-yyyy');
              }

              return Column(
                children: [
                  Container(
                      decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.white),
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: getPersonalInfoItem('Name', achievementList[index]['name'] != null ? achievementList[index]['name'] : ''),
                              ),
                              GestureDetector(
                                  onTap: () async {
                                    await Get.to(() => DoctorAchievementView(
                                          isEditMode: true,
                                          doc_id: model.doctorDetails['_id'],
                                          achievement_data: achievementList[index],
                                        ));
                                    model.getDoctorDetails();
                                    // setState(() {});
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: activeColor,
                                  )),
                            ],
                          ),
                          getPersonalInfoItem('Credential ID', achievementList[index]['credential_Id'] != null ? achievementList[index]['credential_Id'] : ''),
                          getPersonalInfoItem('Organization ', achievementList[index]['organization'] != null ? achievementList[index]['organization'] : ''),
                          getPersonalInfoItem('Issue date', startDate),
                          getPersonalInfoItem('Expiration date', endDate),
                          getPersonalInfoItem('Credential URL', achievementList[index]['credential_url'] != null ? achievementList[index]['credential_url'] : ''),
                          fileViewerWidget('Uploaded document', certificate),
                        ],
                      )),
                  UIHelper.verticalSpaceSmall,
                ],
              );
            })
        : SizedBox();
  }

  Widget clinicListWidget(int index, ProfileViewmodel model) {
    List<dynamic> clinicList = model.clinic_list;

    return expandedIndexs.contains(index)
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: clinicList.length,
            itemBuilder: (context, index) {
              String certificate = '';
              String imgUrl = '';
              if (clinicList[index]['id_proof_file'] != null) {
                if (clinicList[index]['id_proof_file'].length > 0) {
                  certificate = clinicList[index]['id_proof_file'][0];
                }
              }

              if (clinicList[index]['clinic_images'] != null) {
                if (clinicList[index]['clinic_images'].length > 0) {
                  imgUrl = clinicList[index]['clinic_images'][0];
                }
              }

              return Column(
                children: [
                  Container(
                      decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.white),
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: getPersonalInfoItem('Clinic Name', clinicList[index]['clinic_name'] != null ? clinicList[index]['clinic_name'] : ''),
                              ),
                              GestureDetector(
                                  onTap: () async {
                                    await Get.to(() => DoctorClinicView(
                                          isEditMode: true,
                                          doc_id: model.doctorDetails['_id'],
                                          clinic_data: clinicList[index],
                                        ));
                                    model.getDoctorDetails();
                                    // setState(() {});
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: activeColor,
                                  )),
                            ],
                          ),
                          getPersonalInfoItem('Location', clinicList[index]['address'] != null ? clinicList[index]['address'] : ''),
                          getPersonalInfoItem('Phone Number', clinicList[index]['phone_number'] != null ? clinicList[index]['phone_number'] : ''),
                          getPersonalInfoItem('Registration No.', clinicList[index]['clinic_registration_no'] != null ? clinicList[index]['clinic_registration_no'] : ''),
                          fileViewerWidget('Uploaded document', certificate),
                          fileViewerWidget('Clinic Photo', imgUrl),
                        ],
                      )),
                  UIHelper.verticalSpaceSmall,
                ],
              );
            })
        : SizedBox();
  }

  Widget getPaymentWidget(int index, ProfileViewmodel model) {
    dynamic insuranceData = model.doctorDetails;

    String insuranceStr = '';
    String paymentStr = '';
    String isInsurance = 'No';
    if (insuranceData['insurance'] != null) {
      List al = insuranceData['insurance'];
      insuranceStr = al.join(', ');
    }

    if (insuranceData['payment'] != null) {
      List bl = insuranceData['payment'];
      paymentStr = bl.join(', ');
    }
    if (insuranceData['insurance_checkbox'] == "true") {
      isInsurance = "Yes";
    }

    return expandedIndexs.contains(index)
        ? Container(
            decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.white),
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(children: [
                  getPersonalInfoItem('Insurance', isInsurance),
                  getPersonalInfoItem('Insurance name', insuranceStr),
                  getPersonalInfoItem('Payment Methods', paymentStr),
                  getPersonalInfoItem('Bank name', insuranceData['bank_name'] != null ? insuranceData['bank_name'] : ''),
                  getPersonalInfoItem('Account No.', insuranceData['account_number'] != null ? insuranceData['account_number'] : ''),
                  getPersonalInfoItem('Ifsc Code ', insuranceData['ifsc_code'] != null ? insuranceData['ifsc_code'] : '')
                ])),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: () async {
                      await Get.to(() => DoctorPaymentView(
                            payment_data: model.doctorDetails,
                          ));
                      model.getDoctorDetails();
                      // setState(() {});
                    },
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: activeColor,
                    )),
              ],
            ))
        : SizedBox();
  }

  Widget getServiceList(int index, ProfileViewmodel model) {
    dynamic serviceList = model.profile_Info;
    String servisesStr = '';
    if (serviceList['doctor_services'] != null) {
      List al = serviceList['doctor_services'];
      servisesStr = al.join(', ');
    }
    return expandedIndexs.contains(index)
        ? Container(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: UIHelper.rightcornerRadiuswithColor(8, 8, Colors.white),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(servisesStr).fontSize(13),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: () async {
                      await Get.to(() => DoctorServicesView(
                            serviceInfo: model.profile_Info,
                          ));
                      model.getUserProfile(false);
                      // setState(() {});
                    },
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: activeColor,
                    )),
              ],
            ))
        : SizedBox();
  }

  Widget getPersonalInfoWidget(BuildContext context, ProfileViewmodel model) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
      width: Screen.width(context),
      decoration: UIHelper.roundedBorderWithColorWithShadow(8, subtleColor, borderColor: Color(0xFFE2E2E2)),
      child: Column(
        children: [
          getTitleWidget('About', 0, model, true),
          getPersonalTitle(0, model),
          UIHelper.hairLineWidget(),
          getTitleWidget('Personal', 1, model, true),
          UIHelper.hairLineWidget(),
          getTitleWidget('Contact', 2, model, true),
          UIHelper.hairLineWidget(),
          getTitleWidget('Registration/ License', 3, model, false),
          UIHelper.hairLineWidget(),
          getTitleWidget('Education', 4, model, false),
          UIHelper.hairLineWidget(),
          getTitleWidget('Experience', 5, model, false),
          UIHelper.hairLineWidget(),
          getTitleWidget('Achievement', 6, model, false),
          UIHelper.hairLineWidget(),
          getTitleWidget('Clinic or Hospital ', 7, model, false),
          UIHelper.hairLineWidget(),
          getTitleWidget('Payment ', 8, model, true),
          UIHelper.hairLineWidget(),
          getTitleWidget('Services', 9, model, true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SwarAppDoctorBar(isProfileBar: true),
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          child: Container(
              padding: EdgeInsets.only(left: 12, right: 12),
              child: ViewModelBuilder<ProfileViewmodel>.reactive(
                  onModelReady: (model) async {
                    modelRef = model;
                    model.getUserProfile(false);
                    await model.getDoctorDetails();
                  },
                  builder: (context, model, child) {
                    return model.isBusy
                        ? Center(
                            child: UIHelper.swarPreloader(),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                UIHelper.verticalSpaceSmall,
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Get.back(result: {'refresh': true});
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_back_outlined,
                                              size: 20,
                                            ),
                                            Text(' Profile').bold(),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          Loader.show(context);
                                          await model.download(model.doctorDetails['_id']);
                                          Loader.hide();
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title: "Download Complete",
                                                  descriptions: "File stored in download folder of your device",
                                                  descriptions1: "",
                                                  text: "OK",
                                                );
                                              });
                                        },
                                        child: Icon(
                                          Icons.file_download_outlined,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                UIHelper.verticalSpaceSmall,
                                addHeader(context, model),
                                UIHelper.verticalSpaceSmall,
                                getPersonalInfoWidget(context, model),
                                UIHelper.verticalSpaceSmall,
                              ],
                            ),
                          );
                  },
                  viewModelBuilder: () => ProfileViewmodel())),
        ));
  }

  void launchExternalDoc(String url) async {
    try {
      browser.openUrlRequest(urlRequest: URLRequest(url: Uri.parse(url)), options: options);
    } catch (e) {
      print('ExEXEXEX');

      print(e.toString());
    }
  }

  Widget ImagesDialog(BuildContext context, String getImg) {
    String setImg = '${ApiService.fileStorageEndPoint}$getImg';
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
}

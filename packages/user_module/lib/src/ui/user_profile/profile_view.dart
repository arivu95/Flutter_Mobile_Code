import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_profile_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:user_module/src/ui/user_profile/edit_profile_view.dart';
import 'package:user_module/src/ui/user_profile/profile_viewmodel.dart';
import 'package:documents_module/src/ui/uploads/uploads_view.dart';
import 'package:documents_module/src/ui/downloads/downloads_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swarapp/frideos/extended_asyncwidgets.dart';
import 'package:member_module/src/ui/members/view_member_view.dart';
import 'package:user_module/src/ui/user_profile/member_profile_view.dart';

class ProfileView extends StatefulWidget {
  ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

final picker = ImagePicker();
List<dynamic>? friends_stream;

Map<String, dynamic> userInfo = {};

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

Future<void> _displayTextInputDialog(BuildContext context, ProfileViewmodel model, String title, int type) async {
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
        actions: <Widget>[
          FlatButton(
            color: Colors.red,
            textColor: Colors.white,
            child: Text('CANCEL'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

class _ProfileViewState extends State<ProfileView> with AutomaticKeepAliveClientMixin {
  String dob = '';
  TextEditingController _doctorFieldController = TextEditingController();
  TextEditingController _clinicFieldController = TextEditingController();
  TextEditingController _profilestatusFieldController = TextEditingController();
  TextEditingController _doctorcountrycodeController = TextEditingController();
  final picker = ImagePicker();
  String localPath = '';
  String cover_localPath = '';
  String network_img_url = '';
  String cover_url = '';
  int memberIndex = 0;
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  Widget addHeader(BuildContext context, ProfileViewmodel model) {
    TextEditingController _textFieldController = TextEditingController();

    _doctorFieldController.text = model.profile_Info['emergency_doctor_number'] != null ? model.profile_Info['emergency_doctor_number'] : "";
    _clinicFieldController.text = model.profile_Info['emergency_clinic_number'] != null ? model.profile_Info['emergency_clinic_number'] : "";
    _profilestatusFieldController.text = model.profile_Info['profilestatus'] != null ? model.profile_Info['profilestatus'] : "";

    if (model.profile_Info['azureBlobStorageLink'] != null) {
      network_img_url = '${ApiService.fileStorageEndPoint}${model.profile_Info['azureBlobStorageLink']}';
    }

    if (model.profile_Info['coverimg_azureBlobStorageLink'] != null) {
      cover_url = '${ApiService.fileStorageEndPoint}${model.profile_Info['coverimg_azureBlobStorageLink']}';
    }
    return SizedBox(
      height: 225,
      child: Stack(
        children: [
          cover_localPath.isNotEmpty
              ? Image.file(
                  File(cover_localPath),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                )
              : cover_url == ''
                  ? Container(
                      color: subtleColor,
                      width: double.infinity,
                      height: 180,
                    )
                  : Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(cover_url), fit: BoxFit.cover)),
                    ),
          Positioned(
            top: 105,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 115),
              child: Column(
                children: [
                  Container(
                    width: 230,
                    height: 30,
                    child: FormBuilderTextField(
                      // readOnly: true,
                      style: TextStyle(color: Colors.black),
                      name: 'profilestatus',
                      autocorrect: false,
                      controller: _profilestatusFieldController,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) async {},
                      decoration: InputDecoration(
                        fillColor: statusColor,
                        filled: true,
                        contentPadding: EdgeInsets.only(left: 5),
                        hintText: 'Emergency medical notes',
                        // hintStyle: loginInputHintTitleStyle,
                        hintStyle: TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: disabledColor),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: UIHelper.getInputBorder(1),
                        focusedErrorBorder: UIHelper.getInputBorder(1),
                        errorBorder: UIHelper.getInputBorder(1),
                      ),
                      onEditingComplete: () async {
                        if (FocusScope.of(context).isFirstFocus) {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        }
                        if (_profilestatusFieldController.text.length > 50) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialogBox(
                                  title: "Alert !",
                                  descriptions: "Only 50 characters are allowed in Profile Status",
                                  descriptions1: "",
                                  text: "OK",
                                );
                              });
                          _profilestatusFieldController.clear();
                          return;
                        } else {
                          userInfo['profilestatus'] = _profilestatusFieldController.text;
                          model.updatePreferdNumber(userInfo, '', '');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Stack(
            children: [
              Positioned(
                top: 140,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    width: Screen.width(context) - 32,
                    decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white),
                    child: Column(
                      children: [
                        UIHelper.verticalSpaceTiny,
                        Row(
                          children: [
                            UIHelper.horizontalSpaceSmall,
                            // Text(' Keerthi').textColor(Colors.black87).bold().fontSize(17),
                            Text('${model.profile_Info['name']} ${model.profile_Info['lastname'] != null ? model.profile_Info['lastname'] : ""}').textColor(Colors.black87).bold().fontSize(17),
                          ],
                        ),
                        UIHelper.verticalSpaceSmall,
                        Row(children: [
                          UIHelper.horizontalSpaceSmall,
                          Text('SWAR ID').textColor(activeColor).bold(),
                          UIHelper.horizontalSpaceSmall,
                          model.profile_Info['swar_Id'] != null ? Text(model.profile_Info['swar_Id']).textColor(Colors.black).bold() : Text('').textColor(Colors.black),
                        ]),
                      ],
                    ),
                  ),
                ),
                // bottom: 10,
              ),
              Positioned(
                top: 85,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GestureDetector(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(250.0),
                      // width: 200,
                      child: localPath.isNotEmpty
                          ? Image.file(
                              File(localPath),
                              width: 70,
                              height: 70,
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
                                  width: 70,
                                  height: 70,
                                )
                              : UIHelper.getImage(network_img_url, 70, 70),
                    ),
                    onTap: () async {
                      // print('**IMG IS ***' + model.img_url);
                      if (model.img_url != "") {
                        String profile_img = model.img_url;
                        await showDialog(
                            context: context,
                            //https://swarstage.blob.core.windows.net/swardoctor/scaled_image_picker8539268485450644726_1621533729545.jpg
                            builder: (_) => ImageDialog(context, profile_img));
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                  left: 90,
                  top: 115,
                  child: InkWell(
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onTap: () {
                      showFilePickerSheet('type', model);
                      // removeConfirm(model, model.profileInfo);
                    },
                  )),
              Positioned(
                right: 10,
                top: 10,
                child: Row(
                  // button color
                  children: [
                    GestureDetector(
                      onTap: () async {
                        showBottomSheet('type', model);
                      },
                      child: Container(
                          padding: EdgeInsets.all(7),
                          alignment: Alignment.center,
                          decoration: UIHelper.roundedBorderWithColor(4, statusColor),
                          child: Row(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          )),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Get.to(() => EditProfileView(userinfo: model.profile_Info));
                        setState(() {});
                      },
                      child: Icon(
                        Icons.edit,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future getCoverImage(String type, FileType fileType, model) async {
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
              cover_localPath = path;
            });
          }));

      Loader.show(context);
      await model.updatePreferdNumber(userInfo, localPath, cover_localPath);
      Loader.hide();
      print(path);
    }
    ;
  }

  Future getImage(String type, FileType fileType, model) async {
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
      await model.updatePreferdNumber(userInfo, localPath, '');

      Loader.hide();
      print(path);
    }
  }

  //================Dropdown List==========
  Widget membersDropdownList(BuildContext context) {
    return StreamedWidget(
        stream: preferencesService.memebersListStream!.outStream!,
        builder: (context, snapshot) {
          List<dynamic> members = preferencesService.memebersListStream!.value!;
          return Row(
            children: [
              Text('Hi').fontSize(18).padding(left: 1, right: 1),
              UIHelper.horizontalSpaceSmall,
              members.length > 1
                  ? DropdownButton(
                      value: preferencesService.dropdown_user_id,
                      items: members.map((e) {
                        return new DropdownMenuItem(
                          value: e['_id'],
                          child: new Text(e['member_first_name']).fontSize(18).bold(),
                        );
                      }).toList(),
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          preferencesService.dropdown_user_id = value.toString();
                          locator<PreferencesService>().isReload.value = true;
                        });

                        int found = members.indexWhere((val) => val['_id'] == preferencesService.dropdown_user_id);
                        dropdown_member_id = preferencesService.dropdown_user_id;
                        preferencesService.dropdown_user_name = members[found]['member_first_name'];
                        preferencesService.dropdownuserName.value = members[found]['member_first_name'];
                        preferencesService.dropdown_user_dob = members[found]['date_of_birth'];
                        preferencesService.dropdown_user_age = members[found]['age'].toString();
                      })
                  : Text(members.length > 0 ? members[0]['member_first_name'].toString() : preferencesService.userInfo['name']).fontSize(18).bold()
            ],
          );
        });
  }

  Widget uploadRecord(BuildContext context, ProfileViewmodel model) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: EdgeInsets.all(12),
                width: Screen.width(context) - 32,
                decoration: UIHelper.roundedBorderWithColorWithShadow(8, peachColor),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: Text('Click below to upload and view health records', overflow: TextOverflow.ellipsis).fontSize(15).bold()),
                      ],
                    ),
                    UIHelper.verticalSpaceMedium,
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  String currenScreen = "";
                                  if (preferencesService.select_upload == 'upload') {
                                    preferencesService.user_login = '';
                                  } else {
                                    preferencesService.user_login = 'login';
                                  }
                                  preferencesService.select_upload = 'upload';
                                  // List<dynamic> members = preferencesService.memebersListStream!.value!;
                                  // preferencesService.dropdown_user_id = members[0]['_id'];
                                  // preferencesService.dropdown_user_name = members[0]['member_first_name'].toString();
                                  // preferencesService.dropdown_user_dob = members[0]['dateofbirth'] != null ? dob : '';
                                  // preferencesService.dropdown_user_age = members[0]['age'] != null ? members[0]['age'].toString() : '';
                                  await model.getRecentUploads();
                                  // // await Get.to(() => UploadsView());
                                  // Get.back();
                                  // final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                                  // navigationBar.onTap!(0);

                                  // currenScreen = Get.currentRoute.toString();
                                  // print("*********************" + currenScreen + "****************");
                                  // if (currenScreen != null || currenScreen.isNotEmpty) {
                                  //   Get.back();
                                  //   Get.back();
                                  //   if (Get.currentRoute.toString() != null || Get.currentRoute.toString().isNotEmpty) {
                                  //     Get.back();
                                  //     Get.back();
                                  //     Get.back();
                                  //   }
                                  //   final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                                  //   navigationBar.onTap!(0);
                                  // }
                                  await Get.to(() => UploadsView());
                                },
                                child: Row(
                                  children: [
                                    Text('Upload  ').textColor(Colors.black).bold(),
                                    Icon(
                                      Icons.cloud_upload,
                                      color: activeColor,
                                      size: 28,
                                    ),
                                  ],
                                ),
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(80, 45)),
                                  elevation: MaterialStateProperty.all(0),
                                  backgroundColor: MaterialStateProperty.all(Colors.white),
                                )),
                            UIHelper.horizontalSpaceSmall,
                            ElevatedButton(
                                onPressed: () async {
                                  String currenScreen = "";
                                  // List<dynamic> members = preferencesService.memebersListStream!.value!;
                                  // preferencesService.dropdown_user_id = members[0]['_id'];
                                  // preferencesService.dropdown_user_name = members[0]['member_first_name'].toString();
                                  // preferencesService.dropdown_user_dob = members[0]['dateofbirth'] != null ? dob : '';
                                  // preferencesService.dropdown_user_age = members[0]['age'] != null ? members[0]['age'].toString() : '';

                                  await model.getRecentUploads();
                                  await Get.to(() => DownloadsView());
                                  //currenScreen = Get.currentRoute.toString();
                                  // print("*********************" + currenScreen + "****************");
                                  // if (currenScreen != null || currenScreen.isNotEmpty) {
                                  //   Get.back();
                                  //   Get.back();
                                  //   if (Get.currentRoute.toString() != null || Get.currentRoute.toString().isNotEmpty) {
                                  //     Get.back();
                                  //     Get.back();
                                  //     Get.back();
                                  //   }
                                  //   final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
                                  //   navigationBar.onTap!(2);
                                  // }
                                },
                                child: Row(
                                  children: [
                                    Text('View   ').textColor(Colors.black).bold(),
                                    Icon(
                                      Icons.remove_red_eye_rounded,
                                      color: activeColor,
                                      size: 28,
                                    ),
                                  ],
                                ),
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(80, 45)),
                                  elevation: MaterialStateProperty.all(0),
                                  backgroundColor: MaterialStateProperty.all(Colors.white),
                                )),
                          ],
                        ),
                        UIHelper.horizontalSpaceSmall,
                      ],
                    ),
                    UIHelper.verticalSpaceTiny,
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showBottomSheet(String type, ProfileViewmodel model) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        builder: (
          BuildContext context,
        ) {
          return Container(
            height: 190,
            child: ListView(
              children: [
                UIHelper.verticalSpaceSmall,
                model.coverimg_url != ""
                    ? ListTile(
                        onTap: () async {
                          // Get.back();
                          // getImage(type, FileType.image);
                          String cover_img = model.coverimg_url;
                          await showDialog(
                              context: context,
                              //https://swarstage.blob.core.windows.net/swardoctor/scaled_image_picker8539268485450644726_1621533729545.jpg
                              builder: (_) => ImageDialog(context, cover_img));
                        },
                        visualDensity: VisualDensity.compact,
                        //visualDensity: VisualDensity.standard,
                        // visualDensity:VisualDensity.comfortable,
                        title: Text('Preview'),
                      )
                    : Container(),
                model.coverimg_url != "" ? UIHelper.hairLineWidget() : Container(),
                ListTile(
                  onTap: () async {
                    Get.back();
                    await getCoverImage(type, FileType.video, model);
                    if (cover_localPath.isNotEmpty) {
                      userInfo['cover_image'] = cover_localPath;
                    }
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
                    await getCoverImage(type, FileType.image, model);
                    if (cover_localPath.isNotEmpty) {
                      userInfo['cover_image'] = cover_localPath;
                    }
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
                          // Get.back();
                          // getImage(type, FileType.image);
                          String profile_img = model.img_url;
                          await showDialog(
                              context: context,
                              //https://swarstage.blob.core.windows.net/swardoctor/scaled_image_picker8539268485450644726_1621533729545.jpg
                              builder: (_) => ImageDialog(context, profile_img));
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
                    await getImage(type, FileType.video, model);
                    if (localPath.isNotEmpty) {
                      userInfo['profileimage'] = localPath;
                    }
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
                    await getImage(type, FileType.image, model);
                    if (localPath.isNotEmpty) {
                      userInfo['profileimage'] = localPath;
                    }
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

  Widget getinsuranceInfoItem(String title, String value) {
    return Row(
      children: [Text(title).fontSize(13), UIHelper.horizontalSpaceTiny, Text(value).fontSize(13).bold()],
    );
  }

  Widget getPersonalInfoItem(String title, String value) {
    return Row(
      children: [SizedBox(width: Screen.width(context) / 3.7, child: Text(title).fontSize(13)), Text(value).fontSize(13).bold()],
    );
  }

  Widget additionalInfoWidget(BuildContext context, String title, String value) {
    return Row(
      children: [
        UIHelper.horizontalSpaceSmall,
        SizedBox(
          child: Text(title).fontSize(13),
          width: Screen.width(context) / 4,
        ),
        Flexible(
          child: Text(value, overflow: TextOverflow.ellipsis).fontSize(13).bold(),
        )
      ],
    );
  }

  Widget getInfoItem(String title, String value) {
    return Row(
      children: [SizedBox(width: Screen.width(context) / 4, child: Text(title).fontSize(13)), Text(value).fontSize(13).bold()],
    );
  }

  Widget IconWidget(IconData icon) {
    return Icon(
      icon,
      color: activeColor,
      size: 18,
    );
  }

  Widget getPersonalInfoWidget(BuildContext context, ProfileViewmodel model) {
    Jiffy valid_date = Jiffy();
    Jiffy dob_ = Jiffy(model.profile_Info['dateofbirth']);
    dob = dob_.format('dd MMM yyyy');
    if (model.profile_Info['insurance_validitydate'] != null) {
      valid_date = Jiffy(model.profile_Info['insurance_validitydate']);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(8),
        width: Screen.width(context),
        decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: Color(0xFFE2E2E2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Incase of emergency contact', overflow: TextOverflow.ellipsis).fontSize(15).bold(),
            UIHelper.verticalSpaceSmall,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Doctor No.').textColor(activeColor).bold().fontSize(13),
                UIHelper.horizontalSpaceSmall,
                Row(
                  children: [
                    Container(
                      width: 85,
                      height: 30,
                      child: FormBuilderDropdown(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 5),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          // enabledBorder: UIHelper.getInputBorder(1),
                          focusedErrorBorder: UIHelper.getInputBorder(1),
                          errorBorder: UIHelper.getInputBorder(1),
                          focusedBorder: UIHelper.getInputBorder(1),
                        ),
                        name: "alternateno_countryCode",
                        hint: Text('Code').fontSize(12),
                        initialValue: model.profile_Info['alternateno_countryCode'],
                        items: model.countries
                            .map<DropdownMenuItem<String>>((altercode) => DropdownMenuItem<String>(
                                value: altercode['countryCode_digits'],
                                child: Container(
                                    padding: EdgeInsets.only(top: 4), child: Text(altercode['countryCode_digits'] + ' ' + altercode['country'], overflow: TextOverflow.fade).textColor(Colors.black).fontSize(12)) // Row(

                                //  Row(
                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     SvgPicture.network(
                                //       altercode['countryFlag'],
                                //       height: 15,
                                //       width: 25,
                                //     ),
                                //     SizedBox(width: 5),
                                //     //  Text(altercode['countryCode_digits']).textColor(Colors.black).fontSize(12),
                                //     Expanded(child: Text(altercode['countryCode_digits'] + '\n' + altercode['country']).textColor(Colors.black).fontSize(12)),
                                //   ],
                                // )
                                ))
                            .toList(),
                        onChanged: (value) async {
                          setState(() {
                            userInfo['alternateno_countryCode'] = value;
                          });
                          await model.updatePreferdNumber(userInfo, '', '');
                        },
                      ),
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Container(
                      width: 125,
                      height: 30,
                      child: FormBuilderTextField(
                        style: loginInputTitleStyle,
                        name: 'emergency_doctor_number',
                        controller: _doctorFieldController,
                        autofocus: false,
                        onChanged: (value) {
                          print(value);
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 5),
                          hintText: 'Doctor No',
                          hintStyle: loginInputHintTitleStyle,
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          // enabledBorder: UIHelper.getInputBorder(1),
                          focusedErrorBorder: UIHelper.getInputBorder(1),
                          errorBorder: UIHelper.getInputBorder(1),
                          focusedBorder: UIHelper.getInputBorder(1),
                        ),
                        //inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]"))],
                        inputFormatters: [
                          // is able to enter lowercase letters

                          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                        ],
                        keyboardType: TextInputType.number,
                        onEditingComplete: () async {
                          if (FocusScope.of(context).isFirstFocus) {
                            if (_doctorFieldController.text == "") {
                              FocusScope.of(context).requestFocus(new FocusNode());
                              userInfo['emergency_doctor_number'] = _doctorFieldController.text;
                              model.updatePreferdNumber(userInfo, '', '');
                            } else {
                              FocusScope.of(context).requestFocus(new FocusNode());
                            }
                          }
                          if (_doctorFieldController.text.isNotEmpty) {
                            if (_doctorFieldController.text.length < 7 || _doctorFieldController.text.length > 15 || _clinicFieldController.text == _doctorFieldController.text) {
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
                              _doctorFieldController.clear();
                              return;
                            } else {
                              userInfo['emergency_doctor_number'] = _doctorFieldController.text;
                              model.updatePreferdNumber(userInfo, '', '');
                            }
                          }
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
            UIHelper.verticalSpaceSmall,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Text('Relative/friends', overflow: TextOverflow.ellipsis).textColor(activeColor).bold().fontSize(13),
                ),
                Row(
                  children: [
                    Container(
                      width: 85,
                      height: 30,
                      child: FormBuilderDropdown(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 5),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          // enabledBorder: UIHelper.getInputBorder(1),
                          focusedErrorBorder: UIHelper.getInputBorder(1),
                          errorBorder: UIHelper.getInputBorder(1),
                          focusedBorder: UIHelper.getInputBorder(1),
                        ),
                        name: "alternatemobilenumber",

                        hint: Text('Code').fontSize(15),
                        initialValue: model.profile_Info['alternatemobilenumber'],
                        // items: model.countries!.map((dynamic value) {
                        //   return new DropdownMenuItem(
                        //     value: value,
                        //     child: new Text(value['countryCode_digits']).fontSize(13).bold(),
                        //   );
                        // }).toList(),
                        items: model.countries
                            .map<DropdownMenuItem<String>>((altercode) => new DropdownMenuItem<String>(
                                value: altercode['countryCode_digits'],
                                child: Container(
                                    padding: EdgeInsets.only(top: 4), child: Text(altercode['countryCode_digits'] + ' ' + altercode['country'], overflow: TextOverflow.fade).textColor(Colors.black).fontSize(12)) // Row(

                                //  Row(
                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     // Image.asset(
                                //     //   'assets/cayman.png',
                                //     //   height: 15,
                                //     //   width: 21,
                                //     // ),
                                //     SvgPicture.network(
                                //       altercode['countryFlag'],
                                //       height: 15,
                                //       width: 25,
                                //     ),
                                //     SizedBox(width: 5),
                                //     //  Text(altercode['countryCode_digits']).textColor(Colors.black).fontSize(12),
                                //     Expanded(child: Text(altercode['countryCode_digits'] + '\n' + altercode['country']).textColor(Colors.black).fontSize(12)),
                                //   ],
                                // )
                                ))
                            .toList(),
                        onChanged: (value) async {
                          // altercode = _doctorcountrycodeController;
                          // altercode['countryCode_digits'] = altercode;
                          setState(() {
                            userInfo['alternatemobilenumber'] = value;
                          });
                          await model.updatePreferdNumber(userInfo, '', '');
                        },
                      ),
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Container(
                      width: 125,
                      height: 30,
                      child: FormBuilderTextField(
                        style: loginInputTitleStyle,
                        name: 'emergency_clinic_number',
                        controller: _clinicFieldController,
                        autocorrect: false,
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 5),
                          hintText: 'Clinic No',
                          hintStyle: loginInputHintTitleStyle,
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          // enabledBorder: UIHelper.getInputBorder(1),
                          focusedErrorBorder: UIHelper.getInputBorder(1),
                          errorBorder: UIHelper.getInputBorder(1),
                          focusedBorder: UIHelper.getInputBorder(1),
                        ),
                        keyboardType: TextInputType.number,
                        //inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]"))],
                        inputFormatters: [
                          // is able to enter lowercase letters

                          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                        ],
                        onEditingComplete: () async {
                          if (FocusScope.of(context).isFirstFocus) {
                            if (_clinicFieldController.text == "") {
                              FocusScope.of(context).requestFocus(new FocusNode());
                              userInfo['emergency_clinic_number'] = _clinicFieldController.text;
                              model.updatePreferdNumber(userInfo, '', '');
                            } else {
                              FocusScope.of(context).requestFocus(new FocusNode());
                            }
                          }

                          if (_clinicFieldController.text.isNotEmpty) {
                            if (_clinicFieldController.text.length < 7 || _clinicFieldController.text.length > 15 || _clinicFieldController.text == _doctorFieldController.text) {
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
                              _clinicFieldController.clear();
                              return;
                            } else {
                              userInfo['emergency_clinic_number'] = _clinicFieldController.text;
                              model.updatePreferdNumber(userInfo, '', '');
                            }
                          }
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
            UIHelper.verticalSpaceSmall,
            Container(
              padding: EdgeInsets.all(12),
              width: Screen.width(context),
              decoration: UIHelper.roundedBorderWithColorWithShadow(10, Colors.white),
              child: Column(
                children: [
                  Row(
                    children: [
                      // getinsuranceInfoItem('Insurance Name ', model.profile_Info['insurance_name'] != null ? model.profile_Info['insurance_name'] : ""),
                      Text('Insurance Name  '),
                      UIHelper.horizontalSpaceMedium,
                      Container(
                        child: Flexible(child: Text(model.profile_Info['insurance_name'] != null ? model.profile_Info['insurance_name'] : "", overflow: TextOverflow.ellipsis).bold()),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpaceSmall,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // getinsuranceInfoItem('Number ', model.profile_Info['insurance_number'] != null ? model.profile_Info['insurance_number'] : ""),
                      // Text('Number  ').fontSize(13),
                      // Flexible(child: Text(model.profile_Info['insurance_number'] != null ? model.profile_Info['insurance_number'] : "", overflow: TextOverflow.ellipsis).bold()),

                      Text('Number  '),

                      Container(
                        child: Flexible(child: Text(model.profile_Info['insurance_number'] != null ? model.profile_Info['insurance_number'] : "", overflow: TextOverflow.ellipsis).bold()),
                      ),
                      UIHelper.horizontalSpaceTiny,
                      // Text(model.profile_Info['insurance_name']).bold(),
                      getinsuranceInfoItem(' Validity ', model.profile_Info['insurance_validitydate'] != null ? valid_date.format('dd MMM yyyy') : ""),
                    ],
                  )
                ],
              ),
            ),
            UIHelper.verticalSpaceSmall,
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     getinsuranceInfoItem('   Blood Group    ', model.profile_Info['bloodgroup'] != null ? model.profile_Info['bloodgroup'] : ""),
            //     // getinsuranceInfoItem('Gender    ', model.profile_Info['gender'] != null ? model.profile_Info['gender'] : ""),
            //     UIHelper.horizontalSpaceSmall,
            //     UIHelper.horizontalSpaceSmall,
            //     Container(width: Screen.width(context) / 6, child: Text('Gender')),
            //     UIHelper.horizontalSpaceSmall,
            //     Text(model.profile_Info['gender'] != null ? model.profile_Info['gender'].toString() : '').fontSize(13).bold().bold(),
            //   ],
            // ),

            Row(
              children: [
                UIHelper.horizontalSpaceSmall,
                SizedBox(
                  child: Text('Blood Group').fontSize(13),
                  width: Screen.width(context) / 4,
                ),
                Container(
                  width: Screen.width(context) / 4,
                  child: Text(model.profile_Info['bloodgroup'] != null ? model.profile_Info['bloodgroup'].toString() : '').fontSize(13).bold(),
                ),
                UIHelper.horizontalSpaceSmall,
                UIHelper.horizontalSpaceTiny,
                Text('Gender'),
                UIHelper.horizontalSpaceSmall,
                Text(model.profile_Info['gender'] != null ? model.profile_Info['gender'].toString() : '').fontSize(13).bold().bold(),
              ],
            ),
            UIHelper.verticalSpaceSmall,
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     getinsuranceInfoItem('   Date of Birth   ', model.profile_Info['dateofbirth'] != null ? dob : ""),
            //     Container(width: Screen.width(context) / 6, child: Text('Age')),
            //     UIHelper.horizontalSpaceSmall,
            //     Text(model.profile_Info['age'] != null ? model.profile_Info['age'].toString() : '').fontSize(13).bold()
            //   ],
            // ),

            Row(
              children: [
                UIHelper.horizontalSpaceSmall,
                SizedBox(
                  child: Text('Date of Birth').fontSize(13),
                  width: Screen.width(context) / 4,
                ),
                Container(width: Screen.width(context) / 4, child: Text(model.profile_Info['dateofbirth'] != null ? dob : '').fontSize(13).bold()),
                UIHelper.horizontalSpaceSmall,
                UIHelper.horizontalSpaceTiny,
                Container(width: Screen.width(context) / 7, child: Text('Age')),
                UIHelper.horizontalSpaceSmall,
                Text(model.profile_Info['age'] != null ? model.profile_Info['age'].toString() : '').fontSize(13).bold()
              ],
            ),
            UIHelper.verticalSpaceSmall,
            // getPersonalInfoItem('   Email Id', model.profile_Info['email'] != null ? model.profile_Info['email'] : ""),
            additionalInfoWidget(
              context,
              'Email Id',
              model.profile_Info['email'] != null ? model.profile_Info['email'].toString() : '',
            ),
            UIHelper.verticalSpaceSmall,
            model.profile_Info['countryCode_digits'] != null
                ? getPersonalInfoItem('   Mobile No.', model.profile_Info['mobilenumber'] != null ? model.profile_Info['countryCode_digits'] + ' ' + model.profile_Info['mobilenumber'] : "")
                : getPersonalInfoItem('   Mobile No.', model.profile_Info['mobilenumber'] != null ? model.profile_Info['mobilenumber'] : ""),
            UIHelper.verticalSpaceSmall,
            getPersonalInfoItem('   Country', model.profile_Info['country'] != null ? model.profile_Info['country'] : ""),
            UIHelper.verticalSpaceSmall,
          ],
        ),
      ),
    );
  }

  Widget coverImg(BuildContext context) {
    return Container(
      width: Screen.width(context) - 32,
      height: 250,
      decoration: UIHelper.roundedBorderWithColorWithShadow(6, fieldBgColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> members = preferencesService.memebersListStream!.value!;
    memberIndex = members.indexWhere((val) => val['_id'] == preferencesService.dropdown_user_id);

    super.build(context);
    return Scaffold(
        appBar: SwarProfileAppBar(),
        backgroundColor: Colors.white,
        body: SafeArea(
            top: false,
            child: Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(10, 0, 0, 0), child: membersDropdownList(context)),
              memberIndex == 0
                  ? Expanded(
                      child: Container(
                          // padding: EdgeInsets.only(left: 16, right: 16),
                          child: ViewModelBuilder<ProfileViewmodel>.reactive(
                              onModelReady: (model) async {
                                await model.getUserProfile(false);
                                await model.getCountries();
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
                                            addHeader(context, model),
                                            uploadRecord(context, model),
                                            UIHelper.verticalSpaceSmall,
                                            getPersonalInfoWidget(
                                              context,
                                              model,
                                            ),
                                            UIHelper.verticalSpaceSmall,
                                          ],
                                        ),
                                      );
                              },
                              viewModelBuilder: () => ProfileViewmodel())))
                  : ViewMemberProfileView(memberId: preferencesService.dropdown_user_id, view_type: 'family'),
            ])));
  }
}

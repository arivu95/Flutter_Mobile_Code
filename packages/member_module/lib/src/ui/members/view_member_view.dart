import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:member_module/src/ui/members/edit_member_view.dart';
import 'package:member_module/src/ui/members/view_member_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/inappbrowser.dart';
import 'package:swarapp/shared/pdf_viewer.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/app/locator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:documents_module/src/ui/downloads/downloads_view.dart';
import 'package:documents_module/src/ui/uploads/uploads_view.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_module/src/ui/user_profile/member_profile_view.dart';

class ViewMemberView extends StatefulWidget {
  final String memberId, view_type;

  ViewMemberView({Key? key, required this.memberId, required this.view_type}) : super(key: key);

  @override
  _ViewMemberViewState createState() => _ViewMemberViewState();
}

class _ViewMemberViewState extends State<ViewMemberView> {
  PreferencesService preferencesService = locator<PreferencesService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppStaticBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: UIHelper.addHeader(context, " View Member", true),
              ),
              ViewMemberProfileView(memberId: widget.memberId, view_type: 'family')
            ],
          )),
    );
  }
}


// import 'dart:io';
// import 'dart:math';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jiffy/jiffy.dart';
// import 'package:member_module/src/ui/members/edit_member_view.dart';
// import 'package:member_module/src/ui/members/view_member_viewmodel.dart';
// import 'package:stacked/stacked.dart';
// import 'package:swarapp/services/api_services.dart';
// import 'package:swarapp/shared/app_bar.dart';
// import 'package:swarapp/shared/app_colors.dart';
// import 'package:swarapp/shared/app_static_bar.dart';
// import 'package:swarapp/shared/custom_dialog_box.dart';
// import 'package:swarapp/shared/flutter_overlay_loader.dart';
// import 'package:swarapp/shared/image_cropper.dart';
// import 'package:swarapp/shared/inappbrowser.dart';
// import 'package:swarapp/shared/pdf_viewer.dart';
// import 'package:swarapp/shared/screen_size.dart';
// import 'package:swarapp/shared/text_styles.dart';
// import 'package:swarapp/shared/ui_helpers.dart';
// import 'package:styled_widget/styled_widget.dart';
// import 'package:swarapp/services/preferences_service.dart';
// import 'package:swarapp/app/locator.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pinch_zoom/pinch_zoom.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:documents_module/src/ui/downloads/downloads_view.dart';
// import 'package:documents_module/src/ui/uploads/uploads_view.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ViewMemberView extends StatefulWidget {
//   final String memberId, view_type;

//   ViewMemberView({Key? key, required this.memberId, required this.view_type}) : super(key: key);

//   @override
//   _ViewMemberViewState createState() => _ViewMemberViewState();
// }

// class _ViewMemberViewState extends State<ViewMemberView> {
//   Jiffy validity = Jiffy();
//   String dob = '';

//   TextEditingController attachController = TextEditingController();

//   String _filename = '';
//   late File imageFile;
//   late MembersViewmodel model;
//   final picker = ImagePicker();
//   String localPath = '';
//   String cover_localPath = '';
//   String notes = '';
//   String notes_Path = '';
//   String network_img_url = '';
//   String cover_url = '';
//   String isvideo = '';

//   final MyInAppBrowser browser = new MyInAppBrowser();

//   var options = InAppBrowserClassOptions(
//       crossPlatform: InAppBrowserOptions(hideUrlBar: false),
//       inAppWebViewGroupOptions: InAppWebViewGroupOptions(
//           crossPlatform: InAppWebViewOptions(
//               javaScriptEnabled: true,
//               clearCache: true,
//               useShouldInterceptAjaxRequest: true,
//               useShouldOverrideUrlLoading: true,
//               useShouldInterceptFetchRequest: true,
//               javaScriptCanOpenWindowsAutomatically: true,
//               allowFileAccessFromFileURLs: true,
//               allowUniversalAccessFromFileURLs: true)));

//   Future getProfile(String type, FileType fileType, model) async {
//     String path = '';

//     final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
//     if (pickedFile != null) {
//       await Get.to(() => ImgCropper(
//           index: 0,
//           imagePath: pickedFile!.path,
//           onCropComplete: (path) {
//             String st = path;
//             print(path);
//             setState(() {
//               localPath = path;
//             });
//           }));
//       Loader.show(context);
//       await model.updateMemberProfile(widget.memberId, model.profileInfo, localPath, cover_localPath);
//       await model.getMemberProfile(widget.memberId);
//       Loader.hide();
//       print(path);

//       print(path);
//     }
//   }

//   Future getAttachNotes(String type, FileType fileType, MembersViewmodel model) async {
//     String path = '';
//     if (type == "camera") {
//       final notes_pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
//       if (notes_pickedFile != null) {
//         await Get.to(() => ImgCropper(
//             index: 0,
//             imagePath: notes_pickedFile!.path,
//             onCropComplete: (path) {
//               String st = path;

//               print(path);

//               setState(() {
//                 notes_Path = path;

//                 // attachController.text = notes_Path;
//               });
//             }));
//         Loader.show(context);
//         await model.addNotes(widget.memberId, model.profileInfo, notes_Path, '');
//         await model.getMemberProfile(widget.memberId);
//         Loader.hide();
//         print(path);
//       }
//     } else {
//       preferencesService.paths.clear();
//       final FilePickerResult? notes_pickedFile = await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: false, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx']);
//       //     if (notes_pickedFile == null) return;
//       //  loadSelectedFiles(result!.files);
//       if (notes_pickedFile != null) {
//         // String path = result.files.single.path!;
//         String path = notes_pickedFile.paths.last!;
//         preferencesService.paths.add(path);

//         // print(files);
//         setState(() {
//           notes_Path = path;
//         });
//         if (preferencesService.paths.toString().contains("mp4") || preferencesService.paths.toString().contains("mp3")) {
//           setState(() {
//             isvideo = "yes";
//           });
//           return showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return CustomDialogBox(
//                   title: "Not Allowed !",
//                   descriptions: "Video Files not allowed",
//                   descriptions1: "",
//                   text: "OK",
//                 );
//               });
//         } else {
//           Loader.show(context);
//           await model.addNotes(widget.memberId, model.profileInfo, notes_Path, '');
//           await model.getMemberProfile(widget.memberId);
//           Loader.hide();
//           print(path);
//         }
//       }
// // print(notes_pickedFile.toString());
//     }
//   }

//   Widget ImagesDialog(BuildContext context, String getImg) {
//     String setImg = '${ApiService.fileStorageEndPoint}${getImg}';
//     return Dialog(
//         backgroundColor: Color.fromRGBO(105, 105, 105, 0.5),
//         insetPadding: EdgeInsets.all(15),
//         child: Container(
//           child: Stack(
//             // child: SingleChildScrollView(
//             children: [
//               PinchZoom(
//                 // image:DecorationImage(),
//                 image: Image.network(setImg),
//                 zoomedBackgroundColor: Colors.black.withOpacity(0.5),
//                 resetDuration: const Duration(milliseconds: 100),
//                 maxScale: 2.5,
//                 onZoomStart: () {
//                   print('Start zooming');
//                 },
//                 onZoomEnd: () {
//                   print('Stop zooming');
//                 },
//               ),
//               Positioned(
//                 right: 0.0,
//                 top: 0.5,
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Align(
//                     alignment: Alignment.topRight,
//                     child: CircleAvatar(
//                       radius: 14.0,
//                       backgroundColor: Colors.red,
//                       child: Icon(Icons.close, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ));
//   }

//   void launchExternalDoc(String url) async {
//     try {
//       // bool status = await launch(url, forceWebView: true, enableJavaScript: true);

//       // print('>>>>>> ' + status.toString());

//       browser.openUrlRequest(urlRequest: URLRequest(url: Uri.parse(url)), options: options);
//     } catch (e) {
//       print('ExEXEXEX');

//       print(e.toString());
//     }
//   }

//   PreferencesService preferencesService = locator<PreferencesService>();
//   Widget addHeader(BuildContext context, MembersViewmodel model) {
//     attachController.text = model.profileInfo['notes_description'];
//attachController.text = model.profileInfo['notes_description'] != null ? model.profileInfo['notes_description'] : "";
//     notes = attachController.text;
//     Jiffy fromDate_ = Jiffy(model.profileInfo['insurance_validitydate']);
//     if (model.profileInfo['insurance_validitydate'] != null) {
//       validity = Jiffy(model.profileInfo['insurance_validitydate']);
//     }
//     print(validity);
//     print("***********" + model.img_url.toString());
//     var screenSize = MediaQuery.of(context).size;
//     bool isAutoValidate = false;
//     Jiffy dob_ = Jiffy(model.profileInfo['date_of_birth']);
//     dob = dob_.format('dd MMM yyyy');

//     bool isuser = model.profileInfo['is_user'];
//     print('===========isuser');
//     print(isuser);
//     if (model.profileInfo['azureBlobStorageLink'] != null) {
//       network_img_url = '${ApiService.fileStorageEndPoint}${model.profileInfo['azureBlobStorageLink']}';
//     }

//     if (model.profileInfo['coverimg_azureBlobStorageLink'] != null) {
//       cover_url = '${ApiService.fileStorageEndPoint}${model.profileInfo['coverimg_azureBlobStorageLink']}';
//     }
//     Widget ImageDialog(BuildContext context, String getImg) {
//       String setImg = getImg;
//       return Dialog(
//           backgroundColor: Color.fromRGBO(105, 105, 105, 0.5),
//           insetPadding: EdgeInsets.all(15),
//           child: Container(
//             child: Stack(
//               // child: SingleChildScrollView(
//               children: [
//                 PinchZoom(
//                   // image:DecorationImage(),
//                   image: Image.network(setImg),
//                   zoomedBackgroundColor: Colors.black.withOpacity(0.5),
//                   resetDuration: const Duration(milliseconds: 100),
//                   maxScale: 2.5,
//                   onZoomStart: () {
//                     print('Start zooming');
//                   },
//                   onZoomEnd: () {
//                     print('Stop zooming');
//                   },
//                 ),
//                 Positioned(
//                   right: 0.0,
//                   top: 0.5,
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: Align(
//                       alignment: Alignment.topRight,
//                       child: CircleAvatar(
//                         radius: 14.0,
//                         backgroundColor: Colors.red,
//                         child: Icon(Icons.close, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ));
//     }

//     Future getCoverImage(String type, FileType fileType, model) async {
//       String path = '';

//       final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 480);
//       if (pickedFile != null) {
//         await Get.to(() => ImgCropper(
//             index: 0,
//             imagePath: pickedFile!.path,
//             onCropComplete: (path) {
//               String st = path;
//               print(path);
//               setState(() {
//                 cover_localPath = path;
//               });
//             }));
//         Loader.show(context);
//         await model.updateMemberProfile(widget.memberId, model.profileInfo, localPath, cover_localPath);
//         await model.getMemberProfile(widget.memberId);
//         Loader.hide();
//       }
//       print(path);
//     }

//     void showBottomSheet(String type, MembersViewmodel model) {
//       showModalBottomSheet(
//           context: context,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
//           ),
//           builder: (
//             BuildContext context,
//           ) {
//             return Container(
//               height: 190,
//               child: ListView(
//                 children: [
//                   UIHelper.verticalSpaceSmall,
//                   model.coverimg_url != ""
//                       ? ListTile(
//                           onTap: () async {
//                             // Get.back();
//                             // getImage(type, FileType.image);
//                             String cover_img = model.coverimg_url;
//                             await showDialog(
//                                 context: context,
//                                 //https://swarstage.blob.core.windows.net/swardoctor/scaled_image_picker8539268485450644726_1621533729545.jpg
//                                 builder: (_) => ImageDialog(context, cover_img));
//                           },
//                           visualDensity: VisualDensity.compact,
//                           //visualDensity: VisualDensity.standard,
//                           // visualDensity:VisualDensity.comfortable,
//                           title: Text('Preview'),
//                         )
//                       : Container(),
//                   model.coverimg_url != "" ? UIHelper.hairLineWidget() : Container(),
//                   ListTile(
//                     onTap: () async {
//                       Get.back();
//                       await getCoverImage(type, FileType.video, model);
//                       if (cover_localPath.isNotEmpty) {
//                         model.profileInfo['cover_image'] = cover_localPath;
//                       }
//                       // Loader.show(context);
//                       // await model.updatePreferdNumber(userInfo, localPath);
//                       // Loader.hide();
//                     },
//                     visualDensity: VisualDensity.compact,
//                     title: Text('Camera'),
//                   ),
//                   UIHelper.hairLineWidget(),
//                   ListTile(
//                     onTap: () async {
//                       Get.back();
//                       await getCoverImage(type, FileType.image, model);
//                       if (cover_localPath.isNotEmpty) {
//                         model.profileInfo['cover_image'] = cover_localPath;
//                       }
//                       // Loader.show(context);
//                       // await model.updatePreferdNumber(userInfo, localPath);
//                       // Loader.hide();
//                     },
//                     visualDensity: VisualDensity.compact,
//                     //visualDensity: VisualDensity.standard,
//                     // visualDensity:VisualDensity.comfortable,
//                     title: Text('Photo Library'),
//                   ),
//                 ],
//               ),
//             );
//           });
//     }

//     void showFilePickerSheet(String type, MembersViewmodel model) {
//       showModalBottomSheet(
//           context: context,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
//           ),
//           builder: (
//             BuildContext context,
//           ) {
//             return Container(
//               height: 190,
//               child: ListView(
//                 children: [
//                   UIHelper.verticalSpaceSmall,
//                   model.img_url != ""
//                       ? ListTile(
//                           onTap: () async {
//                             // Get.back();
//                             // getImage(type, FileType.image);
//                             String profile_img = model.img_url;
//                             await showDialog(
//                                 context: context,
//                                 //https://swarstage.blob.core.windows.net/swardoctor/scaled_image_picker8539268485450644726_1621533729545.jpg
//                                 builder: (_) => ImageDialog(context, profile_img));
//                           },
//                           visualDensity: VisualDensity.compact,
//                           //visualDensity: VisualDensity.standard,
//                           // visualDensity:VisualDensity.comfortable,
//                           title: Text('Preview'),
//                         )
//                       : Container(),
//                   model.img_url != "" ? UIHelper.hairLineWidget() : Container(),
//                   ListTile(
//                     onTap: () async {
//                       Get.back();
//                       await getProfile(type, FileType.video, model);
//                       if (localPath.isNotEmpty) {
//                         model.profileInfo['profileimage'] = localPath;
//                       }
//                       // Loader.show(context);
//                       // await model.updatePreferdNumber(userInfo, localPath);
//                       // Loader.hide();
//                     },
//                     visualDensity: VisualDensity.compact,
//                     title: Text('Camera'),
//                   ),
//                   UIHelper.hairLineWidget(),
//                   ListTile(
//                     onTap: () async {
//                       Get.back();
//                       await getProfile(type, FileType.image, model);
//                       if (localPath.isNotEmpty) {
//                         model.profileInfo['profileimage'] = localPath;
//                       }
//                       // Loader.show(context);
//                       // await model.updatePreferdNumber(userInfo, localPath);
//                       // Loader.hide();
//                     },
//                     visualDensity: VisualDensity.compact,
//                     //visualDensity: VisualDensity.standard,
//                     // visualDensity:VisualDensity.comfortable,
//                     title: Text('Photo Library'),
//                   ),
//                 ],
//               ),
//             );
//           });
//     }

//     return SizedBox(
//       height: 300,
//       child: Stack(
//         children: [
//           // Positioned(child: Icon(Icons.access_time_rounded)),
//           cover_localPath.isNotEmpty
//               ? Image.file(
//                   File(cover_localPath),
//                   width: double.infinity,
//                   height: 160,
//                   fit: BoxFit.cover,
//                 )
//               : cover_url == ''
//                   ? Container(
//                       padding: EdgeInsets.only(bottom: 60),
//                       color: subtleColor,
//                       width: double.infinity,
//                       // child: GestureDetector(
//                       //   onTap: () async {
//                       //     showBottomSheet('type', model);
//                       //   },
//                       //   child: Row(
//                       //     mainAxisAlignment: MainAxisAlignment.center,
//                       //     crossAxisAlignment: CrossAxisAlignment.center,
//                       //     children: [
//                       //       UIHelper.horizontalSpaceMedium,
//                       //       Icon(
//                       //         Icons.camera_alt,
//                       //          color: Colors.white,
//                       //          size: 20,
//                       //       ),
//                       //       Text('Add cover Photo')

//                       //     ],

//                       //   ),
//                       // ),
//                       height: 160,
//                     )
//                   : Container(
//                       width: double.infinity,
//                       height: 160,
//                       decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(cover_url), fit: BoxFit.cover)),
//                     ),
//           Stack(
//             children: [
//               Positioned(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Container(
//                     width: Screen.width(context) - 32,
//                     height: 70,
//                     padding: EdgeInsets.all(8),
//                     decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             UIHelper.verticalSpaceNormal,
//                             Row(
//                               children: [
//                                 UIHelper.horizontalSpaceMedium,
//                                 Container(
//                                   width: Screen.width(context) / 2,
//                                   // color: Colors.red,
//                                   child: Text(
//                                     model.profileInfo['member_first_name'] != null ? model.profileInfo['member_first_name'].toString() : '',
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(fontSize: 18),
//                                   ).bold(),
//                                 ),
//                                 Container(
//                                     // color: Colors.red,
//                                     child: Text(model.profileInfo['relation'] != null ? model.profileInfo['relation'].toString() : '').bold()),
//                               ],
//                             ),
//                             UIHelper.verticalSpaceNormal,
//                             Row(
//                               children: [
//                                 UIHelper.horizontalSpaceMedium,
//                                 Text(
//                                   'SWAR ID',
//                                   style: TextStyle(color: Colors.redAccent.shade700),
//                                 ).bold(),
//                                 UIHelper.horizontalSpaceSmall,
//                                 Text(model.profileInfo['swar_Id'] != null ? model.profileInfo['swar_Id'].toString() : '').bold(),
//                                 UIHelper.horizontalSpaceLarge,
//                                 UIHelper.horizontalSpaceSmall,
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 bottom: 110,
//               ),
//               Positioned(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Container(
//                     width: Screen.width(context) - 32,
//                     height: 100,
//                     padding: EdgeInsets.all(8),
//                     decoration: UIHelper.roundedBorderWithColorWithShadow(6, peachColor),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Column(children: [
//                           SizedBox(
//                             height: 2,
//                           ),
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Container(
//                                   width: Screen.width(context) / 1.17,
//                                   child: Text(
//                                     'Click below to store and view health records',
//                                     overflow: TextOverflow.ellipsis,
//                                     textAlign: TextAlign.center,
//                                   ).bold()),
//                             ],
//                           ),
//                           UIHelper.verticalSpaceSmall,
//                           SizedBox(
//                             height: 2,
//                           ),
//                           Row(
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: Colors.white),
//                                 alignment: Alignment.center,
//                                 // color: Colors.white,
//                                 height: 40,
//                                 width: 130,
//                                 child: InkWell(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text('Upload').bold(),
//                                       UIHelper.horizontalSpaceSmall,
//                                       Icon(
//                                         Icons.cloud_upload_rounded,
//                                         color: Colors.redAccent.shade700,
//                                       ),
//                                     ],
//                                   ),
//                                   onTap: () async {
//                                     preferencesService.dropdown_user_id = widget.memberId;
//                                     preferencesService.dropdown_user_name = model.profileInfo['member_first_name'].toString();
//                                     preferencesService.dropdown_user_dob = model.profileInfo['date_of_birth'] != null ? dob : '';
//                                     preferencesService.dropdown_user_age = model.profileInfo['age'] != null ? model.profileInfo['age'].toString() : '';
//                                     if (preferencesService.select_upload == 'upload') {
//                                       preferencesService.user_login = '';
//                                     } else {
//                                       preferencesService.user_login = 'login';
//                                     }
//                                     preferencesService.select_upload = 'upload';
//                                     await model.getRecentUploads();
//                                     await Get.to(() => UploadsView());

//                                     // final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;

//                                     // navigationBar.onTap!(1);
//                                   },
//                                 ),
//                               ),
//                               UIHelper.horizontalSpaceSmall,
//                               Container(
//                                 height: 40,
//                                 width: 130,
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: Colors.white),
//                                 // color: Colors.white,
//                                 child: InkWell(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [Text('View').bold(), UIHelper.horizontalSpaceSmall, Icon(Icons.remove_red_eye_rounded, color: Colors.redAccent.shade700)],
//                                   ),
//                                   onTap: () async {
//                                     preferencesService.dropdown_user_id = widget.memberId;
//                                     preferencesService.dropdown_user_name = model.profileInfo['member_first_name'].toString();
//                                     preferencesService.dropdown_user_dob = model.profileInfo['date_of_birth'] != null ? dob : '';
//                                     preferencesService.dropdown_user_age = model.profileInfo['age'] != null ? model.profileInfo['age'].toString() : '';
//                                     await model.getRecentUploads();
//                                     await Get.to(() => DownloadsView());
//                                     //Get.back();
//                                     // final BottomNavigationBar navigationBar = locator<PreferencesService>().bottomTab_globalKey.currentWidget as BottomNavigationBar;
//                                     // navigationBar.onTap!(2);
//                                   },
//                                 ),
//                               )
//                             ],
//                           ),
//                         ]),
//                       ],
//                     ),
//                   ),
//                 ),
//                 top: 200,
//               ),
//               Positioned(
//                 left: 20,
//                 top: 42,
//                 child: GestureDetector(
//                   child: ClipRRect(
//                       borderRadius: BorderRadius.circular(250.0),
//                       // width: 200,
//                       child: localPath.isNotEmpty
//                           ? Image.file(
//                               File(localPath),
//                               width: 90,
//                               height: 90,
//                               fit: BoxFit.cover,
//                             )
//                           : network_img_url == ''
//                               ? CircleAvatar(
//                                   radius: 45,
//                                   backgroundColor: subtleColor,
//                                   child: Icon(
//                                     Icons.account_circle,
//                                     size: 30,
//                                     color: Colors.black38,
//                                   ),
//                                 )
//                               : UIHelper.getImage(network_img_url, 90, 90)

//                       //  CircleAvatar(
//                       //     radius: 45,

//                       //     UIHelper.getImage(img_url , 90,90)
//                       //     // backgroundImage: NetworkImage(network_img_url),

//                       //   ),
//                       ),
//                   onTap: () async {
//                     // print('**IMG IS ***' + model.img_url);
//                     if (model.img_url != "") {
//                       String profile_img = model.img_url;
//                       await showDialog(
//                           context: context,
//                           //https://swarstage.blob.core.windows.net/swardoctor/scaled_image_picker8539268485450644726_1621533729545.jpg
//                           builder: (_) => ImageDialog(context, profile_img));
//                     }
//                   },
//                 ),
//               ),
//               Positioned(
//                   left: 95,
//                   top: 100,
//                   child: InkWell(
//                     child: Icon(
//                       Icons.camera_alt,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     onTap: () {
//                       showFilePickerSheet('type', model);
//                       // removeConfirm(model, model.profileInfo);
//                     },
//                   )),
//               Positioned(
//                   left: Screen.width(context) / 1.8,
//                   top: 5,
//                   child: GestureDetector(
//                     onTap: () {},
//                     child: Row(
//                       // button color

//                       children: [
//                         GestureDetector(
//                           onTap: () async {
//                             showBottomSheet('type', model);
//                           },
//                           child: Container(
//                               padding: EdgeInsets.all(7),
//                               alignment: Alignment.center,
//                               decoration: UIHelper.roundedBorderWithColor(4, statusColor),
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.camera_alt,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                   cover_url.isEmpty ? Text(' Add Cover Photo') : Text(' Edit Cover Photo')
//                                 ],
//                               )),
//                         ),
//                       ],
//                     ),
//                   ))
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   // Future<void> removeConfirm(MembersViewmodel model, dynamic delinfo) async {
//   //   String memberId = delinfo['id'];
//   //   String name = delinfo['member_first_name'];
//   //   return showDialog(
//   //       context: context,
//   //       builder: (context) {
//   //         return AlertDialog(
//   //           title: Text('Delete'),
//   //           content: Text('Do you want to Delete $name Details ?'),
//   //           actions: <Widget>[
//   //             FlatButton(
//   //               color: Colors.red,
//   //               textColor: Colors.white,
//   //               child: Text('CANCEL'),
//   //               onPressed: () {
//   //                 Get.back(result: {'refresh': false});
//   //               },
//   //             ),
//   //             FlatButton(
//   //               color: Colors.green,
//   //               textColor: Colors.white,
//   //               child: Text('OK'),
//   //               onPressed: () async {
//   //                 Navigator.pop(context);
//   //                 final response = await model.deletemember(memberId);
//   //                 //locator<PreferencesService>().isReload.value = true;
//   //                 if (response) {
//   //                   model.isBusy ? Loader.show(context) : Loader.hide();
//   //                   //  locator<PreferencesService>().isReload.value = true;
//   //                   // locator<PreferencesService>().isReload.value = true;
//   //                   // locator<PreferencesService>().isUploadReload.value = true;
//   //                   // locator<PreferencesService>().isDownloadReload.value = true;
//   //                   //  preferencesService.onRefreshRecentDocument!.value = true;
//   //                   //   preferencesService.onRefreshRecentDocumentOnDownload!.value = true;
//   //                   //    preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
//   //                   // setState(() async {

//   //                   Get.back(result: {'refresh': true});
//   //                   // await  Get.to(() => MembersView());
//   //                   // });
//   //                 }
//   //               },
//   //             ),
//   //           ],
//   //         );
//   //       });
//   // }

//   Widget additionalInfoWidget(BuildContext context, String title, String value) {
//     return Row(
//       children: [
//         UIHelper.horizontalSpaceSmall,
//         SizedBox(
//           child: Text(
//             title,
//             overflow: TextOverflow.ellipsis,
//           ).fontSize(13),
//           width: Screen.width(context) / 4,
//         ),
//         Flexible(
//           child: Text(
//             value,
//             overflow: TextOverflow.ellipsis,
//           ).fontSize(13).bold(),
//         )
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //appBar: SwarAppBar(2),
//       appBar: SwarAppStaticBar(),
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         top: false,
//         child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 0),
//             width: Screen.width(context),
//             child: ViewModelBuilder<MembersViewmodel>.reactive(
//                 onModelReady: (model) {
//                   model.getMemberProfile(widget.memberId);
//                 },
//                 builder: (context, model, child) {
//                   String allergic = '';
//                   if (model.profileInfo['allergicto'] != null) {
//                     List al = model.profileInfo['allergicto'];
//                     allergic = al.join(', ');
//                   }
//                   return model.isBusy
//                       ? Center(
//                           child: UIHelper.swarPreloader(),
//                         )
//                       : SingleChildScrollView(
//                           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                             UIHelper.verticalSpaceSmall,
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 8),
//                               child: UIHelper.addHeader(context, " View Member", true),
//                             ),
//                             UIHelper.verticalSpaceSmall,
//                             addHeader(context, model),
//                             UIHelper.verticalSpaceSmall,
//                             SingleChildScrollView(
//                               padding: const EdgeInsets.symmetric(horizontal: 16),
//                               child: Container(
//                                 // padding: EdgeInsets.all(8),
//                                 decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
//                                 width: Screen.width(context),
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       width: Screen.width(context) - 32,
//                                       height: 60,
//                                       // padding: EdgeInsets.all(8),
//                                       decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
//                                       child: Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               UIHelper.verticalSpaceSmall,
//                                               Row(
//                                                 children: [
//                                                   UIHelper.horizontalSpaceSmall,
//                                                   Text('Insurance Name'),
//                                                   UIHelper.horizontalSpaceSmall,
//                                                   Container(
//                                                     width: Screen.width(context) / 2.3,
//                                                     child: Text(
//                                                       model.profileInfo['insurance_name'] != null ? model.profileInfo['insurance_name'].toString() : '',
//                                                       overflow: TextOverflow.ellipsis,
//                                                     ).bold(),
//                                                   ),
//                                                   InkWell(
//                                                     child: Icon(
//                                                       Icons.edit,
//                                                       size: 16,
//                                                     ),
//                                                     onTap: () async {
//                                                       final response = await Get.to(() => EditMemberView(
//                                                             // isEditMode:true,
//                                                             memberinfo: model.profileInfo,
//                                                             memberId: widget.memberId,
//                                                           ));
//                                                       if (response != null) {
//                                                         if (response['refresh'] == true) {
//                                                           model.getMemberProfile(widget.memberId);
//                                                           setState(() {});
//                                                         }
//                                                       }
//                                                     },
//                                                   )
//                                                 ],
//                                               ),
//                                               UIHelper.verticalSpaceSmall,
//                                               Row(
//                                                 children: [
//                                                   UIHelper.horizontalSpaceSmall,
//                                                   Text(
//                                                     'Number',
//                                                   ),
//                                                   UIHelper.horizontalSpaceSmall,
//                                                   Container(
//                                                     width: Screen.width(context) / 3.8,
//                                                     child: Text(
//                                                       model.profileInfo['insurance_number'] != null ? model.profileInfo['insurance_number'].toString() : '',
//                                                       overflow: TextOverflow.ellipsis,
//                                                     ).bold(),
//                                                   ),
//                                                   Container(width: Screen.width(context) / 6, child: Text('Validity')),
//                                                   // UIHelper.horizontalSpaceSmall,
//                                                   Text(
//                                                     model.profileInfo['insurance_validitydate'] != null ? validity.format('dd MMM yyyy') : "",
//                                                   ).bold()
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     UIHelper.verticalSpaceMedium,
//                                     Row(
//                                       children: [
//                                         UIHelper.horizontalSpaceSmall,
//                                         SizedBox(
//                                           child: Text('Blood Group').fontSize(13),
//                                           width: Screen.width(context) / 4,
//                                         ),
//                                         Container(
//                                           width: Screen.width(context) / 4,
//                                           child: Text(model.profileInfo['blood_group'] != null ? model.profileInfo['blood_group'].toString() : '').fontSize(13).bold(),
//                                         ),
//                                         UIHelper.horizontalSpaceSmall,
//                                         Container(width: Screen.width(context) / 6, child: Text('Gender')),
//                                         UIHelper.horizontalSpaceSmall,
//                                         Text(model.profileInfo['gender'] != null ? model.profileInfo['gender'].toString() : '').fontSize(13).bold().bold(),
//                                       ],
//                                     ),
//                                     UIHelper.verticalSpaceSmall,
//                                     Row(
//                                       children: [
//                                         UIHelper.horizontalSpaceSmall,
//                                         SizedBox(
//                                           child: Text('Date of Birth').fontSize(13),
//                                           width: Screen.width(context) / 4,
//                                         ),
//                                         Flexible(
//                                           child: Container(width: Screen.width(context) / 4, child: Text(model.profileInfo['date_of_birth'] != null ? dob : '').fontSize(13).bold()),
//                                         ),
//                                         UIHelper.horizontalSpaceSmall,
//                                         Container(width: Screen.width(context) / 6, child: Text('Age')),
//                                         UIHelper.horizontalSpaceSmall,
//                                         Text(model.profileInfo['age'] != null ? model.profileInfo['age'].toString() : '').fontSize(13).bold()
//                                       ],
//                                     ),
//                                     UIHelper.verticalSpaceSmall,
//                                     additionalInfoWidget(
//                                       context,
//                                       'Email Id',
//                                       model.profileInfo['member_email'] != null ? model.profileInfo['member_email'].toString() : '',
//                                     ),
//                                     UIHelper.verticalSpaceSmall,
//                                     (model.profileInfo['member_mobileno_countryCode'] == null || model.profileInfo['member_mobileno_countryCode'] == "")
//                                         ? additionalInfoWidget(
//                                             context,
//                                             'Mobile No.',
//                                             model.profileInfo['member_mobile_number'] != null ? model.profileInfo['member_mobile_number'].toString() : '',
//                                           )
//                                         : additionalInfoWidget(
//                                             context,
//                                             'Mobile No.',
//                                             model.profileInfo['member_mobile_number'] != null ? model.profileInfo['member_mobileno_countryCode'] + "  " + model.profileInfo['member_mobile_number'].toString() : '',
//                                           ),
//                                     UIHelper.verticalSpaceSmall,
//                                     additionalInfoWidget(
//                                       context,
//                                       'Country',
//                                       model.profileInfo['country'] != null ? model.profileInfo['country'].toString() : '',
//                                     ),
//                                     UIHelper.verticalSpaceSmall,
//                                     Container(
//                                       child: Row(
//                                         children: [
//                                           UIHelper.horizontalSpaceSmall,
//                                           Container(
//                                             width: Screen.width(context) / 4,
//                                             child: Text(
//                                               'Notes',
//                                             ),
//                                           ),
//                                           InkWell(
//                                             child: Container(
//                                                 width: Screen.width(context) / 1.7,
//                                                 child: Text(
//                                                   model.profileInfo['notes_azureBlobStorageLink'] != null ? model.profileInfo['notes_azureBlobStorageLink'].toString().split('_').last : '',
//                                                   overflow: TextOverflow.ellipsis,
//                                                   style: TextStyle(decoration: TextDecoration.underline),
//                                                 ).bold()),
//                                             onTap: () async {
//                                               String note_img = model.profileInfo['notes_azureBlobStorageLink'];
//                                               String img_url = '${ApiService.fileStorageEndPoint}${note_img.toString()}';

//                                               print('______&&&&*******&&&&______' + img_url);
//                                               (note_img.toLowerCase().contains('.pdf'))
//                                                   ?

//                                                   // await showDialog(

//                                                   //     context: context,

//                                                   //     builder: (_) => PdfDialog(context, img_url),

//                                                   //   )

//                                                   await Get.to(() => PdfViewr(url: img_url, file_name: note_img))

//                                                   //await launch('https://docs.google.com/viewer?url=$img_url')

//                                                   : (note_img.toLowerCase().contains('.docx')) || (note_img.toLowerCase().contains('.xls')) || (note_img.toLowerCase().contains('.xlsx'))
//                                                       ? launchExternalDoc('https://docs.google.com/viewer?url=$img_url&time=${DateTime.now()}')
//                                                       : await showDialog(
//                                                           context: context,
//                                                           builder: (_) => ImagesDialog(context, note_img),
//                                                         );
//                                               // await showDialog(
//                                               //     context: context,
//                                               //     //https://swarstage.blob.core.windows.net/swardoctor/scaled_image_picker8539268485450644726_1621533729545.jpg
//                                               //     builder: (_) => ImagesDialog(context, note_img));
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     UIHelper.verticalSpaceSmall,
//                                     UIHelper.verticalSpaceSmall,
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                                       child: Container(
//                                         width: Screen.width(context) - 32,
//                                         height: 60,
//                                         // padding: EdgeInsets.all(8),
//                                         decoration: UIHelper.roundedBorderWithColorWithShadow(6, peachColor1),
//                                         child: Row(
//                                           children: [
//                                             Column(
//                                               children: [
//                                                 Container(
//                                                   alignment: Alignment.centerLeft,
//                                                   width: Screen.width(context) / 1.8,
//                                                   padding: EdgeInsets.only(top: 5, right: 10, left: 10),
//                                                   child: FormBuilderTextField(
//                                                     // readOnly: true,
//                                                     style: TextStyle(color: Colors.black),
//                                                     name: 'notes_description',
//                                                     autocorrect: false,
//                                                     controller: attachController,
//                                                     textCapitalization: TextCapitalization.sentences,
//                                                     onChanged: (value) async {},
//                                                     decoration: InputDecoration(
//                                                       fillColor: statusColor,
//                                                       filled: true,
//                                                       contentPadding: EdgeInsets.only(left: 5),
//                                                       hintText: 'Write your notes..',
//                                                       // hintStyle: loginInputHintTitleStyle,
//                                                       hintStyle: TextStyle(color: Colors.black),
//                                                       enabledBorder: OutlineInputBorder(
//                                                         borderSide: const BorderSide(color: disabledColor),
//                                                         borderRadius: BorderRadius.circular(4.0),
//                                                       ),
//                                                       focusedBorder: UIHelper.getInputBorder(1),
//                                                       focusedErrorBorder: UIHelper.getInputBorder(1),
//                                                       errorBorder: UIHelper.getInputBorder(1),
//                                                     ),
//                                                     onEditingComplete: () async {
//                                                       if (FocusScope.of(context).isFirstFocus) {
//                                                         FocusScope.of(context).requestFocus(new FocusNode());
//                                                       }
//                                                       if (attachController.text.length > 50) {
//                                                         showDialog(
//                                                             context: context,
//                                                             builder: (BuildContext context) {
//                                                               return CustomDialogBox(
//                                                                 title: "Alert !",
//                                                                 descriptions: "Only 50 characters are allowed in Profile Status",
//                                                                 descriptions1: "",
//                                                                 text: "OK",
//                                                               );
//                                                             });

//                                                         return;
//                                                       } else {
//                                                         model.profileInfo['notes_description'] = attachController.text;

//                                                         model.addNotes(
//                                                           widget.memberId,
//                                                           model.profileInfo,
//                                                           notes_Path,
//                                                           notes,
//                                                         );
//                                                       }
//                                                     },
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(width: Screen.width(context) / 18),
//                                             // UIHelper.horizontalSpaceSmall,
//                                             InkWell(
//                                               child: Icon(
//                                                 Icons.camera_alt,
//                                                 color: Colors.redAccent.shade700,
//                                               ),
//                                               onTap: () {
//                                                 getAttachNotes('camera', FileType.video, model);
//                                               },
//                                             ),
//                                             UIHelper.horizontalSpaceMedium,
//                                             InkWell(
//                                               child: Transform.rotate(
//                                                 angle: 45 * pi / 180,
//                                                 child: Icon(
//                                                   Icons.attach_file,
//                                                   size: 20,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               onTap: () async {
//                                                 getAttachNotes('', FileType.custom, model);
//                                                 //  await getpick(context, model);
//                                               },
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     UIHelper.verticalSpaceSmall,
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ]),
//                         );
//                 },
//                 viewModelBuilder: () => MembersViewmodel())),
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:documents_module/src/ui/uploads/capture_upload_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_crop/image_crop.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/ui_helpers.dart';

class CaptureGalleryView extends StatefulWidget {
  final XFile image_path;
  // ignore: non_constant_identifier_names
  CaptureGalleryView({Key? key, required this.image_path}) : super(key: key);

  @override
  _CaptureGalleryViewState createState() => _CaptureGalleryViewState();
}

class _CaptureGalleryViewState extends State<CaptureGalleryView> {
  final cropKey = GlobalKey<CropState>();
  PreferencesService preferencesService = locator<PreferencesService>();

  String imagePath = '';
  String cropPath = '';
  int selectedIndex = 0;
  int viewIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      imagePath = preferencesService.paths.first;
    });
  }

  Widget recentItem(BuildContext context, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.file(
        File(preferencesService.paths[index]),
        fit: BoxFit.cover,
        height: 60,
        width: 60,
      ),
    );
  }

  Widget showImageViewer(BuildContext context) {
    return Column(
      children: [
        UIHelper.commonTopBar('Gallery'),
        UIHelper.verticalSpaceSmall,
        Container(
          width: Screen.width(context),
          // padding: EdgeInsets.only(left: 12, right: 12),
          height: 64,
          // padding: EdgeInsets.only(left: 12, right: 12),
          child: ListView.builder(
              // shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: preferencesService.paths.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      imagePath = preferencesService.paths[index];
                      print('selected image path ---' + imagePath);
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 4, left: 4),
                    width: 60,
                    height: 60,
                    child: Container(
                      //decoration: UIHelper.roundedBorderWithColor(8, selectedIndex == index ? activeColor : Color(0xFFEFEFEF), borderColor: Colors.yellow),
                      decoration: UIHelper.roundedLineBorderWithColor(10, subtleColor, 2, borderColor: selectedIndex == index ? activeColor : Colors.transparent),
                      child: recentItem(context, index),
                    ),
                  ),
                );
              }),
        ),
        UIHelper.verticalSpaceSmall,
        Expanded(
            child: Container(
          color: Colors.black,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            width: Screen.width(context),
          ),
        )),
        Container(
          height: 72,
          color: Colors.white,
          width: Screen.width(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  String path = preferencesService.paths[selectedIndex];
                  print(path);

                  await Get.to(() => ImgCropper(
                      index: selectedIndex,
                      imagePath: path,
                      onCropComplete: (path) {
                        setState(() {
                          imagePath = path;
                          preferencesService.paths[selectedIndex] = path;
                        });
                      }));
                },
                child: SizedBox(
                  height: 48,
                  child: Column(
                    children: [Icon(Icons.crop), Text('Edit')],
                  ),
                ),
              ),
              Container(
                decoration: UIHelper.roundedBorderWithColor(24, activeColor),
                width: 48,
                height: 48,
                child: IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.camera_alt, size: 30),
                    onPressed: () {
                      Get.back(result: {'selectedIndex': selectedIndex});
                      //Get.back();
                    }),
              ),
              GestureDetector(
                onTap: () async {
                  print('PRITN PATH IS ______________ ))))' + preferencesService.paths.length.toString());
                  if (preferencesService.paths.length < 6) {
                    Get.to(() => CaptureUploadView(
                          camera_mode: "Camera",
                        ));
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialogBox(
                            title: "Not Allowed !  ",
                            descriptions: "Files can be allowed within 5",
                            descriptions1: "",
                            text: "OK",
                          );
                        });
                    setState(() {});
                  }
                },
                child: Container(
                  height: 48,
                  child: Column(
                    children: [Icon(Icons.check, color: Colors.green), Text('Save')],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: SwarAppBar(2),
        appBar: SwarAppStaticBar(),
        body: Container(
          width: Screen.width(context),
          child: showImageViewer(context),
        ));
  }
}

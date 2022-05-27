import 'dart:io';

import 'package:camera/camera.dart';
import 'package:documents_module/src/ui/uploads/capture_gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/shared/app_static_bar.dart';
class CameraCaptureViewTwo extends StatefulWidget {
  CameraCaptureViewTwo({Key? key}) : super(key: key);

  @override
  _CameraCaptureViewTwoState createState() => _CameraCaptureViewTwoState();
}

class _CameraCaptureViewTwoState extends State<CameraCaptureViewTwo> {
  PreferencesService preferencesService = locator<PreferencesService>();
  late List<CameraDescription> cameras;
  late CameraController controller;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    cameraInitialize();
  }

  void cameraInitialize() async {
    cameras = await availableCameras();
    //controller = CameraController(cameras[0], ResolutionPreset.max);
    controller = CameraController(cameras[0], ResolutionPreset.ultraHigh);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        isInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     //appBar: SwarAppBar(2),
     appBar:SwarAppStaticBar(),
      body: Column(
        children: [
          UIHelper.commonTopBar('Back'),
          UIHelper.verticalSpaceSmall,
          Container(
            // padding: EdgeInsets.all(12),
            child: isInitialized
                ? Container(
                    width: Screen.width(context),
                    height: Screen.height(context) - 250,
                    child: CameraPreview(controller),
                  )
                : Text('Loading...'),
          ),
          UIHelper.verticalSpaceMedium,
          isInitialized
              ? Container(
                  decoration: UIHelper.roundedBorderWithColor(24, activeColor),
                  width: 48,
                  height: 48,
                  child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.camera_alt, size: 30),
                      onPressed: () async {
                        // final Directory extDir = await getTemporaryDirectory();
                        // final testDir = await Directory('${extDir.path}/test').create(recursive: true);
                        // final String filePath = '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                        XFile file = await controller.takePicture();
                        print('path is _--------'+file.path);
                        preferencesService.paths.insert(0, file.path);
                        print(file.path);
                        Get.to(() => CaptureGalleryView(
                              image_path: file,
                            ));
                      }),
                )
              : Container()
        ],
      ),
    );
  }
}

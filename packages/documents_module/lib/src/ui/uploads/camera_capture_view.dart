import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class CameraCaptureView extends StatefulWidget {
  CameraCaptureView({Key? key}) : super(key: key);

  @override
  _CameraCaptureViewState createState() => _CameraCaptureViewState();
}

class _CameraCaptureViewState extends State<CameraCaptureView> {
  ValueNotifier<CameraFlashes> _switchFlash = ValueNotifier(CameraFlashes.NONE);
  ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);
  ValueNotifier<CaptureModes> _captureMode = ValueNotifier(CaptureModes.PHOTO);
  ValueNotifier<Size> _photoSize = ValueNotifier(Size(1920, 1080));
  ValueNotifier<double> _zoomNotifier = ValueNotifier(0);
  // Controllers

  PictureController _pictureController = new PictureController();

  Widget cameraWidget(BuildContext context) {

    return Container(
      width: Screen.width(context),
      height: Screen.height(context) - 200,
      child: CameraAwesome(
        // testMode: true,
        onPermissionsResult: (result) {
          if (result!) {
            setState(() {});
          }
        },

        // onPermissionsResult: _onPermissionsResult,
        selectDefaultSize: (List<Size> availableSizes) => Size(1920, 1080),
        onCameraStarted: () {
          print('Camera Started');
          setState(() {
            _photoSize.value = Size(1920, 1080);
          });
      
        },

        // onOrientationChanged: (CameraOrientations newOrientation) {},
        zoom: _zoomNotifier,
        sensor: _sensor,
        photoSize: _photoSize,
        switchFlashMode: _switchFlash,
        captureMode: _captureMode,
        // orientation: DeviceOrientation.portraitUp,
        fitted: true,
        
      ),
    );
  }

  _onPermissionsResult(bool granted) {
    if (!granted) {
      AlertDialog alert = AlertDialog(
        title: Text('Error'),
        content: Text('It seems you doesn\'t authorized some permissions. Please check on your settings and try again.'),
        actions: [
          FlatButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );



      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      setState(() {});
      print("granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: SwarAppBar(2),
      appBar:SwarAppStaticBar(),
      body: Container(
        child: Column(
          children: [
            UIHelper.verticalSpaceSmall,
            cameraWidget(context),
            ElevatedButton(
                onPressed: () async {
                  final Directory extDir = await getTemporaryDirectory();
                  final testDir = await Directory('${extDir.path}/test').create(recursive: true);
                  final String filePath = '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                  await _pictureController.takePicture(filePath);

                // await  Future.delayed(const Duration(milliseconds: 500), () {
                //       _pictureController.takePicture(filePath);
                //       });
                },
                child: Text('Capture').bold(),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(160, 36)),
                  backgroundColor: MaterialStateProperty.all(activeColor),
                )),
          ],
        ),
      ),
    );
  }
}

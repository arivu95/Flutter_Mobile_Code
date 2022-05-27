import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_crop/image_crop.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';

class ImageCropView extends StatefulWidget {
  final int index;
  final String imagePath;
  final Function(String) onCropComplete;
  ImageCropView({Key? key, required this.index, required this.imagePath, required this.onCropComplete}) : super(key: key);

  @override
  _ImageCropViewState createState() => _ImageCropViewState();
}

class _ImageCropViewState extends State<ImageCropView> {
  final cropKey = GlobalKey<CropState>();

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.imagePath);
    return Scaffold(
      body: isLoading
          ? Center(
              child: UIHelper.swarPreloader(),
            )
          : Column(
              children: [
                UIHelper.verticalSpaceMedium,
                
                GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    
                    child: Text('Back')),
                UIHelper.verticalSpaceSmall,
                Container(
                  width: Screen.width(context),
                  height: Screen.height(context) - 120,
                  // padding: const EdgeInsets.all(20.0),
                  child: Crop(
                    key: cropKey,
                    image: FileImage(File(widget.imagePath)),
                   // aspectRatio: 4.0 / 3.0,
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      final croppedFile = await ImageCrop.cropImage(
                        file: File(widget.imagePath),
                        area: cropKey.currentState!.area!,
                      );
                      print('-croped patj-----'+croppedFile.path);
                      widget.onCropComplete(croppedFile.path);
                      Get.back();
                    },
                    child: Text('Crop').bold(),
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(160, 36)),
                      backgroundColor: MaterialStateProperty.all(activeColor),
                    ))
              ],
            ),
    );
  }
}

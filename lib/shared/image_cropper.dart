import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/ui_helpers.dart';

class ImgCropper extends StatefulWidget {
  final int index;
   String imagePath;
  final Function(String) onCropComplete;
  ImgCropper({Key? key, required this.index, required this.imagePath, required this.onCropComplete}) : super(key: key);

  @override
  ImgCropperState createState() => ImgCropperState();
}

class ImgCropperState extends State<ImgCropper> {
  final cropKey = GlobalKey<CropState>();

  bool isLoading = true;
 File? imageFile;
 var croppedFile ='';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cropImage();
   
  }

  _cropImage() async {
     
     String imageFile="https://www.tompetty.com/sites/g/files/g2000007521/f/sample_01.jpg";
     
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath:widget.imagePath
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '',
           toolbarColor: Colors.black.withOpacity(0.8),
            activeControlsWidgetColor:activeColor,
           toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
           iosUiSettings: IOSUiSettings(
          title: '',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile as String;
     // widget.imagePath=imageFile!.path;
      setState(() {
        isLoading = false;
       
      });
      widget.onCropComplete(widget.imagePath);
    widget.imagePath="";

    }
      Get.back();
  }

   @override
  Widget build(BuildContext context) {
    print(widget.imagePath);
    return Scaffold(
         appBar:SwarAppStaticBar(),
         backgroundColor: Colors.white,
           body: SafeArea(
        top: false,
        child:
         isLoading
          ? Center(
              child: UIHelper.swarPreloader(),
            )
          : 
            Center(
            child: imageFile != null ? Image.file(imageFile!) : Container(),
            ),

           ),
    );
  }
}

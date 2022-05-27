import 'package:doctor_module/src/ui/doctor_profile/doctor_about_viewmodel.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_declaration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_profile_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:stacked/stacked.dart';
import 'package:get/get.dart';

import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';

class DoctorDeclarationView extends StatefulWidget {
  DoctorDeclarationView({
    Key? key,
  }) : super(key: key);

  @override
  _DoctorDeclarationViewState createState() => _DoctorDeclarationViewState();
}

class _DoctorDeclarationViewState extends State<DoctorDeclarationView> {
  bool isEdit = false;

  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppDoctorBar(isProfileBar: false),
      // backgroundColor: Color(0xFFF5F3F3),
      backgroundColor: Colors.white,
      body: ViewModelBuilder<DoctorDeclarationViewModel>.reactive(
          onModelReady: (model) async {
            Loader.show(context);
            await model.getDoctorDetails();
            Loader.hide();
          },
          builder: (context, model, child) {
            return SafeArea(
                top: false,
                child: Container(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      UIHelper.verticalSpaceSmall,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: UIHelper.addHeader(context, "Self Declaration", true),
                      ),
                      UIHelper.verticalSpaceMedium,
                      Expanded(
                          child: Container(
                        width: Screen.width(context),
                        decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
                        padding: EdgeInsets.all(12),
                        child: Text('I declare that'),
                      )),
                      UIHelper.verticalSpaceMedium,
                      model.doctorDetails['esign'] != null
                          ? Expanded(
                              child: Container(
                                  width: Screen.width(context),
                                  decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
                                  padding: EdgeInsets.all(12),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('Signature').fontWeight(FontWeight.w700),
                                    Expanded(
                                      child: Image.network('${ApiService.fileStorageEndPoint}${model.doctorDetails['esign'].toString()}'),
                                    )
                                  ])))
                          : Container(
                              height: 200,
                              width: Screen.width(context),
                              decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Signature').fontWeight(FontWeight.w700),
                                  Expanded(
                                    child: Center(
                                      child: AspectRatio(
                                        aspectRatio: 2.0,
                                        child: Stack(
                                          children: <Widget>[
                                            Container(
                                              constraints: BoxConstraints.expand(),
                                              color: Colors.white,
                                              child: HandSignaturePainterView(
                                                control: control,
                                                type: SignatureDrawType.shape,
                                              ),
                                            ),
                                            CustomPaint(
                                              painter: DebugSignaturePainterCP(
                                                control: control,
                                                cp: false,
                                                cpStart: false,
                                                cpEnd: false,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          control.clear();
                                          rawImageFit.value = null;
                                        },
                                        child: Text('clear').textColor(Colors.black38),
                                      )
                                    ],
                                  ),
                                ],
                              )),
                      UIHelper.verticalSpaceMedium,
                      model.doctorDetails['esign'] != null
                          ? SizedBox(
                              height: 50,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      rawImageFit.value = await control.toImage(
                                        color: Colors.black,
                                        background: Colors.white,
                                      );
                                      if (rawImageFit.value != null) {
                                        Loader.show(context);
                                        final Uint8List bytes = rawImageFit.value!.buffer.asUint8List();
                                        await model.getImagetoFile(bytes);
                                        Future.delayed(Duration(seconds: 4), () {
                                          Loader.hide();
                                        });

                                        //Get.back();
                                        Get.back(result: {'refresh': true});
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CustomDialogBox(
                                                title: "Alert !",
                                                descriptions: "Please Sign...",
                                                descriptions1: "",
                                                text: "OK",
                                              );
                                            });
                                      }
                                    },
                                    child: Text('Submit').bold(),
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(Size(220, 36)),
                                      backgroundColor: MaterialStateProperty.all(activeColor),
                                    )),
                              ],
                            ),
                      UIHelper.verticalSpaceMedium
                    ])));
          },
          viewModelBuilder: () => DoctorDeclarationViewModel()),
    );
  }
}

HandSignatureControl control = new HandSignatureControl(
  threshold: 0.01,
  smoothRatio: 0.65,
  velocityRange: 2.0,
);

ValueNotifier<ByteData?> rawImageFit = ValueNotifier<ByteData?>(null);

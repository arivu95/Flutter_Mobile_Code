import 'dart:convert';
import 'dart:io';

import 'package:doctor_module/src/ui/doctor_profile/doctor_service_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/email_validator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_date_picker.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/signup_viewmodel.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:badges/badges.dart';
import 'package:swarapp/shared/app_static_bar.dart';

class DoctorServicesView extends StatefulWidget {
  dynamic serviceInfo;
  DoctorServicesView({Key? key, this.serviceInfo}) : super(key: key);

  @override
  _DoctorServicesViewState createState() => _DoctorServicesViewState();
}

class _DoctorServicesViewState extends State<DoctorServicesView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  PreferencesService preferencesService = locator<PreferencesService>();
  List<String> selectedData = [];

  @override
  void initState() {
    super.initState();
    setState(() {
  
   if (widget.serviceInfo['doctor_services'] != null) {
        if (widget.serviceInfo['doctor_services'].length > 0) {
          selectedData = new List<String>.from(widget.serviceInfo['doctor_services']);
        }
      }
    });
  }

  Widget servicesWidget(String title, String url) {
    return GestureDetector(
      onTap: () {
        if (selectedData.contains(title)) {
          selectedData.remove(title);
        } else {
          selectedData.add(title);
        }
        setState(() {});
      },
      child: Badge(
        elevation: 2,
        badgeColor: selectedData.contains(title) ? Colors.green : Colors.white,
        badgeContent: Icon(Icons.done_outlined, size: 15, color: Colors.white),
        child: Container(
          width: Screen.width(context) / 2,
          padding: EdgeInsets.only(left: 5, top: 10, bottom: 10),
          decoration: UIHelper.accountCardwithShadow(6, 6, Colors.white),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(url, width: 30, height: 30),
                  SizedBox(width: 10),
                  Text(title, textAlign: TextAlign.center).fontSize(14).fontWeight(FontWeight.w600).textColor(Colors.black),
                  title == "Chat" ? Text('(Default)', textAlign: TextAlign.center).fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38) : SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget servicesListWidget(BuildContext context) {
    return Container(
        width: Screen.width(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          UIHelper.verticalSpaceSmall,
          Text('Services').fontWeight(FontWeight.w600),
          UIHelper.verticalSpaceMedium,
          Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(8),
                  child: servicesWidget('In clinic', 'assets/clinic.png'),
                )),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(8),
                  child: servicesWidget('Online', 'assets/online_img.png'),
                )),
              ]),
              UIHelper.verticalSpaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.all(8),
                    child: servicesWidget('Home visit', 'assets/home_visit_img.png'),
                  )),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.all(8),
                    child: servicesWidget('Chat', 'assets/chat_img.png'),
                  )),
                ],
              ),
              UIHelper.verticalSpaceLarge,
            ],
          ),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:SwarAppDoctorBar(isProfileBar: true),
      backgroundColor: Colors.white,
      body: Container(
        width: Screen.width(context),
        padding: EdgeInsets.all(10),
        child: ViewModelBuilder<DoctorServicesViewmodel>.reactive(
            onModelReady: (model) async {},
            builder: (context, model, child) {
              return Column(
                children: [
                  UIHelper.addHeader(context, "Profile", true),
                  Expanded(child: SingleChildScrollView(child: servicesListWidget(context))),
                  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                 Loader.show(context);
                                  await model.updateAboutme(selectedData);
                                  Loader.hide();
                                  Get.back();
                              },
                              child: Text('Save').bold(),
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(Size(220, 36)),
                                backgroundColor: MaterialStateProperty.all(Color(0xFF00C064)),
                              )),
                        ],
                      ),
                      UIHelper.verticalSpaceMedium
                ],
              );
            },
            viewModelBuilder: () => DoctorServicesViewmodel()),
      ),
    );
  }
}

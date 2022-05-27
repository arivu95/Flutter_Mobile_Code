import 'dart:ui';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:swarapp/ui/subscription/subscription_view.dart';
import 'package:member_module/src/ui/members/members_viewmodel.dart';

import 'dotted_line.dart';

class ProfileStageWidget extends StatefulWidget {
  final bool isContainer;
  const ProfileStageWidget({Key? key, required this.isContainer}) : super(key: key);

  get boolValue => null;

  get isDelete => "yes";

  @override
  _ProfileStageWidgetState createState() => _ProfileStageWidgetState();
}

class _ProfileStageWidgetState extends State<ProfileStageWidget> {
  bool isremove = false;
  SharedPreferences? prefs;
  String gt = "";
  int index = 1;
  dynamic levelStates = ['Entry', 'Enhanced', 'Verified', 'SWAR doctor'];
  set boolValue(String boolValue) {
    this.isremove = boolValue as bool;
  }

//SharedPreferences prefs = await SharedPreferences.getInstance();
  TextEditingController mailController = TextEditingController();
  bool get isDelete {
    return isremove;
  }

  void initState() {
    //await _prefs!.setString(prefUserLogin, cubeUser.login!);
    getStateLevel();
  }

  String radioValue = "phone";
  final validCharacters = RegExp(r'^[0-9]+$');
  final emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  Future getStateLevel() async {
    String userId = preferencesService.doctor_profile_id;
    String chk = preferencesService.doctorInfo['_id'];
    await locator<ApiService>().getStageProfile(userId);
    prefs = await SharedPreferences.getInstance();
    gt = preferencesService.doctorStageValue.toString();
    //gt = prefs!.getString('profile_level') != null && prefs!.getString('profile_level')!.isNotEmpty ? prefs!.getString('profile_level')! : '';
    //levelStates
    // index = levelStates.indexWhere((item) => item.toLowerCase() == gt.toLowerCase());
    // preferencesService.stage_level_count = gt.isNotEmpty ? index + 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
        stream: locator<PreferencesService>().doctorStageValue.outStream,
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.data != "") {
            index = levelStates.indexWhere((item) => item.toLowerCase() == snapshot.data!.toLowerCase());
            preferencesService.stage_level_count = index + 1;
            return Container(
                decoration: widget.isContainer ? UIHelper.roundedBorderWithColorWithShadow(6, Colors.white) : null,
                padding: EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  widget.isContainer
                      ? Text(
                          '     Profile Stages with SWAR',
                          textAlign: TextAlign.center,
                        ).fontWeight(FontWeight.w600)
                      : SizedBox(),
                  widget.isContainer ? UIHelper.verticalSpaceSmall : SizedBox(),
                  Row(
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
                              for (int i = 1; i <= 4; i++)
                                Column(
                                  children: [
                                    //Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text(state).fontWeight(FontWeight.w600)
                                    //state == gt
                                    preferencesService.stage_level_count== i || preferencesService.stage_level_count> i
                                        ? Container(
                                            width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, Colors.green, 1, borderColor: Colors.red), child: Icon(Icons.done, size: 20, color: Colors.white))
                                        : Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
                                    //levelStates
                                    Text(i == 4 ? 'Swar Dr.' : levelStates[i - 1]).fontWeight(FontWeight.w600)
                                  ],
                                ),
                            ],
                          ),
                        ],
                      )),
                      SizedBox(
                        width: 15,
                      ),
                    ],
                  )
                ]));
          } else {
            return Container(
                decoration: widget.isContainer ? UIHelper.roundedBorderWithColorWithShadow(6, Colors.white) : null,
                padding: EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  widget.isContainer
                      ? Text(
                          '     Profile Stages with SWAR',
                          textAlign: TextAlign.center,
                        ).fontWeight(FontWeight.w600)
                      : SizedBox(),
                  widget.isContainer ? UIHelper.verticalSpaceSmall : SizedBox(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: widget.isContainer ? 15 : 5,
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
                              for (int i = 1; i <= 4; i++)
                                Column(
                                  children: [
                                    //Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)), Text(state).fontWeight(FontWeight.w600)
                                    Container(width: 32, height: 32, decoration: UIHelper.roundedLineBorderWithColor(16, subtleColor, 1, borderColor: Colors.red)),
                                    //levelStates
                                    Text(i == 4 ? "Swar Dr. " : levelStates[i - 1]).fontWeight(FontWeight.w600)
                                  ],
                                ),
                            ],
                          ),
                        ],
                      )),
                      SizedBox(
                        width: widget.isContainer ? 15 : 5,
                      ),
                    ],
                  )
                ]));
          }
        });
  }
}

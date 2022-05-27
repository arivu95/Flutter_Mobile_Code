import 'dart:ui';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swarapp/ui/subscription/subscription_view.dart';
import 'package:member_module/src/ui/members/members_viewmodel.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:documents_module/src/ui/uploads/uploads_view.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, descriptions, descriptions1, text;
  const CustomDialogBox({Key? key, required this.title, required this.descriptions, required this.descriptions1, required this.text, boolValue}) : super(key: key);

  get boolValue => null;

  get isDelete => "yes";

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  bool isremove = false;
  set boolValue(String boolValue) {
    this.isremove = boolValue as bool;
  }

  TextEditingController mailController = TextEditingController();
  bool get isDelete {
    return isremove;
  }

  String radioValue = "phone";
  final validCharacters = RegExp(r'^[0-9]+$');
  final emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  void radioButtonChanges(String value) {
    setState(() {
      radioValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ViewModelBuilder<MembersViewmodel>.reactive(
          onModelReady: (model) {},
          builder: (context, model, child) {
            return contentBox(context, model);
          },
          viewModelBuilder: () => MembersViewmodel()),
    );
  }

  contentBox(context, MembersViewmodel model) {
    return Stack(
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(left: Constants.padding, top: Constants.avatarRadius + Constants.padding, right: Constants.padding, bottom: Constants.padding),
            margin: EdgeInsets.only(top: Constants.avatarRadius),
            decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.white, borderRadius: BorderRadius.circular(Constants.padding), boxShadow: [
              BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            ]),
            child: (widget.title == "Invite")
                ?
                //invite mail dialogbox
                Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/invite_mail_popup.png',
                            fit: BoxFit.none,
                          ),
                          UIHelper.horizontalSpaceMedium,
                          Text(
                            'Invite New Members',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      FormBuilderTextField(
                        name: 'email',
                        controller: mailController,
                        autocorrect: false,
                        onChanged: (value) {
                          print(value);
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 20),
                          hintText: 'Email Id / Mobile Number',
                          filled: true,
                          fillColor: Colors.white70,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                          ),
                          focusedBorder: UIHelper.getInputBorder(1, borderColor: Color(0xFFCCCCCC)),
                          focusedErrorBorder: UIHelper.getInputBorder(1),
                          errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                          FormBuilderValidators.email(context),
                        ]),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                            visualDensity: VisualDensity.compact,
                            activeColor: activeColor,
                            value: 'phone',
                            groupValue: radioValue,
                            onChanged: (value) {
                              setState(() {
                                radioValue = 'phone';
                              });
                            },
                          ),
                          Text('Phone'),
                          UIHelper.horizontalSpaceMedium,
                          Radio(
                            visualDensity: VisualDensity.compact,
                            activeColor: activeColor,
                            value: 'email',
                            groupValue: radioValue,
                            onChanged: (value) {
                              setState(() {
                                radioValue = 'email';
                              });
                            },
                          ),
                          Text('Email')
                        ],
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: TextButton.styleFrom(
                                primary: Colors.black,
                                backgroundColor: Colors.grey[400],
                              ),
                            ),
                            UIHelper.horizontalSpaceMedium,
                            TextButton(
                              onPressed: () {
                                print('radio ===' + radioValue);
                                String mail = mailController.text.toString();
                                if (radioValue == "email") {
                                  if (emailValid.hasMatch(mail)) {
                                    model.getInviteMember(mail);
                                    Fluttertoast.showToast(
                                      msg: "Invite has been sent !",
                                      backgroundColor: Colors.greenAccent,
                                      gravity: ToastGravity.TOP,
                                      textColor: Colors.black,
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Invalid Mail Id !",
                                      backgroundColor: Colors.red,
                                      gravity: ToastGravity.TOP,
                                      textColor: Colors.white,
                                    );
                                  }
                                } else {
                                  print('number');
                                  if (validCharacters.hasMatch(mail)) {
                                    model.getInviteMemberMobile(mail);
                                    Fluttertoast.showToast(
                                      msg: "Invite has been sent !",
                                      backgroundColor: Colors.greenAccent,
                                      gravity: ToastGravity.TOP,
                                      textColor: Colors.black,
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Invalid mobile number !",
                                      backgroundColor: Colors.red,
                                      gravity: ToastGravity.TOP,
                                      textColor: Colors.white,
                                    );
                                  }
                                }
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Send',
                                style: TextStyle(fontSize: 18),
                              ),
                              style: TextButton.styleFrom(
                                primary: Colors.white,
                                backgroundColor: activeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : (widget.title == "Confirm")
                    ?

                    //Delete confirmation
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            widget.title,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            widget.descriptions,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          Text(
                            widget.descriptions1,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  style: TextButton.styleFrom(
                                    primary: Colors.black,
                                    backgroundColor: Colors.grey[400],
                                  ),
                                ),
                                UIHelper.horizontalSpaceMedium,
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isremove = true;
                                    });

                                    //  setRemove(isremove);
                                    boolValue = isremove.toString();
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: activeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    :
//usual dialogbox
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            widget.title,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            widget.descriptions,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          Text(
                            widget.descriptions1 == "PLAN REDIRECTION" ? "" : widget.descriptions1,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          widget.descriptions1 != "PLAN REDIRECTION"
                              ? Align(
                                  //alignment: Alignment.bottomRight,
                                  alignment: Alignment.bottomCenter,
                                  child: TextButton(
                                      onPressed: () {
                                        if (widget.title == "Error" ||
                                            widget.title == "Warning !" ||
                                            widget.title == "Delete" ||
                                            widget.title == "Alert !" ||
                                            widget.title == "Not Allowed !" ||
                                            widget.title == "Download Complete") {
                                          Navigator.of(context).pop();
                                        } else if (widget.title == 'Excellent!') {
                                          Get.back(result: {'refresh': true});
                                        } else if (widget.title == 'Success !  ') {
                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                        } else if (widget.title == 'New Feature!') {
                                          Navigator.of(context).pop();
                                        } else if (widget.title == 'Not Allowed !  ') {
                                          Get.back(result: {'refresh': true});
                                          Get.back(result: {'refresh': true});
                                          Get.back(result: {'refresh': true});
                                        } else {
                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                        }
                                      },
                                      child: Text(
                                        widget.text,
                                        style: TextStyle(fontSize: 18),
                                      )))
                              : Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          '   Cancel   ',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        style: TextButton.styleFrom(primary: Colors.white, backgroundColor: activeColor),
                                      ),
                                      UIHelper.horizontalSpaceMedium,
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Get.to(() => SubscriptionView());
                                        },
                                        child: Text(
                                          ' Subscribe ',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      )),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: (widget.title != "Invite") || (widget.title != "Confirm") ? ClipRRect(borderRadius: BorderRadius.all(Radius.circular(Constants.avatarRadius)), child: Image.asset("assets/swar_logo.png")) : null,
          ),
        ),
      ],
    );
  }
}

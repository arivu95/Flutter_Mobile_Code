import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/background_view.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/start_viewmodel.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class StartView extends StatefulWidget {
  StartView({Key? key}) : super(key: key);

  @override
  _StartViewState createState() => _StartViewState();
}

class _StartViewState extends State<StartView> with RestorationMixin {
  NavigationService navigationService = locator<NavigationService>();
  String radioValue = "phone";

  void radioButtonChanges(String value) {
    setState(() {
      radioValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ViewModelBuilder<StartViewModel>.reactive(
          builder: (context, model, child) {
            return BackgroundView(
              child: Container(
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/swar_logo.png'),
                    UIHelper.verticalSpaceLarge,
                    UIHelper.verticalSpaceMedium,
                    Text('Get started').fontWeight(FontWeight.w600).fontSize(20),
                    SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio(
                          visualDensity: VisualDensity.compact,
                          activeColor: blackColor,
                          value: 'phone',
                          groupValue: radioValue,
                          onChanged: (value) {
                            setState(() {
                              radioValue = 'phone';
                            });
                          },
                        ),
                        Text("Phone", style: radioValue == 'phone' ? TextStyle(fontWeight: FontWeight.w900, fontSize: 15) : TextStyle(fontWeight: FontWeight.w600)),
                        UIHelper.horizontalSpaceSmall,
                        Radio(
                          visualDensity: VisualDensity.compact,
                          activeColor: blackColor,
                          value: 'email',
                          groupValue: radioValue,
                          onChanged: (value) {
                            setState(() {
                              radioValue = 'email';
                            });
                          },
                        ),
                        Text("Email", style: radioValue == 'email' ? TextStyle(fontWeight: FontWeight.w900, fontSize: 15) : TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  Loader.show(context);
                                  bool result = await model.azureSignup(radioValue, false);

                                  if (result == false) {
                                    Loader.hide();
                                    // locator<DialogService>().showDialog(title: 'Error', description: 'Something went wrong. Try after sometime');
                                    return;
                                  }

                                  final isUserExists = await model.checkUserExist();
                                  Loader.hide();
                                  if (isUserExists == "User Exists") {
                                    if (preferencesService.userInfo['login_role_id'] == '61e7a9e44c559c1530e0e562' || preferencesService.userInfo['login_role_id'] == '61e7aa154c559c1530e0e564') {
                                      navigationService.clearStackAndShow(RoutePaths.DoctorDashboard);
                                    } else {
                                      preferencesService.user_login = 'Login';
                                      preferencesService.current_index = '0';
                                      navigationService.clearStackAndShow(RoutePaths.Dashboard);
                                    }
                                  } else if (isUserExists == "Member becomes User") {
                                    preferencesService.user_login = 'Signup';
                                    preferencesService.current_index = '0';
                                    navigationService.clearStackAndShow(RoutePaths.RoleSelect);
                                  } else if (isUserExists == "New User") {
                                    preferencesService.user_login = 'Signup';
                                    preferencesService.current_index = '0';
                                    navigationService.clearStackAndShow(RoutePaths.RoleSelect);
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Warning",
                                            descriptions: "Your account has been deactivated",
                                            descriptions1: "",
                                            text: "OK",
                                          );
                                        });
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text('Existing User').fontSize(15).fontWeight(FontWeight.w600),
                                    ),
                                    UIHelper.verticalSpaceTiny,
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text('Login').fontSize(17).fontWeight(FontWeight.w900),
                                    ),
                                  ],
                                ),
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(130, 55)),
                                  backgroundColor: MaterialStateProperty.all(activeColor),
                                )),
                          ],
                        ),
                        UIHelper.horizontalSpaceMedium,
                        Column(
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  Loader.show(context);
                                  bool result = await model.azureSignup(radioValue, true);

                                  if (result == false) {
                                    Loader.hide();
                                    // locator<DialogService>().showDialog(title: 'Error', description: 'Something went wrong. Try after sometime');
                                    return;
                                  }

                                  final isUserExists = await model.checkUserExist();
                                  Loader.hide();
                                  if (isUserExists == "User Exists") {
                                    preferencesService.user_login = 'Signup';
                                    preferencesService.current_index = '0';
                                    navigationService.clearStackAndShow(RoutePaths.Dashboard);
                                  } else if (isUserExists == "User Exists,healthprovider") {
                                    navigationService.clearStackAndShow(RoutePaths.DoctorDashboard);
                                  } else if (isUserExists == "Member becomes User") {
                                    preferencesService.user_login = 'Signup';
                                    preferencesService.current_index = '0';
                                    navigationService.clearStackAndShow(RoutePaths.RoleSelect);
                                  } else if (isUserExists == "New User") {
                                    preferencesService.user_login = 'Signup';
                                    preferencesService.current_index = '0';
                                    navigationService.clearStackAndShow(RoutePaths.RoleSelect);
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Warning",
                                            descriptions: "Your account has been deactivated",
                                            descriptions1: "",
                                            text: "OK",
                                          );
                                        });
                                  }

                                  // If true
                                  // check if the email exists
                                  // if exist, go to dashboard
                                  // else go to languate, profile and dashboard
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text('New User').fontSize(15).fontWeight(FontWeight.w600),
                                    ),
                                    UIHelper.verticalSpaceTiny,
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text('Register').fontSize(17).fontWeight(FontWeight.w900),
                                    ),
                                  ],
                                ),
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(Size(130, 55)),
                                  backgroundColor: MaterialStateProperty.all(activeColor),
                                )),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 100),
                  ],
                )),
              ),
            );
          },
          viewModelBuilder: () => StartViewModel()),
    );
  }

  @override
  // TODO: implement restorationId
  String? get restorationId => 'start_view';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // TODO: implement restoreState
    print('RESTORATION ->> start_view');
  }
}

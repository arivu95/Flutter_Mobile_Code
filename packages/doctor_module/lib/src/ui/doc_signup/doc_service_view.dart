import 'package:doctor_module/src/ui/doc_signup/doc_service_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:badges/badges.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_profile_stages_view.dart';

class DocServicesView extends StatefulWidget {
  dynamic serviceInfo;
  DocServicesView({Key? key, this.serviceInfo}) : super(key: key);

  @override
  _DocServicesViewState createState() => _DocServicesViewState();
}

class _DocServicesViewState extends State<DocServicesView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  PreferencesService preferencesService = locator<PreferencesService>();
  List<String> selectedData = ['Chat'];
  String localPath = '';
  String cover_localPath = '';
  var spl_cat;
  Map<String, dynamic> serverInfo = {};
  // TextEditingController specializationcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      // if (widget.serviceInfo['specialization'] != null) {
      //   specializationcontroller = widget.serviceInfo['specialization'];
      // }
    });
  }

  Widget imageItem(String asset) {
    return Image.asset(
      asset,
      height: 70,
    );
  }

  Widget servicesWidget(String title, String url) {
    return GestureDetector(
      onTap: () {
        if (selectedData.contains(title)) {
          selectedData.remove(title);
          selectedData.isEmpty;
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

  Widget specialization(BuildContext context, DocServiceViewmodel model) {
    return Container(
      //  child: FormBuilder(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        UIHelper.verticalSpaceMedium,
        Text('Type of Medical Practice').bold().fontSize(15),
        UIHelper.verticalSpaceMedium,
        Container(
            padding: EdgeInsets.all(12),
            decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                imageItem('assets/service_img.png'),
                UIHelper.verticalSpaceSmall,
                model.profile_Info['medical_practice'] != null ? Text(model.profile_Info['medical_practice']).bold().fontSize(15) : Text('Allopathy').bold().fontSize(15)
              ],
            )),
        UIHelper.verticalSpaceSmall,
        Text('or').bold(),
        UIHelper.verticalSpaceSmall,
        Container(
          height: 45,
          padding: EdgeInsets.only(left: 1),
          decoration: UIHelper.roundedLineBorderWithColor(12, subtleColor, 1),
          child: SizedBox(
            width: Screen.width(context) / 1.7,
            child: FormBuilderDropdown(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: UIHelper.getInputBorder(1),
                focusedBorder: UIHelper.getInputBorder(1),
                focusedErrorBorder: UIHelper.getInputBorder(1),
                errorBorder: UIHelper.getInputBorder(1),
              ),
              name: "medical_practice",
              hint: Text('Choose from drop down').fontSize(13),
              items: ['Allopathy', 'Ayurveda', 'Chinese medicine', 'Homeopathy', 'Naturopathy', 'Osteopathy', 'Siddha', 'Unani', 'Yoga', 'Others']
                  .map((splGrp) => DropdownMenuItem(
                        //value: grp,
                        value: splGrp,
                        child: Text("$splGrp").textColor(Colors.black).fontSize(14),
                      ))
                  .toList(),
              onChanged: (value) async {
                setState(() {
                  serverInfo['medical_practice'] = value;
                });
                await model.updateUserProfile(serverInfo, '', '');
              },
              // onChanged: (value) async {
              //   setState(() {
              //     spl_cat = value;
              //   });
              //   // altercode = _doctorcountrycodeController;
              //   // altercode['countryCode_digits'] = altercode;
              // },
            ),
          ),
        ),
        UIHelper.verticalSpaceMedium,
        UIHelper.verticalSpaceSmall,
      ]),
    );
  }

  Widget servicesListWidget(BuildContext context) {
    return Container(
        width: Screen.width(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          UIHelper.verticalSpaceSmall,
          Text('Choose your services').bold().fontSize(14),
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
              // ViewModelBuilder<DocServiceViewmodel>.reactive(
              //     onModelReady: (model) async {
              //       // await model.getCountries();
              //     },
              //     builder: (context, model, child) {
              //       return Column(
              //         children: [
              //           ElevatedButton(
              //             onPressed: () async {
              //               Map<String, dynamic> postParams = Map.from(_fbKey.currentState!.value);
              //               Loader.show(context);
              //               // await model.registerUser(postParams, localPath);
              //               Loader.hide();
              //             },
              //             child: Text('Continue').fontWeight(FontWeight.w700).fontSize(20),
              //             style: ButtonStyle(
              //               minimumSize: MaterialStateProperty.all(Size(150, 38)),
              //               backgroundColor: MaterialStateProperty.all(submitBtnColor),
              //             ),
              //           ),
              //         ],
              //       );
              //     },
              //     viewModelBuilder: () => DocServiceViewmodel()),
            ],
          ),
        ]));
  }

  Widget getFields(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Container(
          padding: EdgeInsets.all(1),
          width: Screen.width(context),
          child: FormBuilder(
              initialValue: {
                // 'specialization': widget.serviceInfo['specialization'] ?? null,
              },
              key: _fbKey,
              child: Column(
                children: [
                  Column(children: [
                    servicesListWidget(context),
                    ViewModelBuilder<DocServiceViewmodel>.reactive(
                        builder: (context, model, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              selectedData.isEmpty
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        // Loader.show(context);
                                        // await model.updateservices(selectedData);
                                        // Loader.hide();
                                        // Get.to(() => DoctorProfileStagesView());
                                      },
                                      child: Text('Continue').fontWeight(FontWeight.w700).fontSize(20),
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(Size(150, 38)),
                                        backgroundColor: MaterialStateProperty.all(disabledColor),
                                      ))
                                  : ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          preferencesService.select_services = 'true';
                                        });
                                        Loader.show(context);
                                        await model.updateservices(selectedData);
                                        Loader.hide();
                                        Get.to(() => DoctorProfileStagesView());
                                      },
                                      child: Text('Continue').fontWeight(FontWeight.w700).fontSize(20),
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(Size(150, 38)),
                                        backgroundColor: MaterialStateProperty.all(submitBtnColor),
                                      )),
                              // ElevatedButton(

                              //     child: Text('Cancel').textColor(Colors.white),
                              //     style: ButtonStyle(
                              //         minimumSize: MaterialStateProperty.all(Size(80, 32)),
                              //         elevation: MaterialStateProperty.all(0),
                              //         backgroundColor: MaterialStateProperty.all(activeColor),
                              //         shape: MaterialStateProperty.all(
                              //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              //         ))),
                            ],
                          );
                        },
                        viewModelBuilder: () => DocServiceViewmodel()),
                  ])
                ],
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarStaticBar(),
      backgroundColor: Colors.white,
      body: Container(
        decoration: UIHelper.roundedBorderWithColorWithShadow(6, bg_color),
        width: Screen.width(context),
        padding: EdgeInsets.all(10),
        child: ViewModelBuilder<DocServiceViewmodel>.reactive(
            onModelReady: (model) async {},
            builder: (context, model, child) {
              return Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [UIHelper.verticalSpaceMedium, specialization(context, model), getFields(context)],
                      ),
                    ),
                  )),
                ],
              );
            },
            viewModelBuilder: () => DocServiceViewmodel()),
      ),
    );
  }
}

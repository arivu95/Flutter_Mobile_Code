import 'package:doctor_module/src/ui/doc_online_booking/top_specalities_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:user_module/src/ui/doctor_nurse/doctor_nurse_view.dart';
import 'package:doctor_module/src/ui/doc_online_booking/doc_list_view.dart';

class TopSpecialistView extends StatefulWidget {
  final String servicetype;
  TopSpecialistView({Key? key, required this.servicetype}) : super(key: key);

  @override
  _TopSpecialistViewState createState() => _TopSpecialistViewState();
}

class _TopSpecialistViewState extends State<TopSpecialistView> {
  PreferencesService preferencesService = locator<PreferencesService>();
  TextEditingController searchController = TextEditingController();

  String selectedTab = '';

  bool select_personal = false;
  bool select_doc = false;
  var ele_ment;
  bool isSearch = false;

  @override
  Widget addHeader(BuildContext context, bool isBackBtnVisible) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back,
                  size: 20,
                ),
              ),
              Text(widget.servicetype == "Home visit" ? 'Appointment with Home visit doctor' : 'Appointment with doctor').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
        ],
      ),
    );
  }

  Widget showSearchField(BuildContext context, SpecialistViewmodel model) {
    return SizedBox(
      height: 54,
      child: Container(
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    //  model.getDoctorList(value);
                    setState(() {
                      isSearch = true;
                    });
                  },
                  onEditingComplete: () async {
                    if (FocusScope.of(context).isFirstFocus) {
                      if (searchController.text != "") {
                        Get.to(() => DoctorListView(categoryTitle: searchController.text, servicetype: widget.servicetype, doctorsList: model.doc_total_list));
                      }
                    }
                  },
                  style: TextStyle(fontSize: 14),
                  decoration: new InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: activeColor,
                      size: 20,
                    ),
                    suffixIcon: searchController.text.isEmpty
                        ? SizedBox()
                        : IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.black38,
                            ),
                            onPressed: () {
                              searchController.clear();
                              // model.getDoctorList('');
                              setState(() {
                                isSearch = true;
                              });
                              FocusManager.instance.primaryFocus!.unfocus();
                            }),
                    contentPadding: EdgeInsets.only(left: 20),
                    enabledBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0x00CCCCCC)),
                    focusedBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                    focusedErrorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                    errorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                    filled: true,
                    hintStyle: new TextStyle(color: Colors.grey[800]),
                    hintText: "Search a doctor by Specialty, City, Hospital name",
                  ),
                ),
              ),
            ),
            // Icon(
            //   Icons.filter_alt_rounded,
            // ),
          ],
        ),
      ),
    );
  }

  Widget getTextWidgets(BuildContext context, SpecialistViewmodel model) {
    List<dynamic> catList = [];

    List<Widget> list = <Widget>[];

    for (var i = 0; i < model.loginRole.length; i++) {
      String imgUrl = '${ApiService.imageStorageEndPoint}${model.loginRole[i]['specialization_image']}';
      if (model.loginRole[i]['specialization_category'] == 'general') {
        list.add(new GestureDetector(
            onTap: () {
              if (widget.servicetype == "Home visit") {
                selectedTab = model.loginRole[i]['specialization'];
                Get.to(() => DoctorNurseView(categoryTitle: selectedTab, servicetype: widget.servicetype));
              } else {
                selectedTab = model.loginRole[i]['specialization'];
                Get.to(() => DoctorListView(categoryTitle: selectedTab, servicetype: widget.servicetype, doctorsList: model.doc_total_list));
              }
            },
            child: Column(children: [
              Container(
                width: Screen.width(context) / 5,
                height: 70,
                padding: EdgeInsets.all(12),
                decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: disabledColor),
                // child: Image.network(img_url, width: 60, height: 60),
                child: Image.asset(
                  'assets/covid19.png',
                  height: 60,
                  width: 60,
                ),
              ),
              UIHelper.verticalSpaceTiny,
              Container(
                width: Screen.width(context) / 5,
                child: Text(model.loginRole[i]['specialization']).fontSize(10).fontWeight(FontWeight.w500).textAlignment(TextAlign.center),
              )
            ])));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text('Top Specialties').fontSize(16).fontWeight(FontWeight.w600),
      ),
      UIHelper.verticalSpaceSmall,
      Wrap(spacing: 10, runSpacing: 15, children: list),
    ]);
  }

  Widget getsurgeonsWidgets(BuildContext context, SpecialistViewmodel model) {
    List<Widget> list = <Widget>[];

    for (var i = 0; i < model.loginRole.length; i++) {
      String imgUrl = '${ApiService.imageStorageEndPoint}${model.loginRole[i]['specialization_image']}';
      if (model.loginRole[i]['specialization_category'] == 'surgeon') {
        list.add(new GestureDetector(
            onTap: () {
              if (widget.servicetype == "Home visit") {
                selectedTab = model.loginRole[i]['specialization'];
                Get.to(() => DoctorNurseView(categoryTitle: selectedTab, servicetype: widget.servicetype));
              } else {
                selectedTab = model.loginRole[i]['specialization'];
                Get.to(() => DoctorListView(categoryTitle: selectedTab, servicetype: widget.servicetype, doctorsList: model.doc_total_list));
              }
            },
            child: Column(children: [
              Container(
                width: Screen.width(context) / 5,
                height: 70,
                padding: EdgeInsets.all(12),
                decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: disabledColor),
                child: Image.asset(
                  'assets/covid19.png',
                  height: 60,
                  width: 60,
                ),
              ),
              UIHelper.verticalSpaceTiny,
              Container(
                width: Screen.width(context) / 5,
                child: Text(model.loginRole[i]['specialization']).fontSize(10).fontWeight(FontWeight.w500).textAlignment(TextAlign.center),
              )
            ])));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text('Surgeons').fontSize(16).fontWeight(FontWeight.w600),
      ),
      UIHelper.verticalSpaceSmall,
      Wrap(spacing: 10, runSpacing: 15, children: list),
    ]);
  }

  Widget getothersWidgets(BuildContext context, SpecialistViewmodel model) {
    List<Widget> list = <Widget>[];

    // for (String get in model.loginRole) {
    //   print("GDFSFSDFSDFSDF" + get.toString());
    // }

    for (var i = 0; i < model.loginRole.length; i++) {
      String imgUrl = '${ApiService.imageStorageEndPoint}${model.loginRole[i]['specialization_image']}';
      // list.add(new Text(model.loginRole[i]['specialization']));
      // for(List get in model.loginRole)
      // get['category'] == general
      // add in list
      if (model.loginRole[i]['specialization_category'] == 'others') {
        list.add(new GestureDetector(
            onTap: () {
              if (widget.servicetype == "Home visit") {
                selectedTab = model.loginRole[i]['specialization'];
                Get.to(() => DoctorNurseView(categoryTitle: selectedTab, servicetype: widget.servicetype));
              } else {
                selectedTab = model.loginRole[i]['specialization'];
                Get.to(() => DoctorListView(categoryTitle: selectedTab, servicetype: widget.servicetype, doctorsList: model.doc_total_list));
              }
            },
            child: Column(children: [
              Container(
                width: Screen.width(context) / 5,
                height: 70,
                padding: EdgeInsets.all(12),
                decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: disabledColor),
                // child: Image.network(img_url, width: 60, height: 60),
                child: Image.asset(
                  'assets/covid19.png',
                  height: 60,
                  width: 60,
                ),
                // child: img_url.isNotEmpty ? Image.asset(img_url) : Text(''),
                // child: Image.network(img_url != null || img_url != "" ? img_url : "", width: 20, height: 20),
              ),
              UIHelper.verticalSpaceTiny,
              Container(
                width: Screen.width(context) / 5,
                child: Text(model.loginRole[i]['specialization']).fontSize(10).fontWeight(FontWeight.w500).textAlignment(TextAlign.center),
              )
            ])));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text('Others').fontSize(16).fontWeight(FontWeight.w600),
      ),
      UIHelper.verticalSpaceSmall,
      Wrap(spacing: 10, runSpacing: 15, children: list),
    ]);
  }

  Widget getayurvedaWidgets(BuildContext context, SpecialistViewmodel model) {
    List<Widget> list = <Widget>[];

    // for (String get in model.loginRole) {
    //   print("GDFSFSDFSDFSDF" + get.toString());
    // }

    for (var i = 0; i < model.loginRole.length; i++) {
      String imgUrl = '${ApiService.imageStorageEndPoint}${model.loginRole[i]['specialization_image']}';
      // list.add(new Text(model.loginRole[i]['specialization']));
      // for(List get in model.loginRole)
      // get['category'] == general
      // add in list
      if (model.loginRole[i]['specialization_category'] == 'ayurveda') {
        list.add(new GestureDetector(
            onTap: () {
              if (widget.servicetype == "Home visit") {
                selectedTab = model.loginRole[i]['specialization'];
                Get.to(() => DoctorNurseView(categoryTitle: selectedTab, servicetype: widget.servicetype));
              } else {
                selectedTab = model.loginRole[i]['specialization'];
                Get.to(() => DoctorListView(categoryTitle: selectedTab, servicetype: widget.servicetype, doctorsList: model.doc_total_list));
              }
            },
            child: Column(children: [
              Container(
                width: Screen.width(context) / 5,
                height: 70,
                padding: EdgeInsets.all(12),
                decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: disabledColor),
                child: Image.network(imgUrl, width: 60, height: 60),
              ),
              UIHelper.verticalSpaceTiny,
              Container(
                width: Screen.width(context) / 5,
                child: Text(model.loginRole[i]['specialization']).fontSize(10).fontWeight(FontWeight.w500).textAlignment(TextAlign.center),
              )
            ])));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text('Ayurveda').fontSize(16).fontWeight(FontWeight.w600),
            ),
          ],
        ),
        UIHelper.verticalSpaceSmall,
        Wrap(spacing: 10, runSpacing: 15, children: list),
      ]),
    );
  }

  Widget gethomeoWidgets(BuildContext context, SpecialistViewmodel model) {
    List<Widget> list = <Widget>[];

    // for (String get in model.loginRole) {
    //   print("GDFSFSDFSDFSDF" + get.toString());
    // }

    for (var i = 0; i < model.loginRole.length; i++) {
      String imgUrl = '${ApiService.imageStorageEndPoint}${model.loginRole[i]['specialization_image']}';
      // list.add(new Text(model.loginRole[i]['specialization']));
      // for(List get in model.loginRole)
      // get['category'] == general
      // add in list
      if (model.loginRole[i]['specialization_category'] == 'homeopathy') {
        list.add(new GestureDetector(
            onTap: () {
              selectedTab = model.loginRole[i]['specialization'];
              Get.to(() => DoctorListView(categoryTitle: selectedTab, servicetype: widget.servicetype, doctorsList: model.doc_total_list));
            },
            child: Column(children: [
              Container(
                width: Screen.width(context) / 5,
                height: 70,
                padding: EdgeInsets.all(12),
                decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: disabledColor),
                // child: Image.network(img_url, width: 60, height: 60),
                child: Image.asset(
                  'assets/covid19.png',
                  height: 60,
                  width: 60,
                ),
                // child: img_url.isNotEmpty ? Image.asset(img_url) : Text(''),
                // child: Image.network(img_url != null || img_url != "" ? img_url : "", width: 20, height: 20),
              ),
              UIHelper.verticalSpaceTiny,
              Container(
                width: Screen.width(context) / 5,
                child: Text(model.loginRole[i]['specialization']).fontSize(10).fontWeight(FontWeight.w500).textAlignment(TextAlign.center),
              )
            ])));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text('Homeopathy').fontSize(16).fontWeight(FontWeight.w600),
            ),
          ],
        ),
        UIHelper.verticalSpaceSmall,
        Wrap(spacing: 10, runSpacing: 15, children: list),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppStaticBar(),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(12),
        child: ViewModelBuilder<SpecialistViewmodel>.reactive(
            onModelReady: (model) async {
              Loader.show(context);
              await model.getLoginRole();
              Loader.hide();
            },
            builder: (context, model, child) {
              return Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          addHeader(context, true),
                          UIHelper.verticalSpaceSmall,
                          showSearchField(context, model),
                          UIHelper.verticalSpaceSmall,
                          getTextWidgets(context, model),
                          UIHelper.verticalSpaceTiny,
                          getsurgeonsWidgets(context, model),
                          UIHelper.verticalSpaceTiny,
                          getayurvedaWidgets(context, model),
                          UIHelper.verticalSpaceTiny,
                          gethomeoWidgets(context, model),
                          UIHelper.verticalSpaceTiny,
                          getothersWidgets(context, model),

                          // specialities(context, model),
                          // UIHelper.verticalSpaceSmall,
                          // surgeons(context, model),
                        ],
                      ),
                    ),
                  )),
                ],
              );
            },
            viewModelBuilder: () => SpecialistViewmodel()),
      ),
    );
  }
}

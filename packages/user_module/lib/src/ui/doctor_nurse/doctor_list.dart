import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:user_module/src/ui/doctor_nurse/doctor_profile_view.dart';

class DoctorListView extends StatefulWidget {
  DoctorListView({Key? key}) : super(key: key);
  @override
  _DoctorListViewState createState() => _DoctorListViewState();
}

class _DoctorListViewState extends State<DoctorListView> {
  TextEditingController searchController = TextEditingController();

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
                  Icons.arrow_back_ios,
                  size: 20,
                ),
              ),
              Text('Covid-19 Doctors Nearby').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
        ],
      ),
    );
  }

  Widget showSearchField(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {},
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
                                FocusManager.instance.primaryFocus!.unfocus();
                              }),
                      contentPadding: EdgeInsets.only(left: 20),
                      enabledBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedErrorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      errorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "chennai",
                      fillColor: fieldBgColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nurseList(
    BuildContext context,
  ) {
    return Container(
        padding: EdgeInsets.all(4),
        width: Screen.width(context),
        decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              Image.asset(
                'assets/doctor.png',
                height: 90,
              ),
              UIHelper.verticalSpaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.call,
                    color: Colors.black38,
                    size: 20,
                  ),
                  UIHelper.horizontalSpaceSmall,
                  Icon(
                    Icons.videocam,
                    color: Colors.black38,
                    size: 20,
                  ),
                  UIHelper.horizontalSpaceSmall,
                  Icon(
                    Icons.textsms_outlined,
                    color: Colors.black38,
                    size: 20,
                  ),
                ],
              )
            ]),
            UIHelper.horizontalSpaceSmall,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available in 5 min').fontSize(8).fontWeight(FontWeight.w600).textColor(Colors.green),
                UIHelper.verticalSpaceTiny,
                Text('Dr.Ganesh').fontSize(12).fontWeight(FontWeight.w600),
                UIHelper.verticalSpaceTiny,
                Text('General Physician').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                UIHelper.verticalSpaceSmall,
                Text('M.B.B.S, Diploma \n Family Medicine').fontSize(9).fontWeight(FontWeight.w300),
                UIHelper.verticalSpaceTiny,
                Text('5 years experinece').fontSize(10).textColor(Colors.black38),
                UIHelper.verticalSpaceSmall,
                Text('Insurance ').fontSize(10).fontWeight(FontWeight.w600),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DoctorProfileView()),
                      );
                    },
                    child: Text('Book  Appointment').fontSize(10).textColor(Colors.white),
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(65, 22)),
                        backgroundColor: MaterialStateProperty.all(activeColor),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Patients visit').fontSize(10),
                    UIHelper.horizontalSpaceSmall,
                    Text('1.5K').fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor),
                  ],
                ),
                UIHelper.verticalSpaceMedium,
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
                  child: Column(
                    children: [
                      Text('Language known').fontSize(10),
                      UIHelper.verticalSpaceSmall,
                      Text('English, Tamil, \n Telugu').fontSize(9).fontWeight(FontWeight.w500),
                    ],
                  ),
                ),
                UIHelper.verticalSpaceLarge,
                Text('  2.5 kms Away ').fontSize(10).textColor(Colors.black38),
              ],
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppStaticBar(),
      body: SafeArea(
          top: false,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: Screen.width(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  addHeader(context, true),
                  showSearchField(context),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        UIHelper.verticalSpaceSmall,
                        nurseList(context),
                        UIHelper.verticalSpaceSmall,
                        nurseList(context),
                      ],
                    ),
                  ))
                ],
              ))),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:user_module/src/ui/doctor_nurse/doctor_list.dart';

class TopSpecialistView extends StatefulWidget {
  const TopSpecialistView({Key? key}) : super(key: key);

  @override
  _TopSpecialistViewState createState() => _TopSpecialistViewState();
}

class _TopSpecialistViewState extends State<TopSpecialistView> {
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
              Text('Appointment with doctor').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
        ],
      ),
    );
  }

  Widget showSearchField(BuildContext context) {
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
                              onPressed: () {}),
                      contentPadding: EdgeInsets.only(left: 20),
                      enabledBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0x00CCCCCC)),
                      focusedBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                      focusedErrorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                      errorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "Search a doctor by Specialty,City,Hospital name",
                      fillColor: fieldBgColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget iconCard(BuildContext context, String img_url, String title) {
    return GestureDetector(
        onTap: () {
          Get.to(() => DoctorListView());
        },
        child: Column(
          children: [
            Container(
              width: Screen.width(context) / 5,
              height: 70,
              padding: EdgeInsets.all(7),
              decoration: UIHelper.roundedBorderWithColorWithShadow(8, Colors.white, borderColor: disabledColor),
              child: img_url.isNotEmpty ? Image.asset(img_url) : Text(''),
            ),
            UIHelper.verticalSpaceTiny,
            Text(title).fontSize(12).fontWeight(FontWeight.w500),
          ],
        ));
  }

  Widget specialities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Specialities').fontSize(16).fontWeight(FontWeight.w600),
        UIHelper.verticalSpaceSmall,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            iconCard(context, 'assets/covid19.png', 'Covid-19'),
            iconCard(context, 'assets/baby.png', 'Pediatrics'),
            iconCard(context, 'assets/heart.png', 'Cardiology'),
            iconCard(context, 'assets/dermatology.png', 'Dermatology'),
          ],
        ),
        UIHelper.verticalSpaceSmall,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            iconCard(context, 'assets/respiratory.png', 'Respiratory '),
            iconCard(context, 'assets/physician.png', 'General\nphysician'),
            iconCard(context, 'assets/orthopedic.png', 'Orthopedic'),
            iconCard(context, 'assets/orthopedic.png', 'Nephrologist'),
          ],
        )
      ],
    );
  }

  Widget surgeons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Surgeons').fontSize(16).fontWeight(FontWeight.w600),
        UIHelper.verticalSpaceSmall,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            iconCard(context, '', 'General\nSurgeon'),
            iconCard(context, '', 'Gastro\nSurgeon'),
            iconCard(context, '', 'Plastic\nSurgeon'),
            iconCard(context, '', 'Neuro\nSurgeon'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppStaticBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UIHelper.verticalSpaceTiny,
                addHeader(context, true),
                UIHelper.verticalSpaceTiny,
                showSearchField(context),
                UIHelper.verticalSpaceSmall,
                specialities(context),
                UIHelper.verticalSpaceSmall,
                surgeons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:user_module/src/ui/appoinments/book_appointment_view.dart';

class DoctorProfileView extends StatefulWidget {
  DoctorProfileView({Key? key}) : super(key: key);
  @override
  _DoctorProfileViewState createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  Widget requestcard(
    BuildContext context,
  ) {
    return Container(
        width: Screen.width(context),
        height: 600,
        decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  width: Screen.width(context),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        'assets/doctor.png',
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              padding: EdgeInsets.all(5),
                              decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, Colors.white),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dr. Ganesh').fontSize(12).fontWeight(FontWeight.w600),
                                  UIHelper.verticalSpaceTiny,
                                  Text('General Physician').fontSize(10).textColor(Colors.black38),
                                  UIHelper.verticalSpaceSmall,
                                  Row(
                                    children: [
                                      Text('Insurance accepted').fontSize(10).fontWeight(FontWeight.w600),
                                      Icon(
                                        Icons.done,
                                        size: 20,
                                        color: Colors.green,
                                      )
                                    ],
                                  ),
                                ],
                              )),
                        ],
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          UIHelper.verticalSpaceSmall,
                          Container(
                            height: 20,
                            padding: EdgeInsets.only(left: 4, right: 4),
                            decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white70),
                            child: Row(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text('Favorite').fontSize(10).textColor(Colors.black87),
                                ),
                                UIHelper.horizontalSpaceSmall,
                                Icon(
                                  Icons.favorite_border,
                                  color: Colors.red,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                          UIHelper.verticalSpaceSmall,
                          Container(
                            height: 20,
                            padding: EdgeInsets.only(left: 4, right: 4),
                            decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white70),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.done_rounded,
                                  color: Colors.green,
                                  size: 14,
                                ),
                                UIHelper.horizontalSpaceSmall,
                                Text('Verified').fontSize(10).textColor(Colors.black87),
                              ],
                            ),
                          ),
                          UIHelper.verticalSpaceSmall,
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Patients',
                                  ).fontSize(10).fontWeight(FontWeight.w500),
                                  Text(
                                    'visit',
                                  ).fontSize(10).fontWeight(FontWeight.w500),
                                ],
                              ),
                              Text(' 1.5K').fontSize(16).fontWeight(FontWeight.w200).textColor(activeColor),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpaceMedium,
            Container(
              width: Screen.width(context),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                UIHelper.horizontalSpaceSmall,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SPECIALITIES').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                      UIHelper.verticalSpaceSmall,
                      Container(
                          child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                        Container(
                          height: 20,
                          padding: EdgeInsets.only(left: 4, right: 4),
                          decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white70),
                          child: Text('Medicines').fontSize(10).textColor(Colors.black87),
                        ),
                        UIHelper.horizontalSpaceSmall,
                        Container(
                          height: 20,
                          padding: EdgeInsets.only(left: 4, right: 4),
                          decoration: UIHelper.roundedBorderWithColorWithShadow(6, Colors.white70),
                          child: Text('General').fontSize(10).textColor(Colors.black87),
                        ),
                      ]))
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('LANGUAGE SPOKE').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                      UIHelper.verticalSpaceSmall,
                      Text('English,Tamil,Telugu').fontSize(10).fontWeight(FontWeight.w600).textColor(Colors.black),
                    ],
                  ),
                ),
              ]),
            ),
            UIHelper.verticalSpaceSmall,
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('  QUALIFICATION').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                  UIHelper.verticalSpaceSmall,
                  Text('  M.B.B.S, Diploma - Family Medicine').fontSize(10).fontWeight(FontWeight.w600).textColor(Colors.black),
                  UIHelper.verticalSpaceSmall,
                  Text('  ABOUT').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                  UIHelper.verticalSpaceSmall,
                  Text('     Lorem ipsum dolor sit amet, consectetur adipiscing elit. ').fontSize(10).fontWeight(FontWeight.w600).textColor(Colors.black),
                  UIHelper.verticalSpaceSmall,
                  UIHelper.hairLineWidget(),
                  UIHelper.verticalSpaceVeryLarge,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 80),
                        child: ElevatedButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BookAppointmentView()),
                              );
                            },
                            child: Text(' Book Appointment ', style: TextStyle(fontSize: 16)).bold(),
                            style: ButtonStyle(minimumSize: MaterialStateProperty.all(Size(160, 40)), backgroundColor: MaterialStateProperty.all(activeColor))),
                      ),
                    ],
                  )
                ],
              ),
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
                  UIHelper.verticalSpaceSmall,
                  UIHelper.addHeader(context, "Doctor Profile", true),
                  UIHelper.verticalSpaceSmall,
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        UIHelper.verticalSpaceSmall,
                        requestcard(context),
                      ],
                    ),
                  ))
                ],
              ))),
    );
  }
}

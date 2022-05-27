import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/pushnotification_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:doctor_module/src/ui/doc_online_booking/bookings_view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:doctor_module/src/ui/doc_online_booking/doc_detail_view.dart';
import 'package:user_module/src/ui/doctor_nurse/homevisit_model.dart';

class DoctorNurseView extends StatefulWidget {
  String servicetype;
  final String categoryTitle;
  //DoctorListView({Key? key, required this.categoryTitle}) : super(key: key);

  DoctorNurseView({Key? key, required this.categoryTitle, required this.servicetype}) : super(key: key);
  @override
  _DoctorNurseViewState createState() => _DoctorNurseViewState();
}

class _DoctorNurseViewState extends State<DoctorNurseView> {
  Homevisitmodel modelRef = Homevisitmodel();
  TextEditingController searchController = TextEditingController();
  int selectedIndex = 0;
  String selectedDoc = '';
  String start_year = '';
  String end_year = '';
  String workExperience = '';
  String Insurance = '';
  String ClinicName = '';
  String Fees = '';
  String Discount = '';
  String final_amount = '';
  List<dynamic> fees_list = [];
  List<dynamic> service_list = [];
  List<dynamic> category_list = [];
  dynamic selection = "Online";

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
              Text('Home visit').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
          Container(
              decoration: UIHelper.roundedLineBorderWithColor(12, fieldBgColor, 1),
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: activeColor,
                  ),
                  Text('Chennai').fontSize(12).bold(),
                ],
              )),
        ],
      ),
    );
  }

  Widget showSearchField(BuildContext context, Homevisitmodel model) {
    return SizedBox(
      height: 44,
      child: Container(
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    //  model.getdoctors_search(value);
                    setState(() {});
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
                                model.getdoctors_search('');
                                setState(() {});
                              }),
                      contentPadding: EdgeInsets.only(left: 20),
                      enabledBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedErrorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      errorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: selectedIndex == 0 ? "Search Doctor" : "Search Nurse",
                      fillColor: fieldBgColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectProfession(BuildContext context, Homevisitmodel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () async {
            setState(() {
              selectedIndex = 0;
            });
            // await model.getDoctorList(widget.categoryTitle, selectedIndex);
          },
          child: Container(
            decoration: selectedIndex == 0 ? UIHelper.rowSeperator(activeColor) : UIHelper.rowSeperator(Colors.white),
            padding: EdgeInsets.all(4),
            child: Text('Doctor').fontSize(16).fontWeight(FontWeight.w600),
          ),
        ),
        GestureDetector(
          onTap: () async {
            setState(() {
              selectedIndex = 1;
            });
            //   await model.getDoctorList(widget.categoryTitle, selectedIndex);
          },
          child: Container(
            decoration: selectedIndex == 1 ? UIHelper.rowSeperator(activeColor) : UIHelper.rowSeperator(Colors.white),
            padding: EdgeInsets.all(4),
            child: Text('Nurse').fontSize(16).fontWeight(FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget listview(BuildContext context, Homevisitmodel model) {
    return model.isBusy
        ? Center(
            child: UIHelper.swarPreloader(),
          )
        : Container(
            width: Screen.width(context),
            decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.transparent),
            child: Column(children: [
              model.doctorList.length > 0
                  ? ListView.builder(
                      itemCount: model.doctorList.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (model.doctorList[index]['doctor_profile_id']['experience'].length > 0) {
                          if (model.doctorList[index]['doctor_profile_id']['experience'][0]['startyear'] != "") {
                            Jiffy dt = Jiffy(model.doctorList[index]['doctor_profile_id']['experience'][0]['startyear']);
                            start_year = dt.format('yyyy');
                          }

                          if (model.doctorList[index]['doctor_profile_id']['experience'][0]['endyear'] != null && model.doctorList[index]['doctor_profile_id']['experience'][0]['endyear'] != "") {
                            Jiffy dt = Jiffy(model.doctorList[index]['doctor_profile_id']['experience'][0]['endyear']);
                            end_year = dt.format('yyyy');
                          }
                          if (model.doctorList[index]['doctor_profile_id']['experience'][0]['work_experience'] != null && model.doctorList[index]['doctor_profile_id']['experience'][0]['work_experience'] != "") {
                            int exper_int = int.parse(model.doctorList[index]['doctor_profile_id']['experience'][0]['work_experience']);
                            if (exper_int < 12) {
                              workExperience = '$exper_int  month';
                            } else {
                              double exper = exper_int / 12;
                              String work_experience = exper.toStringAsFixed(2).toString();
                              workExperience = '$work_experience year';
                            }
                          }
                        }

                        String qualification = '';
                        if (model.doctorList[index]['doctor_profile_id']['educational_information'].length > 0) {
                          for (int i = 0; model.doctorList[index]['doctor_profile_id']['educational_information'].length > i; i++) {
                            var qua = model.doctorList[index]['doctor_profile_id']['educational_information'][i]['qualification'];
                            if (qua != "" && qua != null) {
                              qualification != '' ? qualification = qualification + ',' + qua.toString() : qualification = qua.toString();
                            }
                          }
                        }

                        if (model.doctorList[index]['doctor_profile_id']['clinic_details'].length > 0) {
                          if (model.doctorList[index]['doctor_profile_id']['clinic_details'][0]['clinic_name'] != "") {
                            ClinicName = model.doctorList[index]['doctor_profile_id']['clinic_details'][0]['clinic_name'];
                          }
                        }
                        if ((model.doctorList[index]['doctor_profile_id']['insurance'] != null) && (model.doctorList[index]['doctor_profile_id']['insurance'].length > 0)) {
                          if (model.doctorList[index]['doctor_profile_id']['insurance'][0] != "") {
                            Insurance = model.doctorList[index]['doctor_profile_id']['insurance'][0];
                          }
                        }

                        String network_img_url = '';

                        if (model.doctorList[index]['azureBlobStorageLink'] != null) {
                          network_img_url = '${ApiService.fileStorageEndPoint}${model.doctorList[index]['azureBlobStorageLink']}';
                        } else {
                          print("NOT UPDATED");
                        }

                        String exp = '';

                        if (workExperience != '') {
                          exp = ' ,' + workExperience + ' exp';
                        }
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                preferencesService.selected_doctor_info_id = model.doctorList[index]['_id'];
                                preferencesService.selected_doctor_id = model.doctorList[index]['doctor_profile_id']['_id'];
                                selectedDoc = preferencesService.selected_doctor_id;
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => DoctorDetailView(DoctorDetail: selectedDoc, servicetype: 'Home visit')),
                                );
                              },
                              child: Container(
                                decoration: UIHelper.allcornerRadiuswithbottomShadow(12, 12, 12, 12, Colors.white),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(children: [
                                        network_img_url == ''
                                            ? Container(
                                                height: 100,
                                                width: 70,
                                                decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                                                child: Icon(
                                                  Icons.account_circle,
                                                  color: Colors.black38,
                                                ),
                                              )
                                            : UIHelper.getImage(network_img_url, 70, 100),
                                        model.doctorList[index]['doctor_profile_id']['stage'] == "verified"
                                            ? Container(
                                                height: 20,
                                                width: 70,
                                                decoration: UIHelper.allcornerRadiuswithbottomShadow(0, 0, 6, 6, img_badgeColor),
                                                child: Text('Verified').fontSize(13.8).bold().textColor(Colors.white).textAlignment(TextAlign.center))
                                            : model.doctorList[index]['doctor_profile_id']['stage'] == "Enhanced"
                                                ? Container(
                                                    height: 20,
                                                    width: 70,
                                                    decoration: UIHelper.allcornerRadiuswithbottomShadow(0, 0, 6, 6, img_badgeColor),
                                                    child: Text('Enhanced').fontSize(12.8).bold().textColor(Colors.white).textAlignment(TextAlign.center))
                                                : Container(
                                                    height: 30,
                                                    width: 70,
                                                    decoration: UIHelper.allcornerRadiuswithbottomShadow(0, 0, 6, 6, activeColor),
                                                    child: Text('SWAR Doctor').fontSize(12.8).bold().textColor(Colors.white).textAlignment(TextAlign.center))
                                        // model.doctorList[index]['doctor_profile_id']['stage'] != null
                                        //     ? Container(
                                        //         height: 20,
                                        //         width: 70,
                                        //         decoration: UIHelper.allcornerRadiuswithbottomShadow(0, 0, 6, 6, img_badgeColor),
                                        //         child: Text(model.doctorList[index]['doctor_profile_id']['stage']).fontSize(12.8).bold().textColor(Colors.white).textAlignment(TextAlign.center))
                                        //     : Container(child: Text(""))
                                      ]),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Container(
                                            child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              model.doctorList[index]['name'],
                                              overflow: TextOverflow.clip,
                                            ).fontSize(11).fontWeight(FontWeight.w600),
                                            UIHelper.verticalSpaceTiny,
                                            Text(
                                              widget.categoryTitle + exp,
                                              overflow: TextOverflow.clip,
                                            ).fontSize(11).fontWeight(FontWeight.w600).textColor(Colors.black38),
                                            UIHelper.verticalSpaceTiny,
                                            Row(
                                              children: [
                                                Text(qualification).fontSize(9).fontWeight(FontWeight.w300).bold(),
                                              ],
                                            ),
                                            UIHelper.verticalSpaceTiny,
                                            Insurance != ''
                                                ? Row(children: [
                                                    Expanded(
                                                      child: Text(
                                                        Insurance != '' ? Insurance : "",
                                                        overflow: TextOverflow.clip,
                                                      ).fontSize(9).fontWeight(FontWeight.w300).bold(),
                                                    ),
                                                    Icon(
                                                      Icons.done,
                                                      color: Colors.green,
                                                      size: 15,
                                                    ),
                                                  ])
                                                : Text(''),
                                            UIHelper.verticalSpaceTiny,
                                            ClinicName != ''
                                                ? Row(children: [
                                                    Icon(
                                                      Icons.location_pin,
                                                      color: locationColor,
                                                      size: 20,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        ClinicName.toString(),
                                                        overflow: TextOverflow.clip,
                                                      ).fontSize(9).fontWeight(FontWeight.w300).bold(),
                                                    )
                                                  ])
                                                : Text(''),
                                            Text('2.5 kms Away ').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  preferencesService.selected_doctor_info_id = model.doctorList[index]['_id'];
                                                  preferencesService.selected_doctor_id = model.doctorList[index]['doctor_profile_id']['_id'];
                                                  selectedDoc = preferencesService.selected_doctor_id;
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => BookAppointmentView(BookingInfo: selectedDoc, servicetype: "Home visit")),
                                                  );
                                                },
                                                child: Text('Book  Appointment').fontSize(10).textColor(Colors.white),
                                                style: ButtonStyle(
                                                    minimumSize: MaterialStateProperty.all(Size(65, 25)),
                                                    backgroundColor: MaterialStateProperty.all(activeColor),
                                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
                                          ],
                                        )),
                                      ),
                                      Container(
                                        width: 100,
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text('Patients visit').fontSize(10),
                                                SizedBox(width: 3),
                                                Text(model.doctorList[index]['count'] != null ? model.doctorList[index]['count'] : '').fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                UIHelper.horizontalSpaceMedium,
                                                Icon(
                                                  Icons.star_purple500_sharp,
                                                  color: goldenColor,
                                                  size: 20,
                                                ),
                                                Text(model.doctorList[index]['rating'] != null ? model.doctorList[index]['rating'] : '').fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor),
                                              ],
                                            ),
                                            UIHelper.verticalSpaceSmall,
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, Colors.white),
                                                child: Column(
                                                  children: [
                                                    Text('Languages').fontSize(10),
                                                    UIHelper.verticalSpaceTiny,
                                                    // Text('English, Tamil, \n      Telugu').fontSize(9).fontWeight(FontWeight.w800),
                                                    Column(children: [
                                                      for (var lang in model.doctorList[index]['language_known'])
                                                        Text(
                                                          lang != null ? lang : '',
                                                          maxLines: 1,
                                                          softWrap: false,
                                                          overflow: TextOverflow.fade,
                                                        ).fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                                                    ]),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            UIHelper.verticalSpaceSmall,
                                            Text(preferencesService.Final_amount != "" ? 'Discount %' : ''),
                                            preferencesService.Final_amount != ""
                                                //  model.doctorList[index]['doctor_profile_id']['services'] !=null ? Text(model.doctorList[index]['doctor_profile_id']['services'][0]['fees']) : Text('');
                                                ? Row(
                                                    children: [
                                                      Text(Fees,
                                                          style: TextStyle(
                                                            decoration: TextDecoration.lineThrough,
                                                          )).textColor(Colors.black38),
                                                      UIHelper.horizontalSpaceTiny,
                                                      //Text('₹' + final_amount).textColor(activeColor),
                                                      model.doctorList[index]['doctor_profile_id']['services'] != null ? Text(model.doctorList[index]['doctor_profile_id']['services'][0]['fees']) : Text('')
                                                    ],
                                                  )
                                                : Text(''),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            UIHelper.verticalSpaceSmall,
                          ],
                        );
                      })
                  : Center(
                      child: Text('No Records Found'),
                    )
            ]),
          );
  }

  Widget showcaution() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: () async {},
            child: Text('Caution: Its not for emergency service', style: TextStyle(fontWeight: FontWeight.w500)).textColor(Colors.white),
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(360, 36)),
              backgroundColor: MaterialStateProperty.all(Color(0xFF00B0FF)),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    modelRef.getDoctorList(widget.categoryTitle, selectedIndex);
    return Scaffold(
      appBar: SwarAppStaticBar(),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(12),
        child: ViewModelBuilder<Homevisitmodel>.reactive(
            onModelReady: (model) async {
              modelRef = model;
              await model.getDoctorList(widget.categoryTitle, selectedIndex);
            },
            builder: (context, model, child) {
              return Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [addHeader(context, true), showSearchField(context, model), selectProfession(context, model), UIHelper.verticalSpaceSmall, UIHelper.verticalSpaceSmall, listview(context, model)],
                      ),
                    ),
                  )),
                  showcaution()
                ],
              );
            },
            viewModelBuilder: () => Homevisitmodel()),
      ),
    );
  }
}

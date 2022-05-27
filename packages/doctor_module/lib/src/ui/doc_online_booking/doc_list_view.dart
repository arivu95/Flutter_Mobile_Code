import 'package:doctor_module/src/ui/doc_online_booking/bookings_view.dart';
import 'package:doctor_module/src/ui/doc_online_booking/doc_list_model.dart';
import 'package:doctor_module/src/ui/doc_online_booking/top_specalities_view_model.dart';
import 'package:doctor_module/src/ui/doctor_profile/doctor_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_doctorprofile_bar.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/language_select_view.dart';
import 'package:swarapp/ui/startup/role_select_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:doctor_module/src/ui/doc_signup/role_select_view.dart';
import 'package:doctor_module/src/ui/doc_online_booking/doc_list_view.dart';
import 'package:doctor_module/src/ui/doc_online_booking/doc_detail_view.dart';
import 'package:jiffy/jiffy.dart';

class DoctorListView extends StatefulWidget {
  final String categoryTitle;
  String servicetype;
  List<dynamic> doctorsList;
  DoctorListView({Key? key, required this.categoryTitle, required this.servicetype, required this.doctorsList}) : super(key: key);

  @override
  _DoctorListViewState createState() => _DoctorListViewState();
}

class _DoctorListViewState extends State<DoctorListView> {
  PreferencesService preferencesService = locator<PreferencesService>();
  TextEditingController searchController = TextEditingController();

  String selectedTab = '';
  dynamic selection = "Online";
  int Tab_id = 3;
  bool select_personal = false;
  bool select_doc = false;
  bool isSearch = false;
  String selectedDoc = '';
  String workExperience = '';

  String ClinicName = '';
  List<dynamic> fees_list = [];
  List<dynamic> service_list = [];
  List<dynamic> category_list = [];
  List<dynamic> filteredDoctorList = [];
  List<dynamic> doctor_search_details = [];
  String Fees = '';
  String Discount = '';
  String final_amount = '';

  void initState() {
    super.initState();
    _specialization();
  }

  void _specialization() async {
    filteredDoctorList = widget.doctorsList.where((e) {
      return e['specialization'].toString().toLowerCase().contains(widget.categoryTitle.toLowerCase());
    }).toList();
  }

  void searchList(String value) {
    doctor_search_details = service_list.where((e) {
      return e['name'].toString().toLowerCase().contains(value.toLowerCase()) || e['specialization'].toString().toLowerCase().contains(value.toLowerCase());
    }).toList();
  }

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
              Text(widget.categoryTitle + ' Doctors Nearby').fontSize(16).fontWeight(FontWeight.w600),
            ],
          ),
        ],
      ),
    );
  }

  Widget showSearchField(BuildContext context, DocListmodel model) {
    List<dynamic> serviceType = ['Online', 'In clinic', 'Home visit'];
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
                    searchList(value);
                    setState(() {
                      isSearch = true;
                    });
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
                                searchList('');
                                setState(() {
                                  isSearch = true;
                                });
                                FocusManager.instance.primaryFocus!.unfocus();
                              }),
                      contentPadding: EdgeInsets.only(left: 20),
                      enabledBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      focusedErrorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      errorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFCCCCCC)),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "Search a doctor by Specialty,City,Hospital name",
                      fillColor: fieldBgColor),
                ),
              ),
            ),
            UIHelper.horizontalSpaceTiny,
            widget.servicetype == ""
                ? DropdownButton(
                    value: selection.isNotEmpty ? selection : serviceType[0],
                    items: ['Online', 'In clinic', 'Home visit'].map((e) {
                      return new DropdownMenuItem(
                        value: e,
                        child: new Text(e).fontSize(15),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      print(value);
                      setState(() {
                        selection = value;
                      });
                      service_list = filteredDoctorList.where((msg) => msg['doctor_services'].toString().contains(selection)).toList();
                      setState(() {});
                      Loader.hide();
                    })
                : Icon(
                    Icons.filter_alt_rounded,
                  ),
          ],
        ),
      ),
    );
  }

  Widget listview(BuildContext context, DocListmodel model) {
    List<dynamic> dbUserList = isSearch ? doctor_search_details : service_list;
    return dbUserList != null
        ? model.isBusy
            ? Center(
                child: UIHelper.swarPreloader(),
              )
            : Container(
                width: Screen.width(context),
                decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.transparent),
                child: Column(children: [
                  dbUserList.length > 0
                      ? ListView.builder(
                          itemCount: dbUserList.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (dbUserList[index]['doctor_profile_id']['experience'].length > 0) {
                              if (dbUserList[index]['doctor_profile_id']['experience'][0]['work_experience'] != null && dbUserList[index]['doctor_profile_id']['experience'][0]['work_experience'] != "") {
                                int experInt = int.parse(dbUserList[index]['doctor_profile_id']['experience'][0]['work_experience']);
                                if (experInt < 12) {
                                  workExperience = '$experInt  month';
                                } else {
                                  double exper = experInt / 12;
                                  String workExperience = exper.toStringAsFixed(2).toString();
                                  workExperience = '$workExperience year';
                                }
                              }
                            }

                            String Qualification = '';
                            if (dbUserList[index]['doctor_profile_id']['educational_information'].length > 0) {
                              for (int i = 0; dbUserList[index]['doctor_profile_id']['educational_information'].length > i; i++) {
                                var qua = dbUserList[index]['doctor_profile_id']['educational_information'][i]['qualification'];
                                if (qua != "" && qua != null) {
                                  Qualification != '' ? Qualification = Qualification + ',' + qua.toString() : Qualification = qua.toString();
                                }
                              }
                            }
                            if (dbUserList[index]['doctor_profile_id']['clinic_details'].length > 0) {
                              if (dbUserList[index]['doctor_profile_id']['clinic_details'][0]['clinic_name'] != "") {
                                ClinicName = dbUserList[index]['doctor_profile_id']['clinic_details'][0]['clinic_name'];
                              }
                            }
                            String Insurance = '';
                            if ((dbUserList[index]['doctor_profile_id']['insurance'] != null) && (dbUserList[index]['doctor_profile_id']['insurance'].length > 0)) {
                              if (dbUserList[index]['doctor_profile_id']['insurance'][0] != "") {
                                Insurance = dbUserList[index]['doctor_profile_id']['insurance'][0];
                              }
                            }
                            String networkImgUrl = '';
                            if (dbUserList[index]['azureBlobStorageLink'] != null) {
                              networkImgUrl = '${ApiService.fileStorageEndPoint}${dbUserList[index]['azureBlobStorageLink']}';
                            } else {
                              print("NOT UPDATEDDD");
                            }
                            if (dbUserList[index]['doctor_profile_id']['services'].length > 0) {
                              for (var i = 0; i < dbUserList[index]['doctor_profile_id']['services'].length; i++) {
                                if ((dbUserList[index]['doctor_profile_id']['services'][i]['services_type'] == widget.servicetype) ||
                                    (dbUserList[index]['doctor_profile_id']['services'][i]['services_type'] == "Online") ||
                                    (dbUserList[index]['doctor_profile_id']['services'][i]['services_type'] == selection)) {
                                  Fees = dbUserList[index]['doctor_profile_id']['services'][i]['fees'].toString();
                                  preferencesService.Final_fees = dbUserList[index]['doctor_profile_id']['services'][i]['fees'].toString();
                                }
                                if ((dbUserList[index]['doctor_profile_id']['services'][i]['services_type'] == widget.servicetype) ||
                                    (dbUserList[index]['doctor_profile_id']['services'][i]['services_type'] == "Online") ||
                                    (dbUserList[index]['doctor_profile_id']['services'][i]['services_type'] == selection)) {
                                  Discount = dbUserList[index]['doctor_profile_id']['services'][i]['discount'].toString();
                                  preferencesService.Final_discount = dbUserList[index]['doctor_profile_id']['services'][i]['discount'].toString();
                                }
                                if ((dbUserList[index]['doctor_profile_id']['services'][i]['services_type'] == widget.servicetype) ||
                                    (dbUserList[index]['doctor_profile_id']['services'][i]['services_type'] == "Online") ||
                                    (dbUserList[index]['doctor_profile_id']['services'][i]['services_type'] == selection)) {
                                  final_amount = dbUserList[index]['doctor_profile_id']['services'][i]['final_amount'].toString();
                                  preferencesService.Final_amount = dbUserList[index]['doctor_profile_id']['services'][i]['fees'].toString();
                                }
                              }
                            }
                            String exp = '';

                            if (workExperience != '') {
                              exp = ' ,' + workExperience + ' exp';
                            }

                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    preferencesService.selected_doctor_info_id = dbUserList[index]['_id'];
                                    preferencesService.selected_doctor_id = dbUserList[index]['doctor_profile_id']['_id'];
                                    selectedDoc = preferencesService.selected_doctor_id;
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => DoctorDetailView(DoctorDetail: dbUserList[index], servicetype: selection)),
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
                                            networkImgUrl == ''
                                                ? Container(
                                                    height: 100,
                                                    width: 70,
                                                    decoration: UIHelper.allcornerRadiuswithbottomShadow(2, 2, 2, 2, fieldBgColor),
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.black,
                                                    ),
                                                  )
                                                : UIHelper.getImage(networkImgUrl, 70, 100),
                                            dbUserList[index]['doctor_profile_id']['stage'] == "verified"
                                                ? Container(
                                                    height: 20,
                                                    width: 70,
                                                    decoration: UIHelper.allcornerRadiuswithbottomShadow(0, 0, 6, 6, img_badgeColor),
                                                    child: Text('Verified').fontSize(13.8).bold().textColor(Colors.white).textAlignment(TextAlign.center))
                                                : dbUserList[index]['doctor_profile_id']['stage'] == "Enhanced"
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
                                          ]),
                                          SizedBox(width: 5),
                                          Expanded(
                                            child: Container(
                                                child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dbUserList[index]['name'],
                                                  overflow: TextOverflow.clip,
                                                ).fontSize(11).fontWeight(FontWeight.w600),
                                                UIHelper.verticalSpaceTiny,
                                                Text(
                                                  widget.categoryTitle + exp,
                                                  overflow: TextOverflow.clip,
                                                ).fontSize(11).fontWeight(FontWeight.w600).textColor(Colors.black38),
                                                UIHelper.verticalSpaceTiny,
                                                Text(
                                                  Qualification,
                                                  overflow: TextOverflow.clip,
                                                ).fontSize(9).fontWeight(FontWeight.w300).bold(),
                                                UIHelper.verticalSpaceTiny,
                                                Insurance != ''
                                                    ? Row(children: [
                                                        Text(
                                                          'Insurance ',
                                                          overflow: TextOverflow.clip,
                                                        ).fontSize(9).fontWeight(FontWeight.w300).bold(),
                                                        Icon(
                                                          Icons.done,
                                                          color: Colors.green,
                                                          size: 15,
                                                        ),
                                                      ])
                                                    : Row(children: [
                                                        Text(
                                                          'Insurance ',
                                                          overflow: TextOverflow.clip,
                                                        ).fontSize(9).fontWeight(FontWeight.w300).bold(),
                                                        Icon(
                                                          Icons.cancel,
                                                          color: activeColor,
                                                          size: 15,
                                                        ),
                                                      ]),
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
                                                ElevatedButton(
                                                    onPressed: () async {
                                                      preferencesService.selected_doctor_info_id = dbUserList[index]['_id'];
                                                      preferencesService.selected_doctor_id = dbUserList[index]['doctor_profile_id']['_id'];
                                                      selectedDoc = preferencesService.selected_doctor_id;
                                                      await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => BookAppointmentView(BookingInfo: selectedDoc, servicetype: selection)),
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
                                                    Text('Patients visit').fontSize(10).fontWeight(FontWeight.w600).textColor(Colors.black).paddingZero,
                                                    SizedBox(width: 3),
                                                    dbUserList[index]['count'] != null ? Text(dbUserList[index]['count']).fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor) : Text(""),
                                                  ],
                                                ),
                                                dbUserList[index]['rating'] == '0.0'
                                                    ? SizedBox()
                                                    : Row(
                                                        children: [
                                                          UIHelper.horizontalSpaceMedium,
                                                          Icon(
                                                            Icons.star_purple500_sharp,
                                                            color: goldenColor,
                                                            size: 20,
                                                          ),
                                                          dbUserList[index]['rating'] != null ? Text(dbUserList[index]['rating']).fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor) : Text(''),
                                                        ],
                                                      ),
                                                UIHelper.verticalSpaceTiny,
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
                                                          for (var lang in dbUserList[index]['language_known'])
                                                            Text(
                                                              lang != null ? lang : '',
                                                              maxLines: 1,
                                                              softWrap: false,
                                                              overflow: TextOverflow.fade,
                                                            ).fontSize(10).fontWeight(FontWeight.w600).textColor(Colors.black),
                                                        ]),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                UIHelper.verticalSpaceSmall,
                                                Text(preferencesService.Final_amount != "" ? 'Discount %' : '').fontWeight(FontWeight.w600).textColor(Colors.black).paddingZero,
                                                preferencesService.Final_amount != ""
                                                    ? Row(
                                                        children: [
                                                          preferencesService.Final_discount != ''
                                                              ? Text(Fees,
                                                                  style: TextStyle(
                                                                    decoration: TextDecoration.lineThrough,
                                                                  )).textColor(Colors.black38)
                                                              : Text(
                                                                  Fees,
                                                                ).textColor(Colors.black38),
                                                          UIHelper.horizontalSpaceTiny,
                                                          Text(final_amount != '' ? '₹' + final_amount : "").textColor(activeColor),
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
                                UIHelper.verticalSpaceTiny,
                              ],
                            );
                          })
                      : Center(
                          child: Text('No Records Found'),
                        )
                ]),
              )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget nurseList1(
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
                height: 95,
                width: 40,
              ),
              Container(height: 20, width: 40, decoration: UIHelper.allcornerRadiuswithbottomShadow(0, 0, 6, 6, img_badgeColor), child: Text('  Verified ').fontSize(15).bold().textColor(Colors.white)),
            ]),
            UIHelper.horizontalSpaceSmall,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dr.Ganesh').fontSize(12).fontWeight(FontWeight.w600),
                UIHelper.verticalSpaceTiny,
                Text('General physician, 5 years exp').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black38),
                UIHelper.horizontalSpaceSmall,
                UIHelper.verticalSpaceSmall,
                Text('M.B.B.S, Diploma - Family Medicine').fontSize(9).fontWeight(FontWeight.w300).bold(),
                UIHelper.verticalSpaceTiny,
                Row(children: [
                  Text('Insurance ').fontSize(10).fontWeight(FontWeight.w600),
                  Icon(
                    Icons.done,
                    color: Colors.green,
                    size: 15,
                  ),
                ]),
                Row(children: [
                  Icon(
                    Icons.location_pin,
                    color: locationColor,
                    size: 20,
                  ),
                  Text('GodWell, Chennai').fontSize(10).fontWeight(FontWeight.w300).bold(),
                ]),
                ElevatedButton(
                    onPressed: () async {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => DoctorDetailView()),
                      // );
                    },
                    child: Text('Book  Appointment').fontSize(10).textColor(Colors.white),
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(65, 25)),
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
                    Text('Patients visit').fontSize(12).fontWeight(FontWeight.w600).textColor(Colors.black).paddingZero,
                    UIHelper.horizontalSpaceSmall,
                    Text('1.5K').fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    UIHelper.horizontalSpaceMedium,
                    Icon(
                      Icons.star_purple500_sharp,
                      color: goldenColor,
                      size: 20,
                    ),
                    Text(' 4.0').fontSize(12).fontWeight(FontWeight.w500).textColor(activeColor),
                  ],
                ),
                UIHelper.verticalSpaceMedium,
                Container(
                  width: 100,
                  padding: EdgeInsets.all(4),
                  decoration: UIHelper.allcornerRadiuswithbottomShadow(6, 6, 6, 6, Colors.white),
                  child: Column(
                    children: [
                      Text('Languages').fontSize(10),
                      UIHelper.verticalSpaceTiny,
                      Text('English, Tamil, \n      Telugu').fontSize(9).fontWeight(FontWeight.w800),
                    ],
                  ),
                ),
                UIHelper.verticalSpaceSmall,
                Text('Discount %'),
                Row(
                  children: [
                    Text('₹ 750',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                        )).textColor(Colors.black38),
                    UIHelper.horizontalSpaceTiny,
                    Text(' ₹ 500').textColor(activeColor),
                  ],
                )
              ],
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SwarAppStaticBar(),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(12),
        child: ViewModelBuilder<DocListmodel>.reactive(
            onModelReady: (model) async {
              //Loader.show(context);
              // await model.getDoctorList(widget.categoryTitle);
              widget.servicetype == ""
                  ? service_list = filteredDoctorList.where((msg) => msg['doctor_services'].toString().contains("Online")).toList()
                  : service_list = filteredDoctorList.where((msg) => msg['doctor_services'].toString().toLowerCase().contains(widget.servicetype.toLowerCase())).toList();
              //Loader.hide();
            },
            builder: (context, model, child) {
              return Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [addHeader(context, true), UIHelper.verticalSpaceSmall, showSearchField(context, model), UIHelper.verticalSpaceSmall, listview(context, model)],
                      ),
                    ),
                  )),
                ],
              );
            },
            viewModelBuilder: () => DocListmodel()),
      ),
    );
  }
}

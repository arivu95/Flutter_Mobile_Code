import 'package:documents_module/src/ui/medical_records/maternity_widget/maternity_widget.dart';
import 'package:documents_module/src/ui/medical_records/vaccination_viewmodel.dart';
import 'package:documents_module/src/ui/medical_records/vaccination_widget/Birth_details_view.dart';
import 'package:documents_module/src/ui/medical_records/vaccination_widget/vaccination_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:share/share.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class VaccineMaternityListView extends StatefulWidget {
  final String cat_Type;
  VaccineMaternityListView({Key? key, required this.cat_Type}) : super(key: key);
  @override
  _VaccineMaternityListViewState createState() => _VaccineMaternityListViewState();
}

class _VaccineMaternityListViewState extends State<VaccineMaternityListView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  VaccineViewmodel modelRef = VaccineViewmodel();
  TextEditingController conditionController = TextEditingController();
  int selectedIndex = 0;
  String pick_dt = "";
  String due_date_show = "";
  String mat_Remaining = '';
  String vacc_Remaining = '';

  String rootDocId = '';
  String pregnancy_dt = "";
  String category_name = '';
  String next_vaccine = "";
  String due_date = "";
  bool isPick = false;
  bool isnavigation = false;
  bool isnavigation_vaccine = false;
  bool isnavigationDue = false;
  bool isFirst_dueDate = false;
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

// Maternity Due Date Picker
  Future<void> _dueDatepick(BuildContext context, VaccineViewmodel model) async {
    final DateTime? duepicDate = await showDatePicker(context: context, initialDate: currentDate, firstDate: DateTime(1900, 1), lastDate: DateTime(DateTime.now().year + 79));
    if (duepicDate == null && isnavigationDue || model.due_date == duepicDate) {
      Get.back();
    }
    if (duepicDate != null) {
      // if (duepicDate != null) {
      setState(() {
        Jiffy d = Jiffy(duepicDate);
        mat_Remaining = duepicDate.toString();
        due_date_show = d.format('dd/MM/yyyy').toString();
        due_date = d.format('MM-dd-yyyy').toString();
        isPick = true;

        if (isnavigationDue == true) {
          Navigator.pop(context);
        }
      });
      Jiffy dt = Jiffy(duepicDate);
      String dateStr = dt.format('MM-dd-yyyy');
      await model.getheaderData(pregnancy_dt, dateStr, "");
    }
  }

// Maternity pregnancy date picker
  Future<void> _selectDate(BuildContext context, VaccineViewmodel model) async {
    final DateTime? pickedDate = await showDatePicker(context: context, initialDate: currentDate, firstDate: DateTime(1900, 1), lastDate: DateTime(DateTime.now().year + 79));
    if (pickedDate == null && isnavigation || model.pregnancy_dt == pickedDate) {
      // String val = isnavigation.toString();
      Get.back();
    }
    if (pickedDate != null) {
      setState(() {
        currentDate = pickedDate;
        Jiffy d = Jiffy(currentDate);
        pick_dt = d.format('dd/MM/yyyy').toString();
        isPick = true;
        if (isnavigation == true) {
          Navigator.pop(context);
        }
      });
      Jiffy dt = Jiffy(pickedDate);
      String dateStr = dt.format('MM-dd-yyyy');

//      await model.getheaderData(dateStr, due_date, "");
      await model.getheaderData(dateStr, due_date, "");
    }
  }

// Next Vaccination date picker
  Future<void> _selectvaccineDate(BuildContext context, VaccineViewmodel model) async {
    final DateTime? nextvaccine = await showDatePicker(context: context, initialDate: currentDate, firstDate: DateTime.now(), lastDate: DateTime(DateTime.now().year + 79));
    if (nextvaccine == null && isnavigation_vaccine || model.next_vaccine == nextvaccine) {
      Get.back();
    }
    if (nextvaccine != null) {
      setState(() {
        currentDate = nextvaccine;
        vacc_Remaining = nextvaccine.toString();
        Jiffy d = Jiffy(currentDate);
        next_vaccine = d.format('dd/MM/yyyy').toString();
        preferencesService.dropdown_user_vaccine_date = next_vaccine;
        isPick = true;
        if (isnavigation_vaccine == true) {
          Navigator.pop(context);
        }
      });
      Jiffy nxtVacDate = Jiffy(nextvaccine);
      String datevaccine = nxtVacDate.format('MM-dd-yyyy');
      await model.updatenextvaccinationDate(datevaccine);
    }
  }

// Vaccination & Maternity date  change POPUP
  Future<void> _pickAlertBox(BuildContext context, VaccineViewmodel model, String title) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Caution!'),
            content: Text('Are you sure to change the ' + title + '?'),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Yes'),
                onPressed: () async {
                  if (title == "Next Vaccine") {
                    _selectvaccineDate(context, model);
                  }
                  if (title == "Pregnancy date") {
                    _selectDate(context, model);
                  }
                  if (title == "Due date") {
                    _dueDatepick(context, model);
                  }
                },
              ),
            ],
          );
        });
  }

  Widget addReportHeader(BuildContext context, VaccineViewmodel model, String rootDocId) {
    if (widget.cat_Type == "Maternity") {
      selectedIndex = 1;
    } else {
      selectedIndex = 0;
    }

    //Next vaccination
    if (next_vaccine != "") {
      isPick = !isPick;
    } else {
      if (model.next_vaccine.isNotEmpty) {
        vacc_Remaining = model.next_vaccine;
        Jiffy nxtVacDate = Jiffy(model.next_vaccine);
        next_vaccine = nxtVacDate.format('dd/MM/yyyy');
      }
    }

// Maternity pregnancy Date
    if (pick_dt != "") {
      isPick = !isPick;
    } else {
      pick_dt = model.pregnancy_dt;
      preferencesService.dropdown_user_pragnancy_date = pick_dt;
    }

// Maternity Due Date
    if (due_date_show != "") {
      isPick = !isPick;
    } else {
      if ((model.due_date != null) && (model.due_date.isNotEmpty)) {
        Jiffy datestr = Jiffy(model.due_date);
        mat_Remaining = model.due_date;
        due_date = datestr.format('MM-dd-yyyy').toString();
        due_date_show = datestr.format('dd/MM/yyyy').toString();
      }
    }

// Maternity mother condition
    if ((model.condition_mother != null) || (model.condition_mother != null)) {
      conditionController.text = model.condition_mother;
    }

    // Next vaccine remaining days calculation
    String vaccineDay = "";
    String vaccineWeek = "";
    String vaccineMonth = "";
    if ((vacc_Remaining != null) && (vacc_Remaining.isNotEmpty)) {
      var now = new DateTime.now();
      var now1 = Jiffy(now).format("MM-dd-yyyy");
      var nextvaccine = Jiffy(vacc_Remaining).format("MM-dd-yyyy");
      var currentDate = Jiffy(now1, 'MM-dd-yyyy');
      var nxtVaccineDate = Jiffy(nextvaccine, 'MM-dd-yyyy');
      vaccineDay = nxtVaccineDate.diff(currentDate, Units.DAY).toString();
      vaccineMonth = nxtVaccineDate.diff(currentDate, Units.MONTH).toString();
      vaccineWeek = nxtVaccineDate.diff(currentDate, Units.WEEK).toString();
    } else {
      vaccineDay = '-';
      vaccineMonth = '-';
      vaccineWeek = '-';
    }

    // Maternity remaining days calculation
    String maternityDay = "";
    String maternityWeek = "";
    String maternityMonth = "";
    if ((mat_Remaining != null) && (mat_Remaining.isNotEmpty)) {
      var datestr1 = Jiffy(mat_Remaining).format("MM-dd-yyyy");
      var datestr = Jiffy(datestr1, 'MM-dd-yyyy');
      var now = new DateTime.now();
      var now1 = Jiffy(now).format("MM-dd-yyyy");
      var currentDate = Jiffy(now1, 'MM-dd-yyyy');
      maternityDay = datestr.diff(currentDate, Units.DAY).toString();
      maternityMonth = datestr.diff(currentDate, Units.MONTH).toString();
      maternityWeek = datestr.diff(currentDate, Units.WEEK).toString();
    } else {
      maternityDay = '-';
      maternityMonth = '-';
      maternityWeek = '-';
    }

    return Container(
      width: Screen.width(context),
      padding: EdgeInsets.all(8),
      decoration: UIHelper.roundedBorderWithColorWithShadow(8, fieldBgColor),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                child: Container(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 0;
                          });
                        },
                        child:

                            // Container(
                            //   child: Text(preferencesService.dropdown_user_name).textColor(Colors.black).bold(),
                            // ),
                            Container(
                                child: StreamBuilder<String?>(
                                    stream: locator<PreferencesService>().userName.outStream,
                                    builder: (context, snapshotname) =>
                                        // !snapshotname.hasData || snapshotname.data == '' ? Text(preferencesService.dropdown_user_name).textColor(Colors.black).bold() : Text(snapshotname.data!).textColor(Colors.black).bold(),
                                        Text(preferencesService.dropdown_user_name).textColor(Colors.black).bold())),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await Get.to(() => BirthDetailsView(userVaccineData: model.userVaccineData, vaccineData: model.vaccineData, docId: rootDocId));
                  },
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    selectedIndex == 0
                        ? Container(
                            padding: EdgeInsets.all(7),
                            alignment: Alignment.center,
                            decoration: UIHelper.roundedBorderWithColor(4, activeColor),
                            child: Text('Birth Details').textColor(Colors.white).bold(),
                          )
                        : Text(""),
                  ]),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      (selectedIndex == 0) ? category_name = "vaccine" : category_name = "maternity";
                      if (category_name.isNotEmpty) {
                        Loader.show(context);
                        List<String> paths = await model.shareDocs(category_name);
                        Loader.hide();
                        await Share.shareFiles(paths, subject: 'SWAR Doctor');
                      }
                    },
                    child: Icon(
                      Icons.share,
                      size: 20,
                    ),
                  ),
                  UIHelper.horizontalSpaceSmall,
                  GestureDetector(
                      onTap: () async {
                        (selectedIndex == 0) ? category_name = "vaccine" : category_name = "maternity";
                        if (category_name.isNotEmpty) {
                          Loader.show(context);
                          await model.download(category_name);
                          Loader.hide();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialogBox(
                                  title: "Download Complete",
                                  descriptions: "File stored in download folder of your device",
                                  descriptions1: "",
                                  text: "OK",
                                );
                              });
                        }
                      },
                      child: Icon(Icons.download_sharp))
                ],
              )
            ],
          ),
          UIHelper.verticalSpaceSmall,
          Align(
              alignment: Alignment.topLeft,
              child: Row(children: [
                SizedBox(
                  child: Text(selectedIndex == 1 ? 'Mother${"'"}s  Condition :' : '').fontSize(13),
                ),
                UIHelper.horizontalSpaceSmall,
                Flexible(
                  child: selectedIndex == 1
                      ? FormBuilderTextField(
                          controller: conditionController,
                          name: 'mothers_condition',
                          autocorrect: false,
                          onEditingComplete: () {
                            if (FocusScope.of(context).isFirstFocus) {
                              FocusScope.of(context).requestFocus(new FocusNode());
                            }
                            model.condition_mother = conditionController.text;
                            model.getheaderData(pregnancy_dt, "", conditionController.text);
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 4),
                            hintText: 'Eg: Low Bp & Diabetic',
                            hintStyle: loginInputHintTitleStyle,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: UIHelper.getInputBorder(1),
                            focusedBorder: UIHelper.getInputBorder(1),
                            focusedErrorBorder: UIHelper.getInputBorder(1),
                            errorBorder: UIHelper.getInputBorder(1, borderColor: activeColor),
                          ),
                          // inputFormatters: [
                          //   new WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
                          // ],
                          inputFormatters: [
                            // is able to enter lowercase letters
                            new FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                            //if (control_name == 'mobilenumber') FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                          ],
                        )
                      : UIHelper.horizontalSpaceSmall,
                )
              ])),
          UIHelper.verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              selectedIndex == 0
                  ? Flexible(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: () async {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('DOB: ' + model.baby_dob.toString()).fontSize(12),
                              ],
                            )),
                      ],
                    ))
                  : Flexible(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: () async {
                              String pgDate = model.pregnancy_dt.toString();
                              if (pgDate.isEmpty || pgDate == null || pick_dt == "") {
                                print('55555555555555555555');
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialogBox(
                                        title: "Alert !",
                                        descriptions: "please select Pregnancy Date",
                                        descriptions1: "",
                                        text: "OK",
                                      );
                                    });
                              } else {
                                if (model.due_date != "") {
                                  setState(() {
                                    isnavigationDue = true;
                                  });
                                  await _pickAlertBox(context, model, "Due date");
                                } else {
                                  await _dueDatepick(context, model);
                                }
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Due Date : ' + due_date_show).fontSize(12),
                                UIHelper.horizontalSpaceTiny,
                                (due_date_show.isNotEmpty)
                                    ? Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.black38,
                                      )
                                    : Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: activeColor,
                                      ),
                              ],
                            )),
                      ],
                    )),
              Container(
                width: Screen.width(context) / 2.1,
                padding: EdgeInsets.all(6),
                decoration: UIHelper.roundedActiveButtonLineBorderWithGradient(8, 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(selectedIndex == 0 ? vaccineDay : maternityDay).fontSize(18),
                        Text('Days').fontWeight(FontWeight.w600).fontSize(13),
                      ],
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Column(
                      children: [
                        Text(selectedIndex == 0 ? vaccineWeek : maternityWeek).fontSize(18),
                        Text('Weeks').fontWeight(FontWeight.w600).fontSize(13),
                      ],
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Column(
                      children: [
                        Text(selectedIndex == 0 ? vaccineMonth : maternityMonth).fontSize(18),
                        Text('Months').fontWeight(FontWeight.w600).fontSize(13),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          UIHelper.verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              selectedIndex == 0
                  ? Flexible(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: () async {
                              if (model.next_vaccine != "") {
                                setState(() {
                                  isnavigation_vaccine = true;
                                });
                                await _pickAlertBox(context, model, "Next Vaccine");
                              } else {
                                await _selectvaccineDate(context, model);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Next Vaccination: ' + next_vaccine).fontSize(12),
                                UIHelper.horizontalSpaceTiny,
                                (next_vaccine.isNotEmpty)
                                    ? Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.black38,
                                      )
                                    : Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: activeColor,
                                      ),
                              ],
                            )),
                      ],
                    ))
                  : Flexible(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      GestureDetector(
                        onTap: () async {
                          if (model.pregnancy_dt != "") {
                            setState(() {
                              isnavigation = true;
                            });
                            await _pickAlertBox(context, model, "Pregnancy date");
                          } else {
                            await _selectDate(context, model);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Pregnancy Date : ' + pick_dt).fontSize(12),
                            UIHelper.horizontalSpaceTiny,
                            (pick_dt.isNotEmpty)
                                ? Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.black38,
                                  )
                                : Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: activeColor,
                                  ),
                          ],
                        ),
                      ),
                    ])),
              Padding(
                padding: const EdgeInsets.only(top: 1, bottom: 10, left: 10, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    selectedIndex == 0 ? Text("") : Text('Remaining days \n    for delivery').bold().fontSize(12),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget addHeader(BuildContext context, bool isBackBtnVisible) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        children: [
          isBackBtnVisible
              ? GestureDetector(
                  onTap: () {
                    locator<PreferencesService>().isReload.value = true;
                    locator<PreferencesService>().isUploadReload.value = true;
                    locator<PreferencesService>().isDownloadReload.value = true;
                    Get.back();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 20,
                  ),
                )
              : SizedBox(),
          Text(widget.cat_Type).bold().fontSize(16),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (locator<PreferencesService>().isReload.value == true) {
      locator<PreferencesService>().isReload.value = false;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SwarAppStaticBar(),
      body: ViewModelBuilder<VaccineViewmodel>.reactive(
          onModelReady: (model) async {
            Loader.show(context);
            await model.getUserVaccine();
            Loader.hide();
          },
          builder: (context, model, child) {
            return Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                width: Screen.width(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UIHelper.verticalSpaceTiny,
                    addHeader(context, true),
                    UIHelper.verticalSpaceSmall,
                    UIHelper.hairLineWidget(),
                    addReportHeader(context, model, rootDocId),
                    UIHelper.verticalSpaceSmall,
                    UIHelper.verticalSpaceSmall,
                    Expanded(
                      child: IndexedStack(
                        index: selectedIndex,
                        children: [VaccinationWidget(), MaternityWidget()],
                      ),
                    ),
                    UIHelper.verticalSpaceSmall,
                  ],
                ));
          },
          viewModelBuilder: () => VaccineViewmodel()),
    );
  }

  DateFormat(String s) {}
}

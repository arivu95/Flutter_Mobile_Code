import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:dio/src/multipart_file.dart' as MP1;
import 'package:jiffy/jiffy.dart';

class ManageCalenderWidgetmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic profileInfo = {};
  String res = "";
  dynamic session_info = {};
  List<dynamic> specialization = [];
  String img_url = '';
  List<dynamic> countries = [];
  String coverimg_url = '';
  List<dynamic> get_session_view = [];
  List convert_dates = [];
  List validate_convert_dates = [];
  List today_dates = [];
  dynamic calender_date_view = {};
  dynamic validate_calender_date_view = {};
  dynamic calender_date_viewall = {};
  List<dynamic> get_date_validitate = [];
  String startDt = Jiffy().format('MM-dd-yyyy');
  String getLimit = Jiffy(DateTime.now()).add(months: 3).format('MM-dd-yyyy').toString();
  dynamic getSessions = [];
  List<dynamic> setSessionTime = [];
  dynamic defaultSessions = [];

  Future init() async {
    // await getPatientsList("6200c2021da5d80033aa6ea8");
    String userId = preferencesService.userId;
    // await apiService.getStageProfile(userId);
    // getSessions = await apiService.getetSessionsDay();
    // for (dynamic noonslot in getSessions['shift_details']) {
    //   setSessionTime.add(noonslot);
    // }
    await getSessionDay();
    //print(setSessionTime.length);
    // for (var eachtime in setSessionTime) {
    //   eachtime['start_time'] = double.parse(eachtime['start_time'].replaceAll(":", "."));
    //   eachtime['end_time'] = double.parse(eachtime['end_time'].replaceAll(":", "."));
    //   defaultSessions.add(eachtime);
    // }
  }

  Future getSessionDay() async {
    getSessions.clear();
    getSessions = await apiService.getetSessionsDay();
    for (dynamic noonslot in getSessions['shift_details']) {
      setSessionTime.add(noonslot);
    }
    for (var eachtime in setSessionTime) {
      eachtime['start_time'] = double.parse(eachtime['start_time'].replaceAll(":", "."));
      eachtime['end_time'] = double.parse(eachtime['end_time'].replaceAll(":", "."));
      defaultSessions.add(eachtime);
    }
  }

  Future getSpecialization() async {
    setBusy(true);
    specialization = await apiService.getSpecialization();
    setBusy(false);
  }

// Future addSession(){
// session_info=await
// }

  Future addSession(dynamic postparams, dynamic dates) async {
    setBusy(true);
    String userId = preferencesService.userId;
    postparams['doctor_id'] = userId;
    List getdates = [];

    for (var single in dates) {
      Jiffy fromDate_ = Jiffy(single);
      getdates.add(fromDate_.format('MM-dd-yyyy').toString());
    }
    session_info = await apiService.addSessions(postparams, userId, getdates);
    postparams['services_type'].toString().toLowerCase() != "In clinic"
        ? await viewSession(startDt, getLimit, postparams['services_type'])
        : await viewSessionByclinic(startDt, getLimit, preferencesService.clinicListStream!.value![0]['information_Id']);
    if (setSessionTime.length < 0) {
      getSessions = await apiService.getetSessionsDay();
      for (dynamic noonslot in getSessions['shift_details']) {
        setSessionTime.add(noonslot);
      }
    }
    setBusy(false);
  }

//session view_all_button

  Future viewSession(String startDate, String endDate, String serviceType) async {
    setBusy(true);
    get_session_view.clear();
    String userId = preferencesService.userId;
    // Jiffy startDt = Jiffy(startDate);
    // String startDtString = startDt.format('MM-dd-yyyy');
    //02-24-2022
    String startDtString = "02-26-2022";

    // postparams['user_id'] = userId;
    ////sessionslot/slots_timing_list?user_id=6200c2021da5d80033aa6ea8&start_slot_date=02-15-2022&end_slot_date=02-19-2022
    String jif = Jiffy().format('MM-dd-yyyy');
    // Jiffy d = Jiffy(DateTime(2018, 1, 13)).add(months: 6);
    // String till_date = d.format('MM-dd-yyy');
    //get_session_view = await apiService.getSessions(userId, '02-24-2022', '02-26-2022', 'clinic');
    get_session_view = await apiService.getSessionsByType(userId, startDate, endDate, serviceType);
    get_date_validitate = await apiService.getSessionsByType(userId, startDate, endDate, "");
    if (get_session_view != null && get_session_view != "") {
      //  calender_date_view = get_session_view[0];
      for (dynamic slot in get_session_view) {
        String gt = slot['slot_date'];
        // Jiffy fromDate_ = Jiffy(gt);
        //DateTime.parse("2022-02-27"),
        // DateFormat('MM-dd-yyyy').format(args.value.startDate).toString();
        DateTime now = DateTime.parse(slot['slot_date']);
        String isoDate = now.toIso8601String();
        Jiffy fromDate_ = Jiffy(isoDate);
        String m = fromDate_.format('MM-dd-yyyy');
        slot['slot_date'] = m;
        convert_dates.add(m);
        calender_date_view = get_session_view;
        // if (startDtString == m) {
        //   calender_date_view = slot;
        //   return;
        // }
        print("88888888" + m);
      }
      // get valid-unique date
      if (get_date_validitate != null && get_date_validitate != "") {
        //  calender_date_view = get_session_view[0];
        for (dynamic validslot in get_date_validitate) {
          String gt = validslot['slot_date'];
          // Jiffy fromDate_ = Jiffy(gt);
          //DateTime.parse("2022-02-27"),
          // DateFormat('MM-dd-yyyy').format(args.value.startDate).toString();
          DateTime now = DateTime.parse(validslot['slot_date']);
          String isoDate = now.toIso8601String();
          Jiffy fromDate_ = Jiffy(isoDate);
          String m = fromDate_.format('MM-dd-yyyy');
          validslot['slot_date'] = m;
          validate_convert_dates.add(m);
          validate_calender_date_view = get_date_validitate;
          // if (startDtString == m) {
          //   calender_date_view = slot;
          //   return;
          // }
          print("88888888" + m);
        }
      }
    }
    setBusy(false);
  }

  Future updateSession(dynamic postparams, dynamic dates) async {
    setBusy(true);
    String userId = preferencesService.userId;
    postparams['doctor_id'] = userId;

    List getdates = [];

    for (var single in dates) {
      Jiffy fromDate_ = Jiffy(single);
      getdates.add(fromDate_.format('MM-dd-yyyy').toString());
    }
    postparams['slot_date'] = getdates;
    session_info = await apiService.updateSessions(postparams, userId);
    setBusy(false);
  }

  //getSessionsByclinic

  Future viewSessionByclinic(String startDate, String endDate, String clinicId) async {
    setBusy(true);
    String userId = preferencesService.userId;
    get_session_view.clear();
    // Jiffy startDt = Jiffy(startDate);
    // String startDtString = startDt.format('MM-dd-yyyy');
    //02-24-2022
    String startDtString = "02-26-2022";

    // postparams['user_id'] = userId;
    ////sessionslot/slots_timing_list?user_id=6200c2021da5d80033aa6ea8&start_slot_date=02-15-2022&end_slot_date=02-19-2022
    String jif = Jiffy().format('MM-dd-yyyy');
    // Jiffy d = Jiffy(DateTime(2018, 1, 13)).add(months: 6);
    // String till_date = d.format('MM-dd-yyy');
    //get_session_view = await apiService.getSessions(userId, '02-24-2022', '02-26-2022', 'clinic');
    get_session_view = await apiService.getSessionsByclinic(userId, startDate, endDate, 'In clinic', clinicId);
    get_date_validitate = await apiService.getSessionsByType(userId, startDate, endDate, "");
    if (get_session_view != null && get_session_view != "") {
      //  calender_date_view = get_session_view[0];
      for (dynamic slot in get_session_view) {
        String gt = slot['slot_date'];
        // Jiffy fromDate_ = Jiffy(gt);
        //DateTime.parse("2022-02-27"),
        // DateFormat('MM-dd-yyyy').format(args.value.startDate).toString();
        DateTime now = DateTime.parse(slot['slot_date']);
        String isoDate = now.toIso8601String();
        Jiffy fromDate_ = Jiffy(isoDate);
        String m = fromDate_.format('MM-dd-yyyy');
        slot['slot_date'] = m;
        convert_dates.add(m);
        calender_date_view = get_session_view;
        // if (startDtString == m) {
        //   calender_date_view = slot;
        //   return;
        // }
        print("88888888" + m);
      }
    }
    // get valid-unique date
    if (get_date_validitate != null && get_date_validitate != "") {
      //  calender_date_view = get_session_view[0];
      for (dynamic validslot in get_date_validitate) {
        String gt = validslot['slot_date'];
        // Jiffy fromDate_ = Jiffy(gt);
        //DateTime.parse("2022-02-27"),
        // DateFormat('MM-dd-yyyy').format(args.value.startDate).toString();
        DateTime now = DateTime.parse(validslot['slot_date']);
        String isoDate = now.toIso8601String();
        Jiffy fromDate_ = Jiffy(isoDate);
        String m = fromDate_.format('MM-dd-yyyy');
        validslot['slot_date'] = m;
        validate_convert_dates.add(m);
        validate_calender_date_view = get_date_validitate;
        // if (startDtString == m) {
        //   calender_date_view = slot;
        //   return;
        // }
        print("88888888" + m);
      }
    }
    setBusy(false);
  }
}

import 'dart:convert';

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

class PatientWidgetmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<int> ccIds = [];
  List<CubeUser> sourceUsers = [];
  List<CubeUser> searchUsers = [];
  dynamic bookingPatients = [];
  dynamic search_bookingPatients = [];
  dynamic search_Patients_list = [];
  dynamic bookingsdata = {};
  dynamic bookeddata = [];
  dynamic bookingappoinments = [];
  dynamic bookedappoinments = [];
  dynamic bookedPatientsdata = [];
  dynamic bookedpatientInfo = [];
  dynamic bookedhistorydata = [];
  dynamic bookedfilesdata = [];
  List<dynamic> searchBy_lists = [];
  dynamic accept_patients = [];
  List fileName = [];
  String sortMode = "";
  Future init() async {
    // await getPatientsList("6200c2021da5d80033aa6ea8");
    String userId = preferencesService.userId;
    await getPatientsList(userId);
  }

  Future getPatientsDetails(String patientsId) async {
    setBusy(true);
    ccIds.clear();
    //623c00e303e5c6002e85bb0b -patients_id
    //623d47fd8f2e2e002e3e26b1
    final patients = await apiService.getProfile(patientsId);
    if (patients['connectycube_id'] != null) {
      ccIds.add(int.parse(patients['connectycube_id'].toString()));
    }
    // print(ccIds.length);
    // if (ccIds.length == 0) {
    //   setBusy(false);
    // }
    setBusy(false);
  }

//model.bookingPatients
  Future getPatientsList(String doctorUserId) async {
    setBusy(true);

    ccIds.clear();

    //623c00e303e5c6002e85bb0b -patients_id
    //623d47fd8f2e2e002e3e26b1
    final patientsInfo = await apiService.getPatientsList(doctorUserId);
//bookingPatients=patients.data;
    // print(ccIds.length);
    // if (ccIds.length == 0) {
    //   setBusy(false);
    // }
    setBusy(true);

//    bookingsdata = patientsInfo['BookingData'];
    bookingsdata = patientsInfo;

    //print(bookingappoinments);
// for(var lst in bookingsdata){

// }
    if (bookingsdata != null) {
      // List doctors = patientsInfo['patient_id'];
      // List doctorsProfile = patientsInfo['Doctor_profile_Data'];

      bookingappoinments.clear();
      for (var innerbookings in bookingsdata) {
        bookingappoinments.add(innerbookings);
      }
      // bookingappoinments = bookingsdata['booking_appointments'];
      //  datas = [];
      if (bookingappoinments.length > 0) {
        for (dynamic gtlist in bookingappoinments) {
          accept_patients.add(gtlist['patient_id']);
        }
        //Map<String, dynamic> getObj = gtlist['patient_id'];
        // Map<String, dynamic> myMap = Map<String, dynamic>.from(gtlist['patient_id']);
        //List<dynamic> s=gtlist['patient_id'];
        //dynamic patients_detail = Map.from(getObj);
        // List<dynamic> accpt = gtlist.expand((i) => i['patient_id']).toList();
        // List pat_lst = patients_detail.toList();
        for (dynamic glt in accept_patients) {
          // if (gtlist.length > 0) {
          var datasMap = {
            'name': glt['name'],
            'age': glt['age'],
            'gender': glt['gender'],
            'address': glt['address'],
            'mobilenumber': glt['mobilenumber'],
            'email': glt['email'],
            'countryCode_digits': glt['countryCode_digits'],
            'swar_Id': glt['swar_Id'],
            'azureBlobStorageLink': glt['azureBlobStorageLink'],
            'patient_id': glt['_id'],

            //
          };
          bookingPatients.add(datasMap);
          //}
        }

        //print(bookingPatients.toString());
      }
    }
    //await getBookedPatientDetail(doctor_user_id);
    setBusy(false);
  }
  //getBookedPatientDetails

  Future getBookedPatientDetail(String patientUserId, int index) async {
    setBusy(true);

    //623c00e303e5c6002e85bb0b -patients_id
    //623d47fd8f2e2e002e3e26b1
    bookedpatientInfo = await apiService.getBookedPatientDetails(patientUserId);

    for (var innerd in bookedpatientInfo['BookingData']) {
      // dynamic s = inner;

      bookedappoinments.add(innerd);
    }
    for (dynamic inn in bookedappoinments) {
      // dynamic s = inner;
      bookedfilesdata.add(inn['appointment_upload_documents']);
    }
    for (int i = 0; i < bookedfilesdata.length; i++) {
      for (var fl in bookedfilesdata[i]) {
        fileName.add(fl);
      }
    }

//bookingPatients=patients.data;
    // print(ccIds.length);
    // if (ccIds.length == 0) {
    //   setBusy(false);
    // }

    // bookeddata = bookedpatientInfo.map((e) {
    //   return e[0];
    // });
    // for(var s in bookedpatientInfo){
    //bookeddata = bookedpatientInfo['BookingData'];

    // if (bookingappoinments[0]['appointment_upload_documents'] != null) {
    //   print(bookingappoinments[0]['appointment_upload_documents'].length.toString);
    //   //fileName.add('${ApiService.fileStorageEndPoint}${bookeddata['appointment_upload_documents']}');
    //   // document_img_url = '${ApiService.fileStorageEndPoint}${model.documentData['appointment_upload_documents'][0]}';

    // }
    // if (bookedpatientInfo != "") {
    //   bookeddata = bookedpatientInfo;
    //   // for (var inner in bookedpatientInfo['BookingData']) {
    //   //   dynamic s = inner;
    //   //   // bookedappoinments.add(inner);
    //   // }
    //   // final jsonList = bookedpatientInfo[0].map((item) => jsonEncode(item)).toList();
    //   // bookeddata = bookedpatientInfo.map((e) {
    //   //   return e['BookingData'];
    //   // });
    // }

    //print(bookingappoinments);

    // if (bookeddata != null) {
    //   // List doctorsProfile = patientsInfo['Doctor_profile_Data'];
    //   bookedappoinments.clear();
    //   for (var innerbooked in bookedappoinments) {
    //     bookedappoinments.add(innerbooked);
    //   }
    // }

    // if (bookedpatientInfo['user_personal_Data'] != null) {
    //   List patient = bookedpatientInfo['user_personal_Data'];
    //   // List doctorsProfile = patientsInfo['Doctor_profile_Data'];
    //   // bookingappoinments.clear();
    //   // for (var inner in patient) {
    //   //   bookingappoinments.add(inner);
    //   // }
    //   // bookingappoinments = bookingsdata['booking_appointments'];
    //   //  datas = [];
    //   // if (patient.length > 0) {
    //   for (final gtplist in patient) {
    //     if (gtplist.length > 0) {
    //       var datasMap = {
    //         'name': gtplist['name'],
    //         'age': gtplist['age'],
    //         'gender': gtplist['gender'],
    //         'address': gtplist['address'],
    //         'mobilenumber': gtplist['mobilenumber'],
    //         'email': gtplist['email'],
    //         'countryCode_digits': gtplist['countryCode_digits'],
    //         'swar_Id': gtplist['swar_Id'],
    //         'azureBlobStorageLink': gtplist['azureBlobStorageLink']
    //       };
    //       bookedPatientsdata.add(datasMap);
    //     }
    //   }
    //print(bookingPatients.toString());
    //}
    //}

    setBusy(false);
  }

//patients search
  void getPatient_search(String search) {
    List<dynamic> usersListStream = preferencesService.usersListStream!.value!;

    // recentFamily.add({});
    // recentFriends = memSections.where((e) {
    search_Patients_list = accept_patients.where((e) {
      return e['name'].toString().toLowerCase().contains(search.toLowerCase()) ||
              e['swar_Id'].toString().toLowerCase().contains(search.toLowerCase()) ||
              e['mobilenumber'].toString().toLowerCase().contains(search.toLowerCase())
          //mobilenumber
          ;
    }).toList();

    // search_bookingPatients.add(searchBy_lists);
    // for (dynamic gtli in search_bookingPatients) {
    //   search_Patients_list.add(gtli);
    // }
    // accept_patients=accept_patients.where((e) {
    //   return e['name'].toString().toLowerCase().contains(search.toLowerCase());
    // }).toList();
    //accept_patients.clear();

    // bookingappoinments.clear();
    // bookingappoinments.add(searchBy_lists);
    // recentFriends.add({});
    setBusy(false);
  }
}

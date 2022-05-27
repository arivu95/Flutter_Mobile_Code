import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class Homevisitmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> tempDoctorList = [];
  List<dynamic> doctorList = [];
  List<dynamic> healthproviders = [];
  String loginroleid = "";
  String educational_list = '';
  List<dynamic> medicalRegistration_list = [];
  List<dynamic> experience_list = [];
  List<dynamic> clinic_list = [];
  List<dynamic> achievement_list = [];
  List<dynamic> spl_list = [];
  List<dynamic> doctorDetails = [];
  List<dynamic> doctor_edu_details = [];
  List<dynamic> doctor_experience_details = [];
  List<dynamic> doc_insurance_details = [];
  List<dynamic> doc_clinic_details = [];
  List<dynamic> doc_total_list = [];
  List<dynamic> doctorListSection = [];

  Future getDoctorList(String cat, int selectedIndex) async {
    setBusy(true);
    if (selectedIndex == 0) {
      loginroleid = "61e7a9e44c559c1530e0e562";
    } else {
      loginroleid = "61e7aa154c559c1530e0e564";
    }
    tempDoctorList = await apiService.getHomevistDoctorList(loginroleid);
    List<dynamic> ratingData = await apiService.getDoctorRating();
    if (tempDoctorList.isNotEmpty) {
      doc_total_list = [];
      doctorList = [];
      List doctorstages = ['verified', 'Enhanced', 'swar doctor'];
      for (int i = 0; i < doctorstages.length; i++) {
        for (var doctors in tempDoctorList) {
          if (doctors['doctor_profile_id']['stage'] == doctorstages[i]) {
            doc_total_list.add(doctors);
          }
        }
      }
      print("doctorlist" + doc_total_list.toString());
      if (doc_total_list.length > 0) {
        doctorList = doc_total_list.where((e) {
          return e['specialization'].toString().toLowerCase().contains(cat);
        }).toList();
      }
    } else {
      doc_total_list = [];
    }

    if (doc_total_list.length > 0) {
      doctorList = doc_total_list.where((e) {
        return e['specialization'].toString().toLowerCase().contains(cat.toLowerCase());
      }).toList();
    }
    doctorListSection = doctorList.toList();

    for (var i = 0; i < doctorList.length; i++) {
      for (var each in ratingData) {
        if (doctorList[i]['_id'] == each['doctor_id']) {
          doctorList[i]['count'] = each['patients_totalCount'].toString();
          if (each['average_rating'] != null) {
            doctorList[i]['rating'] = each['average_rating'].toString();
          } else {
            doctorList[i]['rating'] = '0.0';
          }
        }
      }
    }

    // for (var i = 0; i < doctorList.length; i++) {
    //   dynamic ratingData = await apiService.getDoctorRating(doctorList[i]['_id']);
    //   doctorList[i]['count'] = ratingData['patients_totalCount'].toString();
    //   if (ratingData['average_rating'] != null) {
    //     doctorList[i]['rating'] = ratingData['average_rating'].toString();
    //   } else {
    //     doctorList[i]['rating'] = '0.0';
    //   }
    // }

    // if (doctorDetails.isNotEmpty) {
    //   for (var i = 0; i < doctorDetails.length; i++) {
    //     if ((doctorDetails[i]['educational_information'].isNotEmpty) && (doctorDetails[i]['educational_information'] != "")) {
    //       doctor_edu_details.add(doctorDetails[i]['educational_information']);
    //     }
    //   }
    // }

    // if (doctorDetails.isNotEmpty) {
    //   for (var i = 0; i < doctorDetails.length; i++) {
    //     if ((doctorDetails[i]['experience'].isNotEmpty) && (doctorDetails[i]['experience'] != "")) {
    //       doctor_experience_details.add(doctorDetails[i]['experience']);
    //     }
    //   }
    // }

    // if (doctorDetails.isNotEmpty) {
    //   for (var i = 0; i < doctorDetails.length; i++) {
    //     if ((doctorDetails[i]['insurance'] != null) && (doctorDetails[i]['insurance'] != "")) {
    //       doc_insurance_details.add(doctorDetails[i]['insurance']);
    //     }
    //   }
    // }

    // if (doctorDetails.isNotEmpty) {
    //   for (var i = 0; i < doctorDetails.length; i++) {
    //     if ((doctorDetails[i]['clinic_details'].isNotEmpty) && (doctorDetails[i]['clinic_details'] != "")) {
    //       doc_clinic_details.add(doctorDetails[i]['clinic_details']);
    //     }
    //   }
    // }
    await getProviderRole();
    setBusy(false);
  }

  Future getProviderRole() async {
    healthproviders = await apiService.gethealthproviders();
  }

  void getdoctors_search(String search) {
    doctorList = doctorListSection.where((e) {
      return e['name'].toString().toLowerCase().contains(search.toLowerCase());
    }).toList();
  }
}

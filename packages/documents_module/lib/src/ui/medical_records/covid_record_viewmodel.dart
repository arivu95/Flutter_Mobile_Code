import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class CovidRecordViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  List<dynamic> coviddose = [];
  List<dynamic> vaccines = [];
  List<dynamic> labtest = [];
  List<dynamic> records = [];
  List<dynamic> memberVaccines = [];
  List<dynamic> memberLabTests = [];
  List<dynamic> memberTreatments = [];
  List<dynamic> memberdose = [];
  List outputList = [];
  dynamic dose_count = '';
  dynamic get_user_covid = '';
  dynamic getdoseid = '';
  dynamic covidVaccineData;
  dynamic labTestData;
  List<dynamic> recentUploads = [];
  String memberId = '60d8282a9b92da087d28b999';
  // String memberId = '60cd4cfa5d2d9d08c726e82d';
  // String memberId='60cca116ce685920d8199664';
  String countryCode = '602dde0764f3802c6453641b';
  String mem_name = '';
  String covidMaster_id = '';

  Future getMemberVaccines() async {
    setBusy(true);
    // String memberId = '60cd9ffa5d2d9d08c726e857';
    records = await apiService.getCovidMemeberRecords(memberId);
    //print('________________recCRES'+records[0].usercovidvaccine['dosestatus'].toString());
    if (records.isNotEmpty) {
      covidVaccineData = records.first;
      covidMaster_id = covidVaccineData['_id'];
      if (covidVaccineData['usercovidvaccine'] != null) {
        memberVaccines = covidVaccineData['usercovidvaccine'];
        if (memberVaccines.isNotEmpty) {
          memberdose = memberVaccines[0]['dosestatus'];
        }
      }
      if (covidVaccineData['usercovidtest'] != null) {
        memberLabTests = covidVaccineData['usercovidtest'];
      }
      if (covidVaccineData['treatment_details'] != null) {
        memberTreatments = covidVaccineData['treatment_details'];
      }
    }
    // await getCovidVaccines();
    // await getCovidLabTest();
    await getCovidVaccine_LabTest();
    setBusy(false);
  }

  Future addMoreVaccine(String covidVaccinationId) async {
    if (isCovidRecordAdded()) {
      // Send a PATCH Request
      final response = await apiService.addMoreVaccinePatch(covidVaccineData['_id'], covidVaccinationId);
      print(response);
      await getMemberVaccines();
    } else {
      // Send a POST Request
      final response = await apiService.addNewVaccineForMember(memberId, covidVaccinationId, countryCode, 'covidVaccinationMaster_Id');
      await getMemberVaccines();
    }
  }

  //
  //
   Future updateCovidVaccineInfo(bool status, String dateStr, dynamic covidData, String documentId, String filterTitle1) async {
    Map<String, dynamic> postParams = {};
    if (status == true) {
      postParams['status'] = '1';
    } else {
      postParams['status'] = '0';
    }
    if (filterTitle1.isNotEmpty) {
      postParams['title1'] = filterTitle1;
    }
    postParams['title2'] = covidData['dose'];
    covidData['status'] = status;
    if (dateStr.isNotEmpty) {
      Jiffy date = Jiffy(dateStr, 'MM-dd-yyyy');
      String dt = date.format();
      covidData['date'] = dt;
      postParams['date'] = dateStr;
    }

    postParams['covidDose_Id'] = covidData['_id'];
    postParams['covidVaccination_Id'] = documentId;

    if (preferencesService.paths.length > 0) {
      covidData['attach_record'] = preferencesService.paths;
    } else {
      covidData['attach_record'] = "";
    }
    setBusy(false);
    final response = await apiService.updateCovidVaccineInfo(covidVaccineData['_id'], postParams, preferencesService.paths);
    print(response);
    preferencesService.paths.clear();
//     if(response){
// preferencesService.onRefreshRecentDocumentFromTable!.value = true;
//     }
    //preferencesService.onRefreshRecentDocumentFromTable!.value = true;
  }

  Future deleteCovidInfo(String refId, String flag) async {
    final response = await apiService.deleteCovidInfo(refId, flag, covidVaccineData['_id']);
    print(response);
    await getMemberVaccines();
    setBusy(false);
    // preferencesService.onRefreshRecentDocumentFromTable!.value = true;
  }

  //
  Future deleteTestInfo(String refId, String flag) async {
    final response = await apiService.deleteCovidInfo(refId, flag, covidVaccineData['_id']);
    print(response);
    await getMemberVaccines();
    setBusy(false);
    //preferencesService.onRefreshRecentDocumentFromTable!.value = true;
  }

  Future updateCovidTestInfo(String result, String dateStr, dynamic covidData,int index, String documentId) async {
    setBusy(true);
    Map<String, dynamic> postParams = {};
    postParams['test_result'] = result;
    covidData['test_result'] = result;
    postParams['title1'] = covidData['test_name']+'_'+covidData['_id'].toString();
    if (dateStr.isNotEmpty) {
      Jiffy date = Jiffy(dateStr, 'MM-dd-yyyy');
      String dt = date.format();
      covidData['taken_date'] = dt;
      postParams['date'] = dateStr;
    }
    postParams['covidtest_Id'] = covidData['_id'];
    if (preferencesService.paths.length > 0) {
      covidData['attach_reports'] = preferencesService.paths;
    }

    final response = await apiService.updateCovidVaccineInfo(covidVaccineData['_id'], postParams, preferencesService.paths);
    await getMemberVaccines();
    preferencesService.paths.clear();
    preferencesService.onRefreshRecentDocumentOnDownload!.value = true;
    // preferencesService.onRefreshDownloadDocumentFromTable!.value = true;
    print(response);
    setBusy(false);
  }

  Future updateCovidTreatmentDetails(String path) async {
    final response = await apiService.updateCovidTreatmentDetails(covidVaccineData['_id'], path);
    print(response);
    setBusy(false);
  }

//Lab Test getCovidLabTest
  Future getCovidLabTest() async {
    //  setBusy(true);
    labtest = await apiService.getCovidLabTest(countryCode);
    // print('------------------lab'+labtest.toString());
    //setBusy(false);
  }

  Future getCovidVaccines() async {
    //setBusy(true);
    vaccines = await apiService.getCovidVaccines(countryCode);
    //setBusy(false);
  }

  Future getCovidVaccine_LabTest() async {
    // setBusy(true);
    labtest = await apiService.getCovidLabTest(countryCode);
    vaccines = await apiService.getCovidVaccines(countryCode);
    print('------------------lab' + labtest.toString());
    // setBusy(false);
  }

  //labTest
  // Future getMemberLabtest() async {
  //   // String memberId = '60cd9ffa5d2d9d08c726e857';
  //   List records = await apiService.getCovidMemeberRecords(memberId);
  //   //print('________________recCRES'+records[0].usercovidvaccine['dosestatus'].toString());
  //   if (records.isNotEmpty) {
  //     labTestData = records.first;
  //     print('******LAB TEST*******' + labTestData.toString());
  //     if (labTestData['usercovidtest'] != null) {
  //       memberLabTests = labTestData['usercovidtest'];
  //     }
  //   }
  //   setBusy(false);
  // }

  bool isCovidRecordAdded() {
    if (records.length > 0) {
      return true;
    }
    return false;
  }

//addNewLabTest
  Future addNewLabTest(String labTestId) async {
    if (isCovidRecordAdded()) {
      // Send a PATCH Request
      final response = await apiService.addMoreLabtestPatch(covidVaccineData['_id'], labTestId);
      await getMemberVaccines();
    } else {
      // Send a POST Request
      final response = await apiService.addNewVaccineForMember(memberId, labTestId, countryCode, 'covidtest_Id');
      await getMemberVaccines();
    }
  }

  // Future addLabtestDetails(String covidVaccinationId) async {
  //   //print('___________________'+memberVaccines.length.toString()+ memberVaccines.toString());
  //   if (memberVaccines.length > 0) {
  //     // Send a PATCH Request
  //     final response = await apiService.addMoreVaccinePatch(covidVaccineData['_id'], covidVaccinationId);
  //     //print('_____________________________'+response);
  //     print(response);
  //     await getMemberVaccines();
  //   } else {
  //     // Send a POST Request
  //     final response = await apiService.addNewVaccineForMember(memberId, covidVaccinationId, countryCode);
  //     // print('post resq______________'+response);
  //     // print('post resq______________'+response);
  //     await getMemberVaccines();
  //   }
  // }

  Future getdoselist() async {
    setBusy(true);
    coviddose = await apiService.getdoeslist();
    setBusy(false);
  }

  Future getRecentUploads() async {
    setBusy(false);
    String selectedDropdownid = preferencesService.dropdown_user_id;
    recentUploads = await apiService.getRecentUploads(selectedDropdownid);
    setBusy(false);
  }

  Future addCoviddose(String covidDose) async {
    setBusy(true);
    final response = await apiService.addCovidDose(covidDose, covidMaster_id);
    await getMemberVaccines();
    setBusy(false);
  }

  Future coviddoseupdated(String doseid, String dosename) async {
    setBusy(true);
    final response = await apiService.edit_covid_dose(doseid, dosename);
    await getdoselist();
    setBusy(false);
  }
}

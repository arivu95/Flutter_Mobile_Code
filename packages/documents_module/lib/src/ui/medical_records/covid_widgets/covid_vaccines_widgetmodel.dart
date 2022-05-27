import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class CovidVaccinesWidgetModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  List<dynamic> vaccines = [];
  List<dynamic> labtest = [];
  List<dynamic> memberVaccines = [];
  dynamic covidVaccineData;
  String memberId = '60cda0cd5d2d9d08c726e85b';
  // String memberId = '60cd4cfa5d2d9d08c726e82d';
  // String memberId='60cca116ce685920d8199664';
  String countryCode = '602dde0764f3802c6453641b';

  Future getCovidVaccines() async {
    setBusy(true);
    vaccines = await apiService.getCovidVaccines(countryCode);
    setBusy(false);
  }

  Future getMemberVaccines() async {
    // String memberId = '60cd9ffa5d2d9d08c726e857';
    List records = await apiService.getCovidMemeberRecords(memberId);
    //print('________________recCRES'+records[0].usercovidvaccine['dosestatus'].toString());
    if (records.isNotEmpty) {
      covidVaccineData = records.first;
      if (covidVaccineData['usercovidvaccine'] != null) {
        memberVaccines = covidVaccineData['usercovidvaccine'];
      }
    }
    setBusy(false);
  }

  // Future addMoreVaccine(String covidVaccinationId) async {
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
  //    // print('post resq______________'+response);
  //   // print('post resq______________'+response);
  //     await getMemberVaccines();
  //   }
  // }

  //

  Future updateCovidVaccineInfo(bool status, String dateStr, String path, dynamic covidData, String documentId) async {
    Map<String, dynamic> postParams = {};
    postParams['status'] = status;
    // covidData['status'] = status;
    if (dateStr.isNotEmpty) {
      covidVaccineData['date'] = dateStr;
      postParams['date'] = dateStr;
    }

    postParams['covidDose_Id'] = covidData['_id'];
    // postParams['covidVaccination_Id'] = documentId;
    // print('--------TTTTTTTTTTTTT-----');
    if (path.isNotEmpty) {
      covidVaccineData['fileName'] = "fileAttach";
      covidVaccineData['attach_record'] = path;
    }

    setBusy(false);
    final response = await apiService.updateCovidVaccineInfo(covidVaccineData['_id'], postParams, [path]);
    print(response);
    // Calling refresh
    //preferencesService.onRefreshRecentDocumentFromTable!.value = true;
  }

  //
  Future deleteCovidInfo(String refId, String flag) async {
    final response = await apiService.deleteCovidInfo(refId, flag, covidVaccineData['_id']);
    print(response);
    await getMemberVaccines();
    setBusy(false);
  }
}

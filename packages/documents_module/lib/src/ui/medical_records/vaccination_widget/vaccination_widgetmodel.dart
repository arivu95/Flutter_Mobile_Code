import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class VaccinationWidgetModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  //String memberId = '60d8282a9b92da087d28b999';

  String countryId = '602dde0764f3802c6453641b';

  List<dynamic> userVaccine = [];
  dynamic userVaccineData = {};
  bool isNewtable=false;
  Future getUserVaccine() async {
    // print(preferencesService.dropdown_user_id.toString());
    String memberId = preferencesService.dropdown_user_id;
    final response = await apiService.getUserVaccine(memberId);

    if (response.length == 0) {
        isNewtable=true;
      createVaccinationTableForUser();
      return;
    } else {
      userVaccineData = response.first;
      isNewtable=false;
      if (userVaccineData['vaccination'] != null) {
        userVaccine = userVaccineData['vaccination'];
      }
    }

    setBusy(false);
  }

  Future createVaccinationTableForUser() async {
    String memberId = preferencesService.dropdown_user_id;
    userVaccineData = await apiService.createVaccinationTableForUser(memberId, countryId);

    print(userVaccineData);
    if (userVaccineData['vaccination'] != null) {
      userVaccine = userVaccineData['vaccination'];
    }

  }

  //Future updateCovidVaccineInfo(bool status, String dateStr, String path, dynamic covidData, String documentId) async {
  Future updateVaccinationInfo(bool status, String dateStr, String path, dynamic vaccineData, String documentId) async {
    Map<String, dynamic> postParams = {};
    String selectedDropdownid = preferencesService.dropdown_user_id;
    vaccineData['status'] = status;

    if (dateStr.isNotEmpty) {
      Jiffy date = Jiffy(dateStr, 'MM-dd-yyyy');
      String dt = date.format();
      vaccineData['date'] = dt;
      postParams['date'] = dateStr;
    }
    if (path.isNotEmpty) {
      vaccineData['attach_record'] = path;
    }
    if (status == true) {
      postParams['status'] = '1';
    } else {
      postParams['status'] = '0';
    }
    postParams['vaccinationMaster_Id'] = documentId;
    postParams['vaccine_Id'] = vaccineData['_id'];
    postParams['member_Id'] = selectedDropdownid;
    postParams['country_Id'] = countryId;
    setBusy(false);
    // print('POST PARAMS*********************'+postParams.toString());
    final response = await apiService.updateVaccinationInfo(userVaccineData['_id'], postParams, [path]);
    preferencesService.onRefreshRecentDocumentFromTable!.value = true;
    preferencesService.onRefreshRecentDocumentOnDownload!.value = true;

//refresh the
 // Future.delayed(Duration(milliseconds: 1000), () {
      // print(preferencesService.onRefreshDownloadDocumentFromTable!.value);
      // preferencesService.onRefreshDownloadDocumentFromTable!.value = preferencesService.onRefreshDownloadDocumentFromTable!.value! + 1;
      // preferencesService.onRefreshDownloadDocumentFromTable!.refresh();
  //  });

      //print(preferencesService.onRefreshDownloadDocumentFromTable!.value);
     // preferencesService.onRefreshDownloadDocumentFromTable!.value = true;
      //preferencesService.onRefreshDownloadDocumentFromTable!.refresh();

    print(response);
  }
}

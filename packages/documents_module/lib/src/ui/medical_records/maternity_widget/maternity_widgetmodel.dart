import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class MaternityWidgetModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  String countryId = '602dde0764f3802c6453641b';

  List<dynamic> userMaternity = [];
  dynamic userMaternityData = {};
  String due_date = '';

  Future getUserMaternity() async {
    setBusy(true);
    String memberId = preferencesService.dropdown_user_id;
    final response = await apiService.getUserMaternity(memberId);
    if (response.length == 0) {
      //await createMaternityTableForUser();
      createMaternityTableForUser();
      return;
    } else {
      userMaternityData = response.first;
      if (userMaternityData['reports'] != null) {
        userMaternity = userMaternityData['reports'];
      }
      if (userMaternityData['expected_due_date'] != null) {
        due_date = userMaternityData['expected_due_date'];
      }
    }

    setBusy(false);
  }

  Future createMaternityTableForUser() async {
    String memberId = preferencesService.dropdown_user_id;
    userMaternityData = await apiService.createMaternityTableForUser(memberId, countryId);

    print(userMaternityData);
    if (userMaternityData['reports'] != null) {
      userMaternity = userMaternityData['reports'];
    }
  }

  Future updateMaternityInfo(String motherWeight, dynamic maternityData, String documentId) async {
    setBusy(true);
    Map<String, dynamic> postParams = {};
    String selectedDropdownid = preferencesService.dropdown_user_id;
    print(motherWeight);
    if (motherWeight != null) {
      maternityData['mother_weight'] = motherWeight;
      postParams['mother_weight'] = motherWeight;
    }

      if (preferencesService.paths.length>0) {
      maternityData['attach_record'] = preferencesService.paths;
    }
    postParams['title1'] = maternityData['pregnancy_week']+' Week';
    postParams['maternity_Id'] = documentId;
    postParams['member_id'] = selectedDropdownid;
    postParams['country_Id'] = countryId;
    postParams['expected_due_date'] = due_date;

//other field (edit maternity fields)
// can able to give postParams=maternityData;
    // but it give date format error.as of now seperatly, give

    if (maternityData['checkup_date'] != null && maternityData['checkup_date'] != "") {
      Jiffy chck = Jiffy(maternityData['checkup_date']);
      postParams['checkup_date'] = chck.dateTime;
    }

    postParams['pregnancy_week'] = maternityData['pregnancy_week'];
    postParams['mother_BP'] = maternityData['mother_BP'];
    postParams['baby_blood_group'] = maternityData['baby_blood_group'];
    postParams['clinic_name'] = maternityData['clinic_name'];
    postParams['note'] = maternityData['note'];
    postParams['glucose_level'] = maternityData['glucose_level'];
    postParams['blood_sugar'] = maternityData['blood_sugar'];
    postParams['mother_blood_group'] = maternityData['mother_blood_group'];
    postParams['temperature'] = maternityData['temperature'];
    postParams['spo2'] = maternityData['spo2'];
    postParams['doctor_name'] = maternityData['doctor_name'];
    postParams['baby_BPM'] = maternityData['baby_BPM'];
    postParams['baby_HCG_level'] = maternityData['baby_HCG_level'];
    postParams['clinic_name'] = maternityData['clinic_name'];
    postParams['baby_head_circumference'] = maternityData['baby_head_circumference'];
    postParams['member_medical_id'] = maternityData['member_medical_id'];


    final response = await apiService.updateMaternityInfo(userMaternityData['_id'], postParams,preferencesService.paths);
    await getUserMaternity();
    preferencesService.paths.clear();
    print(response);
    setBusy(false);
    // preferencesService.onRefreshRecentDocumentFromTable!.value = true;
    preferencesService.onRefreshRecentDocumentOnDownload!.value = true;
  }
}


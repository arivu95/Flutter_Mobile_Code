import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class updateMaternityViewmodel extends BaseViewModel {
  
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  String countryId = '602dde0764f3802c6453641b';

  Future updateMaternityInfo(Map<String, dynamic> postParams, String userMaternityDataId) async {
     setBusy(true);
     String selectedDropdownid=  preferencesService.dropdown_user_id;
     postParams['member_id'] = selectedDropdownid;
      postParams['member_Id'] = selectedDropdownid;
    postParams['country_Id'] = countryId;
       postParams['fileName'] = 'fileAttach';
     if(preferencesService.paths.isNotEmpty){
      postParams['attach_record'] = preferencesService.paths;
    }

      final response = await apiService.updateMaternityInfo(userMaternityDataId, postParams, preferencesService.paths);
      print(response);
        preferencesService.onRefreshRecentDocument!.value = true;
      setBusy(false);
  //return true;
  }
}

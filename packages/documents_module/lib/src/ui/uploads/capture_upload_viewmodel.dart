import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class CaptureUploadViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  //
  List<dynamic> fileCategory = [];
  double stored_tot = 0.0;
  List<dynamic> listmembers = [];
  double subscib_storg = 0.0;
  Future getFileCategory() async {
    setBusy(true);
    fileCategory = await apiService.getFileCategory();

//check storage storage

    String subscTot = preferencesService.subscriptionInfo['storage_size_conversion'];
    if (subscTot != null) {
      subscTot = subscTot.replaceAll(RegExp("[a-zA-Z]"), "");
      subscTot = subscTot.trim();

      subscib_storg = double.parse(subscTot);
    }
    //preferencesService.subscriptionInfo['storage_size_conversion'].toString();

// current storage size
    String userId = preferencesService.userId;
    List members = await apiService.getUserMembersList(userId);
    if (members.length > 0) {
      listmembers = [];
      for (var i = 0; i < members.length; i++) {
        if (members[i][0]['storage_size'] != null) {
          var temp = members[i][0]['storage_size']!;
          // print('---------------'+temp);
          if (temp != "" && temp != null) {
            stored_tot = stored_tot + temp!;
          }
        }
      }
    }
    print(fileCategory);
    setBusy(false);
  }

  String getCategoryId(int index) {
    if (fileCategory.length > index) {
      dynamic category = fileCategory[index];
      return category['_id'];
    }
    return '';
  }

  Future<bool> checkStorag() async {
    preferencesService.subscriptionInfo['storage_size_conversion'].toString();
    String userId = preferencesService.userId;
    List members = await apiService.getUserMembersList(userId);
    if (members.length > 0) {
      listmembers = [];
      for (var i = 0; i < members.length; i++) {
        var temp = members[i][0]['storage_size']!;
        // print('---------------'+temp);
        if (temp != "" && temp != null) {
          stored_tot = stored_tot + temp!;
        }
      }
    }

    return true;
  }

  //
  Future<bool> uploadDocuments(String path, String catId, String mode) async {
    //print('path is--------'+path);
    String selectedDropdownid = preferencesService.dropdown_user_id;
    // print('++++++++++))))))))))'+selected_dropdownid);
    String userId = preferencesService.userId;
    //print('++++++++++))))))))))'+userId);
    final response = await apiService.uploadDocuments(
        {'member_id': selectedDropdownid, 'filecategoryid': catId, 'active_flag': 1, 'created_by': selectedDropdownid, 'fileName': path}, preferencesService.paths, preferencesService.thumbnail_paths, mode);
    print(response);

    return response;
  }
}

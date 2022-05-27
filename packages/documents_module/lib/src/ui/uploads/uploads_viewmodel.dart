import 'dart:convert';

import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class UploadsViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> recentUploads = [];
  List<dynamic> listmembers = [];
  List<dynamic> fileCategory = [];
  String selectedMembers = '';
  String selectedMemberName = '';
  String selectedMemberDob = '';
  String selectedMemberAge = '';
  dynamic usercountry = {};
  double stored_tot = 0.0;
  // Future<bool> uploadDocuments(
  //     String path, String catId, String filepath, String mode) async {
  //   String userId = preferencesService.userId;
  //   final response = await apiService.uploadDocuments({
  //     'filecategoryid': catId,
  //     'active_flag': 1,
  //     'created_by': userId,
  //     'member_id': userId,
  //   }, [
  //     filepath
  //   ], mode);
  //   print(response);
  //   return response;
  // }

  Future init() async {
    preferencesService.initRefreshRecentDocumentOnUpload();
    preferencesService.onRefreshRecentDocumentOnUpload!.onChange((isRefresh) {
      if (isRefresh) {
        preferencesService.onRefreshRecentDocumentOnUpload!.value = false;
        getRecentUploads();
      }
    });
  }

  Future getRecentUploads() async {
    setBusy(true);
    String selectedDropdownid = preferencesService.dropdown_user_id;
    recentUploads = await apiService.getRecentUploads(selectedDropdownid);
    preferencesService.onRefreshRecentDocument!.value = true;
    setBusy(false);
  }

  Future getCountry() async {
    setBusy(true);
    usercountry = await apiService.getuserCounty(preferencesService.user_country_id);
    preferencesService.user_country_flag = usercountry['countryFlag'];
    setBusy(false);
  }

  Future getMembersList(bool isReload) async {
    if (isReload) {
      setBusy(true);
    }

    String userId = preferencesService.userId;
    //List members = await apiService.getUserMembersList(userId);
    List members = List.from(preferencesService.memebersListStream!.value!);
    if (members.length > 0) {
      listmembers = [];
      for (dynamic member in members) {
        if (member.length > 0) {
          listmembers.add(member);
          final jsonList = listmembers.map((item) => jsonEncode(item)).toList();
          final uniqueJsonList = jsonList.toSet().toList();
          listmembers = uniqueJsonList.map((item) => jsonDecode(item)).toList();
        }
      }
    }

    await getRecentUploads();
    await getCountry();
    if (isReload && listmembers.length > 0) {
      // if(selectedMembers.isNotEmpty) selectedMembers="";
      selectedMembers = listmembers.first['_id'];

      selectedMemberName = listmembers.first['member_first_name'];
      selectedMemberDob = listmembers.first['date_of_birth'];
      selectedMemberAge = listmembers.first['age'].toString();
    }
    setBusy(false);
  }

  Future updateUserStatus(String status) async {
    String userId = preferencesService.userId;
    await apiService.updateUserStatus(userId, status);
  }

  //download
  Future getFileCategory() async {
    setBusy(true);
    fileCategory = await apiService.getFileCategory();
    await getMembersList(false);
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

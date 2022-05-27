import 'dart:convert';

import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class DownloadsViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> fileCategory = [];
  List<dynamic> recentUploads = [];
  List<dynamic> listmembers = [];
  String selectedMembers = '';
  String selectedMemberName = '';
  String selectedMemberDob = '';
  String selectedMemberAge = '';
  List<dynamic> labtest = [];
  List<dynamic> vaccines = [];
  List<dynamic> membe = [];
  String countryCode = '602dde0764f3802c6453641b';
  Future init() async {
    preferencesService.initRefreshRecentDocumentOnDownload();
    preferencesService.onRefreshRecentDocumentOnDownload!.onChange((isRefresh) {
      if (isRefresh) {
        preferencesService.onRefreshRecentDocumentOnDownload!.value = false;
        getRecentUploads();
      }
    });
  }

  Future getMembersList(bool isReload) async {
    //print('default id is======'+preferencesService.dropdown_user_name.toString());
    if (isReload) {
      setBusy(true);
    }
    String userId = preferencesService.userId;
    //List members = await apiService.getUserMembersList(userId);
    List<dynamic> members = List.from(preferencesService.memebersListStream!.value!);
    if (members.length > 0) {
      listmembers = [];
      for (dynamic member in members) {
        if (member.length > 0) {
          listmembers.add(member);
          print(member[0].toString());
          final jsonList = listmembers.map((item) => jsonEncode(item)).toList();
          final uniqueJsonList = jsonList.toSet().toList();
          listmembers = uniqueJsonList.map((item) => jsonDecode(item)).toList();
        }
      }
    }
    //  preferencesService.onRefreshRecentDocumentOnDownload!.value = true;
    await getRecentUploads();
    await getFileCategory();
    //await getCovidVaccine_LabTest();
    if (isReload && listmembers.length > 0) {
      selectedMembers = listmembers.first['_id'];
      selectedMemberName = listmembers.first['member_first_name'];
      selectedMemberDob = listmembers.first['date_of_birth'];
      selectedMemberAge = listmembers.first['age'].toString();
    }
    setBusy(false);
  }

  Future getRecentUploads() async {
    setBusy(true);
    String selectedDropdownid = preferencesService.dropdown_user_id;
    recentUploads = await apiService.getRecentUploads(selectedDropdownid);
    setBusy(false);
  }

  Future getFileCategory() async {
    setBusy(true);
    fileCategory = await apiService.getFileCategory();
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

  Future getCovidVaccine_LabTest() async {
    setBusy(true);
    vaccines = await apiService.getCovidVaccines(countryCode);
    labtest = await apiService.getCovidLabTest(countryCode);

    // print('------------------lab'+labtest.toString());
    setBusy(false);
  }
}

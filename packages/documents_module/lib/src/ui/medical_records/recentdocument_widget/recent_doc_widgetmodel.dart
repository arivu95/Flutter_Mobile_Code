import 'dart:convert';

import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class RecentDocViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> recentUploads = [];
  List<dynamic> listmembers = [];
  List<dynamic> fileCategory = [];
  String currentCategoryId = '';

  Future init() async {
    preferencesService.initRefreshRecentDocumentFromTable();
    preferencesService.onRefreshRecentDocumentFromTable!.onChange((isRefresh) {
      if (isRefresh) {
        preferencesService.onRefreshRecentDocumentFromTable!.value = false;
        // Calling recent upload/download refresh
        preferencesService.onRefreshRecentDocumentOnDownload!.value = true;
        preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
        if (currentCategoryId.isNotEmpty) {

          getRecentUploads(currentCategoryId);
          getRecentUploads("common");

       
        }
      }
    });
  }
//temp hide vaccination +maternity recent documents
  Future getRecentUploads(String categoryId) async {
    currentCategoryId = categoryId;
   
    setBusy(true);
    String selectedDropdownid = preferencesService.dropdown_user_id;
    print('________________get reent '+selectedDropdownid);
     if(currentCategoryId=="common"){
      String selectedDropdownid = preferencesService.dropdown_user_id;
       recentUploads = await apiService.getRecentUploads(selectedDropdownid);
      
    }else{
    recentUploads = await apiService.getFilesByCategory(selectedDropdownid, categoryId);
    print('--------response recent upload=========>' + recentUploads.toString());
    }
    setBusy(false);
  }


  // Future getRecentCommonUploads() async {
  //   setBusy(true);
  //   print('--------GET RECENT DOCUMENTS ************* ------');
  //   String selected_dropdownid = preferencesService.dropdown_user_id;
  //   print('________________get reent ' + selected_dropdownid);
  //   recentUploads = await apiService.getRecentUploads(selected_dropdownid);
  //   print('--------response recent upload=========>' + recentUploads.toString());
  //    preferencesService.onRefreshRecentDocument!.value = true;
  //   setBusy(false);
  // }



  Future getMembersList() async {
    print('--------UPLOAD GET MEMBER LIST ------' + preferencesService.userId);
    String userId = preferencesService.userId;
    print('--------UPLOAD ------' + preferencesService.userId);
    List members = await apiService.getUserMembersList(userId);
    if (members.length > 0) {
      for (List member in members) {
        if (member.length > 0) {
          listmembers.add(member[0]);
          final jsonList = listmembers.map((item) => jsonEncode(item)).toList();
          final uniqueJsonList = jsonList.toSet().toList();
          listmembers = uniqueJsonList.map((item) => jsonDecode(item)).toList();
        }
      }
      print('-----memberlength us**********' + listmembers.toString());
      preferencesService.dropdown_user_id = listmembers[0]['_id'];
      // print('____________current id is____________'+preferencesService.dropdown_user_id);
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
    await getMembersList();
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
}

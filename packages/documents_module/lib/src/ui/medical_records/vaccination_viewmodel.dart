import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:path/path.dart' as path;

class VaccineViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic profileInfo = {};
  String img_url = '';
  String nxt_vaccine = '';
  String vacc_master_id = '';
  String maternity_id = '';
  dynamic userMaternityData = {};
  List<dynamic> userMaternity = [];
  List<dynamic> userVaccine = [];
  List<dynamic> getbabydetail = [];
  List<dynamic> fileList = [];
  List<dynamic> vaccination_list = [];
  List<dynamic> date_list = [];
  List<dynamic> vaccine_list = [];
  dynamic userVaccineData = {};
  dynamic userBirthData = {};
  String vaccine_id = '';
  String birth_id = '';
  String baby_dob = "";
  String next_vaccine = "";
  String due_date = "";
  String pregnancy_dt = "";
  String vac_due = "";
  String condition_mother = "";
  dynamic downloadMaternityData = {};
  bool isNewtable = false;
  String countryId = '602dde0764f3802c6453641b';

  get vaccineData => null;

  Future init() async {
    preferencesService.initRefreshRecentDocument();
    preferencesService.initRefreshActivityfeed();
    preferencesService.onRefreshRecentDocument!.onChange((isRefresh) {
      if (isRefresh) {
        preferencesService.onRefreshRecentDocument!.value = false;
        getUserVaccine();
      }
    });
  }

  Future getUserVaccine() async {
    setBusy(true);
    if (userVaccineData.isNotEmpty) {
      userVaccineData.clear();
      date_list.clear();
    }
    final response = await apiService.getUserVaccine(preferencesService.dropdown_user_id);
    if (response.length > 0) {
      userVaccineData = response.first;
      isNewtable = false;
      birth_id = userVaccineData['_id'];
      if (userVaccineData['vaccination'] != null) {
        userVaccine = userVaccineData['vaccination'];
        Jiffy dob = Jiffy(userVaccineData['next_vaccine_date']);
        vac_due = dob.format('dd/MM/yyyy').toString();
        vaccination_list = userVaccineData['vaccination'];

        for (var i = 0; i < vaccination_list.length; i++) {
          for (var j = 0; j < vaccination_list[i]['vaccine_name'].length; j++) {
            date_list.add(vaccination_list[i]['vaccine_name'][j]);
          }
        }
      }

      print(userVaccineData['next_vaccine_date'].toString());
      if (userVaccineData['next_vaccine_date'] != null) {
        next_vaccine = (userVaccineData['next_vaccine_date'].toString());
      } else {
        next_vaccine = "";
      }

      if (userVaccineData['date_of_birth'] != null) {
        Jiffy dob = Jiffy(userVaccineData['date_of_birth']);
        baby_dob = dob.format('dd/MM/yyyy').toString();
        preferencesService.dropdown_user_dob = baby_dob;
      } else {
        baby_dob = "";
      }
    } else {
      isNewtable = true;
      createVaccinationTableForUser();
    }
    await getUserMaternity();
    setBusy(false);
  }

  Future createVaccinationTableForUser() async {
    String memberId = preferencesService.dropdown_user_id;
    userVaccineData = await apiService.createVaccinationTableForUser(memberId, countryId);
    print(userVaccineData);
    getUserVaccine();
  }

  Future<bool> updateVaccinationRecord(Map<String, dynamic> postParams, String docId, bool isAttach) async {
    setBusy(true);
    String selectedDropdownid = preferencesService.dropdown_user_id;
    postParams['member_id'] = selectedDropdownid;
    postParams['member_Id'] = selectedDropdownid;
    postParams['country_Id'] = countryId;
    postParams['fileName'] = 'fileAttach';
    if (preferencesService.paths.isNotEmpty && isAttach) {
      postParams['attach_record'] = preferencesService.paths;
    }

    final response = await apiService.updateVaccinationInfo(docId, postParams, preferencesService.paths);
    print('true' + response.toString());
    preferencesService.onRefreshRecentDocument!.value = true;
    await getUserVaccine();
    setBusy(false);
    return true;
  }

 Future tableupdateVaccination(bool status, String dateStr, dynamic vaccineData, String documentId,String filterTitle1) async {
    setBusy(true);
    Map<String, dynamic> postParams = {};
    String selectedDropdownid = preferencesService.dropdown_user_id;
    vaccineData['status'] = status;
    if(filterTitle1.isNotEmpty){
      postParams['title1'] = filterTitle1;
    }
     postParams['title2'] = vaccineData['vaccine_name'];
    if (dateStr.isNotEmpty) {
      Jiffy date = Jiffy(dateStr, 'MM-dd-yyyy');
      String dt = date.format();
      vaccineData['date'] = dt;
      postParams['date'] = dateStr;
    }
    if (preferencesService.paths.length>0) {
      vaccineData['attach_record'] = preferencesService.paths;
    }
    if (status == true) {
      postParams['status'] = '1';
    } else {
      postParams['status'] = '0';
    }
    postParams['vaccinationMaster_Id'] = documentId;
    postParams['vaccine_Id'] = vaccineData['_id'];
    postParams['member_id'] = selectedDropdownid;
    postParams['country_Id'] = countryId;
    postParams[' birth_id'] = userVaccineData['_id'];
    postParams['height'] = vaccineData['height'];
    postParams['weight'] = vaccineData['weight'];
    postParams['temperature'] = vaccineData['temperature'];
    postParams['spo2'] = vaccineData['spo2'];
    postParams['blood_pressure'] = vaccineData['blood_pressure'];
    postParams['notes'] = vaccineData['notes'];
    postParams['date'] = vaccineData['date'];
    final response = await apiService.updateVaccinationInfo(userVaccineData['_id'], postParams, preferencesService.paths);
   await getUserVaccine();
    preferencesService.paths.clear();
    preferencesService.onRefreshRecentDocument!.value = true;
    preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
    preferencesService.onRefreshRecentDocumentOnDownload!.value = true;
   
    setBusy(false);
    print(response);
  }

  
  Future getUserMaternity() async {
    String memberId = preferencesService.dropdown_user_id;
    final response = await apiService.getUserMaternity(memberId);
    if (response.length > 0) {
      userMaternityData = response.first;
      maternity_id = userMaternityData['_id'];
      print(maternity_id.toString());
      if (userMaternityData['pregnancy_date_header'] != null) {
        Jiffy dob = Jiffy(userMaternityData['pregnancy_date_header']);
        pregnancy_dt = dob.format('dd/MM/yyyy').toString();
        print(pregnancy_dt.toString());
      }
      if (userMaternityData['expected_due_date'] != null) {
        due_date = (userMaternityData['expected_due_date'].toString());
      }

      if (userMaternityData['mothers_condition'] != null) {
        condition_mother = userMaternityData['mothers_condition'];
      }
    }
  }

  Future getheaderData(String dt, String due, String condTxt) async {
    Map<String, dynamic> postParams = {};
    if (dt != "") {
      postParams['pregnancy_date_header'] = dt;

      pregnancy_dt = postParams['pregnancy_date_header'].toString();
    }
    if (due != "" && due != null) {
      postParams['expected_due_date'] = due;

      due_date = postParams['expected_due_date'].toString();
    }
    String memberId = preferencesService.dropdown_user_id;
    if (condTxt != "") postParams['mothers_condition'] = condTxt;
    final response = await apiService.getheaderRecords(maternity_id, postParams);

    // //update pregnancy date
    // if (response['pregnancy_date_header'] != null) {
    //   Jiffy pgcy = Jiffy(response['pregnancy_date_header']);
    //   pregnancy_dt = pgcy.format('dd/MM/yyyy').toString();
    // }
    // //update due date
    // if (response['expected_due_date'] != null) {
    //   Jiffy due = Jiffy(response['expected_due_date']);
    //   due_date = due.format('dd/MM/yyyy').toString();
    // }

    //return;
    //print(response);
  }

  Future updatenextvaccinationDate(String nxtVacDate) async {
    print('uu================' + nxtVacDate);
    Map<String, dynamic> postParams = {};
    if (nxtVacDate != "") {
      postParams['next_vaccine_date'] = nxtVacDate;
      next_vaccine = postParams['next_vaccine_date'].toString();
    }

    String memberId = preferencesService.dropdown_user_id;
    final response = await apiService.addBirthDetails(postParams, birth_id);
    await getUserVaccine();
    print(response);
  }

//download maternity
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory(await AndroidPathProvider.downloadsPath);
    }
    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }

  Future<Directory> _getTempDirectory() async {
    if (Platform.isAndroid) {
      return Directory(await AndroidPathProvider.documentsPath);
    }
    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }

  Future<bool> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else {
        print('++++++++++++++not allowd+++++' + status.isDenied.toString());
        return false;
      }
    }
    if (status.isRestricted) {
      return false;
    }
    return true;
  }

//getDownload and share Maternity

  Future<void> download(String category) async {
    String memberId = preferencesService.dropdown_user_id;
    String countryId = preferencesService.user_country_id;
    final response = await apiService.getDownloadMaternity(memberId, category, countryId);
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await requestPermissions();
    if (isPermissionStatusGranted) {
      // await Future.forEach(downloadList, (String url) async {
      downloadMaternityData = response.first;
      String _gturl = downloadMaternityData['azureBlobStorageLink'];
      dynamic url = '${ApiService.fileStorageEndPoint}$_gturl';
      String filename = url.split('/').last;
      final savePath = path.join(dir.path, filename);
      await apiService.fileDownload(savePath, url);
    } else {
      return null;
    }
  }

  Future<List<String>> shareDocs(String category) async {
    String memberId = preferencesService.dropdown_user_id;
    String countryId = preferencesService.user_country_id;
    final response = await apiService.getDownloadMaternity(memberId, category, countryId);
    List<String> localPath = [];
    final dir = await _getTempDirectory();
    final isPermissionStatusGranted = await requestPermissions();
    if (isPermissionStatusGranted) {
      downloadMaternityData = response.first;
      String _gturl = downloadMaternityData['azureBlobStorageLink'];
      dynamic url = '${ApiService.fileStorageEndPoint}$_gturl';
      String filename = url.split('/').last;
      final savePath = path.join(dir.path, filename);
      localPath.add(savePath);
      await apiService.fileDownload(savePath, url);
    }
    return localPath;
  }

  Future birthdetails(dynamic userVaccineData, String vacId) async {
    Map<String, dynamic> postParams1 = {};
    String selectedDropdownid = preferencesService.dropdown_user_id;
    postParams1['member_Id'] = selectedDropdownid;
    postParams1['country_Id'] = countryId;
    postParams1['next_vaccine_date'] = next_vaccine;
    //other fields(edit vacc data fields)
    // can able to give postParams=maternityData;
    // but it give date format error.as of now seperatly, give

    postParams1['gestational_Age'] = userVaccineData['gestational_Age'];
    postParams1['mode_of_delivery'] = userVaccineData['mode_of_delivery'];
    postParams1['birth_weight'] = userVaccineData['birth_weight'];
    postParams1['length_at_birth'] = userVaccineData['length_at_birth'];
    postParams1['head_circumference'] = userVaccineData['head_circumference'];
    postParams1['TSH'] = userVaccineData['TSH'];
    postParams1['G6PD'] = userVaccineData['G6PD'];
    postParams1['baby_blood_group'] = userVaccineData['baby_blood_group'];
    postParams1['name'] = userVaccineData['name'];
    postParams1['age'] = userVaccineData['age'];
    postParams1['medical_record_no'] = userVaccineData['medical_record_no'];
    postParams1['date_of_birth'] = userVaccineData['date_of_birth'];
    postParams1['apgar_score'] = userVaccineData['apgar_score'];
    postParams1['mother_Blood_group'] = userVaccineData['mother_Blood_group'];
    postParams1['next_vaccine_date'] = userVaccineData['next_vaccine_date'];
    final response = await apiService.addBirthDetails(postParams1, vacId);
    await getUserVaccine();
    print(response);
  }
}

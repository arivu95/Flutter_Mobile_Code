import 'dart:io';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:swarapp/app/pref_util.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';

class ProfileViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic profile_Info = {};
  dynamic profile_view = {};
  dynamic language_known = {};
  dynamic doctorDetails = {};
  List<dynamic> educational_list = [];
  List<dynamic> medicalRegistration_list = [];
  List<dynamic> experience_list = [];
  List<dynamic> clinic_list = [];
  List<dynamic> achievement_list = [];
  String workExperience = '';
  String img_url = '';
  String stage_level = '';
  dynamic get_stage = {};
  Future getUserProfile(bool isUpdateprofile) async {
    setBusy(true);
    String userId = preferencesService.userId;
    profile_Info = await apiService.getProfile(userId);
    if (profile_Info['azureBlobStorageLink'] != null) {
      img_url = '${ApiService.fileStorageEndPoint}${profile_Info['azureBlobStorageLink']}';
      preferencesService.userInfo = profile_Info;
      preferencesService.profileUrl.value = img_url;
      //profile_view = profile_Info['records'];
      print(preferencesService.getUserProfileImageUrl());
    }

    if (profile_Info['language_known'] != null) {
      language_known = profile_Info['language_known'];
    }
    // get_stage = await apiService.getStageProfile();
    // stage_level = get_stage['stage'];
    setBusy(false);
  }

  Future addStatus(String status) async {
    // setBusy(true);
    Map<String, dynamic> postParams = {};
    String userId = preferencesService.userId;
    String name = preferencesService.userInfo['name'];
    if (status.isNotEmpty) {
      postParams['profilestatus'] = status;
    }
    postParams['user_Id'] = userId;
    postParams['name'] = name;
    Map<String, dynamic> newComment = {'profilestatus': status, 'user_Id': userId, 'name': name};
    final response = await apiService.addstatus(postParams);
    preferencesService.onRefreshRecentDocument!.value = true;
    await getUserProfile(false);
    setBusy(false);
  }

  Future updatePreferdNumber(Map<String, dynamic> userInfo, String profileImagePath) async {
    setBusy(true);
    //  String userId = preferencesService.userId;
    String userId = preferencesService.userId;
    final response = await apiService.updateUserProfile(userId, userInfo, profileImagePath.isNotEmpty ? profileImagePath : '', '');
    //emergency_doctor_number
    //emergency_clinic_number
    await getUserProfile(false);
    setBusy(false);
  }

  Future getDoctorDetails() async {
    setBusy(true);
    //String userId = "61e8e86ca16b070033353428";
    String userId = preferencesService.userId;
    //List doctor = await apiService.getDoctorDetails('6203508c4e8f260033cea46f');
    List doctor = await apiService.getDoctorDetails(userId);
    doctorDetails = doctor[0];
    doctorDetails = doctor.isNotEmpty ? doctor[0] : '';

    //Education List
    if (doctorDetails['educational_information'] != null) {
      if (doctorDetails['educational_information'].length > 0) {
        educational_list = doctorDetails['educational_information'];
      } else {
        educational_list = [];
      }
    }

    //Medical Registration List
    if (doctorDetails['medical_registaration'] != null) {
      if (doctorDetails['medical_registaration'].length > 0) {
        medicalRegistration_list = doctorDetails['medical_registaration'];
      } else {
        medicalRegistration_list = [];
      }
    }

    //Experience List
    if (doctorDetails['experience'] != null) {
      if (doctorDetails['experience'].length > 0) {
        experience_list = doctorDetails['experience'];
        int temp = 0;
        for (int i = 0; i < experience_list.length; i++) {
          if (experience_list[i]['work_experience'] != null && experience_list[i]['work_experience'] != "") {
            int workYears = int.parse(experience_list[i]['work_experience']);
            temp = temp + workYears;
          }
        }

        if (temp < 12) {
          workExperience = '$temp  Month Experience';
        } else {
          double experienceCalc = temp / 12;
          String workExperience = experienceCalc.toStringAsFixed(2).toString();
          workExperience = '$workExperience Year Experience';
        }
      } else {
        experience_list = [];
        workExperience = '';
      }
    }

    //Experience List
    if (doctorDetails['achievement_information'] != null) {
      if (doctorDetails['achievement_information'].length > 0) {
        achievement_list = doctorDetails['achievement_information'];
      } else {
        achievement_list = [];
      }
    }

    //Clinic List
    if (doctorDetails['clinic_details'] != null) {
      if (doctorDetails['clinic_details'].length > 0) {
        clinic_list = doctorDetails['clinic_details'];
        clinic_list.removeWhere((item) => item['active_flag'] == false);
      } else {
        clinic_list = [];
      }
    }

    setBusy(false);
  }

  Future<void> download(String docId) async {
    final response = await apiService.downloadDoctorFile(docId);
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await requestPermissions();

    if (isPermissionStatusGranted) {
      String _gturl = response['downloadfile_pdf'];
      dynamic url = '${ApiService.fileStorageEndPoint}$_gturl';
      String filename = url.split('/').last;
      final savePath = path.join(dir.path, filename);
      await apiService.fileDownload(savePath, url);
    } else {
      return null;
    }
  }

  //download
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory(await AndroidPathProvider.downloadsPath);
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
        return false;
      }
    }
    if (status.isRestricted) {
      return false;
    }
    return true;
  }

  Future updateProfile(String profileurl, dynamic doctorInfo) async {
    setBusy(true);
    String userId = preferencesService.userId;
    Map<String, dynamic> postParams = doctorInfo;

    final response = await apiService.updateUserProfile(userId, postParams, profileurl, '');
    if (response != null || response != "") {
      img_url = '${ApiService.fileStorageEndPoint}$profileurl';

      preferencesService.profileUrl.value = img_url;
    }

    await getUserProfile(true);
    setBusy(false);
  }
}

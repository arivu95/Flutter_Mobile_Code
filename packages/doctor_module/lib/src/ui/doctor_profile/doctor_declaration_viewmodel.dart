import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DoctorDeclarationViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic doctorDetails = {};

  Future getDoctorDetails() async {
    setBusy(true);
    String userId = preferencesService.userId;
    List doctor = await apiService.getDoctorDetails(userId);
    doctorDetails = doctor[0];
    setBusy(false);
  }

  Future<bool> getImagetoFile(byteData) async {
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await requestPermissions();
    String userId = preferencesService.userId;
    if (isPermissionStatusGranted) {
      bool isDirExist = await Directory(dir.path).exists();
      if (!isDirExist) Directory(dir.path).create();
      String tempPath = '${dir.path}/esign.png';
      File file = File('$tempPath');
      await file.writeAsBytes(byteData);

      await apiService.addEsign(doctorDetails['_id'], tempPath);
      await locator<ApiService>().getStageProfile(userId);
      await apiService.getDoctorDetails(userId);
      return true;
    }
    return false;
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory(await AndroidPathProvider.downloadsPath);
    }
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
}

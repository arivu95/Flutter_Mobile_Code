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

class DocCategoryViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> fileList = [];
  List<String> fileDates = [];
  List<String> sourceFileDates = [];
  Map<String, List> fileSections = {};
 dynamic category=[];
  String filteredDateStr = '';
  String sortMode = 'date';
  List imageUrls = [];
  List<dynamic> fileCategory = [];

  Future getFileCategory() async {
    fileCategory = await apiService.getFileCategory();
    print(fileCategory);
  }

  String getCategoryId(int index) {
     
    if (fileCategory.length > index) {
     category = fileCategory[index];
      return category['_id'];
    }
    return '';
  }

  Future getFilesByCategory(String catId,int index) async {

    setBusy(true);
    await getFileCategory();
    catId= getCategoryId(index);
    //String userId = preferencesService.userId;
    String userId = preferencesService.dropdown_user_id;
    fileList = await apiService.getFilesByCategory(userId, catId);
    print(fileList);

    if (fileList.length > 0) {
      sourceFileDates = fileList
          .map((e) {
            Jiffy j = Jiffy(e['createdAt']);
            String dateStr = j.format('dd MMM yyyy');
            if (fileSections[dateStr] == null) {
              fileSections[dateStr] = [e];
            } else {
              fileSections[dateStr]!.add(e);
            }
            return j.format('dd MMM yyyy');
          })
          .toSet()
          .toList();

      fileDates = sourceFileDates.toList();

      print(fileDates);
    } else {
      fileDates = [];
    }
    setBusy(false);
  }

  Future<List<String>> downloadFilesList(List<String> docIds) async {
    List<String> downloadList = [];
    for (var doc in fileList) {
      String docid = doc['_id'];
      if (docIds.contains(docid)) {
        print(doc['fileName']);
        List imageUrls = doc['azureBlobStorageLink'];
        if (imageUrls.length > 0) {
          List<String> dlist = imageUrls.map((e) {
            return '${ApiService.fileStorageEndPoint}$e';
          }).toList();
          downloadList.addAll(dlist);
        }
      }
    }
    return downloadList;
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

  Future<List<String>> downloadDocs(List<String> docIds) async {
    print(docIds);
    // Share.share('check out my website https://example.com', subject: 'Look what I made!');
    List<String> downloadList = await downloadFilesList(docIds);
    List<String> localPath = [];
    final dir = await _getTempDirectory();
    final isPermissionStatusGranted = await requestPermissions();
    if (isPermissionStatusGranted) {
      int count = 0;
      await Future.forEach(downloadList, (String url) async {
        String filename = url.split('/').last;
        final savePath = path.join(dir.path, filename);
        localPath.add(savePath);
        await apiService.fileDownload(savePath, url);
      });
    }
    // print(localPath);
    return localPath;
  }
}

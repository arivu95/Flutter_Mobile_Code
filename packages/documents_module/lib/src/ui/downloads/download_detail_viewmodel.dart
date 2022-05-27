import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:get/state_manager.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/api_utils.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:path/path.dart' as path;
import 'package:connectycube_sdk/connectycube_sdk.dart';

class DownloadDetailViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> fileList = [];
  List<String> fileDates = [];
  List dicomFiles = [];
  List<String> sourceFileDates = [];
  Map<String, List> fileSections = {};
  RxString downloadMessage = 'Downloading'.obs;
  String filteredDateStr = '';
  String sortMode = 'date';
  List imageUrls = [];
  List<int> ccIds = [];
  List<CubeUser> sourceUsers = [];
  List<CubeUser> searchUsers = [];
  List<dynamic> labtest = [];
  List<dynamic> vaccines = [];
  String countryCode = '602dde0764f3802c6453641b';

  Future init() async {
    preferencesService.initDownloadDocuments();

    // preferencesService.onRefreshDownloadDocumentFromTable!.value = false;
    //  getRecentUploads();
    preferencesService.onRefreshRecentDocumentFromTable!.onChange((val) {
      if (val) {
        preferencesService.onRefreshDownloadDocumentFromTable!.value = false;
        getFilesByCategory("6093ceff7a735c0acfb77365");
      }
    });
  }

  Future getFilesByCategory(String catId) async {
    setBusy(true);
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
      refreshView();
      filterAllImages();
      getRecentMembers();
      //getCovidVaccine_LabTest();
      preferencesService.onRefreshRecentDocumentOnDownload!.value = true;
      print(fileDates);
    } else {
      fileDates = [];
    }
    setBusy(false);
  }

  Future getDicomFilesByCategory(String catId, String filename) async {
    setBusy(true);
    String userId = preferencesService.dropdown_user_id;
    List<dynamic> dataS = await apiService.getDicomFilesByCategory(userId, catId, filename);

    if (dataS.length > 0) {
      dicomFiles = dataS[0]['extracted_files'];
    }
    //   sourceFileDates = fileList
    //       .map((e) {
    //         Jiffy j = Jiffy(e['createdAt']);
    //         String dateStr = j.format('dd MMM yyyy');
    //         if (fileSections[dateStr] == null) {
    //           fileSections[dateStr] = [e];
    //         } else {
    //           fileSections[dateStr]!.add(e);
    //         }
    //         return j.format('dd MMM yyyy');
    //       })
    //       .toSet()
    //       .toList();

    //   fileDates = sourceFileDates.toList();
    //   refreshView();
    //   filterAllImages();
    //   getRecentMembers();
    //   //getCovidVaccine_LabTest();
    //   preferencesService.onRefreshRecentDocumentOnDownload!.value = true;
    //   print(fileDates);
    // } else {
    //   fileDates = [];
    // }
    setBusy(false);
  }

  Future getFilteredFilesByCategory(String catId, String cattitle, dynamic data) async {
    setBusy(true);
    String userId = preferencesService.dropdown_user_id;
    List<dynamic> temp = await apiService.getFilesByCategory(userId, catId);
    if (cattitle == "Vaccination") {
      fileList = temp.where((e) {
        return e['fileCategory'].toString().toLowerCase().contains("Vaccination".toLowerCase()) &&
            e['filter_title1'].toString().toLowerCase().contains(data['title1'].toLowerCase()) &&
            e['filter_title2'].toString().toLowerCase().contains(data['title2'].toLowerCase());
      }).toList();
    }

    if (cattitle == "Maternity") {
      fileList = temp.where((e) {
        return e['fileCategory'].toString().toLowerCase().contains("Maternity".toLowerCase()) && e['filter_title1'].toString().toLowerCase().contains(data['title1'].toLowerCase());
      }).toList();
    }

    if (cattitle == "Covid Vaccine") {
      fileList = temp.where((e) {
        return e['fileCategory'].toString().toLowerCase().contains("Covid Vaccine".toLowerCase()) &&
            e['filter_title1'].toString().toLowerCase().contains(data['title1'].toLowerCase()) &&
            e['filter_title2'].toString().toLowerCase().contains(data['title2'].toLowerCase());
      }).toList();
    }

    if (cattitle == "Covid Test") {
      fileList = temp.where((e) {
        return e['fileCategory'].toString().toLowerCase().contains("Covid Test".toLowerCase()) && e['filter_title1'].toString().toLowerCase().contains(data['title1'].toLowerCase());
      }).toList();
    }

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
      refreshView();
      filterAllImages();
      getRecentMembers();
      //getCovidVaccine_LabTest();
      preferencesService.onRefreshRecentDocumentOnDownload!.value = true;
      print(fileDates);
    } else {
      fileDates = [];
      //getCovidVaccine_LabTest();
    }
    setBusy(false);
  }

  // filter All images for slide show
  void filterAllImages() {
    imageUrls.clear();
    for (var file in fileList) {
      if (file['azureBlobStorageLink'] != null) {
        List images = file['azureBlobStorageLink'];
        List filteredList = images.where((element) {
          String value = element.toString();
          return value.contains('.jpg') || value.contains('.png') || value.contains('.jpeg');
        }).toList();

        filteredList = filteredList.map((e) => '${ApiService.fileStorageEndPoint}${e.toString()}').toList();

        imageUrls.addAll(filteredList);
      }
    }
    //img_url = '${ApiService.fileStorageEndPoint}${imageUrls.first.toString()}';
    print(imageUrls);
  }

  //
  void refreshView() {
    if (sortMode == 'name') {
      filteredDateStr = '';
      if (fileList.length > 0) {
        fileDates = ['Sort by Name'];
        fileSections['Sort by Name'] = fileList.toList();
        fileList.sort((a, b) {
          return a['fileName'].toString().toLowerCase().compareTo(b['fileName'].toString().toLowerCase());
        });
      }
    } else {
      if (filteredDateStr.isEmpty) {
        fileDates = sourceFileDates.toList();
      } else {
        if (sourceFileDates.contains(filteredDateStr)) {
          fileDates = [filteredDateStr];
        } else {
          fileDates = [];
        }
      }
    }
    updateOnTextSearch('');

    setBusy(false);
  }

  void updateOnTextSearch(String search) {
    fileSections.clear();
    if (sortMode == 'name') {
      fileSections['Sort by Name'] = fileList.where((e) {
        return e['fileName'].toString().contains(search);
      }).toList();
    } else {
      fileList.map((e) {
        if (e['fileName'].toString().toLowerCase().contains(search.toLowerCase())) {
          Jiffy j = Jiffy(e['createdAt']);
          String dateStr = j.format('dd MMM yyyy');
          if (fileSections[dateStr] == null) {
            fileSections[dateStr] = [e];
          } else {
            fileSections[dateStr]!.add(e);
          }
          return j.format('dd MMM yyyy');
        }
      }).toList();
    }
    setBusy(false);
  }

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
        return false;
      }
    }
    if (status.isRestricted) {
      return false;
    }
    return true;
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

  Future<List<String>> shareDocs(List<String> docIds) async {
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
    //Share.shareFiles(localPath);
    return localPath;
  }

//for delete files
  Future<void> deleteDocs(List<String> docIds) async {
    await Future.forEach(docIds, (String docid) async {
      await apiService.fileDelete(docid);
      preferencesService.onRefreshRecentDocumentOnDownload!.value = true;
      preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
    });
  }

  //rename files
  Future<void> renameFile(String docIds, String filename) async {
    setBusy(true);
    await apiService.fileRename(docIds, filename);
    setBusy(false);
  }

  Future<void> download(List<String> docIds) async {
    print(docIds);
    List<String> downloadList = await downloadFilesList(docIds);
    print(downloadList);
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await requestPermissions();
    if (isPermissionStatusGranted) {
      await Future.forEach(downloadList, (String url) async {
        String filename = url.split('/').last;
        final savePath = path.join(dir.path, filename);
        await apiService.fileDownload(savePath, url);
      });

      await Future.forEach(docIds, (String id) async {
        await apiService.updateDownloadDocStatus(id);
      });
    } else {
      return null;
    }
  }

  Future getRecentMembers() async {
    setBusy(true);
    String userId = preferencesService.userId;
    final members = await apiService.getRecentMembers(userId);
    final recentMembers = members.expand((i) => i).toList();
    // memberIds = recentMembers.map((e) {
    //   return 'custom_' + e['user_Id'].toString();
    // }).toList();
    // print(memberIds);
    ccIds.clear();
    for (var member in recentMembers) {
      if (member['connectycube_id'] != null) {
        ccIds.add(int.parse(member['connectycube_id'].toString()));
      }
    }
    print(ccIds.toString());
    if (ccIds.length == 0) {
      setBusy(false);
    }
    //
  }

//getuserdList

  Future getUserList(String search) async {
    Map<int, CubeUser> users = await getUsersByIds(ccIds.toSet());
    sourceUsers.clear();
    for (var user in users.values) {
      sourceUsers.add(user);
    }

    searchUsers = sourceUsers.toList();
    setBusy(false);
  }

//get covid, lab test type

  Future getCovidVaccine_LabTest() async {
    setBusy(true);
    labtest = await apiService.getCovidLabTest(countryCode);
    vaccines = await apiService.getCovidVaccines(countryCode);
    print('------------------lab' + labtest.toString());
    setBusy(false);
  }

  // Future getCovidVaccines() async {
  //   setBusy(true);
  //   vaccines = await apiService.getCovidVaccines(countryCode);
  //   setBusy(false);
  // }

//internal share
  Future<List<String>> downloadgetFilesList(List<String> docIds, List<dynamic> data) async {
    List<String> downloadList = [];
    for (var doc in data) {
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

//for internal sharing

  Future<List<String>> downloadDocs(List<String> docIds, dynamic data) async {
    List<String> downloadList = [];
    // Share.share('check out my website https://example.com', subject: 'Look what I made!');
    //Future.forEach(data, (dynamic file) async {
    // for (var doc in data) {
    downloadList = await downloadgetFilesList(docIds, data);
    //  }
    //});
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
      Future.forEach(docIds, (String id) async {
        await apiService.updateDownloadDocStatus(id);
      });
    }
    // print(localPath);
    return localPath;
  }
}

import 'dart:io';

import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:path/path.dart' as path;

class ActivityFeedWidgetModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> recentMembers = [];
  List<dynamic> recentFriends = [];
  List<dynamic> listmembers = [];
  List<dynamic> fileList = [];
  List<String> fileDates = [];

  List outputList = [];
  String usr_img = '';
  String usr_name = '';
  dynamic tot_count = '';
  dynamic tot_likes = '';
  dynamic tot_care = '';
  dynamic tot_donate = '';
  dynamic check = '';
  dynamic invite_exits = '';
  dynamic self_like = '';
  String bgmsg_txt = '';
  Future init() async {
    preferencesService.initRefreshActivityfeed();
    preferencesService.call_feeds();

    preferencesService.onRefreshActivityfeed!.onChange((val) async {
      if (val != null) {
        preferencesService.onRefreshRecentDocument!.value = false;
        getuserfeedList(false);
      }
    });
    //  checkMsg_Bg();
  }

  Future getuserfeedList(bool isReload) async {
    if (isReload) {
      setBusy(true);
    }

    String userId = preferencesService.userId;
    dynamic userFeedObject = await apiService.getUserFeedsList(userId);

    if (userFeedObject['feedData'] != null) {
      List members = userFeedObject['feedData'];
      List userData = userFeedObject['userData'];

      List products = [];
      if (userData.length > 0) {
        for (final gtlst in userData) {
          if (gtlst.length > 0) {
            var productMap = {
              'get_id': gtlst['_id'],
              'get_azure_link': gtlst['azureBlobStorageLink'],
              'get_name': gtlst['name'],
            };
            products.add(productMap);
          }
        }
        print(products.toString());
      }
      listmembers.clear();
      if (members.length > 0) {
        for (var i = 0; i < members.length; i++) {
          tot_count = '';
          tot_likes = '';
          tot_care = '';
          tot_donate = '';
          if (products.length > 0) {
            outputList = products.where((o) => o['get_id'] == members[i]['user_Id']).toList();
            if (outputList.length != 0) {
              List<dynamic>? getUserLike = members[i]['likes'].toList();
              List<dynamic>? getUserCare = members[i]['cares'].toList();
              List<dynamic>? getUserDonate = members[i]['donates'].toList();
              usr_img = outputList[0]['get_azure_link'] != null ? outputList[0]['get_azure_link'].toString() : "";
              usr_name = outputList[0]['get_name'].toString();
              tot_count = members[i]['comments'].length.toString();
              tot_likes = members[i]['likes'].length.toString();
              tot_care = members[i]['cares'].length.toString();
              tot_donate = members[i]['donates'].length.toString();
              members[i]['profile_img'] = usr_img;
              members[i]['profile_name'] = usr_name;
              members[i]['count'] = tot_count;
              members[i]['likes_count'] = tot_likes;
              members[i]['cares_count'] = tot_care;
              members[i]['donates_count'] = tot_donate;

              if (members[i]['likes_count'].length > 0) {
                for (var getLike in getUserLike!) {
                  if (getLike['likedBy'] == preferencesService.userId.toString()) {
                    members[i]['likestate'] = "LikedUser";
                    break;
                  }
                }
              } else {
                members[i]['likestate'] = '';
              }
              if (members[i]['cares_count'].length > 0) {
                for (var getCare in getUserCare!) {
                  if (getCare['caredBy'] == preferencesService.userId.toString()) {
                    members[i]['carestate'] = "CaredUser";
                    break;
                  }
                }
              } else {
                members[i]['carestate'] = '';
              }
              if (members[i]['donates_count'].length > 0) {
                for (var getDonate in getUserDonate!) {
                  if (getDonate['donatedBy'] == preferencesService.userId.toString()) {
                    members[i]['donatestate'] = "DonatedUser";
                    break;
                  }
                }
              } else {
                members[i]['donatestate'] = '';
              }
              listmembers.add(members[i]);
            } else {
              listmembers.add(members[i]);
            }
          } else {
            if (members[i]['feeds_category'] == "invite") {
              listmembers.add(members[i]);
            }
            print(listmembers.toString());
          }
        }
      }
    }
    //await getRecentFriends();
    setBusy(false);
  }

  Future checkInviteExist(String inviterId) async {
    setBusy(true);
    String userId = preferencesService.userId;
    List userData = await apiService.getUsersFeedData(userId);
    userData.forEach((produit) {
      if (produit['_id'].contains(inviterId)) {
        invite_exits = "exist";
      } else {
        invite_exits = " ";
      }
      // _searchProduct.add(produit);
    });
    setBusy(false);
    return invite_exits;
  }

  Future acceptinvite(String feedId, String status) async {
    setBusy(true);
    String userId = preferencesService.userId;
    String refId = preferencesService.RefId;
    var response = await apiService.acceptinvite(userId, refId, feedId, status);
    setBusy(false);
    return response;
  }

  Future declineinvite(String feedId, String status) async {
    setBusy(true);
    String userId = preferencesService.userId;
    String refId = preferencesService.RefId;
    await apiService.acceptinvite(userId, refId, feedId, status);
    setBusy(false);
  }

  Future addStatus(String status, String path, String thumbPath) async {
    setBusy(true);
    Map<String, dynamic> postParams = {};
    String userId = preferencesService.userId;
    var now = DateTime.now();
    //var now=Jiffy().format("MMMM do yyyy, h:mm:ss a");
    String name = preferencesService.userInfo['name'];
    if (status.isNotEmpty) {
      postParams['profilestatus'] = status;
    }
    postParams['user_Id'] = userId;
    postParams['name'] = name;
    Map<String, dynamic> newComment = {'profilestatus': status, 'user_Id': userId, 'profile_name': name, 'createdAt': now};
    if (path.isNotEmpty) {
      postParams['profilestatus'] = status.isNotEmpty ? status.toString() : " ";

      postParams['path'] = path;
    }
    if (thumbPath.isNotEmpty) {
      postParams['thumbnail'] = thumbPath;
    }
    listmembers.add(newComment);
    final response = await apiService.addstatus(postParams);
    getuserfeedList(true);
    // preferencesService.onRefreshRecentDocument!.value = true;
    setBusy(false);
  }

  Future setlike(String docid, bool islike) async {
    setBusy(true);
    String userId = preferencesService.userId;
    if (islike) {
      final response = await apiService.addlikes(docid, userId);
    } else {
      final response = await apiService.dislike(docid, userId);
    }
    getuserfeedList(true);
    setBusy(false);
  }

  Future setcare(String docid, bool iscare) async {
    setBusy(true);
    String userId = preferencesService.userId;
    if (iscare) {
      final response = await apiService.addcare(docid, userId);
    } else {
      final response = await apiService.removecare(docid, userId);
    }
    getuserfeedList(true);
    setBusy(false);
  }

  // Donate //
  Future setdonate(String docid, bool isdonate) async {
    setBusy(true);
    String userId = preferencesService.userId;
    if (isdonate) {
      final response = await apiService.adddonate(docid, userId);
    } else {
      final response = await apiService.removedonate(docid, userId);
    }
    getuserfeedList(true);
    //  await getuserfeedList(true);
    setBusy(false);
  }

  Future getRecentFriends() async {
    // setBusy(true);
    String userId = preferencesService.userId;
    List friends = await apiService.getRecentFriends(userId, "60dae3e440f5032614a8d24b");
    recentFriends.clear();
    if (friends.length > 0) {
      recentFriends = friends.expand((i) => i).toList();
      // for (List friend in friends) {
      //   if (friend.length > 0) {
      //     recentFriends.add(friend[0]);
      //   }
      // }
    }
    //memSections = recentFriends.toList();
    //recentFriends.add({});
    setBusy(false);
  }

  Future<Directory> _getTempDirectory() async {
    if (Platform.isAndroid) {
      return Directory(await AndroidPathProvider.documentsPath);
    }
    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }

  // Future<List<String>> downloadFilesList(String source_url) async {
  //   List<String> downloadList = [];

  //       if (imageUrls.length > 0) {
  //       String dlist ='${ApiService.fileStorageEndPoint}$e';

  //        // downloadList.addAll(dlist);
  //       }

  //   return downloadList;
  // }

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

  Future<List<String>> shareDocs(String sourceUrl) async {
    // print(docIds);
    // Share.share('check out my website https://example.com', subject: 'Look what I made!');
    //List<String> downloadList = await downloadFilesList(sourceUrl);
    // String to_download = '${ApiService.fileStorageEndPoint}$sourceUrl';
    String toDownload = sourceUrl;
    List<String> localPath = [];
    final dir = await _getTempDirectory();
    final isPermissionStatusGranted = await requestPermissions();
    if (isPermissionStatusGranted) {
      int count = 0;
      // await Future.forEach(downloadList, (String url) async {
      String filename = toDownload.split('/').last;
      final savePath = path.join(dir.path, filename);
      localPath.add(savePath);
      await apiService.fileDownload(savePath, toDownload);
      //  });
    }
    //Share.shareFiles(localPath);
    return localPath;
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class Membersmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> recentMembers = [];
  List<dynamic> recentFamily = [];
  List<dynamic> recentDoctors = [];
  List<dynamic> recentFriends = [];
  List<dynamic> memberSections = [];
  List<dynamic> memSections = [];
  String selectedMembers = '';
  String selectedMemberName = '';
  List<dynamic> listmembers = [];
  List<dynamic> listusers = [];
  // List<dynamic> outputList=[];
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
    preferencesService.initRefreshRecentDocument();

    preferencesService.onRefreshRecentDocument!.onChange((isRefresh) {
      if (isRefresh) {
        preferencesService.onRefreshRecentDocument!.value = false;
        // getuserfeedList(false);
      }
    });
    await apiService.getNotifications(preferencesService.userId, '6128a673b71d012678336f4d');
  }

  Future getRecentMembers() async {
    setBusy(true);
    String userId = preferencesService.userId;
    List members = await apiService.getRecentMembers(userId);
    recentMembers.clear();
    if (members.length > 0) {
      for (List member in members) {
        if (member.length > 0) {
          recentMembers.add(member[0]);
        }
      }
    }
    memberSections = recentMembers.toList();
    recentMembers.add({});
    setBusy(false);
  }

  Future getRecentFamily() async {
    setBusy(true);

    String userId = preferencesService.userId;
    List family = await apiService.getRecentFamily(userId, "60c381bc36cf932d305a572b");
    recentFamily.clear();
    if (family.length > 0) {
      recentFamily = family.expand((i) => i).toList();
      memberSections = recentFamily.toList();
      // for (List famly in family) {
      //   if (famly.length > 0) {
      //     recentFamily.add(famly[0]);
      //   }
      // }
    }
    setBusy(false);
    print(recentFamily.toString());
    //memberSections = recentFamily.toList();
    //recentFamily.add({});

    await getRecentFriends();
    await apiService.getUserMembersList(userId);
    // await getuserfeedList(false);
    // setBusy(false);
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

  Future getRecentDoctors() async {
    // setBusy(true);
    String doctorId = preferencesService.userId;

    String userId = preferencesService.userId;
    List doctors = await apiService.acceptedList(doctorId);
    recentDoctors.clear();
    if (doctors.length > 0) {
      recentDoctors = doctors.expand((i) => i).toList();
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

  Future checkMsg_Bg() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    bool fileExists = await File('${directory.path}/swar_bg_message.txt').exists();
    if (fileExists) {
      final File file = File('${directory.path}/swar_bg_message.txt');
      bgmsg_txt = await file.readAsString();
    } else {
      bgmsg_txt = "";
    }
  }

  Future unsestMsg_Bg() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    bool fileExists = await File('${directory.path}/swar_bg_message.txt').exists();
    if (fileExists) {
      final File file = File('${directory.path}/swar_bg_message.txt');
      await file.writeAsString(" ");
    }

    bgmsg_txt = "";
  }

  Future unFriendMember(String memberId) async {
    setBusy(true);
    String userId = preferencesService.userId;
    final unfriendStatus = await apiService.unFriendUser(userId, memberId);
    listmembers.remove(memberId);
    recentFriends.remove(memberId);
    getRecentFriends();
    setBusy(false);
    return unfriendStatus;
  }

  void getMembers_search(String search) {
    List<dynamic> friendsListStream = preferencesService.friendsListStream!.value!;
    recentFamily = memberSections.where((e) {
      // return e['member_name'].toString().contains(search);
      return e['member_first_name'].toString().toLowerCase().contains(search.toLowerCase());
    }).toList();
    // recentFamily.add({});
    // recentFriends = memSections.where((e) {
    recentFriends = friendsListStream.where((e) {
      return e['member_first_name'].toString().toLowerCase().contains(search.toLowerCase());
    }).toList();
    // recentFriends.add({});
    setBusy(false);
  }

  Future<bool> deletemember(String memberId) async {
    setBusy(true);
    final response = await apiService.deletemember(memberId);
    if (response) {
      String userId = preferencesService.userId;
      // List getmembers = await apiService.getUserMembersList(userId);
      //preferencesService.dropdown_user_id=getmembers[0]['_id'];
      List oldMembers = preferencesService.memebersListStream!.value!.toList();
      List filtr = oldMembers.where((element) => element['_id'] != memberId).toList();
      if (filtr.length > 0) {
        preferencesService.memebersListStream!.value = filtr;
        preferencesService.dropdown_user_id = filtr[0]['_id'].toString();
        preferencesService.dropdown_user_name = filtr[0]['member_first_name'];
        preferencesService.dropdown_user_dob = filtr[0]['date_of_birth'];
        preferencesService.dropdown_user_age = filtr[0]['age'].toString();
      }

      //  print( preferencesService.memebersListStream!.length);
      //  preferencesService.onRefreshRecentDocument!.value = true;
      //  preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
      //  locator<PreferencesService>().isUploadReload.value = true;
    }
    String userId = preferencesService.userId;
    // List members = await apiService.getUserMembersList(userId);

    //await getRecentFamily();
    List family = await apiService.getRecentFamily(userId, "60c381bc36cf932d305a572b");
    recentFamily.clear();
    if (family.length > 0) {
      recentFamily = family.expand((i) => i).toList();
      memberSections = recentFamily.toList();
    }
    setBusy(false);
    return response;
  }

  //
  Future<dynamic> getInviteMemberRefId() async {
    String userId = preferencesService.userId;
    String inviteType = 'friend_invite';
    final response = await apiService.getInviteMemberRefId(userId, inviteType);
    return response;
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
  // Future getusersfeedData(String userId) async {
  //   List user_Data = await apiService.getUsersFeedData(userId);
  //   List<dynamic> arrange_list = [];
  //   setBusy(false);
  // }

}

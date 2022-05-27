import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class RequestViewmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic profileInfo = {};
  dynamic notificationInfo = {};
  dynamic SearchByInfo = {};
  dynamic inviteInfo = {};
  String img_url = '';
  dynamic invite_exits = '';
  List<dynamic> sourceFileDates = [];
  //dynamic sourceFileDates;
  Map<String, List> getSections = {};
  Map<String, List> reminderSections = {};
  dynamic reminderDates = {};
  Future getNotification() async {
    setBusy(true);
    String userId = preferencesService.userId;
    //NotificationInfo = await apiService.getNotifications('61d96c9cb34ae365c03706de');
    notificationInfo = await apiService.getNotifications(userId, '6128a673b71d012678336f4d');

    sourceFileDates = notificationInfo
        .map((e) {
          Jiffy j = Jiffy(e['createdAt']);
          //String dateStr = j.format('dd MMM yyyy');
          String dateStr = j.format('yyyy-MM-dd');
          //String dateStr=j.format(day)
          if (reminderSections[dateStr] == null) {
            reminderSections[dateStr] = [e];
          } else {
            reminderSections[dateStr]!.add(e);
          }
          return j.format('yyyy-MM-dd');
        })
        .toSet()
        .toList();
    // for (dynamic info in notificationInfo) {
    //   Jiffy j = Jiffy(info['createdAt']);
    //   String dateStr = j.format('dd MMM yyyy');
    //   if (reminderSections[dateStr] == null) {
    //     reminderSections[dateStr] = [info];
    //   } else {
    //     reminderSections[dateStr]!.add(info);
    //   }
    // }
    // return j.format('dd MMM yyyy');

    reminderDates = sourceFileDates;
    // List notif_Info_List = model.reminderSections[dateStr]!;
    setBusy(false);
    // return true;
  }

  void getInvite_search(String search) {
    List<dynamic> usersListStream = preferencesService.usersListStream!.value!;

    // recentFamily.add({});
    // recentFriends = memSections.where((e) {
    SearchByInfo = notificationInfo.where((e) {
      return e['name'].toString().toLowerCase().contains(search.toLowerCase());
    }).toList();
    // recentFriends.add({});
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

  Future<bool> acceptinvite(String feedId, String refId, String status) async {
    setBusy(true);
    String userId = preferencesService.userId;
    var response = await apiService.acceptinvite(userId, refId, feedId, status);
    await getRecentFriends();
    setBusy(false);
    return response;
  }

  Future<bool> DoctoracceptInvite(String feedId, String refId, String status) async {
    setBusy(true);
    String userId = preferencesService.userId;
    var response = await apiService.Doctoracceptinvite(userId, refId, feedId, status);
    await getRecentFriends();
    setBusy(false);
    return response;
  }

  Future declineinvite(String feedId, String refId, String status) async {
    setBusy(true);
    String userId = preferencesService.userId;
    await apiService.acceptinvite(userId, refId, feedId, status);
    await getNotification();
    setBusy(false);
  }

  Future getRecentFriends() async {
    // setBusy(true);
    String userId = preferencesService.userId;
    await apiService.getRecentFriends(userId, "60dae3e440f5032614a8d24b");

    //memSections = recentFriends.toList();
    //recentFriends.add({});
    setBusy(false);
  }
}

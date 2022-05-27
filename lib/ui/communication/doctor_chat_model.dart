import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/dynamic_link_service.dart';
import 'package:swarapp/services/preferences_service.dart';

class DoctorChatmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  dynamic getsearchedInfo = {};
  dynamic SearchByInfo = {};

  String img_url = '';
  dynamic invite_exits = '';
  List<dynamic> searchBy_lists = [];
  List<dynamic> searchBy_Contactlists = [];
  List<dynamic> tempDoctorList = [];
  List<dynamic> doc_verified_list = [];
  //dynamic sourceFileDates;
  Map<String, List> getSections = {};
  Map<String, List> reminderSections = {};
  dynamic reminderDates = {};
  List<dynamic> countries = [];
  List<dynamic> doctoracceptedList = [];
  List<dynamic> notificationInfo = [];
  List<dynamic> InviteInfo = [];
  List<dynamic> RequestedInfo = [];

  Future getNotification() async {
    setBusy(true);
    String userId = preferencesService.userId;
    print("DAFSDFDSFDAFFAS" + userId.toString());
    //NotificationInfo = await apiService.getNotifications('61d96c9cb34ae365c03706de');
    notificationInfo = await apiService.getNotifications(userId, '6128a673b71d012678336f4d');
    InviteInfo = notificationInfo.where((msg) => msg['notification_type'].contains("invite")).toList();
    print("DAFSDFDSFDAFFAS" + InviteInfo.toString());
  }

  Future getRequestedList() async {
    setBusy(true);
    String inviterId = preferencesService.userId;
    //NotificationInfo = await apiService.getNotifications('61d96c9cb34ae365c03706de');
    notificationInfo = await apiService.getRequestedList(inviterId, '6128a673b71d012678336f4d');
    InviteInfo = notificationInfo.where((msg) => msg['notification_type'].contains("invite")).toList();
    RequestedInfo = InviteInfo.where((msg) => msg['invite_status'].contains("requested")).toList();
    tempDoctorList = await apiService.getDoctorList();
    if (RequestedInfo.length > 0) {
      for (int i = 0; i < RequestedInfo.length; i++) {
        for (var doctor in tempDoctorList) {
          if (doctor['_id'] == RequestedInfo[i]['user_Id']) {
            RequestedInfo[i]['profileData'] = doctor;
          }
        }
      }
    }
  }

  Future<bool> CancelRequest(String notificationId, String RefId) async {
    setBusy(true);
    String userId = preferencesService.userId;
    var response = await apiService.Cancelrequest(userId, RefId, notificationId);
    getDoctorList();
    setBusy(false);
    return response;
  }

  Future getDoctorList() async {
    setBusy(true);
    tempDoctorList = await apiService.getDoctorList();
    if (tempDoctorList != null) {
      for (var i = 0; i < tempDoctorList.length; i++) {
        doc_verified_list = tempDoctorList.where((msg) => msg['doctor_profile_id']['stage'] == 'verified').toList();
      }
    }
  }

  void getContact_search(String search) {
    List<dynamic> usersContactList = preferencesService.deviceContactList!.value!;

// for(var each in users_contact_list){
//  List<dynamic>  getfilterlist= each.displayName;
// }

    searchBy_Contactlists = usersContactList.where((e) {
      return e.displayName.toString().toLowerCase().contains(search.toLowerCase());
    }).toList();
  }

  Future inviteSwarUser(String userIdId) async {
    setBusy(true);
    final response = await apiService.inviteSwarUser(userIdId);
    print(response);
    setBusy(false);
  }

  Future inviteNewUser(Map<String, dynamic> postParams) async {
    setBusy(true);
    final response;
    String userId = preferencesService.userId;
    String inviteType = 'patient_invite_doctor';
    //Map<String, dynamic> postParams = {};
    // if (postParams['mobilenumber'] != null || postParams['mobilenumber'] != "") {
    //   String country = postParams['mobilenumber'];
    //   postParams['mobilenumber'] = "91" + country;
    // }
    final responseRef = await apiService.getInviteMemberRefId(userId, inviteType);
    if (responseRef['msg'] != null) {
      String postMessage = responseRef['msg'];
      if (responseRef['Invitemember'] != null) {
        dynamic inviteMember = responseRef['Invitemember'];
        String refId = inviteMember['reference_id'];
        String inviteLink = await locator<DynamicLinkService>().createMemberInviteLink(refId);
        postParams['postMessage'] = postMessage;
        postParams['inviteLink'] = inviteLink;
        postParams['user_id'] = userId;
        postParams['reference_id'] = refId;

        response = await apiService.inviteNewUser(postParams);
      }
    }

    setBusy(false);
  }

  Future getCountries() async {
    countries = await apiService.getCountries();
  }

  Future acceptedList(String patientId) async {
    setBusy(true);
    String doctorId = preferencesService.userId;
    print("PATTIENTIDD" + patientId.toString());
    doctoracceptedList = await apiService.acceptedList(doctorId);
    print("ACCEPTEDDLISTT" + doctoracceptedList.toString());
    setBusy(false);
  }

  void getUsers_search(String search) {
    List<dynamic> usersListStream = preferencesService.usersListStream!.value!;

    // recentFamily.add({});
    // recentFriends = memSections.where((e) {
    searchBy_lists = doctoracceptedList.where((e) {
      return e['name'].toString().toLowerCase().contains(search.toLowerCase());
    }).toList();
    // recentFriends.add({});
    setBusy(false);
  }

  // Future inviteContactNewUser(String name, String email, String mobile) async {
  //   setBusy(true);
  //   final response;
  //   String userId = preferencesService.userId;
  //   Map<String, dynamic> postParams = {};
  //   final response_ref = await apiService.getInviteMemberRefId(userId);
  //   if (response_ref['msg'] != null) {
  //     String postMessage = response_ref['msg'];
  //     if (response_ref['Invitemember'] != null) {
  //       dynamic inviteMember = response_ref['Invitemember'];
  //       String refId = inviteMember['reference_id'];
  //       String inviteLink = await locator<DynamicLinkService>().createMemberInviteLink(refId);
  //       postParams['postMessage'] = postMessage;
  //       postParams['inviteLink'] = inviteLink;
  //       postParams['name'] = name;

  //       response = await apiService.inviteNewContactUser(mobile, email, postParams);
  //     }
  //   }

  //   setBusy(false);
  // }

  //

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

  Future declineinvite(String feedId, String refId, String status) async {
    setBusy(true);
    String userId = preferencesService.userId;
    await apiService.acceptinvite(userId, refId, feedId, status);
    await getNotification();
    setBusy(false);
  }

  Future<bool> acceptinvite(String feedId, String refId, String status) async {
    setBusy(true);
    String userId = preferencesService.userId;
    var response = await apiService.acceptinvite(userId, refId, feedId, status);
    await getRecentFriends();
    setBusy(false);
    return response;
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

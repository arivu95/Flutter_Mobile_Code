import 'dart:convert';
import 'dart:io';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class Checkoutmodel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  List<dynamic> recentMembers = [];
  List<dynamic> memberSections = [];
  List<dynamic> recentFamily = [];
  List<dynamic> recentFriends = [];
  dynamic doctor_details = {};
  dynamic doctor_Info = {};
  dynamic slotbooking_details = {};
  String createdat = '';
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

  Future getUserdetail() async {
    setBusy(true);
    String getId = preferencesService.selected_doctor_info_id;
    doctor_details = await apiService.getProfile(getId);
    setBusy(false);
  }

  Future getbookingdetail() async {
    setBusy(true);
    String slotbookingId = preferencesService.slot_booking_id;
    slotbooking_details = await apiService.getbookingdetail(slotbookingId);
    setBusy(false);
  }

  Future getUserProfile() async {
    setBusy(true);
    String docId = preferencesService.selected_doctor_id;
    doctor_Info = await apiService.getDoctorProfile(docId);
    await getUserdetail();
    await getRecentFamily();
    await getbookingdetail();
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
    }
    setBusy(false);
    //print(recentFamily.toString());
    //memberSections = recentFamily.toList();
    //recentFamily.add({});
    // await getuserfeedList(false);
    //preferencesService.onRefreshRecentDocumentOnUpload!.value = true;
    // setBusy(false);
  }

  Future bookslot(String docId, Map<String, dynamic> userInfo) async {
    setBusy(true);
    String docId = preferencesService.selected_slot;
    final response = await apiService.bookAppoinment(docId, userInfo);
    setBusy(false);
  }

  Future createrazorpayorder(Map<String, dynamic> razorpayorderInfo) async {
    setBusy(true);
    final orderresponse = await apiService.createrazorpayorder(razorpayorderInfo);
    setBusy(false);
    return orderresponse;
  }

  Future paymentinfoupdate(String slotId, dynamic paymentInfo) async {
    setBusy(true);
    final orderresponse = await apiService.paymentinfoupdate(slotId, paymentInfo);
    setBusy(false);
    return orderresponse;
  }
}

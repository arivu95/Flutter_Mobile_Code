import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class FeedcommentModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  List<dynamic> commentsList = [];
  Map<String, dynamic> usersList = {};

  List<dynamic> feedcomments = [];
  dynamic gData = {};
  List outList = [];
  Future getfeedComment(commentId) async {
    setBusy(true);
    String userId = preferencesService.userId;
    print(userId);
    // final res=await apiService.getfeedComments(commentId);
    commentsList = await apiService.getfeedComments(commentId);
    List usersData = await apiService.getuserfeedsComments(commentId);

    usersList.clear();

    for (var user in usersData) {
      String imgurl = '${ApiService.fileStorageEndPoint}${user['azureBlobStorageLink']}';
      usersList[user['_id']] = {'name': user['name'], 'get_azure_link': imgurl};
    }
    // Adding user info
    usersList[preferencesService.userId] = {'name': preferencesService.userInfo['name'], 'get_azure_link': '${ApiService.fileStorageEndPoint}${preferencesService.userInfo['azureBlobStorageLink']}'};
    // Adding members
    for (var member in preferencesService.memebersListStream!.value!) {
      String imgurl = '${ApiService.fileStorageEndPoint}${member['azureBlobStorageLink']}';
      usersList[member['_id']] = {'name': member['member_first_name'], 'get_azure_link': imgurl};
    }
    setBusy(false);
  }

  Future getuserfeedComment(commentId) async {
    print('=========USER GT FEED=====');
    setBusy(true);
    //List commentresp = await apiService.getuserfeedsComments(commentId);
    final commentresp = await apiService.getuserfeedsComments(commentId);
    // print('========>>>>>>>>====='+commentresp.toString());
    setBusy(false);
  }

  Future addcomment(String comment, String commentId) async {
    // setBusy(true);
    Map<String, dynamic> postParams = {};
    String userId = preferencesService.userId;
    if (comment.isNotEmpty) {
      postParams['comment'] = comment;
    }
    postParams['commentBy'] = userId;
    Map<String, dynamic> newComment = {'comment': comment, 'commentBy': userId};
    commentsList.add(newComment);
    final response = await apiService.addcomments(commentId, postParams);
    preferencesService.onRefreshRecentDocument!.value = true;
    setBusy(false);
  }
}

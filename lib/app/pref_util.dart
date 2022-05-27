import 'dart:async';

import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String prefUserLogin = "pref_user_login";
const String prefUserPsw = "pref_user_psw";
const String prefUserName = "pref_user_name";
const String prefUserId = "pref_user_id";
const String prefUserAvatar = "pref_user_avatar";
const String prefSubscriptionToken = "pref_subscription_token";
const String prefSubscriptionId = "pref_subscription_id";
const String profileLevel = "profile_level";
const String profileId = "profile_id";

class SharedPrefs {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> getPrefs() async {
    Completer<SharedPreferences> completer = Completer();
    if (_prefs != null) {
      completer.complete(_prefs);
    } else {
      _prefs = await SharedPreferences.getInstance();
      completer.complete(_prefs);
    }
    return completer.future;
  }

  static Future<bool> saveNewUser(CubeUser cubeUser) async {
    await _prefs!.setString(prefUserLogin, cubeUser.login!);
    await _prefs!.setString(prefUserPsw, cubeUser.password!);
    await _prefs!.setString(prefUserName, cubeUser.fullName!);
    await _prefs!.setInt(prefUserId, cubeUser.id!);
    await _prefs!.setString(profileLevel, '');
    await _prefs!.setString(profileId, '');
    if (cubeUser.avatar != null) await _prefs!.setString(prefUserAvatar, cubeUser.avatar!);
    return Future.value(true);
  }

  static Future<bool> updateUser(CubeUser cubeUser) async {
    if (cubeUser.password != null) await _prefs!.setString(prefUserPsw, cubeUser.password!);
    if (cubeUser.login != null) await _prefs!.setString(prefUserLogin, cubeUser.login!);
    if (cubeUser.fullName != null) await _prefs!.setString(prefUserName, cubeUser.fullName!);
    if (cubeUser.avatar != null) await _prefs!.setString(prefUserAvatar, cubeUser.avatar!);

    return Future.value(true);
  }

  static Future<CubeUser?> getUser() async {
    if (_prefs!.getString(prefUserLogin) == null) return Future.value();
    var user = CubeUser();
    user.login = _prefs!.getString(prefUserLogin);
    user.password = _prefs!.getString(prefUserPsw);
    user.fullName = _prefs!.getString(prefUserName);
    user.id = _prefs!.getInt(prefUserId);
    user.avatar = _prefs!.getString(prefUserAvatar);
    return Future.value(user);
  }

  static Future<bool> deleteUserData() async {
    await _prefs!.remove(prefUserLogin);
    await _prefs!.remove(prefUserPsw);
    await _prefs!.remove(prefUserName);
    await _prefs!.remove(prefUserId);
    return Future.value(true);
  }

  static Future<bool?> saveSubscriptionToken(String token) async {
    return await _prefs?.setString(prefSubscriptionToken, token);
  }

  static Future<String> getSubscriptionToken() async {
    return Future.value(_prefs!.getString(prefSubscriptionToken) ?? "");
  }

  static Future<bool> saveSubscriptionId(int id) async {
    return await _prefs!.setInt(prefSubscriptionId, id);
  }

  static Future<int> getSubscriptionId() async {
    return Future.value(_prefs!.getInt(prefSubscriptionId) ?? 0);
  }

  static init() {}
}

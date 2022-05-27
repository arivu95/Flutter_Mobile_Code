import 'dart:io';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:dio/src/multipart_file.dart' as MP1;
import 'package:dio/src/form_data.dart' as FormData1;
import 'package:dio/src/response.dart' as Response1;
import 'package:intl/src/intl/date_format.dart';

const endPoint = 'https://testapi02.swardoctor.com/api';
//const endPoint = 'https://swarphase2api.azurewebsites.net/api';

class ApiService {
  static String imageStorageEndPoint = 'https://testapi02.swardoctor.com/';
  static String fileStorageEndPoint = 'https://swartest.blob.core.windows.net/swardoctor/';

  Dio client = new Dio();
  String token = '';
  bool is_feedCall = false;
  int intial_feed = 0;
  CancelToken cancel_Token = CancelToken();
  PreferencesService preferencesService = locator<PreferencesService>();

  //static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  void resetDio() {
    client = new Dio();
  }

  ApiService() {
    //refreshToken();
    (client.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    client.options.baseUrl = endPoint;
    client.options.headers['content-type'] = 'application/json';

    client.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) async {
      request.cancelToken = cancel_Token;
      if (request.extra['endpoint'] == null) {
        token = await locator<PreferencesService>().getUserInfo('swartoken');
        request.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(request);
    }, onError: (err, handler) async {
      if (err.response?.statusCode == 403) {
        // refresh token
        String refreshToken = await locator<PreferencesService>().getUserInfo('refreshtoken');
        Dio refClient = new Dio();
        if (refreshToken.isNotEmpty) {
          //cancel_Token.cancel();
          String userId = preferencesService.userId;
          //Dio refClient = new Dio();
          dynamic response = await refClient.post('$endPoint/auth/userrefreshtoken', data: {'userId': userId, 'refreshToken': refreshToken}, options: Options(extra: {'endpoint': 'access_token'}));
          if (response.data['refresh_token'] != null) {
            dynamic tokenObject = response.data['refresh_token'];
            if (tokenObject['accessToken'] != null) {
              await preferencesService.setUserInfo('swartoken', tokenObject['accessToken']);
              await preferencesService.setUserInfo('refreshtoken', tokenObject['refreshToken']);
              final opts = new Options(method: err.requestOptions.method, headers: err.requestOptions.headers);
              final cloneReq = await client.request(err.requestOptions.path, options: opts, data: err.requestOptions.data, queryParameters: err.requestOptions.queryParameters);
              return handler.resolve(cloneReq);
            }
          }
        } else {
          refClient = new Dio();
        }
        return handler.reject(err);
      } else if (err.response?.statusCode == 401) {
        await locator<PreferencesService>().cleanAllPreferences();
        locator<NavigationService>().clearStackAndShow(RoutePaths.Splash);
      }
      return handler.reject(err);
    }));

    client.interceptors.add(LogInterceptor(responseBody: true, responseHeader: true, requestHeader: true, requestBody: true));
  }

  Future<dynamic> tokenValidation(String azureToken) async {
    try {
      var response = await client.post('$endPoint/auth/tokenvalidation', data: {}, options: Options(headers: {'Authorization': 'Bearer $azureToken'}, extra: {'endpoint': 'access_token'}));
      print(response.data);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<dynamic> userRefreshToken(String refreshToken) async {
    try {
      String userId = preferencesService.userId;
      var respons = await client.post('$endPoint/auth/userrefreshtoken', data: {'userId': userId, 'refreshToken': refreshToken}, options: Options(extra: {'endpoint': 'access_token'}));
      print(respons.data);
      return respons.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<bool> checkUserExist(String oid) async {
    try {
      print("Check user exist---------->>>>");
      var response = await client.get('$endPoint/auth/usercheck?$oid');
      if (response.statusCode == 200) {
        print(response.data['subscriptionplan'].toString());

        // STORING THE SUBSCRIPTION OBJECT TO PREFERENCES
        if (response.data['subscription'] != null) {
          Map<String, dynamic> subscriptionObj = response.data['subscription'];
          if (subscriptionObj.keys.length > 0) {
            preferencesService.subscriptionStream.value = Map.from(subscriptionObj);
          }
        }
        if (response.data['user'] != null) {
          preferencesService.userInfo = response.data['user'];
          preferencesService.user_country = preferencesService.userInfo['country'];
          preferencesService.user_country_id = preferencesService.userInfo['country_id'];
          preferencesService.userId = preferencesService.userInfo['_id'];
          preferencesService.email = preferencesService.userInfo['email'];
          preferencesService.login_roleId = preferencesService.userInfo['login_role_id'];
          oid.contains("email") ? preferencesService.isEmailLogin = true : preferencesService.isPhoneLogin = true;
          preferencesService.dropdown_user_age = response.data['member']['age'].toString();
          preferencesService.profileUrl.value = preferencesService.userInfo['azureBlobStorageLink'] != null ? '$fileStorageEndPoint${preferencesService.userInfo['azureBlobStorageLink']}' : "";
        }
        if (response.data['doctor'] != null) {
          preferencesService.doctorInfo = response.data['doctor'];
          preferencesService.doctor_profile_id = preferencesService.doctorInfo['_id'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('profile_id', preferencesService.doctorInfo['_id']);
          // /String stage_level = get_stage['stage'] != null ? get_stage['stage'] : '';
          //   locator<PreferencesService>().doctorStageValue.value = stage_level;
          // preferencesService.doctor_profile_id = preferencesService.doctorInfo['_id'];
        }
        if (response.data['member'] != null) {
          preferencesService.memberInfo = response.data['member'];
          preferencesService.dropdown_user_id = preferencesService.memberInfo['_id'];
          preferencesService.dropdown_user_name = preferencesService.memberInfo['member_first_name'];
          preferencesService.dropdownuserName.value = preferencesService.memberInfo['member_first_name'];
          preferencesService.dropdown_user_age = response.data['member']['age'].toString();
        }

        if (response.data['subscriptionplan'] != null) {
          preferencesService.subscriptionInfo = response.data['subscriptionplan'];
          preferencesService.member_count = preferencesService.subscriptionInfo['member_count'];
        }

        return true;
      }
      return false;
    } on DioError catch (e) {
      print('===============deio=============');
      print(e.toString());
      return false;
    }
  }

  //For user and member check
  Future<dynamic> checkUserEmailExist(String email) async {
    try {
      var response = await client.get('$endPoint/auth/usermemberlogincheck?email=$email');
      if (response.data['subscription'] != null) {
        Map<String, dynamic> subscriptionObj = response.data['subscription'];
        if (subscriptionObj.keys.length > 0) {
          preferencesService.subscriptionStream.value = Map.from(subscriptionObj);
        }
      }
      if (response.data['subscriptionplan'] != null) {
        preferencesService.subscriptionInfo = response.data['subscriptionplan'];
        preferencesService.member_count = preferencesService.subscriptionInfo['member_count'];
      }
      if (response.data['doctor'] != null) {
        preferencesService.doctorInfo = response.data['doctor'];
        preferencesService.doctor_profile_id = preferencesService.doctorInfo['_id'];
      }
      if (response.data['msg'] == "User Exists") {
        if (response.data['user'] != null) {
          preferencesService.userInfo = response.data['user'];
          preferencesService.user_country = preferencesService.userInfo['country'];
          preferencesService.user_country_id = preferencesService.userInfo['country_id'];
          preferencesService.login_roleId = preferencesService.userInfo['login_role_id'];
          preferencesService.userId = preferencesService.userInfo['_id'];
          preferencesService.profileUrl.value = preferencesService.userInfo['azureBlobStorageLink'] != null ? '$fileStorageEndPoint${preferencesService.userInfo['azureBlobStorageLink']}' : "";
        }
        if (response.data['member'] != null) {
          preferencesService.memberInfo = response.data['member'];
          preferencesService.dropdown_user_id = preferencesService.memberInfo['_id'];
          preferencesService.dropdown_user_name = preferencesService.memberInfo['member_first_name'];
          preferencesService.dropdownuserName.value = preferencesService.memberInfo['member_first_name'];
          preferencesService.dropdown_user_age = response.data['member']['age'].toString();
        }
        return response.data['msg'];
      } else if (response.data['msg'] == "Member becomes User") {
        preferencesService.userInfo = response.data['usermemberdetail'];
        preferencesService.memberId = preferencesService.userInfo['_id'];
        preferencesService.dropdown_user_id = preferencesService.memberId;
        preferencesService.dropdown_user_name = preferencesService.userInfo['member_first_name'];
        preferencesService.dropdownuserName.value = preferencesService.memberInfo['member_first_name'];
        preferencesService.email = preferencesService.userInfo['member_email'];
        preferencesService.phone = preferencesService.userInfo['member_mobile_number'];
        preferencesService.dropdown_user_age = response.data['usermemberdetail']['age'].toString();
        preferencesService.profileUrl.value = preferencesService.userInfo['img_url'];
        preferencesService.profileUrl.value = preferencesService.userInfo['azureBlobStorageLink'] != null ? '$fileStorageEndPoint${preferencesService.userInfo['azureBlobStorageLink']}' : "";
      }
      return response.data['msg'];
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<dynamic> checkUserMobileExist(String email) async {
    try {
      var response = await client.get('$endPoint/auth/usermemberlogincheck?mobilenumber=$email');
      if (response.data['msg'] == "User Exists") {
        // STORING THE SUBSCRIPTION OBJECT TO PREFERENCES
        if (response.data['subscription'] != null) {
          Map<String, dynamic> subscriptionObj = response.data['subscription'];
          if (subscriptionObj.keys.length > 0) {
            preferencesService.subscriptionStream.value = Map.from(subscriptionObj);
          }
        }
        if (response.data['subscriptionplan'] != null) {
          preferencesService.subscriptionInfo = response.data['subscriptionplan'];
          preferencesService.member_count = preferencesService.subscriptionInfo['member_count'];
        }
        if (response.data['doctor'] != null) {
          preferencesService.doctorInfo = response.data['doctor'];
          preferencesService.doctor_profile_id = preferencesService.doctorInfo['_id'];
        }
        if (response.data['user'] != null) {
          preferencesService.userInfo = response.data['user'];
          preferencesService.user_country = preferencesService.userInfo['country'];
          preferencesService.user_country_id = preferencesService.userInfo['country_id'];
          preferencesService.userId = preferencesService.userInfo['_id'];
          preferencesService.email = preferencesService.userInfo['email'];
          preferencesService.profileUrl.value = preferencesService.userInfo['azureBlobStorageLink'] != null ? '$fileStorageEndPoint${preferencesService.userInfo['azureBlobStorageLink']}' : "";
        }
        if (response.data['member'] != null) {
          preferencesService.memberInfo = response.data['member'];
          preferencesService.dropdown_user_id = preferencesService.memberInfo['_id'];
          preferencesService.dropdown_user_name = preferencesService.memberInfo['member_first_name'];
          preferencesService.dropdownuserName.value = preferencesService.memberInfo['member_first_name'];
          preferencesService.dropdown_user_age = response.data['member']['age'].toString();
        }
        return response.data['msg'];
      } else if (response.data['msg'] == "Member becomes User") {
        preferencesService.userInfo = response.data['usermemberdetail'];
        preferencesService.memberId = preferencesService.userInfo['_id'];
        preferencesService.dropdown_user_id = preferencesService.memberId;
        preferencesService.dropdown_user_name = preferencesService.userInfo['member_first_name'];
        preferencesService.dropdownuserName.value = preferencesService.memberInfo['member_first_name'];
        preferencesService.dropdown_user_age = response.data['usermemberdetail']['age'].toString();
        preferencesService.email = preferencesService.userInfo['member_email'];
        preferencesService.phone = preferencesService.userInfo['member_mobile_number'];
        preferencesService.profileUrl.value = preferencesService.userInfo['img_url'];
        preferencesService.profileUrl.value = preferencesService.userInfo['azureBlobStorageLink'] != null ? '$fileStorageEndPoint${preferencesService.userInfo['azureBlobStorageLink']}' : "";
      }
      return response.data['msg'];
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future saveUserDeviceToken(String userid, String devicetoken) async {
    try {
      var response = await client.post('$endPoint/userdevices', data: {'user_Id': userid, 'user_device_Id': devicetoken});
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  //member
  Future<dynamic> member_login(String memberid, String country, String countryId, String language) async {
    try {
      var response = await client.get('$endPoint/members/$memberid/existmembercheck?country_id=$countryId&country=$country&language=$language ');
      if (response.data['subscription'] != null) {
        Map<String, dynamic> subscriptionObj = response.data['subscription'];
        if (subscriptionObj.keys.length > 0) {
          preferencesService.subscriptionStream.value = Map.from(subscriptionObj);
        }
      }
      if (response.data['subscriptionplan'] != null) {
        preferencesService.subscriptionInfo = response.data['subscriptionplan'];
        preferencesService.member_count = preferencesService.subscriptionInfo['member_count'];
      }
      if (response.data['user'] != null) {
        preferencesService.userInfo = response.data['user'];
        preferencesService.user_country = preferencesService.userInfo['country'];
        preferencesService.user_country_id = preferencesService.userInfo['country_id'];
        preferencesService.userId = preferencesService.userInfo['_id'];
        preferencesService.email = preferencesService.userInfo['email'];
        preferencesService.profileUrl.value = '$fileStorageEndPoint${preferencesService.userInfo['azureBlobStorageLink']}';
      }
      if (response.data['member'] != null) {
        preferencesService.memberInfo = response.data['member'];
        preferencesService.dropdown_user_id = preferencesService.memberInfo['_id'];
        preferencesService.dropdown_user_name = preferencesService.memberInfo['member_first_name'];
        preferencesService.dropdownuserName.value = preferencesService.memberInfo['member_first_name'];
        preferencesService.dropdown_user_age = response.data['member']['age'].toString();
      }

      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  // Get Login Role
  Future<List<dynamic>> getloginrole() async {
    try {
      var response = await client.get('$endPoint/loginrole');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

// Get Health provider Role
  Future<List<dynamic>> gethealthproviders() async {
    try {
      var response = await client.get('$endPoint/healthprovider');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get Countries
  Future<List<dynamic>> getCountries() async {
    try {
      var response = await client.get('$endPoint/countries');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

// Get user Countries
  Future<dynamic> getuserCounty(countryId) async {
    try {
      var response = await client.get('$endPoint/countries/$countryId');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  // Get Languages
  Future<List<dynamic>> getLanguages() async {
    try {
      var response = await client.get('$endPoint/languages');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Register User
  Future<dynamic> registerUser(Map<String, dynamic> postParams, String profileImagePath) async {
    try {
      Map<String, dynamic> post = Map.from(postParams);
      if (profileImagePath.length > 0) {
        String filename = profileImagePath.split('/').last;
        post['profileimage'] = await MP1.MultipartFile.fromFile(profileImagePath, filename: filename);
      }
      post['login_role_id'] = "6128a673b71d012678336f4d";
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.post('$endPoint/users', data: formData, options: Options(extra: {'endpoint': 'access_token'}));

      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      if (e.response!.data != null) {
        if (e.response!.data['errors'] != null) {
          List errors = e.response!.data['errors'];
          if (errors.length > 0) {
            dynamic firstError = errors.first;
            if (firstError['messages'] != null) {
              List messages = firstError['messages'];
              locator<DialogService>().showDialog(title: 'Error', description: messages.join(''));
            }
          }
        }
      }
      return {};
    }
  }

  // Register Doctor
  Future<dynamic> registerDoctor(Map<String, dynamic> postParams, String profileImagePath) async {
    try {
      Map<String, dynamic> post = Map.from(postParams);
      if (profileImagePath.length > 0) {
        String filename = profileImagePath.split('/').last;
        post['profileimage'] = await MP1.MultipartFile.fromFile(profileImagePath, filename: filename);
      }
      post['login_role_id'] = preferencesService.login_roleId;
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.post('$endPoint/users', data: formData, options: Options(extra: {'endpoint': 'access_token'}));
      if (response.data.length == 4) {
        if (response.data['doctor_profile'] != null) {
          preferencesService.doctorInfo = response.data['doctor_profile'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('profile_id', preferencesService.doctorInfo['_id']);
          // /String stage_level = get_stage['stage'] != null ? get_stage['stage'] : '';
          //   locator<PreferencesService>().doctorStageValue.value = stage_level;
          preferencesService.doctor_profile_id = preferencesService.doctorInfo['_id'];
        }
      }

      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      if (e.response!.data != null) {
        if (e.response!.data['errors'] != null) {
          List errors = e.response!.data['errors'];
          if (errors.length > 0) {
            dynamic firstError = errors.first;
            if (firstError['messages'] != null) {
              List messages = firstError['messages'];
              locator<DialogService>().showDialog(title: 'Error', description: messages.join(''));
            }
          }
        }
      }
      return {};
    }
  }

  Future<dynamic> getProfile(String userid) async {
    try {
      var response = await client.get('$endPoint/users/$userid');
      dynamic sr = response.data;
      preferencesService.servicesStream.clear();
      preferencesService.servicesStream = sr['doctor_services'];
      preferencesService.usersServiceListStream!.value = preferencesService.servicesStream;
      await preferencesService.setServices();
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<dynamic> getbookingdetail(String slotbookingId) async {
    try {
      var response = await client.get('$endPoint/bookingslot/$slotbookingId');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<dynamic> updateUserProfile(String userid, Map<String, dynamic> userInfo, String profileImagePath, String coverImagePath) async {
    try {
      Map<String, dynamic> post = Map.from(userInfo);

      if (profileImagePath.length > 0) {
        String filename = profileImagePath.split('/').last;
        post['profile_image'] = await MP1.MultipartFile.fromFile(profileImagePath, filename: filename);
      }

      if (coverImagePath.length > 0) {
        String coverFilename = coverImagePath.split('/').last;
        post['cover_image'] = await MP1.MultipartFile.fromFile(coverImagePath, filename: coverFilename);
      }
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/users/$userid', data: formData);
      dynamic sr = response.data['user'];
      preferencesService.servicesStream.clear();
      preferencesService.servicesStream = sr['doctor_services'];
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<bool> updateUserStatus(String userid, String status) async {
    try {
      var formData = FormData1.FormData.fromMap({'profilestatus': status});
      var response = await client.patch('$endPoint/users/$userid', data: formData);
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

//get feed List
  Future<dynamic> getUserFeedsList(String userId) async {
    try {
      var response = await client.get('$endPoint/feeds?user_Id=$userId');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

//get feed of user's details -id, profileimage
  Future<List<dynamic>> getUsersFeedData(String userId) async {
    try {
      var response = await client.get('$endPoint/feeds?user_Id=$userId');
      return response.data['userData'];
    } on DioError catch (e) {
      return [];
    }
  }

//get feed comment List
  Future<List<dynamic>> getfeedComments(String feedDocumentId) async {
    try {
      var response = await client.get('$endPoint/feeds/$feedDocumentId');
      return response.data['feedData'][0]['comments'];
    } on DioError catch (e) {
      return [];
    }
  }

//get feed's comment of user's detail ..
  Future<List<dynamic>> getuserfeedsComments(String feedDocumentId) async {
    try {
      var response = await client.get('$endPoint/feeds/$feedDocumentId');
      return response.data['userData'];
    } on DioError catch (e) {
      return [];
    }
  }

  Future addstatus(Map<String, dynamic> postParams) async {
    try {
      Map<String, dynamic> post = Map.from(postParams);
      if (postParams['path'] != null) {
        String filepath = postParams['path'];
        String filename = filepath.split('/').last;
        post['feedpost'] = await MP1.MultipartFile.fromFile(filepath, filename: filename);
      }
      if (postParams['thumbnail'] != null) {
        String thumbpath = postParams['thumbnail'];
        String thumbname = thumbpath.split('/').last;
        post['thumbnail'] = await MP1.MultipartFile.fromFile(thumbpath, filename: thumbname);
      }
      FormData1.FormData postParams1 = FormData1.FormData.fromMap(post);
      var response = await client.post('$endPoint/feeds', data: postParams1);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future addcomments(String feedDocumentId, Map<String, dynamic> postParams) async {
    try {
      Map<String, dynamic> post = Map.from(postParams);
      FormData1.FormData postParams1 = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/feeds/$feedDocumentId', data: postParams1);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  /// LIKE API ////
  Future addlikes(String feedDocumentId, String userId) async {
    try {
      var response = await client.patch('$endPoint/feeds/$feedDocumentId/likes', data: {'likedBy': userId, 'user_Id': userId});
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  //// Dislike ///////////////
  Future<bool> dislike(String feedDocumentId, String userId) async {
    try {
      var response = await client.delete('$endPoint/feeds/$feedDocumentId/dislike?likedBy=$userId&user_Id=$userId');
      return true;
    } on DioError catch (e) {
      return false;
    }
  }

//// Add Care
  Future addcare(String feedDocumentId, String userId) async {
    try {
      var response = await client.patch('$endPoint/feeds/$feedDocumentId/care', data: {'caredBy': userId, 'user_Id': userId});
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  //// Remove care //////
  Future<bool> removecare(String feedDocumentId, String userId) async {
    try {
      var response = await client.delete('$endPoint/feeds/$feedDocumentId/removecare?caredBy=$userId&user_Id=$userId');
      return true;
    } on DioError catch (e) {
      return false;
    }
  }

  //// Add Donate
  Future adddonate(String feedDocumentId, String userId) async {
    try {
      var response = await client.patch('$endPoint/feeds/$feedDocumentId/donate', data: {'donatedBy': userId, 'user_Id': userId});
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  //// Remove donate //////
  Future<bool> removedonate(String feedDocumentId, String userId) async {
    try {
      var response = await client.delete('$endPoint/feeds/$feedDocumentId/removedonate?donatedBy=$userId&user_Id=$userId');
      return true;
    } on DioError catch (e) {
      return false;
    }
  }

//delete files
  Future<bool> fileDelete(String docid) async {
    try {
      var response = await client.delete('$endPoint/documents/$docid');
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  //file renameFile
  Future<bool> fileRename(String docid, String filename) async {
    try {
      var response = await client.patch(
        '$endPoint/documents/$docid/filerename',
        data: {'fileName': filename},
      );
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<dynamic>> getFileCategory() async {
    try {
      var response = await client.get('$endPoint/filecategory');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<dynamic> userFileSharing(String userId, Map<String, dynamic> postParam) async {
    try {
      var response = await client.post('$endPoint/users/$userId/internalsharing', data: postParam);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

// individual captureimage upload
  Future<bool> uploadDocuments(
    Map<String, dynamic> postParams,
    List<String> filepath,
    Map<String, dynamic> thumbnailpath,
    String mode,
  ) async {
    var response = "";
    try {
      Map<String, dynamic> post = Map.from(postParams);
      //String nam = post['fileName'];
      if (filepath.length > 0) {
        for (var file in filepath) {
          String filename = file.split('/').last;
          String restrictLength = filename.split('.').first;
          //String tdata = DateFormat("HH:mm:ss").format(DateTime.now());
          if (restrictLength.length > 8) {
            filename = restrictLength.substring(0, 8) + '_' + DateFormat("HH_mm_ss").format(DateTime.now()) + "." + filename.split('.').last;
            //DateFormat("dd-MM-yyyy hh:mm:ss").format(now)
          }

          post['fileupload'] = await MP1.MultipartFile.fromFile(file, filename: filename);
          if (filename.contains(".mp4") || filename.contains(".mp3")) {
            String thumbnailS = '';
            //thumbnailpath
            //  int index = filepath.indexWhere((item) => item == currentMonth);
            //products.where((o) => o['get_id'] == members[i]['user_Id'])
            // String thumbnail_s=thumbnailpath.where((item) => item == file).toString();
            thumbnailpath[file] != null ? thumbnailS = thumbnailpath[file] : '';
            String filenameThumbanil = thumbnailS.split('/').last;
            post['thumbnail'] = await MP1.MultipartFile.fromFile(thumbnailS, filename: filenameThumbanil);
          }

          if (mode == "Camera") {
            post['cam_mode'] = 'camera';
          }
          FormData1.FormData formData = FormData1.FormData.fromMap(post);
          var response = await client.post('$endPoint/documents', data: formData);
        }
      }
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<dynamic>> getRecentDownloads(String userid) async {
    try {
      var response = await client.get('$endPoint/users/$userid/recentdownload');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getRecentUploads(String userid) async {
    try {
      var response = await client.get('$endPoint/members/$userid/recentupload');
      List recentsdoc = response.data;
      // keeping a copy in preferences to access it from other widgets
      preferencesService.recentdocListStream!.value = recentsdoc;
      return recentsdoc;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getFilesByCategory(String userid, String catid) async {
    try {
      var response = await client.get('$endPoint/members/$userid/memberscategorywisefiles?filecategoryid=$catid');
      print(response.data);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getDicomFoldersByCategory(String userid, String catid) async {
    try {
      var response = await client.get('$endPoint/members/$userid/diacomfilelist?filecategoryid=$catid');
      print(response.data);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getDicomFilesByCategory(String userid, String catid, String filename) async {
    try {
      var response = await client.get('$endPoint/members/$userid/memberscategorywisefiles?filecategoryid=$catid&diacom_filename=$filename');
      print(response.data);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<bool> fileDownload(String savePath, String url) async {
    try {
      var response = await client.download(url, savePath, options: Options(responseType: ResponseType.bytes, extra: {'endpoint': 'access_token'}));
      print(response.data);
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateDownloadDocStatus(String docId) async {
    try {
      await client.patch('$endPoint/documents/$docId');
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

////////////////MEMBER///////////////////
  // Register member
  Future<dynamic> registerMember(Map<String, dynamic> postParams, String profileImagePath) async {
    try {
      Map<String, dynamic> post = Map.from(postParams);
      if (profileImagePath.length > 0) {
        String filename = profileImagePath.split('/').last;
        post['profileimage'] = await MP1.MultipartFile.fromFile(profileImagePath, filename: filename);
      }
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.post('$endPoint/members', data: formData);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      if (e.response!.data != null) {
        if (e.response!.data['errors'] != null) {
          List errors = e.response!.data['errors'];
          if (errors.length > 0) {
            dynamic firstError = errors.first;
            if (firstError['messages'] != null) {
              List messages = firstError['messages'];
              locator<DialogService>().showDialog(title: 'Error', description: messages.join(''));
            }
          }
        }
      }
      return {};
    }
  }

//get member profile

  Future<dynamic> get_member_Profile(String memberid) async {
    try {
      var response = await client.get('$endPoint/members/$memberid');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

// //Update Member Profile
//   Future<bool> updateMemberProfile(String memberId, Map<String, dynamic> memberInfo, String profileImagePath) async {
//     try {
//       Map<String, dynamic> post = Map.from(memberInfo);
//       if (profileImagePath.length > 0) {
//         String filename = profileImagePath.split('/').last;
//         post['profileimage'] = await MP1.MultipartFile.fromFile(profileImagePath, filename: filename);
//       }
//       var formData = FormData1.FormData.fromMap(post);
//       var response = await client.patch('$endPoint/members/$memberId', data: formData);
//       return true;
//     } on DioError catch (e) {
//       return false;
//     }
//   }
//Update Member Profile
  Future<bool> updateMemberProfile(String memberId, Map<String, dynamic> memberInfo, String profileImagePath, String coverImagePath) async {
    try {
      Map<String, dynamic> post = Map.from(memberInfo);
      if (profileImagePath.length > 0) {
        String filename = profileImagePath.split('/').last;
        post['profileimage'] = await MP1.MultipartFile.fromFile(profileImagePath, filename: filename);
      }

      if (coverImagePath.length > 0) {
        String filename = coverImagePath.split('/').last;
        post['cover_img'] = await MP1.MultipartFile.fromFile(coverImagePath, filename: filename);
      }
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/members/$memberId', data: formData);
      return true;
    } on DioError catch (e) {
      return false;
    }
  }

  Future<bool> addNotesMemberProfile(String memberId, Map<String, dynamic> memberInfo, String notesPath, notes) async {
    try {
      Map<String, dynamic> post = Map.from(memberInfo);
      if (notesPath.length > 0) {
        String filename = notesPath.split('/').last;
        post['notes'] = await MP1.MultipartFile.fromFile(notesPath, filename: filename);
      }
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/members/$memberId', data: formData);
      return true;
    } on DioError catch (e) {
      return false;
    }
  }

//get recent members
  Future<List<dynamic>> getRecentMembers(String userId) async {
    try {
      var response = await client.get('$endPoint/members?user_Id=$userId');
      List<dynamic> recentMembers = response.data;
      preferencesService.recentMembersListStream!.value = recentMembers.expand((element) => element).toList();
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

//get friends list
  Future<List<dynamic>> getRecentFamily(String userId, String roleId) async {
    try {
      var response = await client.get('$endPoint/members?user_Id=$userId&role_name=$roleId');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getRecentFriends(String userId, String roleId) async {
    try {
      var response = await client.get('$endPoint/members?user_Id=$userId&role_name=$roleId');
      //StreamedList<dynamic>? friendsListStream = StreamedList<dynamic>(initialData: []);
      List<dynamic> friends = response.data;
      preferencesService.friendsListStream!.value = friends.expand((element) => element).toList();
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<dynamic> unFriendUser(String userId, String friendId) async {
    try {
      var response = await client.patch('$endPoint/users/$userId/deletefriend?memberid=$friendId');
      print(response);
      return true;
    } on DioError catch (e) {
      return false;
    }
  }

  //get recent members
  Future<List<dynamic>> getUserMembersList(String userId) async {
    try {
      var response = await client.get('$endPoint/users/$userId/userwisememberlist');
      List<dynamic> members = response.data;
      preferencesService.memebersListStream!.value = members.expand((element) => element).toList();
      print(members.toString());
      return members;
    } on DioError catch (e) {
      print('getusermemberlist--------->>' + e.toString());
      return [];
    }
  }

  //Delete Member Profile
  Future<bool> deletemember(String memberId) async {
    try {
      String userId = preferencesService.userId;
      var response = await client.patch('$endPoint/members/$memberId/deletemember?user_Id=$userId');
      return true;
    } on DioError catch (e) {
      return false;
    }
  }

  Future getInviteMemberRefId(String userId, String inviteType) async {
    try {
      var response = await client.post('$endPoint/users/$userId/invitememberinlink', data: {'invite_type': inviteType});
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

//invite members by email
  Future<bool> getInviteMember(String userId, String mailId) async {
    try {
      var response = await client.post('$endPoint/users/$userId/invitememberinmail?email=$mailId');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> getInviteMemberMobile(String userId, String mobile) async {
    try {
      var response = await client.post('$endPoint/users/$userId/invitememberinmail?mobilenumber=$mobile');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  ///////////////////////////////////////////////////////////////////
  /////////////////// MEDICAL RECORDS RELATED START /////////////////
  ///////////////////////////////////////////////////////////////////

  ///covid
  Future<List<dynamic>> getCovidVaccines(String countryCode) async {
    try {
      var response = await client.get('$endPoint/covidvaccination?country_id=$countryCode');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getCovidMemeberRecords(String memberId) async {
    try {
      var response = await client.get('$endPoint/members/$memberId/covidreports');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future addNewVaccineForMember(String memberId, String covidVaccineId, String countryId, String type) async {
    try {
      print('NEW VA**************');
      var response = await client.post('$endPoint/usercovid', data: {'member_Id': memberId, type: covidVaccineId, 'country_Id': countryId});
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<dynamic> addMoreVaccinePatch(String covidDocumentId, String covidVaccineId) async {
    try {
      var response = await client.patch('$endPoint/usercovid/$covidDocumentId/addcovidvaccine', data: {'covidVaccination_Id': covidVaccineId});
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future updateCovidVaccineInfo(String covidDocumentId, Map<String, dynamic> postParams, List<String> filePath) async {
    try {
      Map<String, dynamic> post = Map.from(postParams);
      List path = [];
      if (filePath.length > 0) {
        for (int i = 0; i < filePath.length; i++) {
          String filename = filePath[i].split('/').last;
          String restrictLength = filename.split('.').first;
          //String tdata = DateFormat("HH:mm:ss").format(DateTime.now());
          if (restrictLength.length > 8) {
            filename = restrictLength.substring(0, 8) + '_' + DateFormat("HH_mm_ss").format(DateTime.now()) + "." + filename.split('.').last;
          }
          //DateFormat("dd-MM-yyyy hh:mm:ss").format(now)
          var check = await MP1.MultipartFile.fromFile(filePath[i], filename: filename);
          path.add(check);
        }
        post['attach_record'] = path;
      }
      FormData1.FormData postParams1 = FormData1.FormData.fromMap(post);
      print('THE COUNG VAL IS****-----__________');
      var response = await client.patch('$endPoint/usercovid/$covidDocumentId', data: postParams1);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future updateCovidTreatmentDetails(String covidDocumentId, String path) async {
    if (path.isNotEmpty) {
      Map<String, dynamic> post = {};
      String filename = path.split('/').last;
      post['treatment_details'] = await MP1.MultipartFile.fromFile(path, filename: filename);
      post['fileName'] = filename;
      var response = await client.patch('$endPoint/usercovid/$covidDocumentId', data: post);
      return response.data;
    }
    return {};
  }

  Future deleteCovidInfo(String refId, String flag, String documentId) async {
    try {
      var response = await client.delete('$endPoint/usercovid/$documentId?$flag=$refId');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

//////// Lab Test
  Future<List<dynamic>> getCovidLabTest(String countryCode) async {
    try {
      var response = await client.get('$endPoint/covidlabtest?country_id=$countryCode');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future addNewLabTest(String memberId, String testName, String countryId) async {
    try {
      var response = await client.post('$endPoint/covidlabtest', data: {'member_Id': memberId, 'country_Id': countryId});
      print('------------response data-------' + response.data.toString());
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<dynamic> addMoreLabtestPatch(String covidDocumentId, String covidVaccineId) async {
    try {
      var response = await client.patch('$endPoint/usercovid/$covidDocumentId/addcovidtest', data: {'covidtest_Id': covidVaccineId});
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<List<dynamic>> getUserVaccine(String memberId) async {
    try {
      var response = await client.get('$endPoint/uservaccine?member_Id=$memberId');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future createVaccinationTableForUser(String memberId, String countryId) async {
    try {
      var response = await client.post('$endPoint/uservaccine', data: {'member_Id': memberId, 'country_Id': countryId});
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future updateVaccinationInfo(String covidDocumentId, Map<String, dynamic> postParams, List<String> filePath) async {
    try {
      Map<String, dynamic> post = Map.from(postParams);
      List path = [];
      if (filePath.length > 0) {
        for (int i = 0; i < filePath.length; i++) {
          String filename = filePath[i].split('/').last;
          String restrictLength = filename.split('.').first;
          //String tdata = DateFormat("HH:mm:ss").format(DateTime.now());
          if (restrictLength.length > 8) {
            filename = restrictLength.substring(0, 8) + '_' + DateFormat("HH_mm_ss").format(DateTime.now()) + "." + filename.split('.').last;
          }
          var check = await MP1.MultipartFile.fromFile(filePath[i], filename: filename);
          path.add(check);
        }
        post['attach_record'] = path;
      }

      FormData1.FormData postParams1 = FormData1.FormData.fromMap(post);
      print('THE COUNG VAL IS****-----__________');
      var response = await client.patch('$endPoint/uservaccine/$covidDocumentId', data: postParams1);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<List<dynamic>> getUserMaternity(String memberId) async {
    try {
      var response = await client.get('$endPoint/maternity?member_Id=$memberId');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future createMaternityTableForUser(String memberId, String countryId) async {
    try {
      var response = await client.post('$endPoint/maternity', data: {'member_Id': memberId, 'country_Id': countryId});
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future updateMaternityInfo(String maternityDocumentId, Map<String, dynamic> postParams, List<String> filePath) async {
    try {
      Map<String, dynamic> post = Map.from(postParams);
      List path = [];
      if (filePath.length > 0) {
        for (int i = 0; i < filePath.length; i++) {
          String filename = filePath[i].split('/').last;
          String restrictLength = filename.split('.').first;
          //String tdata = DateFormat("HH:mm:ss").format(DateTime.now());
          if (restrictLength.length > 8) {
            filename = restrictLength.substring(0, 8) + '_' + DateFormat("HH_mm_ss").format(DateTime.now()) + "." + filename.split('.').last;
          }
          var check = await MP1.MultipartFile.fromFile(filePath[i], filename: filename);
          path.add(check);
        }
        post['attach_record'] = path;
      }
      FormData1.FormData postParams1 = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/maternity/$maternityDocumentId', data: postParams1);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future getheaderRecords(String maternityDocumentId, Map<String, dynamic> postParams) async {
    try {
      Map<String, dynamic> post = Map.from(postParams);
      FormData1.FormData postParams1 = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/maternity/$maternityDocumentId/update', data: postParams1);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

//////////////////////////////Vaccination/////////////////////////////////////
  Future<List<dynamic>> getUserVaccineRecords(String memberId) async {
    try {
      var response = await client.get('$endPoint/uservaccine?member_Id=$memberId');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

//add vaccination record
  Future<bool> addVaccinationRecord(Map<String, dynamic> postParams, List<String> filepath, String objId) async {
    try {
      Map<String, dynamic> post = Map.from(postParams);

      for (var file in filepath) {
        if (file.isNotEmpty) {
          String filename = file.split('/').last;
          post['attach_record'] = await MP1.MultipartFile.fromFile(file, filename: filename);
          post['fileName'] = "fileAttach";
        }
      }
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/uservaccine/$objId', data: formData);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

//Check dynmic link Ref id

  Future<bool> checkRefId(String userId, String refId) async {
    try {
      var response = await client.get('$endPoint/users/$userId/invitecheckreference?reference_id=$refId');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }
//Invite accept

  Future<bool> acceptinvite(String userId, String RefId, String feedId, String status) async {
    try {
      var response = await client.get('$endPoint/users/$userId/invitestatus?reference_id=$RefId&invite_status=$status&notificationId=$feedId');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  //Invite decline

  Future<bool> declineinvite(String userId, String RefId, String feedId, String status) async {
    try {
      var response = await client.get('$endPoint/users/$userId/invitestatus?reference_id=$RefId&invite_status=$status&notificationId=$feedId');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  //Download Maternity
  Future<List<dynamic>> getDownloadMaternity(String memberId, String category, String countryId) async {
    try {
      var response = await client.get('$endPoint/userreports?member_Id=$memberId&country_Id=$countryId&file_category=$category');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  ///////////////////////////////////////////////////////////////////
  ////////////////////// MEDICAL RECORDS RELATED END/////////////////
  ///////////////////////////////////////////////////////////////////

// CONNECTYCUBE RELATED
  // Update CC ID to user
  Future updateConnectyCubeIdToUser(int ccId) async {
    try {
      String userid = preferencesService.userId;
      var response = await client.patch('$endPoint/users/$userid', data: {"connectycube_id": ccId});
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future updateConnectyCubeAvatat(CubeUser user) async {
    // Saving user avatar
    print(preferencesService.userInfo['connectycube_id'].toString());
    String profileUrl = preferencesService.getUserProfileImageUrl();
    print(profileUrl);
    if (profileUrl.isNotEmpty) {
      try {
        Response1.Response<List<int>> rs = await client.get<List<int>>(profileUrl, options: Options(responseType: ResponseType.bytes, extra: {'endpoint': 'access_token'}));
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path + "/cc_profile.jpg";
        File avatarFile = await File(path).writeAsBytes(rs.data!);
        CubeFile cfile = await uploadFile(avatarFile, isPublic: false);
        user.avatar = cfile.uid;
        await updateUser(user);
        print(user.avatar.toString());
      } on DioError catch (e) {
        print(e.toString());
        return {};
      }
    } else {
      print('PROFILE PICTURE NOT FOUND...');
    }
    await updateConnectyCubeIdToUser(user.id!);
  }

  /// SUBSCRIPTION RELATED
  Future<dynamic> updateSubscription(String userId, Map<String, dynamic> subsciptionInfo) async {
    try {
      var response = await client.patch('$endPoint/users/$userId/usersubscription', data: subsciptionInfo);
      if (response.statusCode == 200) {
        if (response.data['subscriptionplan'] != null) {
          preferencesService.subscriptionInfo = response.data['subscriptionplan'];
          preferencesService.member_count = preferencesService.subscriptionInfo['member_count'];
        }
        return response.data;
      } else {
        return {};
      }
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  // Add COVID Dose
  Future<bool> addCovidDose(String dose, String docid) async {
    try {
      var formData = FormData1.FormData.fromMap({'dose_name': dose});
      var response = await client.patch('$endPoint/usercovid/$docid/addcoviddose', data: formData);
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Update COVID dose
  Future<bool> edit_covid_dose(String doseid, String dosename) async {
    try {
      var formData = FormData1.FormData.fromMap({'dose_name': dosename});
      var response = await client.patch('$endPoint/coviddose/$doseid', data: formData);
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Get Covid does list
  Future<List<dynamic>> getdoeslist() async {
    try {
      var response = await client.get('$endPoint/coviddose');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  //Add Birth details
  Future<bool> addBirthDetails(Map<String, dynamic> postParams, String objId) async {
    try {
      var formData = FormData1.FormData.fromMap(postParams);
      var response = await client.patch('$endPoint/uservaccine/$objId/addmemberbirthdetails', data: formData);
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Get SubscriptionsList
  Future<List<dynamic>> getSubscriptionsList() async {
    try {
      var response = await client.get('$endPoint/subscriptionplans');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Relations List API
  Future<List<dynamic>> getRelations() async {
    try {
      var response = await client.get('$endPoint/list_management/62395f7ab1926b5884e25fbb');
      return response.data['dropdown_fields'];
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get notification
  Future<List<dynamic>> getNotifications(String userid, String roleId) async {
    try {
      var response = await client.get('$endPoint/notification?user_Id=$userid&role_id=$roleId');
      preferencesService.notificationStreamCount.value = response.data['count'].toString();
      List<dynamic> notification = response.data['notifications'];
      //preferencesService.notificationListStream!.value = notification.expand((element) => element).toList();
      preferencesService.notificationListStream!.value = notification;
      return notification;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

//SET PATCH notification isviewed to true
  Future<dynamic> setNotifications(String userid, String roleId) async {
    try {
      preferencesService.notificationStreamCount.value = "0";
      List<dynamic> notification = preferencesService.notificationListStream!.value!;
      dynamic? response;

      response = await client.patch('$endPoint/notification?user_Id=$userid&role_id=$roleId');
      return response;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

//Doctor//////////////
// Doctor Details Fetch
  Future<List<dynamic>> getDoctorDetails(String userid) async {
    try {
      var response = await client.get('$endPoint/doctorprofile/doctordetails?user_id=$userid');
      print(response.data);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Doctor Educational Details add
  Future<bool> addDoctorDetails(String docId, Map<String, dynamic> educationInfo, List<String> filePath) async {
    try {
      Map<String, dynamic> post = Map.from(educationInfo);
      List path = [];
      if (filePath.length > 0) {
        for (int i = 0; i < filePath.length; i++) {
          String filename = filePath[i].split('/').last;
          var check = await MP1.MultipartFile.fromFile(filePath[i], filename: filename);
          path.add(check);
        }
      }
      post['attach_record'] = path;
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/doctorprofile/$docId/profileinformation_add', data: formData);
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

// Update Doctor Educational Details.
  Future<bool> editDoctorDetails(String docId, Map<String, dynamic> educationInfo, List<String> filePath) async {
    try {
      Map<String, dynamic> post = Map.from(educationInfo);
      List path = [];
      if (filePath.length > 0) {
        for (int i = 0; i < filePath.length; i++) {
          String filename = filePath[i].split('/').last;
          var check = await MP1.MultipartFile.fromFile(filePath[i], filename: filename);
          path.add(check);
        }
      }
      post['attach_record'] = path;
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/doctorprofile/$docId/profileinformation_edit', data: formData);
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

// Update/Remove Doctor Details.
  Future<bool> deleteDoctorDetails(String docId, String dataId, String title) async {
    try {
      var response = await client.patch('$endPoint/doctorprofile/$docId/profileinformation_delete?profile_information=$title&information_Id=$dataId');
      await getStageProfile(preferencesService.userId);
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Doctor Clinic Details add
  Future<bool> addDoctorClinicDetails(String docId, Map<String, dynamic> clinicdata, List<String> docUrl, List<String> clinicUrl) async {
    try {
      Map<String, dynamic> post = Map.from(clinicdata);

      List docUrls = [];
      if (docUrl.length > 0) {
        for (int i = 0; i < docUrl.length; i++) {
          String filename = docUrl[i].split('/').last;
          var check = await MP1.MultipartFile.fromFile(docUrl[i], filename: filename);
          docUrls.add(check);
        }
      }
      List path = [];
      if (clinicUrl.length > 0) {
        for (int i = 0; i < clinicUrl.length; i++) {
          String filename = clinicUrl[i].split('/').last;
          var check = await MP1.MultipartFile.fromFile(clinicUrl[i], filename: filename);
          path.add(check);
        }
      }

      post['id_proof'] = docUrls;
      post['clinic_image'] = path;

      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/doctorprofile/$docId/addclinic', data: formData);
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

// Doctor Clinic Details Update
  Future<bool> updateDoctorClinicDetails(String docId, Map<String, dynamic> clinicdata, List<String> docUrl, List<String> clinicUrl) async {
    try {
      Map<String, dynamic> post = Map.from(clinicdata);

      List filePath = [];
      if (docUrl.length > 0) {
        for (int i = 0; i < docUrl.length; i++) {
          String filename = docUrl[i].split('/').last;
          var check = await MP1.MultipartFile.fromFile(docUrl[i], filename: filename);
          filePath.add(check);
        }
        post['id_proof'] = filePath;
      }

      List path = [];
      if (clinicUrl.length > 0) {
        for (int i = 0; i < clinicUrl.length; i++) {
          String filename = clinicUrl[i].split('/').last;
          var check = await MP1.MultipartFile.fromFile(clinicUrl[i], filename: filename);
          path.add(check);
        }
        post['clinic_image'] = path;
      }

      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/doctorprofile/$docId/editclinic', data: formData);
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Get Specialization
  Future<List<dynamic>> getSpecialization() async {
    try {
      var response = await client.get('$endPoint/list_management/62396032b1926b5884e25fd1');
      return response.data['dropdown_fields'];
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get Languageknown
  Future<List<dynamic>> getLanguageknown() async {
    try {
      var response = await client.get('$endPoint/languageknown');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get Graduate Levels
  Future<List<dynamic>> getLevels() async {
    try {
      var response = await client.get('$endPoint/list_management/62396269b1926b5884e26009');
      return response.data['dropdown_fields'];
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get Graduate Levels
  Future<List<dynamic>> getQualification() async {
    try {
      var response = await client.get('$endPoint/list_management/623961fbb1926b5884e25ff9');
      return response.data['dropdown_fields'];
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get Colleges
  Future<List<dynamic>> getColleges(String country) async {
    try {
      var response = await client.get('http://universities.hipolabs.com/search?country=$country');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get Countries
  Future<List<dynamic>> getCountryState() async {
    try {
      var response = await client.get('https://countriesnow.space/api/v0.1/countries/states');
      return response.data['data'];
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<dynamic> getStageProfile(String userid) async {
    dynamic levelStates = ['Entry', 'Enhanced', 'Verified', 'SWAR Doctor'];
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String g = prefs.getString('profile_id').toString();
      g = preferencesService.doctorInfo['_id'];
      //var response = await client.get('$endPoint/doctorprofile/6203508c4e8f260033cea46f');
      var response = await client.get('$endPoint/doctorprofile/$g');
      //await _prefs!.setString(prefUserLogin, cubeUser.login!);
      //doctorprofile/doctordetails?user_id=$userid
      // var response = await client.get('$endPoint/doctorprofile/doctordetails?user_id=$userid');
      if (response.data != null) {
        dynamic getStage = response.data;
        String stageLevel = getStage['stage'] != null ? getStage['stage'] : '';
        locator<PreferencesService>().doctorStageValue.value = stageLevel;
        preferencesService.clinicListStream!.value = getStage['clinic_details'];
        int ind = levelStates.indexWhere((item) => item.toLowerCase() == stageLevel.toLowerCase());
        preferencesService.stage_level_count = ind + 1;
        Future<bool> token = prefs.setString('profile_level', stageLevel);

        return response.data;
      } else
        return [];
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<bool> addEsign(
    String docId,
    String esignPath,
  ) async {
    try {
      Map<String, dynamic> post = {};
      if (esignPath != null && esignPath.isNotEmpty) {
        String filename = esignPath.split('/').last;
        post['attach_esign'] = await MP1.MultipartFile.fromFile(esignPath, filename: filename);
      }

      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/doctorprofile/$docId/esign', data: formData);
      return true;
    } on DioError catch (e) {
      return false;
    }
  }

// Get Colleges Countries
  Future<List<dynamic>> getCollegesCountries() async {
    try {
      var response = await client.get('$endPoint/auth/country_college_list');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get Colleges
  Future<List<dynamic>> getCollegesList(String country) async {
    try {
      var response = await client.get('$endPoint/auth/country_college_list?country=$country');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<dynamic> downloadDoctorFile(String docId) async {
    try {
      var response = await client.get('$endPoint/doctorprofile/$docId/doctor_download_file');
      return response.data;
    } on DioError catch (e) {
      return {};
    }
  }

  Future<dynamic> updatedoctorProfile(String userid, Map<String, dynamic> userInfo, List<String> certificatePath) async {
    try {
      Map<String, dynamic> post = Map.from(userInfo);

      List path = [];
      if (certificatePath.length > 0) {
        for (int i = 0; i < certificatePath.length; i++) {
          String certificateFilename = certificatePath[i].split('/').last;
          var check = await MP1.MultipartFile.fromFile(certificatePath[i], filename: certificateFilename);
          path.add(check);
        }
      }

      post['certificate'] = path;
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/users/$userid', data: formData);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<List<dynamic>> getAllUserList() async {
    try {
      var response = await client.get('$endPoint/users/userlist?role_id=6128a673b71d012678336f4d');
      String userid = preferencesService.userId;
      List<dynamic> getUsr = response.data;
      List<dynamic> friendslist = preferencesService.friendsListStream!.value!;
      getUsr.removeWhere((item) => item['_id'] == userid);
      for (int i = 0; i < friendslist.length; i++) {
        dynamic removeData = friendslist[i];
        getUsr.removeWhere((item) => item['_id'] == removeData['user_Id']);
      }

      preferencesService.usersListStream!.value = getUsr;
      await getContactAllUserList();
      return getUsr;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get userList
  Future<List<dynamic>> getContactAllUserList() async {
    try {
      var response = await client.get('$endPoint/users');
      List<dynamic> getUsr = response.data['records'];
      preferencesService.contactusersListStream!.value = getUsr;

      return getUsr;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get Invited userList
  Future<List<dynamic>> getInviteUserList(String userId) async {
    try {
      var response = await client.get('$endPoint/notification/userinvitelist?user_id=$userId');
      List<dynamic> getUsr = response.data;
      preferencesService.userInviteListStream!.value = getUsr;
      return getUsr;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

//http://localhost:3000/api/users/621a1c48346014002fd04bae/olduserinvitenotification?user_id=61a9ab96645c96002f88ae84

  // post invite  SWARuserList
  Future<dynamic> inviteSwarUser(String receiverId) async {
    try {
      String userid = preferencesService.userId;
      var response = await client.post('$endPoint/users/$userid/olduserinvitenotification?user_id=$receiverId');
      await getInviteUserList(userid);
      //usersListStreamCount
      // List<dynamic> getUsr = response.data['records'];
      // preferencesService.usersListStream!.value = getUsr;
      // response.data['records'].expand((element) => element).toList();
      getAllUserList();
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }
  //http://localhost:3000/api/users/newuserinvitelink?mobilenumber=918270796750

  //post params
  //postMessage, inviteLink,name, email/mobilenumber

  // post invite  for contact_new user
  Future<dynamic> inviteNewUser(Map<String, dynamic> postParams) async {
    try {
      String userid = preferencesService.userId;
      Map<String, dynamic> post = Map.from(postParams);
      FormData1.FormData postParams1 = FormData1.FormData.fromMap(post);
      var response = await client.post('$endPoint/users/newuserinvitelink', data: postParams1);
      await getInviteUserList(userid);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<dynamic> inviteNewContactUser(String contactNumber, String email, Map<String, dynamic> postParams) async {
    try {
      String userid = preferencesService.userId;
      Map<String, dynamic> post = Map.from(postParams);
      FormData1.FormData postParams1 = FormData1.FormData.fromMap(post);

      var response = email.isEmpty
          ? await client.post('$endPoint/users/newuserinvitelink?mobilenumber=$contactNumber', data: postParams1)
          : contactNumber.isEmpty
              ? await client.post('$endPoint/users/newuserinvitelink?email=$email', data: postParams1)
              : await client.post('$endPoint/users/newuserinvitelink?mobilenumber=$contactNumber&email=$email', data: postParams1);

      //usersListStreamCount
      // List<dynamic> getUsr = response.data['records'];
      // preferencesService.usersListStream!.value = getUsr;
      // response.data['records'].expand((element) => element).toList();
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  //Remove device id while signout
  Future removeUserDeviceToken(String userid, String devicetoken) async {
    try {
      var response = await client.post('$endPoint/users/' + userid + '/removedeviceid', data: {'user_Id': userid, 'user_device_Id': devicetoken});
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  //content Management for - Alert messages
  Future getalertmessageslist() async {
    try {
      var response = await client.get('$endPoint/dynamic_alert_messages');
      preferencesService.alertContentList = response.data;

      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  // Get Doctor Stages
  Future<List<dynamic>> getStages() async {
    try {
      var response = await client.get('$endPoint/content_management/6244032680a5ed0bd0e2267a');
      return response.data['staging'];
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  //add sessions-Doctor
  Future<bool> addSessions(Map<String, dynamic> postParams, String userId, dynamic getDates) async {
    try {
      postParams['slot_date'] = getDates;
      var formData = FormData1.FormData.fromMap(postParams);
      var response = await client.post('$endPoint/sessionslot', data: formData);
      print("asdfsadf" + response.toString());
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Get session-doctor
  Future<List<dynamic>> getSessionsByType(String userId, String startDate, String endDate, String serviceType) async {
    try {
      if (serviceType.isNotEmpty && serviceType != null) {
        var response = await client.get('$endPoint/sessionslot/slots_timing_list?doctor_id=$userId&start_slot_date=$startDate&end_slot_date=$endDate&services_type=$serviceType');
        return response.data;
      } else {
        var response = await client.get('$endPoint/sessionslot/slots_timing_list?doctor_id=$userId&start_slot_date=$startDate&end_slot_date=$endDate');
        return response.data;
      }
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  //patch sessions-doctor
  Future<bool> updateSessions(Map<String, dynamic> postParams, String userId) async {
    try {
      var formData = FormData1.FormData.fromMap(postParams);
      var response = await client.patch('$endPoint/sessionslot', data: formData);
      print("asdfsadf" + response.toString());
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Get session-clinic base-doctor
  Future<List<dynamic>> getSessionsByclinic(String userId, String startDate, String endDate, String serviceType, String clinicName) async {
    try {
      var response = await client.get('$endPoint/sessionslot/slots_timing_list?doctor_id=$userId&start_slot_date=$startDate&end_slot_date=$endDate&services_type=$serviceType&clinic_Id=$clinicName');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get Specialization
  Future<List<dynamic>> getTopSpecialiation() async {
    try {
      var response = await client.get('$endPoint/specialization');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get DoctorList
  Future<List<dynamic>> getDoctorList() async {
    try {
      var response = await client.get('$endPoint/doctorprofile/doctorlist');
      return response.data['docquery'];
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

// Get Doctor Rating  & Patient Visit count Api
  Future<List<dynamic>> getDoctorRating() async {
    try {
      var response = await client.get('$endPoint/bookingslot/patientslist_per_doctor');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

// Get homevisit doctor list
  Future<List<dynamic>> getHomevistDoctorList(String docid) async {
    try {
      var response = await client.get('$endPoint/doctorprofile/doctorlist?doctor_services=Home visit&login_role_id=$docid');
      return response.data['docquery'];
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }
  //Doctor view

  Future<dynamic> getDoctorProfile(String docid) async {
    try {
      var response = await client.get('$endPoint/doctorprofile/$docid');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

//Sessoin slot

  Future<List<dynamic>> getSessionsSlots(String userId, String startDate) async {
    try {
      var response = await client.get('$endPoint/sessionslot/userview_slotlist?doctor_id=$userId&start_slot_date=$startDate');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<dynamic> bookAppoinment(String docId, dynamic userInfo) async {
    try {
      Map<String, dynamic> post = Map.from(userInfo);
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/sessionslot/$docId/patientbook', data: formData);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<dynamic> cancelBooking(String docId, Map<String, dynamic> userInfo) async {
    try {
      Map<String, dynamic> post = Map.from(userInfo);
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/bookingslot/$docId/slot_booking_status', data: formData);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  //Razor pay create order
  Future<dynamic> createrazorpayorder(Map<String, dynamic> razorpayorderInfo) async {
    try {
      var response = await client.post('$endPoint/auth/createrazorpayorder', data: {'amount': razorpayorderInfo['amount'], 'currency': razorpayorderInfo['currency'], 'receipt': razorpayorderInfo['receipt']});
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future paymentinfoupdate(String slotId, dynamic paymentInfo) async {
    try {
      Map<String, dynamic> post = Map.from(paymentInfo);
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/bookingslot/$slotId', data: formData);
      return response.statusCode;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future getoffers() async {
    try {
      var response = await client.get('$endPoint/admin_offers');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  //Get Patient List of Bookings
  Future getBookingList(String memberid) async {
    try {
      var response = await client.get('$endPoint/users/$memberid/bookings');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Update Doctor Fees
  Future updateFeesTable(dynamic feesData, String docId) async {
    try {
      var response = await client.patch('$endPoint/doctorprofile/$docId/profileinformation_edit', data: feesData);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  // Add Offers
  Future addOfferData(dynamic offerData, String docId, String imagePath) async {
    try {
      Map<String, dynamic> post = Map.from(offerData);

      if (imagePath.isNotEmpty) {
        String filename = imagePath.split('/').last;
        post['attach_record'] = await MP1.MultipartFile.fromFile(imagePath, filename: filename);
      }
      var formData = FormData1.FormData.fromMap(post);

      var response = await client.patch('$endPoint/doctorprofile/$docId/profileinformation_add', data: formData);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  // Update Offers
  Future updatefferData(dynamic offerData, String docId, String imagePath) async {
    try {
      Map<String, dynamic> post = Map.from(offerData);

      if (imagePath.isNotEmpty) {
        String filename = imagePath.split('/').last;
        post['attach_record'] = await MP1.MultipartFile.fromFile(imagePath, filename: filename);
      }
      var formData = FormData1.FormData.fromMap(post);

      var response = await client.patch('$endPoint/doctorprofile/$docId/profileinformation_edit', data: formData);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  // Update/Remove Doctor Details.
  Future<bool> deleteOfferDetails(String docId, String dataId, String title) async {
    try {
      var response = await client.patch('$endPoint/doctorprofile/$docId/profileinformation_delete?profile_information=$title&offers_id=$dataId');
      return true;
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future getDoctor_offers(String userId) async {
    try {
      var response = await client.get('$endPoint/doctoroffers?user_Id=$userId');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get session-doctor
  Future<List<dynamic>> getappointment(String doctorId, String listMode) async {
    try {
      var response = await client.get('$endPoint/bookingslot?doctor_id=$doctorId&listMode=$listMode');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<dynamic> acceptAppointment(String docId, Map<String, dynamic> userInfo) async {
    try {
      Map<String, dynamic> post = Map.from(userInfo);
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/bookingslot/$docId/slot_booking_status', data: formData);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<dynamic> cancelAppointment(String docId, Map<String, dynamic> userInfo) async {
    try {
      Map<String, dynamic> post = Map.from(userInfo);
      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/bookingslot/$docId/slot_booking_status', data: formData);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  //Get Admin Offers
  Future getAdminOffersist() async {
    try {
      var response = await client.get('$endPoint/admin_offers');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get patient details=doctor
  Future<dynamic> getPatientsList(String userId) async {
    try {
      //var response = await client.get('$endPoint/bookingslot/particular_patient_details?user_id=$userId');
      var response = await client.get('$endPoint/bookingslot?doctor_id=$userId&listMode=Accepted List');
      //https://testapi02.swardoctor.com/api/bookingslot?doctor_id=627f59de3acb54002e821f63&listMode=Accepted List
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

// Get booked particular patient detail
  Future<dynamic> getBookedPatientDetails(String patientUserId) async {
    try {
      String userId = preferencesService.userId;
      // var response = await client.get('$endPoint/bookingslot/particular_patient_details?user_id=$userId&patient_id=$patient_userId');

      var response = await client.get('$endPoint/bookingslot?doctor_id=$userId&patient_id=$patientUserId&isBooked=true');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  //add patient document
  Future<bool> addPatientDocument(postParams, String notesPath) async {
    try {
      Map<String, dynamic> post = Map.from(postParams);
      if (notesPath.isNotEmpty) {
        String filename = notesPath.split('/').last;
        post['fileupload'] = await MP1.MultipartFile.fromFile(notesPath, filename: filename);
      }

      var formData = FormData1.FormData.fromMap(post);
      var response = await client.patch('$endPoint/bookingslot/upload_waitingroom_documents', data: formData);
      return true;
    } on DioError catch (e) {
      return false;
    }
  }

  //get patient Document
  Future<dynamic> getPatientDocument(String memberid, String doctorId) async {
    try {
      var response = await client.get('$endPoint/bookingslot/particular_patient_details?user_id=$doctorId&patient_id=$memberid');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  //cancel Appointment
  Future<dynamic> cancelPatientAppoinment(String docId, Map<String, dynamic> userInfo) async {
    try {
      Map<String, dynamic> post = Map.from(userInfo);
      var response = await client.patch('$endPoint/sessionslot/$docId/patientbook');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

//get default session timing-doctor
  Future<dynamic> getetSessionsDay() async {
    try {
      var response = await client.get('$endPoint/sessionday');
      dynamic s = response.data[0];
      return response.data[0];
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

//Currency Conveter Api
  Future currencyConveter(String from, String to, double amount) async {
    try {
      var response = await client.get('$endPoint/doctorprofile/currency_converter?from_country=$from&to_country=$to&amount=$amount');
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<dynamic> doctorRatingUpdate(dynamic ratingData) async {
    try {
      var response = await client.patch('$endPoint/bookingslot/upload_patients_rating', data: ratingData);
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<dynamic> getSubscriptionWeb(String planId) async {
    try {
      // FormData1.FormData formData = FormData.fromMap({
      //   "subscriptionplan": planId,
      // });
      var response = await client.post('$endPoint/auth/razorpay', data: {
        "subscriptionplan": planId,
      });
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<dynamic> updateSubscriptionWeb(String userId, Map<String, dynamic> subsciptionInfo) async {
    try {
      var response = await client.patch('$endPoint/users/$userId/usersubscription', data: subsciptionInfo);
      if (response.statusCode == 200) {
        if (response.data['subscriptionplan'] != null) {
          preferencesService.subscriptionInfo = response.data['subscriptionplan'];
          preferencesService.member_count = preferencesService.subscriptionInfo['member_count'];
        }

        return response.data;
      } else {
        return {};
      }
    } on DioError catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<dynamic> getSubscription(String userId) async {
    try {
      var response = await client.get('$endPoint/users/$userId/getusersubscription');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<dynamic> cancelSubscriptionWeb(String subIdId) async {
    try {
      var response = await client.post('$endPoint/auth/cancelrazorpay', data: {
        "subscriptionId": subIdId,
      });
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }
  //Check dynmic link Ref id for doctor

  Future<bool> DoctorcheckRefId(String userId, String refId) async {
    try {
      var response = await client.get('$endPoint/users/$userId/doctor_invitecheckreference?reference_id=$refId');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> Doctoracceptinvite(String userId, String RefId, String feedId, String status) async {
    try {
      var response = await client.get('$endPoint/users/$userId/doctor_invitestatus?reference_id=$RefId&invite_status=$status&notificationId=$feedId');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Cancel Request

  Future<bool> Cancelrequest(String userId, String RefId, String notificationId) async {
    try {
      var response = await client.get('$endPoint/users/$userId/invite_cancel?reference_id=$RefId&notificationId=$notificationId');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Get notification using inviter id
  Future<List<dynamic>> getRequestedList(String inviterId, String roleId) async {
    try {
      var response = await client.get('$endPoint/notification?inviter_Id=$inviterId&role_id=$roleId');
      preferencesService.notificationStreamCount.value = response.data['count'].toString();
      List<dynamic> notification = response.data['notifications'];
      //preferencesService.notificationListStream!.value = notification.expand((element) => element).toList();
      preferencesService.notificationListStream!.value = notification;
      return notification;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }

  //Accepted List

  Future<List<dynamic>> acceptedList(String doctorId) async {
    try {
      var response = await client.get('$endPoint/users/patient_chatlist?doctor_Id=$doctorId');
      List<dynamic> addedDoctors = response.data;
      preferencesService.doctorsListStream!.value = addedDoctors.expand((element) => element).toList();
      return response.data;
    } on DioError catch (e) {
      print(e.toString());
      return [];
    }
  }
}

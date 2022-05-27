import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';

class StartViewModel extends BaseViewModel {
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();
  FlutterAppAuth appAuth = FlutterAppAuth();

  String _authToken = '';
  // String phoneSignInSignup = 'https://swaradb2c.b2clogin.com/swaradb2c.onmicrosoft.com/B2C_1A_B2C_1_PH_SUSI/v2.0/';
  // String emailSignup = 'https://swaradb2c.b2clogin.com/swaradb2c.onmicrosoft.com/B2C_1_SWAR_Email_SignUp/v2.0/';
  // String emailSignin = 'https://swaradb2c.b2clogin.com/swaradb2c.onmicrosoft.com/B2C_1_SWAR_Email_SignIn/v2.0/';

  String phoneSignInSignup = 'https://swartestadb2c.b2clogin.com/swartestadb2c.onmicrosoft.com/B2C_1A_B2C_1_PH_SUSI/v2.0/';
  String emailSignup = 'https://swartestadb2c.b2clogin.com/swartestadb2c.onmicrosoft.com/B2C_1_SWAR_Email_SignUp/v2.0/';
  String emailSignin = 'https://swartestadb2c.b2clogin.com/swartestadb2c.onmicrosoft.com/B2C_1_SWAR_Email_SignIn/v2.0/';

  Future<bool> azureSignup(String type, bool isSignup) async {
    String issuerurl = phoneSignInSignup;
    if (type == 'email') {
      issuerurl = isSignup ? emailSignup : emailSignin;
    }

    // AuthorizationTokenRequest request = AuthorizationTokenRequest('5c73d323-db67-44f4-a04a-12aa9c0bfede', 'msauth.com.kat.swarapp://auth/',
    AuthorizationTokenRequest request = AuthorizationTokenRequest('020dd9a6-3518-446d-8983-5acc163e7365', 'msauth.com.kat.swarapp://auth/',
        issuer: issuerurl,
        scopes: [
          "offline_access",
          "profile",
          "email",
          "phone",
          // '5c73d323-db67-44f4-a04a-12aa9c0bfede',
          '020dd9a6-3518-446d-8983-5acc163e7365',
        ],
        promptValues: ['login'],
        //discoveryUrl: "https://swaradb2c.b2clogin.com/tfp/swaradb2c.onmicrosoft.com/B2C_1_SWAR_Signin_Signup/v2.0/.well-known/openid-configuration",
        allowInsecureConnections: true);

    try {
      AuthorizationTokenResponse? result = await appAuth.authorizeAndExchangeCode(request);
      print(result!.idToken);

      Map<String, dynamic> decodedToken = JwtDecoder.decode(result.idToken!);
      print(decodedToken);
      _authToken = result.accessToken!;
      if (decodedToken['sub'] != null) {
        String oid = decodedToken['sub'];
        await preferencesService.setUserInfo('token', result.accessToken!);

        if (decodedToken['emails'] != null) {
          List emails = decodedToken['emails'];
          if (emails.length > 0) {
            String useremail = emails.first;
            await preferencesService.setUserInfo('email', useremail);
            preferencesService.email = useremail;
            print(useremail);
            preferencesService.isEmailLogin = true;
            await preferencesService.setUserInfo('userkey', 'email=$useremail');
          }
        }

        if (decodedToken['nationalNumber'] != null && !preferencesService.isEmailLogin) {
          await preferencesService.setUserInfo('phone', decodedToken['nationalNumber']);
          preferencesService.phone = decodedToken['nationalNumber'];
          preferencesService.isPhoneLogin = true;
          await preferencesService.setUserInfo('userkey', 'mobilenumber=${decodedToken['nationalNumber']}');
        }
        if (decodedToken['countryCode'] != null) {
          await preferencesService.setUserInfo('countryCode', decodedToken['countryCode']);
        }

        // Adding token validation :: START
        final response = await apiService.tokenValidation(result.accessToken!);
        if (response['token'] != null) {
          dynamic tokenObject = response['token'];
          if (tokenObject['accessToken'] != null) {
            await preferencesService.setUserInfo('swartoken', tokenObject['accessToken']);
            await preferencesService.setUserInfo('refreshtoken', tokenObject['refreshToken']);
          }
          //  else {
          //   return false; // If the token doesn't exist, then sending the failed state
          // }

          print(response);
          await preferencesService.setUserInfo('oid', oid);
          //bool isEmailLogin = false;

          // if (decodedToken['emails'] != null) {
          //   List emails = decodedToken['emails'];
          //   if (emails.length > 0) {
          //     String useremail = emails.first;
          //     await preferencesService.setUserInfo('email', useremail);
          //     preferencesService.email = useremail;
          //     print(useremail);
          //     isEmailLogin = true;
          //     await preferencesService.setUserInfo('userkey', 'email=$useremail');
          //   }
          // }
          // if (decodedToken['nationalNumber'] != null && !isEmailLogin) {
          //   await preferencesService.setUserInfo('phone', decodedToken['nationalNumber']);
          //   preferencesService.phone = decodedToken['nationalNumber'];
          //   await preferencesService.setUserInfo('userkey', 'mobilenumber=${decodedToken['nationalNumber']}');
          // }
          // if (decodedToken['countryCode'] != null) {
          //   await preferencesService.setUserInfo('countryCode', decodedToken['countryCode']);
          // }
        }

        // Adding token validation :: END
        return true;
      }

      return false;
    } on PlatformException catch (err) {
      print(err.toString());
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  //Using object id
  // Future<bool> checkUserExist() async {
  //  // String oid = await preferencesService.getUserInfo('userkey');
  //  String usr_email=await preferencesService.getUserInfo('emails');
  //   print('==============***********************user is==='+preferencesService.getUserInfo('emails').toString());
  //   if (usr_email.length > 0) {
  //     final response = await apiService.checkUserExist(usr_email);
  //     return response;
  //   }
  //   return false;
  // }
  Future<dynamic> checkUserExist() async {
    await apiService.getalertmessageslist();
    String email = await preferencesService.getUserInfo('email');
    String mobile = await preferencesService.getUserInfo('phone');
    if (email != "") {
      final response = await apiService.checkUserEmailExist(email);
      return response;
    } else {
      if (mobile != "") {
        final response = await apiService.checkUserMobileExist(mobile);
        return response;
      }
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_voip_push_notification/flutter_voip_push_notification.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:swarapp/app/consts.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/app/configs.dart' as config;
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/ui/communication/chat_dialog_screen.dart';
import 'package:swarapp/ui/communication/chat_list_view.dart';
import 'package:swarapp/ui/dashboard/dashboard_view.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:uuid/uuid.dart';
import 'package:member_module/src/ui/members/notification_view.dart';
import 'api_services.dart';

PreferencesService preferencesService = locator<PreferencesService>();

//Future<void> _writeData() async {
// void _writeData() async {
//   final directory = await getApplicationDocumentsDirectory();
//   final File _myFile = File('${directory.path}/swar_status.txt');
//   print(directory.path.toString());
//   // If data.txt doesn't exist, it will be created automatically
// // String get_status = await rootBundle.loadString('assets/app_status.txt');

//   await _myFile.writeAsString("backgroundcalls");

//   //await _myFile.writeAsString("");

//   //_textController.clear();
// }

void _writeBgMsgData(String count) async {
  final directorys = await getApplicationDocumentsDirectory();
  final File _myFilebg = File('${directorys.path}/swar_bg_message.txt');
  //print(directorys.path.toString());

  await _myFilebg.writeAsString(count);
}

// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   Map<String, dynamic> data = message.data;
//   if (data.keys.length > 0) {
//     if (data['message'] != null) {
//       String name = '';
//       String msg_count = '';
//       // if(data['badge']!=null){
//       //   msg_count=data['badge'];
//       //   print("badge");
//       // }else if(data['dialog_id']!=null){
//       // msg_count=data['dialog_id'];
//       // }
//       if (data['dialog_id'] != null) {
//         msg_count = data['dialog_id'];
//       }
//       if (data['name'] != null) {
//         name = data['name'];
//       }

//       const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//         'messages_channel_id',
//         'Chat messages',
//         'Chat messages will be received here',
//         importance: Importance.max,
//         priority: Priority.high,
//         showWhen: true,
//         color: Color(0xFFDE2128),
//         // color: Colors.green,
//         icon: '@mipmap/ic_launcher',
//       );
//       const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//       FlutterLocalNotificationsPlugin().show(
//         6543,
//         data['message'],
//         name.isNotEmpty
//             ? data['type'] == 'invite'
//                 ? 'Message from $name'
//                 : '$name'
//             : '',
//         // name.isNotEmpty ? 'Message from $name' : '',
//         platformChannelSpecifics,
//         payload: json.encode(data),
//       );

//       // _writeBgMsgData(msg_count);
//       //onNotificationSelected
//       return;
//     } else {}
//     return;
//   } else {
//     RemoteNotification? data = message.notification;

//     const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'messages_channel_id',
//       'Chat messages',
//       'Chat messages will be received here',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: true,
//       color: Colors.green,
//     );
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//     FlutterLocalNotificationsPlugin().show(
//       6543,
//       "SWAR Doctor",
//       '123223',
//       platformChannelSpecifics,
//       payload: 'sadasd',
//     );
//   }

//   print("Handling a background message");
// }

class PushNotificationService {
  static const TAG = "PushNotificationService";
  static const VOIP_TAG = "PushNotificationService2";
  static PushNotificationService? _instance;
  Future<dynamic> Function(String? payload)? onNotificationClicked;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  PushNotificationService._internal() {
    Firebase.initializeApp();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  static PushNotificationService _getInstance() {
    return _instance ??= PushNotificationService._internal();
  }

  factory PushNotificationService() => _getInstance();

  BuildContext? applicationContext;

  static PushNotificationService get instance => _getInstance();

  FlutterVoipPushNotification _voipPush = FlutterVoipPushNotification();

  init() async {
    if (Platform.isAndroid) {
      _initFcm();
    } else if (Platform.isIOS) {
      _initIosVoIP();
      _initFcm();
    }

    FirebaseMessaging.onMessage.listen((remoteMessage) async {
      processCallNotification(remoteMessage.data);
    });

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    // TODO test after fix https://github.com/FirebaseExtended/flutterfire/issues/4898
    FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
      log('[onMessageOpenedApp] remoteMessage: $remoteMessage', TAG);
      if (onNotificationClicked != null) {
        onNotificationClicked!.call(jsonEncode(remoteMessage.data));
        // Get.to(()=>ChatListView());
      }
    });
  }

  _initIosVoIP() async {
    await _voipPush.requestNotificationPermissions();
    _voipPush.configure(onMessage: onMessage, onResume: onResume);

    _voipPush.onTokenRefresh.listen((token) {
      log('[onTokenRefresh] VoIP token: $token', TAG);
      subscribeVoIP(token);
    });

    _voipPush.getToken().then((token) {
      log('[getToken] VoIP token: $token', TAG);
      if (token != null) {
        subscribeVoIP(token);
      }
    });
  }

  // _initFcm() async {
  //   FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  //   await firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);

  //   //************ */
  //   const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher_foreground');
  //   final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
  //     requestSoundPermission: true,
  //     requestBadgePermission: true,
  //     requestAlertPermission: true,
  //     onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  //   );
  //   final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  //   await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

  //   //********** */

  //   firebaseMessaging.getToken().then((token) {
  //     log('[getToken] FCM token: $token', TAG);
  //     if (!isEmpty(token)) {
  //       subscribe(token!);
  //     }
  //   }).catchError((onError) {
  //     log('[getToken] onError: $onError', TAG);
  //   });

  //   firebaseMessaging.onTokenRefresh.listen((newToken) {
  //     log('[onTokenRefresh] FCM token: $newToken', TAG);
  //     subscribe(newToken);
  //   });
  // }
  _initFcm() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    await firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher_foreground');
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

    String token = '';
    if (Platform.isAndroid) {
      firebaseMessaging.getToken().then((token) {
        log('[getToken] token: $token', TAG);
        subscribe(token!);
      }).catchError((onError) {
        log('[getToken] onError: $onError', TAG);
      });
    } else if (Platform.isIOS) {
      token = (await FirebaseMessaging.instance.getAPNSToken())!;
      if (!isEmpty(token)) {
        subscribe(token);
      }
    }

    // firebaseMessaging.getToken().then((token) {
    //   log('[getToken] FCM token: $token', TAG);
    //   subscribe(token);
    // }).catchError((onError) {
    //   log('[getToken] onError: $onError', TAG);
    // });

    firebaseMessaging.onTokenRefresh.listen((newToken) {
      log('[onTokenRefresh] FCM token: $newToken', TAG);
      subscribe(newToken);
    });
  }

  subscribe(String token) async {
    log('[subscribe] token: $token', PushNotificationService.TAG);

    var savedToken = await SharedPrefs.getSubscriptionToken();
    if (token == savedToken) {
      log('[subscribe] skip subscription for same token', PushNotificationService.TAG);
      return;
    }

    CreateSubscriptionParameters parameters = CreateSubscriptionParameters();
    // parameters.environment = CubeEnvironment.DEVELOPMENT; // TODO for sample we use DEVELOPMENT environment
    bool isProduction = bool.fromEnvironment('dart.vm.product');
    parameters.environment = isProduction ? CubeEnvironment.PRODUCTION : CubeEnvironment.DEVELOPMENT;

    if (Platform.isAndroid) {
      parameters.channel = NotificationsChannels.GCM;
      parameters.platform = CubePlatform.ANDROID;
      parameters.bundleIdentifier = "com.kat.swarapp";
    } else if (Platform.isIOS) {
      parameters.channel = NotificationsChannels.APNS;
      parameters.platform = CubePlatform.IOS;
      parameters.bundleIdentifier = "com.kat.swarapp";
    }

    String? deviceId = await PlatformDeviceId.getDeviceId;
    parameters.udid = deviceId;
    parameters.pushToken = token;

    createSubscription(parameters.getRequestParameters()).then((cubeSubscriptions) {
      log('[subscribe] subscription SUCCESS', PushNotificationService.TAG);
      SharedPrefs.saveSubscriptionToken(token);
      cubeSubscriptions.forEach((subscription) {
        if (subscription.device!.clientIdentificationSequence == token) {
          SharedPrefs.saveSubscriptionId(subscription.id!);
        }
      });
    }).catchError((error) {
      log('[subscribe] subscription ERROR: $error', PushNotificationService.TAG);
    });
  }

  subscribeVoIP(String? token) async {
    // String? pushToken = await FirebaseMessaging.instance.getAPNSToken();
    // print('pushToken >>> $pushToken');

    //log('[subscribe] token: $token', PushNotificationService.TAG);

    // SharedPrefs sharedPrefs = await SharedPrefs.instance.init();
    var savedToken = await SharedPrefs.getSubscriptionToken();
    if (savedToken == token) {
      log('[subscribe] skip subscription for same token', PushNotificationService.VOIP_TAG);
      return;
    }

    bool isProduction = bool.fromEnvironment('dart.vm.product');
    //isProduction = true;
    CreateSubscriptionParameters parameters = CreateSubscriptionParameters();
    parameters.environment = isProduction ? CubeEnvironment.PRODUCTION : CubeEnvironment.DEVELOPMENT;

    if (Platform.isAndroid) {
      parameters.channel = NotificationsChannels.GCM;
      parameters.platform = CubePlatform.ANDROID;
      parameters.bundleIdentifier = "com.kat.swarapp";
    } else if (Platform.isIOS) {
      parameters.channel = NotificationsChannels.APNS_VOIP;
      parameters.platform = CubePlatform.IOS;
      parameters.bundleIdentifier = "com.kat.swarapp";
    }

    String? deviceId = await PlatformDeviceId.getDeviceId;
    parameters.udid = deviceId;
    parameters.pushToken = token;

    createSubscription(parameters.getRequestParameters()).then((cubeSubscription) async {
      log('[subscribe] subscription SUCCESS', PushNotificationService.VOIP_TAG);
      await SharedPrefs.saveSubscriptionToken(token!);
      cubeSubscription.forEach((subscription) async {
        if (subscription.device!.clientIdentificationSequence == token) {
          await SharedPrefs.saveSubscriptionId(subscription.id!);
        }
      });
    }).catchError((error) {
      log('[subscribe] subscription ERROR: $error', PushNotificationService.VOIP_TAG);
    });
  }

  Future<void> unsubscribe() {
    return SharedPrefs.getSubscriptionId().then((subscriptionId) async {
      if (subscriptionId != 0) {
        return deleteSubscription(subscriptionId).then((voidResult) {
          FirebaseMessaging.instance.deleteToken();
          SharedPrefs.saveSubscriptionId(0);
        });
      } else {
        return Future.value();
      }
    }).catchError((onError) {
      log('[unsubscribe] ERROR: $onError', PushNotificationService.TAG);
    });
  }

  //***********************notificateion  */

  Future<dynamic> onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    log('[onDidReceiveLocalNotification] id: $id , title: $title, body: $body, payload: $payload', PushNotificationService.TAG);
    return Future.value();
  }

  showNotificationOnForground(RemoteMessage message) async {
    log('[showNotification] message: $message', PushNotificationService.TAG);
    String _title = "", _body = "", _imgurl = "", _notificationtype = "SINGLE";

    // if (message['aps'] != null) {
    //   if (message['aps']['alert']['title'] != null) {
    //     _title = message['aps']['alert']['title'].toString();
    //   }
    //   if (message['aps']['alert']['body'] != null) {
    //     _body = message['aps']['alert']['body'].toString();
    //   }
    // }

    if (message.data != null) {
      Map<String, dynamic> messageInfo = message.data;
      if (messageInfo['message'] != null) {
        _body = messageInfo['message'] + " From " + messageInfo['caller_name'];
      }
    }

    if (message.notification != null) {
      if (message.notification!.title != null) {
        _title = message.notification!.title.toString();
      }
      if (message.notification!.body != null) {
        _body = message.notification!.body.toString();
      }
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'messages_channel_id',
      'Chat messages',
      'Chat messages will be received here',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: Colors.green,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    FlutterLocalNotificationsPlugin().show(
      6543,
      "SWAR Doctor",
      _body,
      platformChannelSpecifics,
      payload: 'test',
    );
  }

  showNotification(RemoteMessage message) async {
    log('[showNotification] message: $message', PushNotificationService.TAG);
    Map<String, dynamic> data = message.data;

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'messages_channel_id',
      'Chat messages',
      'Chat messages will be received here',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: Colors.green,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    FlutterLocalNotificationsPlugin().show(
      6543,
      "SWAR Doctor",
      data['message'].toString(),
      platformChannelSpecifics,
      payload: jsonEncode(data),
    );
  }

  Future<dynamic> onSelectNotification(String? payload) {
    log('[onSelectNotification] payload: $payload', PushNotificationService.TAG);
    if (onNotificationClicked != null) {
      onNotificationClicked!.call(payload);
    }
    return Future.value();
  }

  Future<dynamic> onNotificationSelected(String? payload, BuildContext? context) async {
    log('[onSelectNotification] payload: $payload', PushNotificationService.TAG);

    //if (context == null) return Future.value();

    log('[onSelectNotification] context != null', PushNotificationService.TAG);

    if (payload != null) {
      await SharedPrefs.getPrefs();
      CubeUser? user = await SharedPrefs.getUser();

      if (user != null) {
        Map<String, dynamic> payloadObject = jsonDecode(payload);
        String? dialogId = payloadObject['dialog_id'];
        if (dialogId != null) {
          log("getNotificationAppLaunchDetails, dialog_id: $dialogId", PushNotificationService.TAG);

          return getDialogs({'id': dialogId}).then((dialogs) {
            if (dialogs?.items != null && dialogs!.items.isNotEmpty) {
              CubeDialog dialog = dialogs.items.first;

              Get.to(() => ChatDialogScreen(user, dialog));
              //Navigator.pushReplacementNamed(context, 'chat_dialog', arguments: {USER_ARG_NAME: user, DIALOG_ARG_NAME: dialog});
            }
          });
        } else {
          Map<String, dynamic> payloadObject = jsonDecode(payload);
          String? typeNotification = payloadObject['type'];
          if (typeNotification == "remainder") {
            preferencesService.notificationStreamCount.value = "0";
            preferencesService.isNotification.value = true;
            final response = await locator<ApiService>().setNotifications(preferencesService.userId, "6128a673b71d012678336f4d");
            Get.to(() => NotificationView());
            preferencesService.isNotification.value = false;

            //  List<dynamic> not = preferencesService.notificationListStream!.value!;

          } else if (typeNotification == 'invite') {
            preferencesService.notificationStreamCount.value = "0";
            preferencesService.isNotification.value = true;
            final response = await locator<ApiService>().setNotifications(preferencesService.userId, "6128a673b71d012678336f4d");
            Get.to(() => NotificationView());
            preferencesService.isNotification.value = false;

            //  List<dynamic> not = preferencesService.notificationListStream!.value!;

          }
        }
      } else {}
    } else {
      return Future.value();
    }

    ////////////////////////////////////////////////////
  }
}

Future<dynamic> onMessage(bool isLocal, Map<String, dynamic> payload) {
  log("[onMessage] received on foreground payload: $payload, isLocal=$isLocal", PushNotificationService.TAG);

  processCallNotification(payload);

  return Future.value();
}

Future<dynamic> onResume(bool isLocal, Map<String, dynamic> payload) {
  log("[onResume] received on background payload: $payload, isLocal=$isLocal", PushNotificationService.TAG);

  return Future.value();
}

processCallNotification(Map<String, dynamic> data) async {
  log('[processCallNotification] message: $data', PushNotificationService.TAG);
  print('-------------------------------');
  print(data.toString());
  print('-------------------------------');
  // String? signalType = data[PARAM_SIGNAL_TYPE];
  // String? sessionId = data[PARAM_SESSION_ID];
  // Set<int> opponentsIds = (data[PARAM_CALL_OPPONENTS] as String).split(',').map((e) => int.parse(e)).toSet();
  if (data[PARAM_SIGNAL_TYPE] != null) {
    String? signalType = data[PARAM_SIGNAL_TYPE];
    String? sessionId = data[PARAM_SESSION_ID];
    Set<int> opponentsIds = (data[PARAM_CALL_OPPONENTS] as String).split(',').map((e) => int.parse(e)).toSet();

    if (signalType == SIGNAL_TYPE_START_CALL) {
      ConnectycubeFlutterCallKit.showCallNotification(
        sessionId: sessionId,
        callType: int.parse(data[PARAM_CALL_TYPE].toString()),
        callerId: int.parse(data[PARAM_CALLER_ID].toString()),
        callerName: data[PARAM_CALLER_NAME],
        opponentsIds: opponentsIds,
      );
    } else if (signalType == SIGNAL_TYPE_END_CALL) {
      ConnectycubeFlutterCallKit.reportCallEnded(sessionId: data[PARAM_SESSION_ID]);
    } else if (signalType == SIGNAL_TYPE_REJECT_CALL) {
      if (opponentsIds.length == 1) {
        CallManager.instance.hungUp();
      }
    }
    return;
  }
  if (data['message'] != null) {
    String name = '';
    if (data['name'] != null) {
      name = data['name'];
    }
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'messages_channel_id',
      'Chat messages',
      'Chat messages will be received here',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: Colors.green,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    if (data['type'] != null) {
      if (data['type'] == 'invite') {
        FlutterLocalNotificationsPlugin().show(
          6543,
          data['message'],
          name.isNotEmpty ? '$name' : '',
          platformChannelSpecifics,
          payload: json.encode(data),
        );
        await locator<ApiService>().getNotifications(preferencesService.userId, '6128a673b71d012678336f4d');
        await locator<ApiService>().getRecentFriends(preferencesService.userId, "60dae3e440f5032614a8d24b");
        //  await locator<ApiService>().getRecentMembers(preferencesService.userId);
      }

      if (data['type'] == 'deletefriend') {
        FlutterLocalNotificationsPlugin().show(
          6543,
          data['message'],
          name.isNotEmpty ? '$name' : '',
          platformChannelSpecifics,
          payload: json.encode(data),
        );
        await locator<ApiService>().getRecentFriends(preferencesService.userId, "60dae3e440f5032614a8d24b");
        // await locator<ApiService>().getRecentMembers(preferencesService.userId);
      }
      if (data['type'] == 'remainder') {
        FlutterLocalNotificationsPlugin().show(
          6543,
          data['message'],
          name.isNotEmpty ? '$name' : '',
          platformChannelSpecifics,
          payload: json.encode(data),
        );

        await locator<ApiService>().getNotifications(preferencesService.userId, '6128a673b71d012678336f4d');
      }

      //  type: 'dicom',
      //       message: 'Dicom upload',
      //       name: 'Dicom upload successfully'
      if (data['type'] == 'dicom') {
        FlutterLocalNotificationsPlugin().show(
          6543,
          data['message'],
          name.isNotEmpty ? '$name' : '',
          platformChannelSpecifics,
          payload: json.encode(data),
        );
      }
    } else {
      FlutterLocalNotificationsPlugin().show(
        6543,
        data['message'],
        name.isNotEmpty && data['type'] == null ? 'Message from $name' : '',
        platformChannelSpecifics,
        payload: json.encode(data),
      );
      print(json.encode(data));
    }
  } else {
    if (data['type'] == 'activityfeed') {
      // FlutterLocalNotificationsPlugin().show(
      //   6543,
      //   "Activityfeed", 'asdfsd',
      //   //name.isNotEmpty ? '$name' : '',
      //   platformChannelSpecifics,
      //   payload: json.encode(data),
      // );

      await locator<ApiService>().getUserFeedsList(preferencesService.userId);
      locator<PreferencesService>().isReloadFeed.value = true;
      //locator<PreferencesService>().isReload.value = true;
    }
    if (data['type'] == 'likes') {
      await locator<ApiService>().getUserFeedsList(preferencesService.userId);
      locator<PreferencesService>().isReloadFeed.value = true;
    }
    if (data['type'] == 'cares') {
      await locator<ApiService>().getUserFeedsList(preferencesService.userId);
      locator<PreferencesService>().isReloadFeed.value = true;
    }
    if (data['type'] == 'donates') {
      await locator<ApiService>().getUserFeedsList(preferencesService.userId);
      locator<PreferencesService>().isReloadFeed.value = true;
    }
    //unlike
    if (data['type'] == 'dislike') {
      await locator<ApiService>().getUserFeedsList(preferencesService.userId);
      locator<PreferencesService>().isReloadFeed.value = true;
    }
    if (data['type'] == 'discare') {
      await locator<ApiService>().getUserFeedsList(preferencesService.userId);
      locator<PreferencesService>().isReloadFeed.value = true;
    }
    if (data['type'] == 'dislike') {
      await locator<ApiService>().getUserFeedsList(preferencesService.userId);
      locator<PreferencesService>().isReloadFeed.value = true;
    }
    if (data['type'] == 'updatecomment') {
      await locator<ApiService>().getUserFeedsList(preferencesService.userId);
      locator<PreferencesService>().isReloadFeed.value = true;
    }
    //updatecomment
  }
}

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated = (
    sessionId,
    callType,
    callerId,
    callerName,
    opponentsIds,
    userInfo,
  ) {
    return sendPushAboutRejectFromKilledState({
      PARAM_CALL_TYPE: callType,
      PARAM_SESSION_ID: sessionId,
      PARAM_CALLER_ID: callerId,
      PARAM_CALLER_NAME: callerName,
      PARAM_CALL_OPPONENTS: opponentsIds.join(','),
    }, callerId);
  };
  ConnectycubeFlutterCallKit.initMessagesHandler();
  print(AppLifecycleState.values);
  Map<String, dynamic> data = message.data;
  if (data['dialog_id'] != null) {
    _writeBgMsgData(data['dialog_id']);
  }

  processCallNotification(message.data);

  return Future.value();
}

Future<void> sendPushAboutRejectFromKilledState(
  Map<String, dynamic> parameters,
  int callerId,
) {
  CubeSettings.instance.applicationId = config.APP_ID;
  CubeSettings.instance.authorizationKey = config.AUTH_KEY;
  CubeSettings.instance.authorizationSecret = config.AUTH_SECRET;
  CubeSettings.instance.accountKey = config.ACCOUNT_ID;
  CubeSettings.instance.onSessionRestore = () async {
    await SharedPrefs.getPrefs();
    CubeUser? user = await SharedPrefs.getUser();
    return createSession(user);
  };

  CreateEventParams params = CreateEventParams();
  params.parameters = parameters;
  params.parameters['message'] = "Reject call";
  params.parameters[PARAM_SIGNAL_TYPE] = SIGNAL_TYPE_REJECT_CALL;
  params.parameters[PARAM_IOS_VOIP] = 1;

  params.notificationType = NotificationType.PUSH;
  params.environment = CubeEnvironment.DEVELOPMENT; // TODO for sample we use DEVELOPMENT environment
  // bool isProduction = bool.fromEnvironment('dart.vm.product');
  // params.environment =
  //     isProduction ? CubeEnvironment.PRODUCTION : CubeEnvironment.DEVELOPMENT;
  params.usersIds = [callerId];

  return createEvent(params.getEventForRequest());
}

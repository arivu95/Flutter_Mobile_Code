import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/call_tone.dart';
import 'package:swarapp/services/pushnotification_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:screen/screen.dart' as stScreen;
import 'package:flutter/foundation.dart' as foundation;
import 'package:swarapp/ui/communication/chat_list_view.dart';
//import 'package:swarapp/ui/members/members_view.dart';
//import 'package:swipe/swipe.dart';
import 'package:flutter/src/foundation/change_notifier.dart';

class ConversationCallScreen extends StatefulWidget {
  final P2PSession _callSession;
  final bool _isIncoming;

  @override
  State<StatefulWidget> createState() {
    return _ConversationCallScreenState(_callSession, _isIncoming);
  }

  ConversationCallScreen(this._callSession, this._isIncoming);
}

class _ConversationCallScreenState extends State<ConversationCallScreen> implements RTCSessionStateCallback<P2PSession> {
  static const String TAG = "_ConversationCallScreenState";
  P2PSession _callSession;
  bool _isIncoming;
  bool _isCameraEnabled = true;
  bool isBg_incoming = false;
//  bool _isSpeakerEnabled = false;
  bool _isSpeakerEnabled = true;
  bool _isMicMute = false;
  final CallManager callManager = locator<CallManager>();
  double aspectRatio = 16 / 9;

  //AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  NavigationService navigationService = locator<NavigationService>();
  // String names = '';
  // String avatarUrl = '';
  List<String> userNames = [];
  List<String?> profileUrls = [];
  String singleCaller = "";
  String single_profile_img = "";
  bool is_mirror = true;
  bool isLoading = true;
  bool isgroupCall = false;
  int count_membr = 0;
  Map<int, RTCVideoRenderer> streams = {};
  bool _isNear = false;
  bool _isSetLock = false;
  bool iscallAdd = false;
  bool isCurrentUserAdded = false;
  CallTone dialtone = locator<CallTone>();
  RTCVideoView? currentUserRenderer;
  RTCVideoRenderer? currentVideoRenderer;
  StreamSubscription<dynamic>? _streamSubscription;
  _ConversationCallScreenState(this._callSession, this._isIncoming);
  String call_Audio_state = "Ringing...";
  String call_Video_state = "Ringing...";
  bool isVideo_useradded = false;
  AudioPlayer player = AudioPlayer();
  AudioCache player_cache = new AudioCache();
  static const alarmAudioPath = "caller_tune.mp3";
  Timer? countdownTimer;
  Duration myDuration = Duration(minutes: 10);
  ValueNotifier minutesDecrementValueNotifier = ValueNotifier(0);
  ValueNotifier secondsDecrementValueNotifier = ValueNotifier(0);
  Future<bool> _willStop() async {
    player.stop(); //change this
    return true;
  }

  openingActions() async {
    //add this
    player.stop();
    player = await player_cache.loop('caller_tune.mp3'); //add this
  }

  // Future<AudioPlayer> playLocalAsset() async {
  //   return await player.play("caller_tune.mp3");
  // }

  @override
  void initState() {
    super.initState();

    CubeUser _cubeUser;
    CallTone dialTone;
    _callSession.onLocalStreamReceived = _addLocalMediaStream;
    _callSession.onRemoteStreamReceived = _addRemoteMediaStream;
    _callSession.onSessionClosed = _onSessionClosed;
    _callSession.setSessionCallbacksListener(this);
    if (preferencesService.isConsultationCall.value) {
      preferencesService.inPipMode!.value = true;
    }

    //_writeData();
//incoming-> usualcall /video call
//outgoing-> usualcall/videocall

    if (_isIncoming) {
      //incomming
      //audioPlayer.stop();
      //FlutterRingtonePlayer.stop();
      setState(() {
        isBg_incoming = false;
        //set speaker  by incomming call
        if (!_isVideoCall()) {
          _isSpeakerEnabled = false;
          _callSession.enableSpeakerphone(_isSpeakerEnabled);
        } else {
          _isSpeakerEnabled = true;
          _callSession.enableSpeakerphone(_isSpeakerEnabled);
        }
      });
      _callSession.acceptCall();
    } else {
      //outgoing...

      // audioPlayer.open(
      //   Audio('assets/caller_tune.mp3'),
      //   autoStart: true,
      //   showNotification: false,
      //   loopMode: LoopMode.single,
      //   volume: 0.2,
      //   //respectSilentMode: true
      // );
      //dialtone.dial_play();

      //player.play(alarmAudioPath);

      // audioManager.setMode(AudioManager.MODE_IN_CALL);

      setState(() {
        //set speaker on-video by outgoing call
        if (!_isVideoCall()) {
          _isSpeakerEnabled = false;
          _callSession.enableSpeakerphone(false);
        } else {
          _isSpeakerEnabled = true;
          _callSession.enableSpeakerphone(true);
        }
      });
      openingActions();
      _callSession.startCall();
    }

    if (!_isVideoCall()) {
      //  listenSensor();
    } else {
      //Wakelock.enable();
    }
    //
    getUserInfos();
  }

//timer
  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    countdownTimer!.cancel();
    //setState(() => countdownTimer!.cancel());
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  void getUserInfos() async {
    PagedResult<CubeUser>? result = await getAllUsersByIds(_callSession.opponentsIds);

    //if _incoming caller id
    var single = await getUserById(widget._callSession.callerId);
    String? callerName = single!.fullName;
    singleCaller = callerName.toString();
    single_profile_img = getPrivateUrlForUid(single.avatar).toString();

    print('>>>>>>>' + singleCaller);
    CubeUser? useragain = await SharedPrefs.getUser();

    print(useragain!.fullName);
    print('sadf>>>>>>' + getPrivateUrlForUid(useragain.avatar).toString());

    if (result!.totalEntries! > 0) {
      List<CubeUser> users = result.items;
      print('>>>>>>' + users.toString());
      print('>>>>>>' + users.length.toString());
      List<String> nm = [];
      List<String?> av = [];
      //chck one to one >>> groupcall
      count_membr = users.length;

      if (_isIncoming) {
        nm.add(singleCaller);
        av.add(single_profile_img);
      }

      for (var user in users) {
        print(user.fullName);
        nm.add(user.fullName!);
        av.add(getPrivateUrlForUid(user.avatar));
        // print(av);
      }

      //  //filter to remove receiver name
      if (_isIncoming) {
        var t = nm.indexOf(useragain.fullName!);
        nm.remove(useragain.fullName);
        av.removeAt(t);
        // av.remove(getPrivateUrlForUid(useragain.avatar));
      }

      setState(() {
        // names = nm.join(', ');
        userNames = nm;
        profileUrls = av;
        //print('====user names'+userNames.toString());
        //  print('===== Profile urls'+profileUrls.toString());
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    streams.forEach((opponentId, stream) async {
      log("[dispose] dispose renderer for $opponentId", TAG);
      await stream.dispose();
    });
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
      //stopTimer();
    }
    // if (preferencesService.isConsultationCall.value) {
    //   stopTimer();
    // }
  }

  Future<void> listenSensor() async {
    double? brightnessVal = await stScreen.Screen.brightness;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (foundation.kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };
    _streamSubscription = ProximitySensor.events.listen((int event) {
      setState(() {
        _isNear = (event > 0) ? true : false;
        if (_isNear) {
          stScreen.Screen.setBrightness(0);
          _isSetLock = true;
        } else {
          stScreen.Screen.setBrightness(brightnessVal!);
          _isSetLock = false;
        }

        // event >0 ? Wakelock.disable() :
        //  Wakelock.enable();
      });

      // if(_isNear) {
      //     Wakelock.disable();

      //   }else{
      //     Wakelock.enable();
      //   }
      //print('SENSE : '+_isNear.toString());
    });
  }

  void redrawCurrentUserRendererOnSwitchCamera() {
    setState(() {
      isCurrentUserAdded = false;
    });
    RTCVideoView rtcVideoView = RTCVideoView(
      currentVideoRenderer!,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      //mirror: true,
      mirror: is_mirror,
    );
    setState(() {
      isCurrentUserAdded = true;
      currentUserRenderer = rtcVideoView;
    });
  }

  void _addLocalMediaStream(MediaStream stream) async {
    log("_addLocalMediaStream", TAG);

    //_onStreamAdd(CubeChatConnection.instance.currentUser!.id!, stream);
    //currentUserRenderer
    RTCVideoRenderer streamRender = RTCVideoRenderer();
    await streamRender.initialize();
    streamRender.srcObject = stream;
    RTCVideoView rtcVideoView = RTCVideoView(
      streamRender,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      //mirror: true,
      mirror: is_mirror,
    );
    //audioPlayer.setVolume(0.4);
    setState(() {
      _isSpeakerEnabled = false;
      _callSession.enableSpeakerphone(_isSpeakerEnabled);

      isCurrentUserAdded = true;
      is_mirror = false;
      currentUserRenderer = rtcVideoView;
      currentVideoRenderer = streamRender;

      // call_state= _isVideoCall() ?"Swar Video Call" : "Swar Voice Call";
    });

    //  _onStreamAdd(CubeChatConnection.instance.currentUser!.id!, stream);
    // setState(() => streams[opponentId] = streamRender);
  }

  // void _addRemoteMediaStream(session, int userId, MediaStream stream) {
  //opponent add
  void _addRemoteMediaStream(BaseCallSession session, int? userId, MediaStream? stream) {
    //audioPlayer.stop();
    //dialtone.dial_stop();
    _willStop();
    //FlutterRingtonePlayer.stop();
    if (!_isVideoCall()) {
      //listenSensor();
    } else {
      //Wakelock.enable();
    }
    setState(() {
      isVideo_useradded = true;
      if (_isVideoCall()) {
        call_Video_state = "Swar Video Call";
      } else {
        call_Audio_state = "Swar Voice Call";
      }
    });

    log("_addRemoteMediaStream for user $userId", TAG);
    _onStreamAdd(userId!, stream!);
  }

  void _removeMediaStream(callSession, int userId) {
    //audioPlayer.stop();
    //dialtone.dial_stop();
    _willStop();
    log("_removeMediaStream for user $userId", TAG);
    //FlutterRingtonePlayer.stop();
    RTCVideoRenderer videoRenderer = streams[userId]!;
    if (videoRenderer == null) return;
    videoRenderer.srcObject = null;
    videoRenderer.dispose();

    setState(() {
      isVideo_useradded = false;
      isBg_incoming = false;
      streams.remove(userId);
    });
  }

// void _getOutOfApp() {

//       if (Platform.isIOS) {
//         try {
//           exit(0);
//         } catch (e) {
//           SystemNavigator.pop();
//         }
//       } else {
//         try {
//           SystemNavigator.pop();
//         } catch (e) {
//           exit(0);
//         }

//       }
//     }

  void _onSessionClosed(session) {
    log("_onSessionClosed", TAG);
    _willStop();
    //audioPlayer.stop();
    //dialtone.dial_stop();
    //FlutterRingtonePlayer.stop();
    //Wakelock.enable();
    //   _writeData();
    setState(() {
      _isSpeakerEnabled = false;
      _callSession.enableSpeakerphone(_isSpeakerEnabled);
      isVideo_useradded = false;
      call_Video_state = "Ringing...";
      call_Audio_state = "Ringing...";
      isBg_incoming = false;
      preferencesService.isConsultantCall.value = false;
    });
    if (preferencesService.isConsultationCall.value) {
      stopTimer();
    }
    _callSession.removeSessionCallbacksListener();

    // if (Get.previousRoute.toLowerCase().contains('incomingcall')) {
    //   locator<NavigationService>().popRepeated(2);
    // } else if (preferencesService.isbgCall == true) {
    //   preferencesService.isbgCall = false;
    //   exit(0);
    //   // navigationService.clearStackAndShow(RoutePaths.Dashboard);

    // } else {
    //   Get.back();
    // }

    //********tried ********* */
    // String ro = Get.previousRoute.toLowerCase();
    // if (Get.previousRoute.toLowerCase().contains('incomingcall')) {
    //   locator<NavigationService>().popRepeated(2);
    // } else if (Get.previousRoute.toLowerCase().contains('membersview')) {
    //   // SystemNavigator.pop();
    //   //Navigator.of(context).pop();
    //   //Navigator.pop(context);
    //   // Get.back();
    //   // String ro = Get.previousRoute.toLowerCase();
    //   //locator<NavigationService>().popRepeated(1);
    //   // Get.back();
    //   Get.to(() => ChatListView());
    //   //locator<NavigationService>().popRepeated(1);
    // } else if (Get.previousRoute.toLowerCase().contains('null')) {
    //   exit(0);
    // } else {
    //   Get.back();
    // }
    //********tried ********* */

//********************* */
    // print('=============previous rout===' + Get.previousRoute.toString());
    // print('=============previous rout===' + Get.currentRoute.toString());
    // String ro = Get.previousRoute.toLowerCase();
    if (Get.previousRoute.toLowerCase().contains('null')) {
      exit(0);
    } else {
      Future.delayed(Duration(milliseconds: 500), () {
        preferencesService.removeOverlay(context);
      });
    }

    // print('=============previous rout===' + Get.previousRoute.toString());
    // print('=============previous rout===' + Get.currentRoute.toString());
    // Get.back();
    //********************* */

    // else {
    //   Get.back();
    // }
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => LoginScreen(),
    //   ),
    // );
  }

  void _onStreamAdd(int opponentId, MediaStream stream) async {
    log("_onStreamAdd for user $opponentId", TAG);
    //audioPlayer.stop();
    //dialtone.dial_stop();
    if (preferencesService.isConsultantCall.value) {
      startTimer();
    }
    preferencesService.isConsultantCall.value == true ? preferencesService.inPipMode!.value = true : preferencesService.inPipMode!.value = false;
    _willStop();
    RTCVideoRenderer streamRender = RTCVideoRenderer();
    await streamRender.initialize();
    streamRender.srcObject = stream;
    //Wakelock.enable();
    // _writeData();
    //audioPlayer.setVolume(0.4);
    setState(() {
      if (_isVideoCall()) {
        _isSpeakerEnabled = true;
        _callSession.enableSpeakerphone(_isSpeakerEnabled);
        call_Video_state = "Swar Video Call";
      } else {
        call_Video_state = "Swar Audio Call";
      }
      iscallAdd = true;
      // else{
      //    _isSpeakerEnabled = false;
      // _callSession.enableSpeakerphone(_isSpeakerEnabled);

      // }
    });
    setState(() => streams[opponentId] = streamRender);
  }

  Widget renderCurrentUserView(BuildContext context) {
    return Container(
      width: 103,
      height: 133,
      decoration: UIHelper.roundedBorderWithColor(4, Colors.black12),
      child: isCurrentUserAdded
          ? currentUserRenderer
          : ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: profileUrls.length == 0 ? SizedBox() : Container(color: Colors.black12, width: 70, height: 70, child: UIHelper.getProfileImageWithInitials(profileUrls[0]!, 60, 60, singleCaller)),
            ),
    );
    //isCurrentUserAdded
  }

  List<Widget> renderStreamsGrid(Orientation orientation) {
    List<Widget> streamsExpanded = streams.entries
        .map(
          (entry) => Expanded(
            child: RTCVideoView(
              entry.value,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              //mirror: true,
              mirror: is_mirror,
            ),
          ),
        )
        .toList();
    if (streams.length > 2) {
      List<Widget> rows = [];

      for (var i = 0; i < streamsExpanded.length; i += 2) {
        var chunkEndIndex = i + 2;

        if (streamsExpanded.length < chunkEndIndex) {
          chunkEndIndex = streamsExpanded.length;
        }

        var chunk = streamsExpanded.sublist(i, chunkEndIndex);

        rows.add(
          Expanded(
            child: orientation == Orientation.portrait ? Row(children: chunk) : Column(children: chunk),
          ),
        );
      }

      return rows;
    }

    return streamsExpanded;
  }

  Widget getAudioAvatarView() {
    return Container(
      // padding: EdgeInsets.all(12),

      child: isLoading
          ? CircularProgressIndicator()
          : Column(
              // mainAxisSize: MainAxisSize.min,

              children: <Widget>[
                  UIHelper.verticalSpaceLarge,
                  UIHelper.verticalSpaceLarge,

                  Text(_isIncoming ? 'Incoming Call' : 'Swar Outgoing Call', style: TextStyle(color: Colors.white)).bold(),
                  //Expanded(child: SizedBox()),
                  SizedBox(
                    width: Screen.width(context) - 100,
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //single_profile_img
                      children: profileUrls.map((e) {
                        int index = profileUrls.indexOf(e);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(40.0),
                              child: Container(
                                  color: Colors.black12,
                                  width: 80,
                                  height: 80,
                                  child:

                                      //onetoone>>>>>

                                      count_membr == 1
                                          ? _isIncoming
                                              ? UIHelper.getProfileImageWithInitials(single_profile_img, 80, 80, singleCaller)
                                              : UIHelper.getProfileImageWithInitials(e!, 80, 80, userNames[index])
                                          :

                                          //groupcall>>>>>>>>

                                          UIHelper.getProfileImageWithInitials(e!, 80, 80, userNames[index]))),
                        );
                      }).toList(),
                    ),
                  ),

                  UIHelper.verticalSpaceSmall,
                  //Text(userNames.join(', ')).bold(),
                  //one to one call
                  count_membr == 1
                      ? Text(!_isIncoming ? userNames.join(', ') : singleCaller, style: TextStyle(color: Colors.white)).bold()
                      :
                      //groupcalled

                      Text(userNames.join(', '), style: TextStyle(color: Colors.white)).bold(),
                  UIHelper.verticalSpaceSmall,

                  //  Text(call_Audio_state,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600)),
                  Expanded(child: SizedBox()),

                  // ClipRRect(borderRadius: BorderRadius.circular(30.0), child: UIHelper.getImage(profileurl, 40, 40))
                ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final days = strDigits(myDuration.inDays);
    // Step 7
    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    minutesDecrementValueNotifier.value = minutes;
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    secondsDecrementValueNotifier.value = seconds;

    return Material(
        child: WillPopScope(
      // onWillPop: () => _onBackPressed(context),
      onWillPop: () async => false,
      child: Stack(
        children: [
          Scaffold(
              backgroundColor: Colors.grey.shade700,
              body: _isVideoCall()
                  ? OrientationBuilder(
                      builder: (context, orientation) {
                        return Stack(
                          children: [
                            Center(
                              child: Container(
                                  child: isVideo_useradded
                                      ? orientation == Orientation.portrait
                                          ? Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: renderStreamsGrid(orientation))
                                          : Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: renderStreamsGrid(orientation))
                                      : currentUserRenderer),
                            ),

                            // Positioned(
                            //   child: Text(userNames.join(', ')).bold(),
                            //   left: 20,
                            //   top: 40,
                            // ),

                            !isVideo_useradded
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: screenSize.width, height: screenSize.height - 440,
                                        // width: scr, height: 100,
                                        decoration: BoxDecoration(
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: Colors.grey.shade500.withOpacity(0.8),
                                            //     spreadRadius: 6,
                                            //     blurRadius: 2,
                                            //     offset: Offset(0, 7), // changes position of shadow
                                            //   ),
                                            // ],
                                            ),
                                        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(40.0),
                                              child: profileUrls.length == 0
                                                  ? SizedBox()
                                                  : Container(color: Colors.black12, width: 100, height: 100, child: UIHelper.getProfileImageWithInitials(profileUrls[0]!, 90, 90, singleCaller)),
                                            ),
                                          ),
                                          UIHelper.verticalSpaceMedium,
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(userNames.join(', '), style: TextStyle(color: Colors.white)).bold(),
                                          ),
                                          UIHelper.verticalSpaceSmall,
                                          //   Text(_isIncoming ? "Swar Video Call" : call_Video_state,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600))
                                        ]),
                                      ),
                                    ],
                                  )
                                : Positioned(
                                    child: renderCurrentUserView(context),
                                    top: 100,
                                    right: 20,
                                  ),
                          ],
                        );
                      },
                    )
                  :
                  //Center(child: preferencesService.inPipMode!.value == false ? getAudioAvatarView() : SizedBox())),
                  Center(
                      // child: preferencesService.inPipMode!.value == false
                      //     ? getAudioAvatarView()
                      //     : SizedBox()

                      child: getAudioAvatarView())),
          Align(
            alignment: Alignment.bottomCenter,
            child: preferencesService.inPipMode!.value == false ? _getActionsPanel() : pipMinmalViewPanel(),
          ),
          // _isVideoCall()
          //     ? SizedBox()
          //     :
          SizedBox(height: 30),
          Container(
              padding: EdgeInsets.only(top: 30),
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.transparent, width: 4.0, style: BorderStyle.solid), //Border.all

              //   borderRadius: BorderRadius.only(
              //     topLeft: Radius.circular(10.0),
              //     topRight: Radius.circular(10.0),
              //     bottomLeft: Radius.circular(10.0),
              //     bottomRight: Radius.circular(10.0),
              //   ),
              //   //BorderRadius.only
              //   /************************************/
              //   /* The BoxShadow widget  is here */
              //   /************************************/
              //   boxShadow: [
              //     BoxShadow(
              //       // color: Colors.grey.shade700,
              //       color: Colors.grey.shade600,
              //       offset: const Offset(
              //         5.0,
              //         5.0,
              //       ),
              //       blurRadius: 10.0,
              //       spreadRadius: 2.0,
              //     ), //BoxShadow
              //     BoxShadow(
              //       color: Colors.transparent,
              //       offset: const Offset(0.0, 0.0),
              //       blurRadius: 0.0,
              //       spreadRadius: 0.0,
              //     ), //BoxShadow
              //   ],
              // ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: Icon(Icons.keyboard_arrow_down),
                      color: Colors.white,
                      iconSize: 30,
                      onPressed: () {
                        preferencesService.enablePip(aspectRatio);
                      }),
                  // preferencesService.inPipMode!.value == false
                  //     ? Positioned(
                  //         top: 20.0,
                  //         left: 8.0,
                  //         child: IconButton(
                  //             icon: Icon(Icons.keyboard_arrow_down),
                  //             color: Colors.white,
                  //             iconSize: 30,
                  //             onPressed: () {
                  //               preferencesService.enablePip(aspectRatio);
                  //             }),
                  //       )
                  //     : SizedBox(),
                  preferencesService.isConsultationCall.value
                      ? Container(
                          child: ValueListenableBuilder(
                              valueListenable: minutesDecrementValueNotifier,
                              builder: (context, $minutes, child) {
                                if (int.parse(minutes) == 9) {
                                  print(secondsDecrementValueNotifier.value);
                                  // if (preferencesService.inPipMode!.value == false) {
                                  //   preferencesService.inPipMode!.value = true;
                                  //   print("PIP MOV===");
                                  // }
                                }

                                // if (int.parse(minutes) == 9) {
                                //   //  print('============nine' + $minutes.toString());
                                //   Fluttertoast.showToast(
                                //     msg: "Call will be endup within $minutes minutes",
                                //     gravity: ToastGravity.TOP,
                                //   );
                                // }

                                //                     else if (int.parse(minutes) == 9 && int.parse(seconds) == 3) {
                                // //need to restrict decline call==while end up with limited time zer0
                                //                     }
                                // return Positioned(
                                //   top: 50.0,
                                //   right: 30.0,
                                //   child: Text('$hours:$minutes:$seconds      ',
                                //       style: TextStyle(
                                //         color: Colors.white,
                                //         fontSize: 15,
                                //       )),
                                // );
                                return Text(
                                  preferencesService.isConsultantCall.value ? '$hours:$minutes:$seconds      ' : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                );
                              }))
                      : SizedBox()
                ],
              ))
        ],
      ),
      // onWillPop: () {
      //   return Future.value(false); // if true allow back else block it
      // },
    ));
  }

  Widget pipMinmalViewPanel() {
    return Container(
        // margin: EdgeInsets.only(bottom: 16, left: 8, right: 8),
        child: ClipRRect(
            // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8), topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            child: InkWell(
      onTap: () {
        preferencesService.disablePip();
      },
      child: Container(
        padding: EdgeInsets.all(4),
        color: Colors.black26,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: FloatingActionButton(
                    mini: true,
                    child: Icon(
                      Icons.call_end,
                      size: 20,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.red,
                    onPressed: () => _endCall(),
                  ),
                ),
                UIHelper.horizontalSpaceSmall,
                count_membr == 1 ? Text(!_isIncoming ? userNames.join(', ') : singleCaller, style: TextStyle(color: Colors.white)).bold() : Text(userNames.join(', '), style: TextStyle(color: Colors.white)).bold(),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: FloatingActionButton(
                    mini: true,
                    elevation: 0,
                    heroTag: "Speacker",
                    child: Icon(
                      Icons.volume_up,
                      size: 20,
                      color: _isSpeakerEnabled ? Colors.white : Colors.grey,
                    ),
                    onPressed: () => _switchSpeaker(),
                    backgroundColor: Colors.black38,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: FloatingActionButton(
                    mini: true,
                    elevation: 0,
                    heroTag: "Mute",
                    child: Icon(
                      Icons.mic,
                      size: 20,
                      color: _isMicMute ? Colors.grey : Colors.white,
                    ),
                    onPressed: () => _muteMic(),
                    backgroundColor: Colors.black38,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    )));
  }

  Widget _getActionsPanel() {
    return Container(
      // margin: EdgeInsets.only(bottom: 16, left: 8, right: 8),
      child: ClipRRect(
        // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32), topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        child: Container(
          padding: EdgeInsets.all(4),
          color: Colors.black26,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: FloatingActionButton(
                      mini: true,
                      child: Icon(
                        Icons.call_end,
                        size: 20,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.red,
                      onPressed: () => _endCall(),
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpaceMedium,
              _isVideoCall()
                  ? Row(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: FloatingActionButton(
                            mini: true,
                            elevation: 0,
                            heroTag: "SwitchCamera",
                            child: Icon(
                              //Icons.switch_video,

                              Icons.flip_camera_android,
                              size: 20,
                              color: _isVideoEnabled() ? Colors.white : Colors.grey,
                            ),
                            onPressed: () => _switchCamera(),
                            backgroundColor: Colors.black38,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: FloatingActionButton(
                            mini: true,
                            elevation: 0,
                            heroTag: "ToggleCamera",
                            child: Icon(
                              // Icons.videocam,
                              Icons.videocam_off,
                              size: 20,
                              color: _isVideoEnabled() ? Colors.white : Colors.grey,
                            ),
                            onPressed: () => _toggleCamera(),
                            backgroundColor: Colors.black38,
                          ),
                        ),
                        // Expanded(
                        //   child: SizedBox(),
                        //   flex: 1,
                        // ),
                        Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: FloatingActionButton(
                            mini: true,
                            elevation: 0,
                            heroTag: "Mute",
                            child: Icon(
                              Icons.mic,
                              size: 20,
                              color: _isMicMute ? Colors.grey : Colors.white,
                            ),
                            onPressed: () => _muteMic(),
                            backgroundColor: Colors.black38,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: FloatingActionButton(
                            mini: true,
                            elevation: 0,
                            heroTag: "Speacker",
                            child: Icon(
                              Icons.volume_up,
                              size: 20,
                              color: _isSpeakerEnabled ? Colors.white : Colors.grey,
                            ),
                            onPressed: () => _switchSpeaker(),
                            backgroundColor: Colors.black38,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: FloatingActionButton(
                            mini: true,
                            elevation: 0,
                            heroTag: "Mute",
                            child: Icon(
                              Icons.mic,
                              size: 20,
                              color: _isMicMute ? Colors.grey : Colors.white,
                            ),
                            onPressed: () => _muteMic(),
                            backgroundColor: Colors.black38,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  _endCall() {
    //callManager.reject(widget._callSession.sessionId!);
    //callManager.hungUp(widget._callSession);
    callManager.hungUp();
  }

  void _writeData() async {
    final directory = await getApplicationDocumentsDirectory();
    final File _myFile = File('${directory.path}/swar_status.txt');
    await _myFile.writeAsString("");
  }

  Future<bool> _onBackPressed(BuildContext context) {
    String currentScreen = Get.currentRoute.toString();
    if (_isVideoCall()) {
      return Future.value(false);
    } else {
      preferencesService.enablePip(aspectRatio);
      return Future.value(false);
    }
    // return //_isVideoCall ? Future.value(true) :
  }

  _muteMic() {
    setState(() {
      _isMicMute = !_isMicMute;
      _callSession.setMicrophoneMute(_isMicMute);
    });
  }

  _switchCamera() {
    if (!_isVideoEnabled()) return;

    // _callSession.switchCamera();
    _callSession.switchCamera().then((isFrontCameraSelected) {
      if (isFrontCameraSelected) {
        setState(() {
          is_mirror = true;
        });
        redrawCurrentUserRendererOnSwitchCamera();
        // front camera selected
        //RTCVideoView(streamRender, mirror: true,);
      } else {
        // back camera selected
        setState(() {
          is_mirror = false;
        });
        redrawCurrentUserRendererOnSwitchCamera();
        // RTCVideoView(currentUserRenderer, mirror: true,);
        //currentUserRenderer
      }
    }).catchError((error) {
      // switching camera failed
    });
  }

  _toggleCamera() {
    if (!_isVideoCall()) return;

    setState(() {
      _isCameraEnabled = !_isCameraEnabled;
      _callSession.setVideoEnabled(_isCameraEnabled);
    });
  }

  bool _isVideoEnabled() {
    return _isVideoCall() && _isCameraEnabled;
  }

  bool _isVideoCall() {
    return CallType.VIDEO_CALL == _callSession.callType;
  }

  _switchSpeaker() {
    setState(() {
      _isSpeakerEnabled = !_isSpeakerEnabled;
      _callSession.enableSpeakerphone(_isSpeakerEnabled);
    });
  }

  @override
  void onConnectedToUser(P2PSession session, int? userId) {
    // TODO: implement onConnectedToUser
    _willStop();
  }

  @override
  void onConnectionClosedForUser(P2PSession session, int? userId) {
    // TODO: implement onConnectionClosedForUser
    log("onConnectionClosedForUser userId= $userId");
    _removeMediaStream(session, userId!);

    // if (preferencesService.isbgCall != true) {
    //   locator<NavigationService>().popRepeated(2);
    // }
  }

  @override
  void onDisconnectedFromUser(P2PSession session, int? userId) {
    // TODO: implement onDisconnectedFromUser
    log("onDisconnectedFromUser userId= $userId");
    _removeMediaStream(session, userId!);
    // if (preferencesService.isbgCall != true) {
    //   locator<NavigationService>().popRepeated(2);
    // }
  }

  // @override
  // void onConnectedToUser(P2PSession session, int userId) {
  //   log("onConnectedToUser userId= $userId");
  // }

  // @override
  // void onConnectionClosedForUser(P2PSession session, int userId) {
  //   log("onConnectionClosedForUser userId= $userId");
  //   _removeMediaStream(session, userId);
  // }

  // @override
  // void onDisconnectedFromUser(P2PSession session, int userId) {
  //   log("onDisconnectedFromUser userId= $userId");
  // }
}

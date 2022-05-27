import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
//import 'package:swipe/swipe.dart';

class IncomingCallScreen extends StatefulWidget {
  static const String TAG = "IncomingCallScreen";

  final P2PSession _callSession;

  IncomingCallScreen(this._callSession);

  @override
  _IncomingCallScreenState createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final CallManager callManager = locator<CallManager>();
  static const String TAG = "_ConversationCallScreenState";
  List<String> userNames = [];
  List<String?> profileUrls = [];
  String singleCaller = "";
  String single_pfl_img = "";
  bool isLoading = true;
  String call_type = "";
  String call_state = "Ringing...";
  AssetsAudioPlayer audio_rintone_Player = AssetsAudioPlayer();

  late CameraController controller;
  late List<CameraDescription> cameras;
  bool isInitialized = false;
  int count_membr = 0;
  //late AnimateIconController c1;
  @override
  void initState() {
    super.initState();
    // widget._callSession.onLocalStreamReceived = _addLocalMediaStream;
    // widget._callSession.setSessionCallbacksListener(this);

//      FlutterRingtonePlayer.play(
//   android: AndroidSounds.ringtone,
//   ios: IosSounds.glass,
//   looping: true, // Android only - API >= 28
//   volume: 1.0,
//   asAlarm: true,
//   // Android only - API >= 28

// );

    audio_rintone_Player.open(
      Audio('assets/ringtone.mp3'),
      autoStart: true,
      showNotification: false,
      loopMode: LoopMode.single,
      volume: 1.0,
      // asAlarm: true,
      //  respectSilentMode: false,
      //  headPhoneStrategy: HeadPhoneStrategy.none,

      //setSpeakerphoneOn:true;
    );
    //audio_rintone_Player.
    // audio_rintone_Player.v
    // audio_rintone_Player.setVolume(1.0);

    //audio_rintone_Player.setVolume(1.0);
    //audio_rintone_Player.
//audio_rintone_Player.setSpeakerphoneOn (boolean on);

    cameraInitialize();
    getUserInfos();
  }

  void cameraInitialize() async {
    cameras = await availableCameras();

    //controller = CameraController(cameras[0], ResolutionPreset.max);
    controller = CameraController(
      cameras[0],
      ResolutionPreset.ultraHigh,
    );

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        isInitialized = true;
      });
    });
  }

  void getUserInfos() async {
    //print('====CALLING<<<<<======'+widget._callSession.client.toString());
    //currentCall
    PagedResult<CubeUser>? result = await getAllUsersByIds(widget._callSession.opponentsIds);
    //caller
    var single = await getUserById(widget._callSession.callerId);
    String? callerName = single!.fullName;
    singleCaller = callerName.toString();
    single_pfl_img = getPrivateUrlForUid(single.avatar).toString();
    //single_pfl_img=single.avatar.toString();
    // print('============'+callerName.toString());
    //get receiver from  SharedPrefs sharedPrefs = await SharedPrefs.instance.init();
    CubeUser? useragain = await SharedPrefs.getUser();

    if (result!.totalEntries! > 0) {
      List<CubeUser> users = result.items;
      print(users.toString());
      List<String> nm = [];
      List<String?> av = [];
      nm.add(callerName!);
      av.add(single_pfl_img);
      count_membr = users.length;
      for (var user in users) {
        print(user.fullName);
        nm.add(user.fullName!);
        av.add(getPrivateUrlForUid(user.avatar));
        //print(av);
      }

      //filter to remove receiver names
      nm.remove(useragain!.fullName);
      av.remove(getPrivateUrlForUid(useragain.avatar));
      setState(() {
        // names = nm.join(', ');
        userNames = nm;
        profileUrls = av;
        // print('====user names'+userNames.toString());
        // print('===== Profile urls'+profileUrls.toString());
        isLoading = false;
      });
    }
  }

// void _addLocalMediaStream(MediaStream stream) async {
//     log("_addLocalMediaStream", TAG);
//     //_onStreamAdd(CubeChatConnection.instance.currentUser!.id!, stream);
//     //currentUserRenderer
//     RTCVideoRenderer streamRender = RTCVideoRenderer();
//     await streamRender.initialize();
//     streamRender.srcObject = stream;
//     RTCVideoView rtcVideoView = RTCVideoView(
//       streamRender,
//       objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//       //mirror: true,
//       mirror: is_mirror,
//     );
//     //audioPlayer.setVolume(0.4);
//     setState(() {

//       currentUserRenderer = rtcVideoView;
//       isCurrentUserAdded = true;
//     });
//     // setState(() => streams[opponentId] = streamRender);
//   }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    bool up = false;
    widget._callSession.onSessionClosed = (callSession) {
      audio_rintone_Player.stop();
      //  FlutterRingtonePlayer.stop();
      log("_onSessionClosed", IncomingCallScreen.TAG);
      Navigator.pop(context);
    };

    //  print("NAME"+userNames.toString());

    return WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
            backgroundColor: Colors.grey.shade700,
            body: OrientationBuilder(builder: (context, orientation) {
              return Stack(
                children: [
                  call_type == "Video"
                      ? Center(
                          child: Container(
                            child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                              CameraPreview(controller),
                            ]),
                          ),
                        )
                      : Container(),

                  //call_type=="Audio" ?
                  //mainAxisSize: MainAxisSize.min,
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //  // mainAxisAlignment: MainAxisAlignment.start,
                  //   //crossAxisAlignment: CrossAxisAlignment.e,
                  //   children: <Widget>[

                  Container(
                    width: screenSize.width, height: screenSize.height - 440,
                    // width: scr, height: 100,

                    decoration: BoxDecoration(
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.grey.shade800.withOpacity(0.8),
                        //     spreadRadius: 6,
                        //     blurRadius: 2,
                        //     offset: Offset(0, 7), // changes position of shadow
                        //   ),
                        // ],
                        ),

                    child: Column(
                      children: [
                        Padding(
                          //padding: EdgeInsets.only(left:36,right: 4,bottom:36),
                          padding: EdgeInsets.all(36),
                          child: Text(_getCallTitle(), style: TextStyle(fontSize: 28, color: Colors.white)),
                        ),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(40.0),
                          child: Container(color: Colors.black12, width: 70, height: 70, child: UIHelper.getProfileImageWithInitials(single_pfl_img, 60, 60, singleCaller)),
                        ),
                        // SizedBox(
                        //     width: Screen.width(context) - 100,
                        //     height: 80,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       //single_profile_img
                        //       children: profileUrls.map((e) {
                        //         int index = profileUrls.indexOf(e);
                        //         return Padding(
                        //           padding: const EdgeInsets.only(right: 8),
                        //           child: ClipRRect(
                        //               borderRadius: BorderRadius.circular(40.0),
                        //               child: Container(
                        //                   color: Colors.black12,
                        //                   width: 80,
                        //                   height: 80,
                        //                   child:

                        //                       //onetoone>>>>>

                        //                      userNames.length<2

                        //                               ? UIHelper.getProfileImageWithInitials(single_pfl_img, 80, 80, singleCaller)

                        //                           :
                        //                           //groupcall>>>>>>>>

                        //                           UIHelper.getProfileImageWithInitials(e!, 80, 80, userNames[index]))),
                        //         );
                        //       }).toList(),
                        //     ),
                        //   ),

                        UIHelper.verticalSpaceMedium,
                        isLoading
                            ? Padding(
                                padding: EdgeInsets.only(bottom: 46),
                                child: CircularProgressIndicator(),
                              )
                            : Padding(
                                padding: EdgeInsets.only(bottom: 46),
                                //  child: Text(
                                //   userNames.join(', ')).bold(),
                                child: Text(
                                  userNames.length > 2 ? userNames.join(', ') : singleCaller,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ).bold(),
                              ),
                        Text("SWAR " + call_type + " Call", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))
                      ],
                    ),
                  ),
                  // :
                  //   Center(
                  //     child: isInitialized
                  //     ? Container(
                  //         width: Screen.width(context),
                  //         height: Screen.height(context),
                  //         child: CameraPreview(controller),
                  //       )

                  //   :SizedBox()

                  // ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      //         Row(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //              call_type=="Video" ?
                      //  Padding(
                      //   padding: EdgeInsets.only(right: 4),
                      //   child: FloatingActionButton(
                      //     mini: true,
                      //     elevation: 0,
                      //     heroTag: "SwitchCamera",
                      //     child: Icon(
                      //       //Icons.switch_video,
                      //       Icons.flip_camera_android,
                      //       size: 20,
                      //       color:  Colors.white,
                      //     ),
                      //     onPressed: () => {},
                      //     backgroundColor: Colors.black38,
                      //   ),
                      // ): Container()
                      //           ],
                      //         ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 4),
                            child: FloatingActionButton(
                              mini: true,
                              elevation: 0,
                              heroTag: "RejectCall",
                              child: Icon(
                                Icons.call_end,
                                color: Colors.red,
                              ),
                              backgroundColor: Colors.black38,
                              onPressed: () => _rejectCall(context, widget._callSession),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 4, bottom: 4),
                            child: FloatingActionButton(
                              mini: true,
                              elevation: 0,
                              heroTag: "AcceptCall",
                              child: Icon(
                                call_type == "Audio" ? Icons.call : Icons.videocam,
                                color: Colors.white,
                              ),
                              backgroundColor: Colors.green,
                              onPressed: () => _acceptCall(context, widget._callSession),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 4, bottom: 4),
                            child: FloatingActionButton(
                              mini: true,
                              elevation: 0,
                              heroTag: "Message",
                              child: Icon(
                                Icons.message_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _rejectCall(context, widget._callSession);
                              },
                              backgroundColor: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              );
            })));
  }

  _getCallTitle() {
    String callType = "";

    switch (widget._callSession.callType) {
      case CallType.VIDEO_CALL:
        callType = "Video";
        break;
      case CallType.AUDIO_CALL:
        callType = "Audio";
        break;
    }
    call_type = callType;
    return "Incoming call";
  }

  void _acceptCall(BuildContext context, P2PSession callSession) {
    //FlutterRingtonePlayer.stop();
    audio_rintone_Player.stop();
    callManager.acceptCall(callSession.sessionId);
    controller.dispose();
  }

  void _rejectCall(BuildContext context, P2PSession callSession) {
    //FlutterRingtonePlayer.stop();
    audio_rintone_Player.stop();
    callManager.reject(callSession.sessionId);
    controller.dispose();
  }

  Future<bool> _onBackPressed(BuildContext context) {
    //FlutterRingtonePlayer.stop();
    audio_rintone_Player.stop();
    controller.dispose();
    return Future.value(false);
  }
}

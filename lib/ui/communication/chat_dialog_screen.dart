import 'dart:async';
import 'dart:io';

//import 'package:cached_network_image/cached_network_image.dart';
//import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/call_manager.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/full_photo.dart';
import 'package:swarapp/shared/inappbrowser.dart';
import 'package:swarapp/shared/loading.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/picker/doc_category_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'group_list_view.dart';
import 'package:swarapp/shared/pdf_viewer.dart';
import 'package:member_module/src/ui/members/widgets/video_player_widget.dart';

class ChatDialogScreen extends StatefulWidget {
  final CubeUser _cubeUser;
  final CubeDialog _cubeDialog;

  ChatDialogScreen(this._cubeUser, this._cubeDialog);

  @override
  _ChatDialogScreenState createState() => _ChatDialogScreenState();
}

class _ChatDialogScreenState extends State<ChatDialogScreen> {
  final CallManager callManager = locator<CallManager>();

  String localPath = '';
  bool isInActiveDialog = false;
  GlobalKey<ChatScreenState> globalKey = GlobalKey();

  ApiService apiService = locator<ApiService>();

  @override
  Widget build(BuildContext context) {
    //print('======ACTIVE=hhhh===='+isInActiveDialog.toString());
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     _cubeDialog.name != null ? _cubeDialog.name! : '',
        //   ),
        //   centerTitle: false,
        //   actions: <Widget>[
        //     IconButton(
        //       onPressed: () => _chatDetails(context),
        //       icon: Icon(
        //         Icons.info_outline,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ],
        // ),
        appBar: SwarAppStaticBar(),
        body: SafeArea(
          top: false,
          // child: IgnorePointer(
          //    ignoring: isInActiveDialog,
          child: Container(
            // padding: EdgeInsets.symmetric(horizontal: 1),
            width: Screen.width(context),
            child: Column(
              children: [
                // UIHelper.verticalSpaceMedium,
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                  child: Row(
                    children: [
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            //Get.back();
                            Loader.show(context);
                            Future.delayed(Duration(seconds: 3), () {
                              Loader.hide();
                            });
                            Get.back(result: {'refresh': true});
                          },
                          child: Icon(
                            Icons.arrow_back,
                          ),
                          // child: Image.asset('assets/arrow_back_chat.png'),
                        ),
                      ),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        //child: UIHelper.getProfileImageWithInitials(getPrivateUrlForUid(_cubeDialog.photo)!, 36, 36, _cubeUser.fullName!)
                        child: UIHelper.getProfileImageWithInitials(
                          widget._cubeDialog.type == 2 ? widget._cubeDialog.photo! : getPrivateUrlForUid(widget._cubeDialog.photo)!,
                          36,
                          36,
                          widget._cubeDialog.name!,
                        ),
                      ),
                      UIHelper.horizontalSpaceSmall,
                      GestureDetector(
                        onTap: () {
                          if (widget._cubeDialog.type == 2) Get.to(() => GroupListView(groupDialog: widget._cubeDialog));
                        },
                        child: Text(widget._cubeDialog.name != null ? widget._cubeDialog.name! : '').bold().fontSize(16),
                      ),
                      Expanded(child: SizedBox()),

                      // IgnorePointer
                      Container(
                          child: IgnorePointer(
                              ignoring: isInActiveDialog,
                              child: Row(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        List<int>? occupants = widget._cubeDialog.occupantsIds;
                                        if (occupants!.contains(widget._cubeUser.id)) {
                                          occupants.remove(widget._cubeUser.id);
                                        }
                                        callManager.startNewCall(context, CallType.VIDEO_CALL, occupants.toSet());
                                      },
                                      child: Icon(
                                        Icons.videocam,
                                        color: Colors.black,
                                        size: 35,
                                      )),
                                  UIHelper.horizontalSpaceSmall,
                                  GestureDetector(
                                      onTap: () {
                                        print('Voice Call');
                                        List<int>? occupants = widget._cubeDialog.occupantsIds;
                                        if (occupants!.contains(widget._cubeUser.id)) {
                                          occupants.remove(widget._cubeUser.id);
                                        }
                                        callManager.startNewCall(context, CallType.AUDIO_CALL, occupants.toSet());
                                      },
                                      child: Icon(
                                        Icons.call,
                                        color: Colors.black,
                                        size: 32,
                                      )),
                                  UIHelper.horizontalSpaceSmall,
                                  widget._cubeDialog.type == 2
                                      ? SizedBox(
                                          height: 36,
                                          width: 36,
                                          child: PopupMenuButton(
                                            padding: EdgeInsets.zero,
                                            offset: Offset(0, 44),
                                            icon: Icon(Icons.more_vert), //don't specify icon if you want 3 dot menu
                                            color: Colors.white,
                                            itemBuilder: (context) => [
                                              PopupMenuItem<int>(
                                                height: 24,
                                                value: 0,
                                                child: Text(
                                                  "Exit Group",
                                                  style: TextStyle(color: Colors.black),
                                                ),
                                              ),
                                            ],
                                            onSelected: (item) async {
                                              deleteGroup(false);
                                            },
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ))),

                      UIHelper.horizontalSpaceMedium,
                    ],
                  ),
                ),
                UIHelper.verticalSpaceTiny,
                Container(
                  // margin: EdgeInsets.only(top: 6, bottom: 6),
                  color: Colors.black12,
                  height: 1,
                ),
                Expanded(
                    child: ChatScreen(widget._cubeUser, widget._cubeDialog, (value) {
                  setState(() {
                    //isInActiveDialog = value;
                    isInActiveDialog = false;
                  });
                  print('======ACTIVE=====' + isInActiveDialog.toString());
                })),
              ],
            ),
          ),
        ));
  }

  _chatDetails(BuildContext context) async {
    log("_chatDetails= ${widget._cubeDialog}");
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ChatDetailsScreen(_cubeUser, _cubeDialog),
    //   ),
    // );
  }

  Future deleteGroup(bool isForceDelete) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Caution!'),
            content: Text('Are you sure, want to exit?'),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Yes'),
                onPressed: () async {
                  Navigator.pop(context);
                  Loader.show(context);
                  await deleteDialog(widget._cubeDialog.dialogId!, isForceDelete);
                  Loader.hide();
                  Get.back();
                },
              ),
            ],
          );
        });
  }
}

class ChatScreen extends StatefulWidget {
  static const String TAG = "_CreateChatScreenState";
  final CubeUser _cubeUser;
  final CubeDialog _cubeDialog;
  final Function(bool) onFriendStatusUpdate;
  ChatScreen(this._cubeUser, this._cubeDialog, this.onFriendStatusUpdate);

  @override
  State createState() => ChatScreenState(_cubeUser, _cubeDialog);
}

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final CubeUser _cubeUser;
  final CubeDialog _cubeDialog;
  final Map<int?, CubeUser?> _occupants = Map();
  late File imageFile;
  final picker = ImagePicker();
  late bool isLoading;
  String? imageUrl;
  List<CubeMessage>? listMessage = [];
  Timer? typingTimer;
  bool isTyping = false;
  String userStatus = '';
  bool _isInForeground = true;
  bool _isreloadChat = false;
  bool isExist = false;
  late PDFDocument document;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  PreferencesService preferencesService = locator<PreferencesService>();
  ApiService apiService = locator<ApiService>();

  StreamSubscription<CubeMessage>? msgSubscription;
  StreamSubscription<MessageStatus>? deliveredSubscription;
  StreamSubscription<MessageStatus>? readSubscription;
  StreamSubscription<TypingStatus>? typingSubscription;
  //Stream<MessageStatus> get deletedStream => _deleteStreamController.stream;

  List<CubeMessage> _unreadMessages = [];
  List<CubeMessage> _unsentMessages = [];

  bool isEditMessage = false;
  String editMessageId = '';
  bool isReadOnly = false;

  ChatScreenState(this._cubeUser, this._cubeDialog);
  final focus = FocusNode();

  final MyInAppBrowser browser = new MyInAppBrowser();
  var options = InAppBrowserClassOptions(
      crossPlatform: InAppBrowserOptions(hideUrlBar: false),
      inAppWebViewGroupOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              clearCache: true,
              useShouldInterceptAjaxRequest: true,
              useShouldOverrideUrlLoading: true,
              useShouldInterceptFetchRequest: true,
              javaScriptCanOpenWindowsAutomatically: true,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true)));

  @override
  void initState() {
    super.initState();
    _initCubeChat();

    isLoading = false;
    imageUrl = '';

    isExist = false;

    WidgetsBinding.instance!.addObserver(this);
    //locator<ConnectyCubeServices>().cubeDialogs
    getRecentFriends();
  }

  void getRecentFriends() async {
    if (_cubeDialog.type == 3) // One to one Chat
    {
      String userId = preferencesService.userId;
      List friends = await apiService.getRecentMembers(userId);
      List doctors = preferencesService.doctorsListStream!.value!;
      print(preferencesService.userInfo['connectycube_id'].toString());
      var flatfriends = friends.expand((i) => i).toList();
      var flatdoctors = preferencesService.doctorsListStream!.value!.expand((i) => i).toList();
      print(flatfriends);
      List<String> ccIds = flatfriends.map((e) => e['connectycube_id'].toString()).toList();
      String ccToken = preferencesService.userInfo['connectycube_id'].toString();
      ccIds.add(ccToken);
      List<String> ccIdsDoctors = flatdoctors.map((e) => e['connectycube_id'].toString()).toList();
      String ccTokenDoctor = preferencesService.userInfo['connectycube_id'].toString();
      ccIdsDoctors.add(ccTokenDoctor);
      List<int>? occupantIds = widget._cubeDialog.occupantsIds;
      isExist = false;
      for (var occupantId in occupantIds!) {
        if (!ccIds.contains(occupantId.toString())) {
          isExist = true;
          break;
        }
      }
      setState(() {
        isReadOnly = isExist;
        // isReadOnly = false;
      });
      widget.onFriendStatusUpdate(isExist);
    }

    // if (_cubeDialog.type == 3) // One to one Chat
    // {
    //   String ccToken = preferencesService.userInfo['connectycube_id'];
    //   int ccTokenInt = int.parse(ccToken);
    //   print(ccToken);
    //   List<int>? occupantIds = widget._cubeDialog.occupantsIds;
    //   setState(() {
    //     if (occupantIds!.contains(ccTokenInt)) {
    //       print('ID Exists');
    //       isReadOnly = false;
    //     } else {
    //       print('ID Not Exists');
    //       isReadOnly = true;
    //     }
    //   });
    // }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      if (state == AppLifecycleState.paused) {
        _isInForeground = false;
      } else {
        _isInForeground = true;
      }
    });
  }

  @override
  void dispose() {
    msgSubscription?.cancel();
    deliveredSubscription?.cancel();
    readSubscription?.cancel();
    typingSubscription?.cancel();
    textEditingController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void openGallery() async {
    // final pickedFile = await picker.getImage(source: ImageSource.gallery);
    // if (pickedFile == null) return;
    // setState(() {
    //   isLoading = true;
    // });
    // imageFile = File(pickedFile.path);
    // uploadImageFile();
    showFilePickerSheet('type');
  }

  Future uploadImageFile(bool isDocument) async {
    // CubeAttachment attachment = CubeAttachment();

    uploadFile(imageFile, isPublic: true, onProgress: (progress) {
      log("uploadImageFile progress= $progress");
    }).then((cubeFile) {
      var url = cubeFile.getPublicUrl();
      // attachment.name = cubeFile.name;
      onSendChatAttachment(url, isDocument, cubeFile);
      setState(() {
        isLoading = false;
      });
    }).catchError((ex) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  Future uploadImageFileCustom(bool isDocument, String path) async {
    File docPath = File(path);
    uploadFile(docPath, isPublic: true, onProgress: (progress) {
      log("uploadImageFile progress= $progress");
    }).then((cubeFile) {
      var url = cubeFile.getPublicUrl();
      // attachment.name = cubeFile.name;
      onSendChatAttachment(url, isDocument, cubeFile);
      setState(() {
        isLoading = false;
      });
    }).catchError((ex) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  Future<void> _displayDialog(BuildContext context, String message) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Do you want to Delete message?'),
            actions: <Widget>[
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Yes'),
                onPressed: () {
                  String dateStr = '';
                  // if (data['date'] != null) {
                  //   Jiffy dt = Jiffy(data['date']);
                  //   dateStr = dt.format('MM-dd-yyyy');
                  // } else {
                  //   dateStr = '';
                  // }
                  //model.updateVaccinationInfo(!data['status'], dateStr, '', data, documentId);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future getImage(String type, FileType fileType) async {
    String path = '';

    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 850);
    //maxWidth: 850,
    // imageQuality:100
    if (pickedFile != null) {
      path = pickedFile.path;
      imageFile = File(path);
      setState(() {
        isLoading = true;
      });
      await uploadImageFile(false);
    }
    print(path);
  }

  // void pickAFile() async {
  //   FilePickerResult result = (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx']))!;
  //   String path = result.files.single.path!;
  //   imageFile = File(path);
  //   print(path);
  //   await uploadImageFile(true);
  // }

  void selectDocPicker(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return DocCategoryView(onFilesSelected: (files) {
            print(files);
            Get.back();
            Future.forEach(files, (String file) async {
              await uploadImageFileCustom(true, file);
            });
          });
        });
  }

  void pickAFile() async {
    FilePickerResult result = (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx', 'mp4']))!;

    String path = result.files.single.path!;
    imageFile = File(path);
    String filename = path.split('/').last;
    print(path);
    if (path.isNotEmpty) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirm'),
              content: Text('Do you want to attach $filename ?'),
              actions: <Widget>[
                FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text('CANCEL'),
                  onPressed: () {
                    // Get.back(result: {'refresh': false});
                    //return;
                    setState(() {
                      Navigator.pop(context);
                    });
                    pickAFile();
                  },
                ),
                FlatButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text('OK'),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                      Navigator.pop(context);
                    });
                    //await uploadImageFile(true);
                    uploadImageFile(true);

                    // model.isBusy
                  },
                ),
              ],
            );
          });
    }
  }

  void showFilePickerSheet(String type) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(6.0)),
        ),
        builder: (BuildContext context) {
          return Container(
            height: 300,
            child: ListView(
              children: [
                UIHelper.verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [UIHelper.horizontalSpaceSmall, Text('Select a type').bold()],
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () {
                    Get.back();
                    getImage(type, FileType.video);
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Camera'),
                ),
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () {
                    Get.back();
                    getImage(type, FileType.image);
                  },
                  visualDensity: VisualDensity.compact,
                  //visualDensity: VisualDensity.standard,
                  // visualDensity:VisualDensity.comfortable,
                  title: Text('Photo Library'),
                ),
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () {
                    Get.back();
                    // getImage(type, FileType.image);
                    pickAFile();
                  },
                  visualDensity: VisualDensity.compact,
                  //visualDensity: VisualDensity.standard,
                  // visualDensity:VisualDensity.comfortable,
                  title: Text('Select a file'),
                ),
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () {
                    Get.back();
                    // getImage(type, FileType.image);
                    selectDocPicker(context);
                  },
                  visualDensity: VisualDensity.compact,
                  //visualDensity: VisualDensity.standard,
                  // visualDensity:VisualDensity.comfortable,
                  title: Text('Health Record'),
                ),
              ],
            ),
          );
        });
  }

  void onReceiveMessage(CubeMessage message) {
    log("onReceiveMessage message= $message");
    if (message.dialogId != _cubeDialog.dialogId || message.senderId == _cubeUser.id) return;
    _cubeDialog.deliverMessage(message);
    addMessageToListView(message);
    // if (!_isInForeground) {
    //   const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    //     'messages_channel_id',
    //     'Chat messages',
    //     'Chat messages will be received here',
    //     importance: Importance.max,
    //     priority: Priority.high,
    //     showWhen: true,
    //     color: Colors.green,
    //   );
    //   const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    //   FlutterLocalNotificationsPlugin().show(
    //     6543,
    //     message.body,
    //     message.dialogId,
    //     platformChannelSpecifics,
    //     payload: 'sadasd',
    //   );
    // }
  }

  void onDeliveredMessage(MessageStatus status) {
    log("onDeliveredMessage message= $status");
    updateReadDeliveredStatusMessage(status, false);
  }

  void onReadMessage(MessageStatus status) {
    log("onReadMessage message= ${status.messageId}");
    updateReadDeliveredStatusMessage(status, true);
  }

  void onTypingMessage(TypingStatus status) {
    log("TypingStatus message= ${status.userId}");
    if (status.userId == _cubeUser.id || (status.dialogId != null && status.dialogId != _cubeDialog.dialogId)) return;
    userStatus = _occupants[status.userId]?.fullName ?? _occupants[status.userId]?.login ?? '';

    if (userStatus.isEmpty) return;
    userStatus = userStatus == _cubeUser.fullName ? " " : "$userStatus is typing ...";

    if (isTyping != true) {
      setState(() {
        isTyping = true;
      });
    }
    startTypingTimer();
  }

  startTypingTimer() {
    typingTimer?.cancel();
    typingTimer = Timer(Duration(milliseconds: 900), () {
      setState(() {
        isTyping = false;
      });
    });
  }

  void onSendChatMessage(String content) async {
    if (content.trim() != '') {
      if (isEditMessage) {
        UpdateMessageParameters updateMessageParameters = UpdateMessageParameters();
        updateMessageParameters.newBody = content.trim();
        updateMessageParameters.read = true;

        await updateMessage(editMessageId, _cubeDialog.dialogId!, updateMessageParameters.getRequestParameters());
        //sendPushNotification();
        //onSendMessage(message);

        CubeMessage? editMessage = listMessage!.firstWhereOrNull((element) {
          //print(editMessage.properties.);
          return element.messageId == editMessageId;
        });

        if (editMessage != null) {
          editMessage.body = content.trim();
          int index = listMessage!.indexOf(editMessage);
          listMessage!.removeAt(index);
          listMessage!.insert(index, editMessage);
        }
        textEditingController.clear();
        listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);

        setState(() {
          isEditMessage = false;
          editMessageId = '';
        });
      } else {
        final message = createCubeMsg();
        message.body = content.trim();
        sendPushNotification();
        onSendMessage(message);
      }
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  void sendPushNotification() {
    CreateEventParams params = CreateEventParams();
    params.parameters = {
      'message': '${textEditingController.text}',
      'name': _cubeUser.fullName,
      'dialog_id': _cubeDialog.dialogId,
      'ios_voip': 0,
    };
    params.notificationType = '${NotificationType.PUSH}';
    bool isProduction = bool.fromEnvironment('dart.vm.product');
    params.environment = isProduction ? CubeEnvironment.PRODUCTION : CubeEnvironment.DEVELOPMENT;

    List<int>? occupants = _cubeDialog.occupantsIds;
    if (occupants!.contains(_cubeUser.id)) {
      occupants.remove(_cubeUser.id);
    }
    params.usersIds = occupants;

    createEvent(params.getEventForRequest()).then((cubeEvent) {
      print('CUBE EVENT -----> $cubeEvent');
    }).catchError((error) {
      print('CUBE EVENT ERROR -----> $error');
    });
  }

  void onSendChatAttachment(String? url, bool isDocument, CubeFile cubeFile) async {
    if (isDocument) {
      final attachment = CubeAttachment();
      attachment.id = cubeFile.hashCode.toString();
      // attachment.type = CubeAttachmentType.AUDIO_TYPE;
      attachment.name = cubeFile.name;
      attachment.contentType = cubeFile.contentType;
      attachment.url = url;
      attachment.height = 200;
      attachment.width = 200;
      final message = createCubeMsg();
      message.body = "Attachment";
      message.attachments = [attachment];
      onSendMessage(message);
      return;
    }
    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());

    final attachment = CubeAttachment();
    attachment.id = cubeFile.hashCode.toString();
    attachment.type = CubeAttachmentType.IMAGE_TYPE;
    attachment.contentType = cubeFile.contentType;
    attachment.url = url;
    attachment.height = decodedImage.height;
    attachment.width = decodedImage.width;
    final message = createCubeMsg();
    message.body = "Attachment";
    message.attachments = [attachment];
    onSendMessage(message);
  }

  CubeMessage createCubeMsg() {
    var message = CubeMessage();

    message.dateSent = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    message.markable = true;
    message.saveToHistory = true;

    return message;
  }

  void onSendMessage(CubeMessage message) async {
    log("onSendMessage message= $message");
    textEditingController.clear();
    await _cubeDialog.sendMessage(message);
    message.senderId = _cubeUser.id;
    addMessageToListView(message);
    listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  updateReadDeliveredStatusMessage(MessageStatus status, bool isRead) {
    log('[updateReadDeliveredStatusMessage]');
    setState(() {
      CubeMessage? msg = listMessage!.firstWhereOrNull((msg) => msg.messageId == status.messageId);
      if (msg == null) return;
      if (isRead)
        msg.readIds == null ? msg.readIds = [status.userId] : msg.readIds?.add(status.userId);
      else
        msg.deliveredIds == null ? msg.deliveredIds = [status.userId] : msg.deliveredIds?.add(status.userId);

      log('[updateReadDeliveredStatusMessage] status updated for $msg');
    });
  }

  addMessageToListView(CubeMessage message) {
    setState(() {
      isLoading = false;
      int existMessageIndex = listMessage!.indexWhere((cubeMessage) {
        return cubeMessage.messageId == message.messageId;
      });

      if (existMessageIndex != -1) {
        listMessage!.replaceRange(existMessageIndex, existMessageIndex + 1, [message]);
      } else {
        listMessage!.insert(0, message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('bsudf_isreloadChat');

    if (_isreloadChat) {
      getAllItems();
//   _isreloadChat=false;
//   buildLoading();
      setState(() {
        isLoading = false;
      });
    }
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Image.asset(
            'assets/chatbg.png',
            fit: BoxFit.cover,
            width: Screen.width(context),
            height: Screen.height(context),
          ),
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),
              //Typing content
              buildTyping(),
              // Input content
              buildInput(),
              // UIHelper.verticalSpaceTiny
            ],
          ),
          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  List<String> docs_supported = ['pdf', 'docx', 'xxls', 'xlsx'];

  String supportedIcon(String contentType) {
    if (contentType.contains('pdf')) {
      return 'assets/PDF.png';
    }
    if (contentType.contains('docx')) {
      return 'assets/word_icon.png';
    }
    if (contentType.contains('.xxls') || contentType.toLowerCase().contains('.xlsx')) {
      return 'assets/excel_icon.png';
    }
    return '';
  }

  Widget getAttachmentContent(BuildContext context, CubeMessage message) {
    CubeAttachment cubeAttachment = message.attachments!.first;
    String contentType = cubeAttachment.name != null ? cubeAttachment.name! : cubeAttachment.contentType!;
    if (cubeAttachment.contentType == null) {
      return UIHelper.getImage(message.attachments!.first.url!, 200, 300);
    }
    String icon = supportedIcon(cubeAttachment.name != null ? cubeAttachment.name! : cubeAttachment.contentType!);
    // if(contentType.toLowerCase().contains('.mp4')){

    // }
    if (icon.isNotEmpty || contentType.toLowerCase().contains('.mp4')) {
      if (contentType.toLowerCase().contains('pdf') ||
          contentType.toLowerCase().contains('docx') ||
          contentType.toLowerCase().contains('xxls') ||
          contentType.toLowerCase().contains('xlsx') ||
          contentType.toLowerCase().contains('.mp4')) {
        return Container(
          color: Colors.black12,
          width: 200,
          height: 50,
          alignment: Alignment.centerLeft,

          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              UIHelper.horizontalSpaceSmall,
              contentType.toLowerCase().contains('.mp4')
                  ? Icon(Icons.smart_display, size: 30, color: Colors.grey)
                  : Image.asset(
                      icon,
                      fit: BoxFit.fitWidth,
                      height: 30,
                      width: 30,
                    ),

              //  Text( cubeAttachment.name.toString(),overflow: TextOverflow.ellipsis,
              //  style: TextStyle(color: Colors.black), ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                //Vertical || Horizontal
                child: new Text(
                  cubeAttachment.name.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          //cubeAttachment
          //Text("Sdf").bold(),
        );
      } else {
        return Container(
          color: Colors.black12,
          width: 200,
          height: 200,
          alignment: Alignment.center,
          child: Image.asset(
            icon,
            fit: BoxFit.none,
            height: 60,
            width: 80,
          ),
        );
      }
    }
    return contentType.toLowerCase().contains('.mp4') ? Container(child: Center(child: Icon(Icons.smart_display, size: 60, color: Colors.grey))) : UIHelper.getImage(message.attachments!.first.url!, 200, 200);
  }

  Widget ImageDialog(BuildContext context, String fileUrl) {
    return Dialog(
        backgroundColor: Color.fromRGBO(105, 105, 105, 0.5),
        insetPadding: EdgeInsets.all(15),
        child: Container(
          child: Stack(
            // child: SingleChildScrollView(
            children: [
              PinchZoom(
                // image:DecorationImage(),
                image: Image.network(fileUrl),
                zoomedBackgroundColor: Colors.black.withOpacity(0.5),
                resetDuration: const Duration(milliseconds: 100),
                maxScale: 2.5,
                onZoomStart: () {
                  print('Start zooming');
                },
                onZoomEnd: () {
                  print('Stop zooming');
                },
              ),
              Positioned(
                right: 0.0,
                top: 0.5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      radius: 14.0,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  changePDF(value) async {
    bool _isLoading = true;

    setState(() => _isLoading = true);
    document = await PDFDocument.fromURL(
      "https://swartest.blob.core.windows.net/swardoctor/maternity_6104fb42aca56f09801e52a5_1628137792306.pdf",
    );
  }

  Widget PdfDialog(BuildContext context, String fileUrl) {
    final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

    bool _isLoading = true;
    changePDF("str");
    return Dialog(
      insetPadding: EdgeInsets.all(15),
      child: Container(
        child: Stack(
          children: [PDFViewer(document: document, zoomSteps: 1)],

          // child: SingleChildScrollView(
          // children: [
          //   SingleChildScrollView(
          //     child: SfPdfViewer.network(
          //       file_url,
          //       //'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
          //       key: _pdfViewerKey,
          //     ),
          //   ),
          //   Positioned(
          //     right: 0.0,
          //     //top: 0.5,
          //     child: GestureDetector(
          //       onTap: () {
          //         Navigator.of(context).pop();
          //       },
          //       child: Align(
          //         alignment: Alignment.topLeft,
          //         child: CircleAvatar(
          //           radius: 14.0,
          //           backgroundColor: Colors.red,
          //           child: Icon(Icons.close, color: Colors.white),
          //         ),
          //       ),
          //     ),
          //   ),
          // ]
        ),
      ),
    );
  }

  Widget buildItem(int index, CubeMessage message) {
    markAsReadIfNeed() {
      var isOpponentMsgRead = message.readIds != null && message.readIds!.contains(_cubeUser.id);
      print("markAsReadIfNeed message= $message, isOpponentMsgRead= $isOpponentMsgRead");
      if (message.senderId != _cubeUser.id && !isOpponentMsgRead) {
        if (message.readIds == null) {
          message.readIds = [_cubeUser.id!];
        } else {
          message.readIds!.add(_cubeUser.id!);
        }

        if (CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.Ready) {
          _cubeDialog.readMessage(message);
        } else {
          _unreadMessages.add(message);
        }
      }
    }

    Widget getReadDeliveredWidget() {
      log("[getReadDeliveredWidget]");
      bool messageIsRead() {
        log("[getReadDeliveredWidget] messageIsRead");
        if (_cubeDialog.type == CubeDialogType.PRIVATE) return message.readIds != null && (message.recipientId == null || message.readIds!.contains(message.recipientId));
        return message.readIds != null && message.readIds!.any((int id) => id != _cubeUser.id && _occupants.keys.contains(id));
      }

      bool messageIsDelivered() {
        log("[getReadDeliveredWidget] messageIsDelivered");
        if (_cubeDialog.type == CubeDialogType.PRIVATE) return message.deliveredIds?.contains(message.recipientId) ?? false;
        return message.deliveredIds != null && message.deliveredIds!.any((int id) => id != _cubeUser.id && _occupants.keys.contains(id));
      }

      if (messageIsRead()) {
        log("[getReadDeliveredWidget] if messageIsRead");
        return Stack(children: <Widget>[
          Icon(
            Icons.check,
            size: 12.0,
            color: Colors.green,
          ),
          Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(
              Icons.check,
              size: 12.0,
              color: Colors.green,
            ),
          )
        ]);
      } else if (messageIsDelivered()) {
        log("[getReadDeliveredWidget] if messageIsDelivered");
        return Stack(children: <Widget>[
          Icon(
            Icons.check,
            size: 15.0,
            //  color: fieldBgColor,
            color: Colors.grey,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(
              Icons.check,
              size: 15.0,
              // color: fieldBgColor,
              color: Colors.grey,
            ),
          )
        ]);
      } else {
        log("[getReadDeliveredWidget] sent");
        return Icon(
          Icons.check,
          size: 15.0,
          color: Colors.green,
        );
      }
    }

    Widget getDateWidget() {
      return Text(
        DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(message.dateSent! * 1000)),
        style: TextStyle(color: Colors.black45, fontSize: 9.0, fontWeight: FontWeight.w500),
      );
    }

    void launchExternalDoc(String url) async {
      try {
        //bool status = await launch(url, forceWebView: true, enableJavaScript: true);
        //print('>>>>>> ' + status.toString());
        browser.openUrlRequest(urlRequest: URLRequest(url: Uri.parse(url)), options: options);
      } catch (e) {
        print('ExEXEXEX');
        print(e.toString());
      }
    }

    Widget getHeaderDateWidget() {
      return Container(
        alignment: Alignment.center,
        child: UIHelper.tagWidget(DateFormat('dd MMMM').format(DateTime.fromMillisecondsSinceEpoch(message.dateSent! * 1000)), activeColor),
        // Text(
        //   DateFormat('dd MMMM').format(DateTime.fromMillisecondsSinceEpoch(message.dateSent! * 1000)),
        //   style: TextStyle(color: activeColor, fontSize: 20.0, fontStyle: FontStyle.italic),
        // ),
        margin: EdgeInsets.all(10.0),
      );
    }

    bool isHeaderView() {
      int headerId = int.parse(DateFormat('ddMMyyyy').format(DateTime.fromMillisecondsSinceEpoch(message.dateSent! * 1000)));
      if (index >= listMessage!.length - 1) {
        return false;
      }
      var msgPrev = listMessage![index + 1];
      int nextItemHeaderId = int.parse(DateFormat('ddMMyyyy').format(DateTime.fromMillisecondsSinceEpoch(msgPrev.dateSent! * 1000)));
      var result = headerId != nextItemHeaderId;
      return result;
    }

    if (message.senderId == _cubeUser.id) {
      // Right (own message)
      return Column(
        children: <Widget>[
          isHeaderView() ? getHeaderDateWidget() : SizedBox.shrink(),
          GestureDetector(
              child: Row(
                children: <Widget>[
                  message.attachments?.isNotEmpty ?? false
                      // Image
                      ? Container(
                          // padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                          child: TextButton(
                            child: Material(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                // Todo - Check document type and set the icons
                                getAttachmentContent(context, message),
                                // UIHelper.getImage(message.attachments!.first.url!, 200, 200),
                                // getDateWidget(),
                                // getReadDeliveredWidget(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    getDateWidget(),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    getReadDeliveredWidget(),
                                    SizedBox(
                                      width: 4,
                                    ),
                                  ],
                                )
                              ]),
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            onPressed: () async {
                              CubeAttachment attachment = message.attachments!.first;

                              //String contentType = attachment.contentType!;
                              String contentType = (attachment.name != null ? attachment.name! : attachment.contentType)!;

                              if (contentType.toLowerCase().contains('.pdf')) {
                                String filename = attachment.name!;
                                await Get.to(() => PdfViewr(url: attachment.url!, file_name: filename));
                                //return;
                              } else if (contentType.toLowerCase().contains('.docx') || contentType.toLowerCase().contains('.xxls') || contentType.toLowerCase().contains('.xlsx')) {
                                print(attachment.url);
                                if (attachment.url!.isNotEmpty) {
                                  launchExternalDoc('https://docs.google.com/viewer?url=${attachment.url!}&time=${DateTime.now()}');
                                }

                                // if (await canLaunch(attachment.url!)) {
                                //   await launch('https://docs.google.com/viewer?url=${attachment.url!}', forceWebView: true, enableJavaScript: true);
                                // }
                                return;
                              } else if (contentType.toLowerCase().contains('.mp3') || contentType.toLowerCase().contains('.mp4')) {
                                await showGeneralDialog(
                                    context: context,
                                    pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                                      return VideoPlayerWidget(
                                        videoUrl: attachment.url!,
                                      );
                                    });
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (_) => ImageDialog(context, message.attachments!.first.url!),
                                );
                              }
                            },
                          ),

                          // margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                          margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 8.0 : 5.0, right: 10.0),
                        )
                      : message.body != null && message.body!.isNotEmpty
                          // Text
                          ? Flexible(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                                decoration: UIHelper.roundedBorderWithColor(4, fieldBgColor),
                                margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 8.0 : 5.0, right: 0.0, left: 55.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      message.body!,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(
                                      height: 0,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        getDateWidget(),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        getReadDeliveredWidget(),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              child: Text(
                                "Empty",
                                style: TextStyle(color: activeColor),
                              ),
                              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                              width: 200.0,
                              decoration: BoxDecoration(color: fieldBgColor, borderRadius: BorderRadius.circular(8.0)),
                              //margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                              margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 8.0 : 5.0, right: 10.0),
                            ),
                  message.attachments?.isEmpty ?? true
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(3.14),
                          child: CustomPaint(
                            painter: CustomShape(subtleColor),
                          ),
                        )
                      : SizedBox(),
                  // SizedBox(
                  //   width: 4,
                  // ),
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(18),
                  //   child: UIHelper.getProfileImageWithInitials(getPrivateUrlForUid(widget._cubeUser.avatar)!, 36, 36, widget._cubeUser.fullName!, bgColor: Colors.white24),
                  // ),
                  UIHelper.horizontalSpaceSmall,
                ],
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              onLongPress: () async {
                //  CubeAttachment attachment = message.attachments!.first;
                //               String filename=attachment.name!;
                //                 String contentType = attachment.contentType!;

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          width: double.maxFinite,
                          height: 100,
                          child: ListView(children: <Widget>[
                            message.body != "Attachment"
                                ? ListTile(
                                    onTap: () {
                                      Get.back();
                                      textEditingController.text = message.body!;

                                      //updateMessage(messageId, dialogId)
                                      setState(() {
                                        isEditMessage = true;
                                        editMessageId = message.messageId!;
                                      });
                                    },
                                    title: Text('Edit'),
                                  )
                                : Container(),
                            ListTile(
                              onTap: () {
                                Get.back();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Caution!'),
                                        content: Text('Are you sure to delete?'),
                                        actions: <Widget>[
                                          FlatButton(
                                            color: Colors.red,
                                            textColor: Colors.white,
                                            child: Text('No'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          FlatButton(
                                            color: Colors.green,
                                            textColor: Colors.white,
                                            child: Text('Yes'),
                                            onPressed: () async {
                                              // bool is_force = false;
                                              // print('LIST DETECT ED' + listMessage![index].toString());
                                              // print('message==' + message.messageId.toString());
                                              DeleteItemsResult result = await deleteMessages([message.messageId!], true);
                                              // print(result);
                                              listMessage!.remove(message);
                                              setState(() {});
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                              title: Text('Delete'),
                            )
                          ]),
                        ),
                      );
                    });
              })
        ],
      );
    } else {
      // Left (opponent message)
      markAsReadIfNeed();
      String? url = '';
      String? fullname = '';
      if (_occupants[message.senderId]?.avatar != null && _occupants[message.senderId]!.avatar!.isNotEmpty) {
        url = _occupants[message.senderId]?.avatar;
      }
      if (_occupants[message.senderId]?.fullName != null && _occupants[message.senderId]!.fullName!.isNotEmpty) {
        fullname = _occupants[message.senderId]?.fullName;
      }
      return Container(
        child: Column(
          children: <Widget>[
            isHeaderView() ? getHeaderDateWidget() : SizedBox.shrink(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(18),
                //   child: Container(
                //     color: Colors.black12,
                //     width: 36,
                //     height: 36,
                //     child: Icon(Icons.portrait),
                //   ),
                // ),
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(18),
                //   child: UIHelper.getProfileImageWithInitials(getPrivateUrlForUid(url)!, 36, 36, fullname!, bgColor: Colors.white24),
                // ),

                UIHelper.horizontalSpaceSmall,
                // SizedBox(
                //   width: 1,
                // ),
                message.attachments?.isEmpty ?? true
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14),
                        child: CustomPaint(
                          painter: CustomShape(subtleColor),
                        ),
                      )
                    : SizedBox(),

                message.attachments?.isNotEmpty ?? false
                    ? Container(
                        padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),

                        child: TextButton(
                          child: Material(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              // Todo - Check document type and set the icons
                              // UIHelper.getImage(message.attachments!.first.url!, 200, 200),
                              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                Text(
                                  widget._cubeDialog.type == 2 ? fullname! : '',
                                  style: TextStyle(
                                    color: activeColor,
                                    fontFamily: "Ewert",
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ]),

                              UIHelper.horizontalSpaceMedium,
                              getAttachmentContent(context, message),
                              SizedBox(
                                width: 4,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  getDateWidget(),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ]),
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () async {
                            CubeAttachment attachment = message.attachments!.first;
                            // if (attachment.contentType == null) {
                            //   Get.to(() => FullPhoto(url: message.attachments!.first.url!, title: _cubeDialog.name,file_type:"null"));
                            //   return;
                            // }
                            //String contentType = attachment.contentType!;
                            String contentType = (attachment.name != null ? attachment.name! : attachment.contentType)!;
                            // if (contentType.toLowerCase().contains('pdf')) {
                            //   //await showDialog(context: context, builder: (_) => PdfDialog(context, attachment.url!));
                            // //  await PdfDialog(context, attachment.url!);
                            //  Get.to(() => FullPhoto(url: message.attachments!.first.url!, title: _cubeDialog.name,file_type:"pdf"));
                            //   return;
                            // } else if (contentType.toLowerCase().contains('docx') || contentType.toLowerCase().contains('xxls') || contentType.toLowerCase().contains('xlsx')) {
                            //   if (await canLaunch(attachment.url!)) {
                            //     await launch('https://docs.google.com/viewer?url=${attachment.url!}');
                            //   }
                            //   return;
                            // }
                            // Get.to(() => FullPhoto(url: message.attachments!.first.url!, title: _cubeDialog.name,file_type:"image"));

                            if (contentType.toLowerCase().contains('pdf')) {
                              String filename = attachment.name!;
                              //  await showDialog(context: context, builder: (_) => PdfDialog(context, attachment.url!));
                              // Get.to(() => FullPhoto(url: message.attachments!.first.url!, title: _cubeDialog.name,file_type:"pdf"));
                              //  PDFDocument document = await PDFDocument.fromURL(
                              //   "https://swartest.blob.core.windows.net/swardoctor/maternity_6104fb42aca56f09801e52a5_1628137792306.pdf",
                              //    ) ;
                              //     PDFViewer(
                              //         document: document,
                              //         zoomSteps: 1);

                              //   return;
                              await Get.to(() => PdfViewr(url: attachment.url!, file_name: filename));
                            } else if (contentType.toLowerCase().contains('.docx') || contentType.toLowerCase().contains('.xxls') || contentType.toLowerCase().contains('.xlsx')) {
                              print(attachment.url);
                              // if (await canLaunch(attachment.url!)) {
                              //   await launch('https://docs.google.com/viewer?url=${attachment.url!}', forceWebView: true, enableJavaScript: true);
                              // }
                              if (attachment.url!.isNotEmpty) {
                                launchExternalDoc('https://docs.google.com/viewer?url=${attachment.url!}&time=${DateTime.now()}');
                              }
                              return;
                            } else if (contentType.toLowerCase().contains('.mp3') || contentType.toLowerCase().contains('.mp4')) {
                              await showGeneralDialog(
                                  context: context,
                                  pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                                    return VideoPlayerWidget(
                                      videoUrl: attachment.url!,
                                    );
                                  });
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) => ImageDialog(context, message.attachments!.first.url!),
                              );
                            }
                          },
                        ),
                        //margin: EdgeInsets.only(left: 10.0),
                      )
                    : message.body != null && message.body!.isNotEmpty
                        ? Flexible(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                              decoration: UIHelper.roundedBorderWithColor(4, fieldBgColor),
                              margin: EdgeInsets.only(left: 0.0, right: 55.0),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                widget._cubeDialog.type == 2
                                    ? Text(
                                        fullname!,
                                        style: TextStyle(
                                          color: activeColor,
                                          fontFamily: "Ewert",
                                        ),
                                        // style: GoogleFonts.lato(fontStyle: FontStyle.italic)
                                      )
                                    : UIHelper.horizontalSpaceSmall,
                                UIHelper.verticalSpaceTiny,
                                Text(
                                  message.body!,
                                  style: TextStyle(color: Colors.black),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [getDateWidget()],
                                ),
                              ]),
                            ),
                          )
                        : Container(
                            child: Text(
                              "Empty",
                              style: TextStyle(color: activeColor),
                            ),
                            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                            width: 200.0,
                            decoration: BoxDecoration(color: fieldBgColor, borderRadius: BorderRadius.circular(8.0)),
                            // margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 8.0 : 5.0, right: 10.0),
                          ),
              ],
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage != null && listMessage![index - 1].id == _cubeUser.id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage != null && listMessage![index - 1].id != _cubeUser.id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const Loading() : Container(),
    );
  }

  Widget buildTyping() {
    return Visibility(
      visible: isTyping,
      child: Container(
        child: Text(
          userStatus,
          style: TextStyle(color: Colors.black),
        ),
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.all(16.0),
      ),
    );
  }

  Widget buildInput() {
    return IgnorePointer(
      ignoring: isReadOnly,
      child: Container(
        child: Row(
          children: <Widget>[
            // Button send image

            // Camera
            SizedBox(
              width: 8,
            ),
            // Edit text
            Expanded(
              child: Container(
                // color: Colors.red,
                //  decoration: UIHelper.roundedBorderWithColor(8, Color(0x99E7E7E7)),
                decoration: UIHelper.roundedBorderWithColor(8, Colors.white),
                //height: 36,
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 6,
                        //  expands: true,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        focusNode: focus,
                        controller: textEditingController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',

                          contentPadding: EdgeInsets.only(left: 10),
                          enabledBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Colors.transparent),
                          focusedBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Colors.transparent),
                          focusedErrorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Colors.transparent),
                          errorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Colors.transparent),
                          // filled: true,
                          // hintStyle: TextStyle(color: fieldBgColor),
                        ),
                        onChanged: (text) {
                          _cubeDialog.sendIsTypingStatus();
                        },
                      ),
                    ),
                    Material(
                      child: Container(
                        // margin: EdgeInsets.symmetric(horizontal: 1.0),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.attach_file_rounded),
                          onPressed: () {
                            openGallery();
                          },
                          color: Colors.black,
                        ),
                      ),
                      color: Colors.transparent,
                    ),
                    Material(
                      child: Container(
                        // margin: EdgeInsets.symmetric(horizontal: 1.0),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.camera_alt),
                          onPressed: () {
                            getImage('type', FileType.video);
                          },
                          color: Colors.black,
                        ),
                      ),
                      color: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),

            // Button send message
            Material(
              child: Container(
                // margin: EdgeInsets.symmetric(horizontal: 8.0),

                child: FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    onSendChatMessage(textEditingController.text);
                  },
                  backgroundColor: Colors.white.withOpacity(0.5),
                  child: Icon(
                    // visualDensity: VisualDensity.compact,
                    Icons.send,
                    // onPressed: () => onSendChatMessage(textEditingController.text),
                    color: activeColor,
                  ),
                ),
              ),
              color: Colors.transparent,
            ),
          ],
        ),
        width: Screen.width(context),
        height: 100.0,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black12,
              width: 0.5,
            ),
          ),
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget buildListMessage() {
    getWidgetMessages(listMessage) {
      return ListView.builder(
        padding: EdgeInsets.all(5.0),
        itemBuilder: (context, index) => buildItem(index, listMessage[index]),
        itemCount: listMessage.length,
        reverse: true,
        controller: listScrollController,
      );
    }

    if (listMessage != null && listMessage!.isNotEmpty) {
      return Flexible(child: getWidgetMessages(listMessage));
    }

    return Flexible(
      child: StreamBuilder(
        stream: getAllItems().asStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            listMessage = snapshot.data as List<CubeMessage>;
            return getWidgetMessages(listMessage);
          }
        },
      ),
    );
  }

  Future<List<CubeMessage>> getAllItems() async {
    Completer<List<CubeMessage>> completer = Completer();
    List<CubeMessage>? messages;
    var params = GetMessagesParameters();
    params.sorter = RequestSorter(UIHelper.SORT_DESC, '', 'date_sent');
    try {
      await Future.wait<void>([
        getMessages(_cubeDialog.dialogId!, params.getRequestParameters()).then((result) => messages = result!.items),
        getAllUsersByIds(_cubeDialog.occupantsIds!.toSet()).then((result) => _occupants.addAll(Map.fromIterable(result!.items, key: (item) => item.id, value: (item) => item)))
      ]);
      completer.complete(messages);
    } catch (error) {
      completer.completeError(error);
    }
    return completer.future;
  }

  Future<bool> onBackPress() {
    //Navigator.pushNamedAndRemoveUntil(context, 'select_dialog', (r) => false, arguments: {UIHelper.USER_ARG_NAME: _cubeUser});
    Get.back();
    return Future.value(false);
  }

  _initChatListeners() {
    //CubeChatConnection.instance.chatMessagesManager!.chatMessagesStream.listen((event) { })
    msgSubscription = CubeChatConnection.instance.chatMessagesManager!.chatMessagesStream.listen(onReceiveMessage);
    deliveredSubscription = CubeChatConnection.instance.messagesStatusesManager!.deliveredStream.listen(onDeliveredMessage);
    readSubscription = CubeChatConnection.instance.messagesStatusesManager!.readStream.listen(onReadMessage);
    typingSubscription = CubeChatConnection.instance.typingStatusesManager!.isTypingStream.listen(onTypingMessage);
    //  CubeChatConnection.instance.messagesStatusesManager!.editedStream.listen((editStatus) {
//});
  }

  void _initCubeChat() {
    log("_initCubeChat");
    bool isValid = CubeSessionManager.instance.isActiveSessionValid();
    print(isValid);
    if (CubeChatConnection.instance.isAuthenticated()) {
      log("[_initCubeChat] isAuthenticated");
      _initChatListeners();
    } else {
      log("[_initCubeChat] not authenticated");
      CubeChatConnection.instance.connectionStateStream.listen((state) {
        log("[_initCubeChat] state $state");
        if (CubeChatConnectionState.Ready == state) {
          _initChatListeners();

          if (_unreadMessages.isNotEmpty) {
            _unreadMessages.forEach((cubeMessage) {
              _cubeDialog.readMessage(cubeMessage);
            });
            _unreadMessages.clear();
          }

          if (_unsentMessages.isNotEmpty) {
            _unsentMessages.forEach((cubeMessage) {
              _cubeDialog.sendMessage(cubeMessage);
            });

            _unsentMessages.clear();
          }
        } else if (CubeChatConnectionState.AuthenticationFailure == state) {
          CubeChatConnection.instance.login(widget._cubeUser);
        }
      });
    }

    CubeChatConnection.instance.connectionStateStream.listen((state) {
      log("New chat connection state is $state");

      switch (state) {
        case CubeChatConnectionState.Idle:
          // instance of connection was created
          break;
        case CubeChatConnectionState.Authenticated:
          // user successfully authorised on ConnectyCube server
          break;
        case CubeChatConnectionState.AuthenticationFailure:
          // error(s) was occurred during authorisation on ConnectyCube server
          break;
        case CubeChatConnectionState.Reconnecting:
          // started reconnection to the chat
          break;
        case CubeChatConnectionState.Resumed:
          // chat connection was resumed
          break;
        case CubeChatConnectionState.Ready:
          // chat connection fully ready for realtime communications
          break;
        case CubeChatConnectionState.ForceClosed:
          // chat connection was interrupted
          break;
        case CubeChatConnectionState.Closed:
          // chat connection was closed
          break;
      }
    });
  }
}

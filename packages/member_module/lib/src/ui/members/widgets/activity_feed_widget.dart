import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:member_module/src/ui/members/feed_comment_view.dart';
import 'package:member_module/src/ui/members/widgets/video_player_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked.dart';
import 'package:member_module/src/ui/members/widgets/activity_feed_widget_model.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/image_cropper.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image/image.dart' as I;

import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:video_compress/video_compress.dart';

class ActivityFeedWidget extends StatefulWidget {
  ActivityFeedWidget({Key? key}) : super(key: key);

  @override
  _ActivityFeedWidgetState createState() => _ActivityFeedWidgetState();
}

class _ActivityFeedWidgetState extends State<ActivityFeedWidget> {
  TextEditingController _textFieldController = TextEditingController();
  ActivityFeedWidgetModel modelRef = ActivityFeedWidgetModel();
  final picker = ImagePicker();
  final videoInfo = FlutterVideoInfo();
  ImageFormat _format = ImageFormat.JPEG;
  int _quality = 10;
  int _size = 0;
  String _tempDir = "";
  String thumb_filePath = "";
  Uint8List? bytes;
  bool _onTouch = false;
  final Completer completer = Completer();
  String _counter = "video";
  File? _thumbnailFile;

  void initState() {
    print("=====init again");
  }

  Widget showSwarMessageField(BuildContext context, ActivityFeedWidgetModel model) {
    return Expanded(
      child: SizedBox(
        height: 30,
        child: TextField(
          controller: _textFieldController,
          // onChanged: (value) {
          //   // model.updateOnTextSearch(value);
          // },
          onEditingComplete: () {
            if (FocusScope.of(context).isFirstFocus) {
              FocusScope.of(context).requestFocus(new FocusNode());
            }
            Loader.show(context);
            model.addStatus(_textFieldController.text, "", '');
            Loader.hide();
            _textFieldController.clear();
          },
          style: TextStyle(fontSize: 11),
          decoration: new InputDecoration(
              contentPadding: EdgeInsets.only(left: 6),
              enabledBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0x00CCCCCC)),
              // focusedBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
              // focusedErrorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
              focusedBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Colors.white),
              focusedErrorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Colors.white),
              errorBorder: UIHelper.getInputBorder(0, radius: 8, borderColor: Color(0xFFCCCCCC)),
              filled: true,
              hintStyle: new TextStyle(color: Colors.grey[800], fontSize: 10),
              hintText: "Write simple message and post.... ",
              fillColor: Colors.white),
        ),
      ),
    );
  }

  _getVideoThumbnail() async {
    var file;

    if (Platform.isMacOS) {
      final typeGroup = XTypeGroup(label: 'videos', extensions: ['mov', 'mp4']);
      file = await openFile(acceptedTypeGroups: [typeGroup]);
    } else {
      final picker = ImagePicker();
      PickedFile? pickedFile = await picker.getVideo(source: ImageSource.gallery);
      file = File(pickedFile!.path);
    }

    if (file != null) {
      _thumbnailFile = await VideoCompress.getFileThumbnail(file.path);
      setState(() {
        print(_thumbnailFile);
      });
    }
  }

  _compressVideo() async {
    var file;
    if (Platform.isMacOS) {
      final typeGroup = XTypeGroup(label: 'videos', extensions: ['mov', 'mp4']);
      file = await openFile(acceptedTypeGroups: [typeGroup]);
    } else {
      final picker = ImagePicker();
      PickedFile? pickedFile = await picker.getVideo(source: ImageSource.gallery);
      file = File(pickedFile!.path);
    }
    if (file == null) {
      return;
    }
    Loader.show(context);
    await VideoCompress.setLogLevel(0);
    final MediaInfo? info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    print("---path file" + info!.path.toString());
    if (info != null) {
      setState(() {
        _counter = info.path!;
      });

      _thumbnailFile = await VideoCompress.getFileThumbnail(_counter);
      thumb_filePath = _thumbnailFile!.path;
      //_getVideoThumbnail();
      //thumb_filePath

      await modelRef.addStatus(_textFieldController.text, _counter, thumb_filePath.isNotEmpty ? thumb_filePath : '');
      Loader.hide();
      _textFieldController.clear();
      // ProgressLoader.show(context);
      // final response = await model.uploadDocuments(_counter, '606d64f2a8adce0a7d52bce4', 'Attach');
      // ProgressLoader.hide();

    }
  }

  Future<void> get_file(String type, FileType fileType) async {
    String path = '';
    String pathImage = '';
    final pickedFile = await picker.getImage(source: fileType == FileType.video ? ImageSource.camera : ImageSource.gallery, maxWidth: 850);
    //maxWidth: 850,
    // imageQuality:100
    if (pickedFile != null) {
      String path = pickedFile.path;

      if (path.contains('.mp4')) {
        var info = await videoInfo.getVideoInfo(path);
        String dur = info!.duration.toString();
        double? durMillisec = info.duration;
        double sec = durMillisec! / 1000;
        String s = sec.toString();
        if (sec > 20.0) {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialogBox(
                  title: "Info !",
                  descriptions: " You cannot upload video more than 20 seconds",
                  descriptions1: "",
                  text: "OK",
                );
              });
        }

        final thumbnail = await VideoThumbnail.thumbnailFile(
          // video: widget.videoUrl,
          // thumbnailPath: _tempDir,
          // imageFormat: _format,
          // maxHeight: Screen.width(context) * .56,
          // maxWidth: Screen.width(context) - 8,
          // // maxHeightOrWidth: _size,
          // quality: _quality
          video: path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 25,
        );
        setState(() {
          final file = File(thumbnail!);
          thumb_filePath = file.path;
        });
        String filename = path.split('/').last;

        Loader.show(context);
        await modelRef.addStatus(_textFieldController.text, path, thumb_filePath.isNotEmpty ? thumb_filePath : '');
        Loader.hide();
        _textFieldController.clear();
        //42678.0
      } else {
        await Get.to(() => ImgCropper(
            index: 0,
            imagePath: pickedFile.path,
            onCropComplete: (crppath) {
              setState(() {
                pathImage = crppath;
              });
              String t = pathImage;
            }));
        String filename = pathImage.split('/').last;
        print(path);
        if (pathImage.isNotEmpty) {
          Loader.show(context);
          await modelRef.addStatus(_textFieldController.text != "" ? _textFieldController.text : '', pathImage.isNotEmpty ? pathImage : '', thumb_filePath.isNotEmpty ? thumb_filePath : '');
          Loader.hide();
          _textFieldController.clear();
        } else {
          _textFieldController.clear();
          return;
        }
      }
      // Loader.show(context);
      // await modelRef.addStatus(_textFieldController.text, path, thumb_filePath);
      // Loader.hide();
      // imageFile = File(path);
      // setState(() {
      //   isLoading = true;
      // });
    }

    _textFieldController.clear();
  }

  Future<void> pickAFile() async {
    String path = '';
    String pathImage = '';
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'mp4', 'png']);
    if (result != null) {
      String path = result.files.single.path!;
      // String path_image = result.files.single.path!;
      if (path.contains('.mp4')) {
        var info = await videoInfo.getVideoInfo(path);
        String dur = info!.duration.toString();
        double? durMillisec = info.duration;
        double sec = durMillisec! / 1000;
        String s = sec.toString();
        if (sec > 20.0) {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialogBox(
                  title: "Info !",
                  descriptions: " You cannot upload video more than 20 seconds",
                  descriptions1: "",
                  text: "OK",
                );
              });
        }
        String temPath = (await getTemporaryDirectory()).path;
        //42678.0
        final thumbnail = await VideoThumbnail.thumbnailFile(
          video: path,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.PNG,
          maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 25,
        );
        // I.Image? _img = I.decodeImage(thumbnail!);
        // _img = I.encodeJpg(_img!) as I.Image?;

        setState(() {
          final file = File(thumbnail!);
          thumb_filePath = file.path;
          // bytes = file.readAsBytesSync();
          // final _image = Image.memory(bytes!);
          // thumb_filePath = path;
        });
        // String filename = path_string.split('/').last;

        Loader.show(context);
        await modelRef.addStatus(_textFieldController.text, path, thumb_filePath.isNotEmpty ? thumb_filePath : '');
        Loader.hide();
        _textFieldController.clear();
      } else {
        await Get.to(() => ImgCropper(
            index: 0,
            imagePath: result.files.single.path!,
            onCropComplete: (croppath) {
              setState(() {
                pathImage = croppath;
              });
            }));
        String filename = pathImage.split('/').last;
        print(path);
        if (pathImage.isNotEmpty) {
          Loader.show(context);
          await modelRef.addStatus(_textFieldController.text != "" ? _textFieldController.text : '', pathImage.isNotEmpty ? pathImage : '', thumb_filePath.isNotEmpty ? thumb_filePath : '');
          Loader.hide();
          _textFieldController.clear();
        } else {
          _textFieldController.clear();
          return;
        }
      }

      // imageFile = File(path);
      // String filename = path.split('/').last;
      // print(path);
      // Loader.show(context);
      // await modelRef.addStatus(_textFieldController.text, path, thumb_filePath.isNotEmpty ? thumb_filePath : '');
      // Loader.hide();
      // _textFieldController.clear();
    }
    _textFieldController.clear();
  }

  void showFilePickerSheet(String type) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(6.0)),
        ),
        builder: (BuildContext context) {
          return Container(
            height: 240,
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
                    get_file(type, FileType.video);
                  },
                  visualDensity: VisualDensity.compact,
                  title: Text('Camera'),
                ),
                UIHelper.hairLineWidget(),
                ListTile(
                  onTap: () {
                    Get.back();
                    get_file(type, FileType.image);
                  },
                  visualDensity: VisualDensity.compact,
                  //visualDensity: VisualDensity.standard,
                  // visualDensity:VisualDensity.comfortable,
                  title: Text('Photo Library'),
                ),
                UIHelper.hairLineWidget(),
              ],
            ),
          );
        });
  }

  Widget getAttachmentWidget(dynamic memberInfo) {
    String url = memberInfo['feedpost_azureBlobStorageLink'] != null ? memberInfo['feedpost_azureBlobStorageLink'].toString() : "";
    String thumbnail = memberInfo['thumbnail_azureBlobStorageLink'] != null ? memberInfo['thumbnail_azureBlobStorageLink'].toString() : "";
    String basePath = ApiService.fileStorageEndPoint;
    String token = locator<ApiService>().token;
    print('$basePath$url');
    double getWidth = Screen.width(context);
    double getHeight = Screen.width(context) * .56;
    if (url.isNotEmpty && url.contains('.mp4')) {
      return Stack(children: <Widget>[
        UIHelper.verticalSpaceSmall,
        GestureDetector(
            onTap: () async {
              String url = memberInfo['feedpost_azureBlobStorageLink'] != null ? memberInfo['feedpost_azureBlobStorageLink'].toString() : "";
              String basePath = ApiService.fileStorageEndPoint;
              setState(() {
                _onTouch = !_onTouch;
              });
              if (url.contains('.mp4')) {
                await showGeneralDialog(
                    context: context,
                    pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                      return VideoPlayerWidget(
                        videoUrl: '$basePath$url',
                      );
                    });
              }
            },
            child: Row(
              children: [
                ClipRRect(child: UIHelper.getImage('$basePath$thumbnail', Screen.width(context) - 4, Screen.width(context) * .56)),
              ],
            )),
        Visibility(
            visible: _onTouch,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _onTouch = !_onTouch;
                });
              },
              child: Container(
                color: Colors.grey.withOpacity(0.5),
                height: Screen.width(context) * .56,
                // padding: EdgeInsets.only(top: 50),
                alignment: Alignment.center,
                child: Icon(Icons.play_circle_outlined, color: Colors.white, size: 30),
              ),
            )),
      ]);
    } else
      return Row(
        children: [
          // ClipRRect(borderRadius: BorderRadius.circular(10.0), child: UIHelper.getImage('$basePath$url', Screen.width(context) - 8, Screen.width(context) * .56))
          // ClipRRect(borderRadius: BorderRadius.circular(20.0), child: Image.network('$basePath$url', width: Screen.width(context) - 4, height: Screen.width(context) * .56, fit: BoxFit.contain))
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(20), // Image border
          //   child: SizedBox.fromSize(
          //     size: Size.fromRadius(100), // Image radius
          //     child: Image.network('$basePath$url'),
          //   ),
          // )
          // Container(
          //     width: get_width - 50.0,
          //     height: get_height,
          //     // width: Screen.width(context),
          //     //  height: 200.0,
          //     decoration: new BoxDecoration(
          //       // shape: BoxShape.rectangle,
          //       image: new DecorationImage(fit: BoxFit.contain, image: NetworkImage('$basePath$url')),
          //       borderRadius: BorderRadius.all(Radius.circular(8.0)),
          //     )),
          UIHelper.verticalSpaceSmall,
          Container(

              // width: Screen.width(context) - 4.5,
              // height: Screen.width(context) * .56,

              child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network('$basePath$url', fit: BoxFit.contain, width: Screen.width(context) - 4.5, height: 250
                // height: Screen.width(context) * .56,
                //height: 200.0,
                ),
          ))
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    if (locator<PreferencesService>().isReloadFeed.value == true) {
      locator<PreferencesService>().isReloadFeed.value = false;
      modelRef.getuserfeedList(true);
      setState(() {});
    }
    return ViewModelBuilder<ActivityFeedWidgetModel>.reactive(
        onModelReady: (model) async {
          modelRef = model;
          await model.init();
          await modelRef.getuserfeedList(true);
        },
        builder: (context, model, child) {
          //print()
          if (locator<PreferencesService>().isReload.value == true) {
            locator<PreferencesService>().isReload.value = false;
            modelRef.getuserfeedList(true);
          }
          return Expanded(
              child: Container(
            // padding: EdgeInsets.all(8),
            // height: Screen.height(context) / 2,
            // padding: EdgeInsets.symmetric(horizontal: 1),
            height: Screen.height(context),
            decoration: UIHelper.roundedBorderWithColorWithShadow(6, fieldBgColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('   Your Update : ').fontSize(13).bold(),
                      showSwarMessageField(context, model),
                      UIHelper.verticalSpaceMedium,
                      Container(
                          margin: EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          height: 30,
                          padding: EdgeInsets.only(left: 6),
                          //camera
                          child: Row(children: [
                            GestureDetector(
                                onTap: _textFieldController.text.isEmpty
                                    ? () async {
                                        // showFilePickerSheet('type');
                                        FocusScope.of(context).unfocus();
                                        get_file('', FileType.video);
                                      }
                                    : null,
                                //attached
                                child: Icon(Icons.camera_alt, color: activeColor, size: 20)),
                            UIHelper.horizontalSpaceSmall,
                            GestureDetector(
                                onTap: _textFieldController.text.isEmpty
                                    ? () async {
                                        FocusScope.of(context).unfocus();
                                        await pickAFile();
                                        //_compressVideo();
                                      }
                                    : null,
                                child: Icon(Icons.attach_file, color: Colors.black, size: 20)),
                          ])),
                    ],
                  ),
                ),
                UIHelper.verticalSpaceTiny,
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0.0,
                        ),
                        //RefreshIndicator(
                        // child: RefreshIndicator(

                        // child: StreamBuilder<bool?>(
                        //     stream: locator<PreferencesService>().isReloadFeed.stream,
                        //     builder: (context, snapshotname) =>

                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            // physics: NeverScrollableScrollPhysics(),

                            primary: false, //
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: model.listmembers.length,
                            itemBuilder: (context, index) {
                              dynamic memberinfo = model.listmembers[index];
                              // dynamic likelist = memberinfo['likes'];
                              Jiffy dateat = Jiffy(memberinfo['createdAt']);
                              dynamic imgurl = memberinfo['azureBlobStorageLink'] != null ? memberinfo['azureBlobStorageLink'] : "";
                              dynamic imgUrl = '${ApiService.fileStorageEndPoint}$imgurl';
                              // print('LINK>>>>>>>>>>>>>>>>>>>>'+model.outputList.toString());
                              //comments get user imageurl
                              String usersName = memberinfo['profile_name'];
                              dynamic feedImgurl = memberinfo['profile_img'];
                              dynamic feedImgUrl = feedImgurl != "" && feedImgurl != null ? '${ApiService.fileStorageEndPoint}$feedImgurl' : '';
                              String category = memberinfo['feeds_category'];
                              bool isLike = memberinfo['likestate'] == "LikedUser" ? true : false;
                              bool isCare = memberinfo['carestate'] == "CaredUser" ? true : false;
                              bool isDonate = memberinfo['donatestate'] == "DonatedUser" ? true : false;
                              bool islikePressed = false;
                              return Container(
                                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                margin: EdgeInsets.only(bottom: 5),
                                decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.white),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        UIHelper.horizontalSpaceMedium,
                                        feedImgUrl == '' || feedImgUrl.contains('null')
                                            ? Container(
                                                // decoration: UIHelper.roundedBorderWithColor(15, Colors.blue),
                                                // child: Icon(Icons.portrait),
                                                child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                                                width: 43,
                                                height: 43,
                                              )
                                            : locator<PreferencesService>().userId == memberinfo['user_Id'].toString()
                                                ? StreamBuilder<String?>(
                                                    stream: locator<PreferencesService>().profileUrl.outStream,
                                                    builder: (context, snapshot) => !snapshot.hasData || snapshot.data == ''
                                                        ? Container(
                                                            child: Icon(Icons.account_circle, size: 40, color: Colors.grey),
                                                            width: 40,
                                                            height: 40,
                                                          )
                                                        : Container(
                                                            padding: EdgeInsets.all(5),
                                                            // decoration: UIHelper.roundedBorderWithColor(4, greyColor),
                                                            child: ClipRRect(borderRadius: BorderRadius.circular(80.0), child: UIHelper.getImage(snapshot.data!, 40, 40)),
                                                          ),
                                                  )
                                                : ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getImage(feedImgUrl, 43, 43)),
                                        UIHelper.horizontalSpaceSmall,
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            //Text(users_name).fontSize(14).fontWeight(FontWeight.w500),
                                            StreamBuilder<String?>(
                                                stream: locator<PreferencesService>().userName.outStream,
                                                builder: (context, snapshotname) => !snapshotname.hasData || snapshotname.data == '' ? Text(usersName).fontSize(14).bold() : Text(snapshotname.data!).fontSize(14).bold()),
                                            Text(dateat.fromNow()).fontSize(12).textColor(Colors.black38),
                                            UIHelper.verticalSpaceSmall,
                                          ],
                                        )),
                                      ],
                                    ),
                                    memberinfo['profilestatus'] != ""
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              UIHelper.verticalSpaceSmall,
                                              UIHelper.horizontalSpaceMedium,
                                              Flexible(
                                                  child: Text(
                                                memberinfo['profilestatus'] != null ? memberinfo['profilestatus'] : '' + '\n',
                                              )),
                                              // Text(
                                              //   memberinfo['profilestatus'],
                                              // ),
                                              // Text(
                                              //   '\n',
                                              // ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                            ],
                                          )
                                        : Container(
                                            child: SizedBox(
                                              height: 10,
                                            ),
                                          ),
                                    GestureDetector(
                                        onTap: () async {
                                          String url = memberinfo['feedpost_azureBlobStorageLink'] != null ? memberinfo['feedpost_azureBlobStorageLink'].toString() : "";
                                          String basePath = ApiService.fileStorageEndPoint;
                                          if (url.contains('.mp4')) {
                                            // VideoPlayerWidget(
                                            //   videoUrl: '$basePath$url',
                                            // );
                                            // showGeneralDialog(
                                            //     context: context,
                                            //     pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                                            //       return _buildDialog(context);
                                            //     });
                                          }
                                        },
                                        // child: memberinfo['feedpost_azureBlobStorageLink'] != null && memberinfo['feedpost_azureBlobStorageLink'].isNotEmpty ||
                                        //         memberinfo['thumbnail_azureBlobStorageLink'] != null && memberinfo['thumbnail_azureBlobStorageLink'].isnotEmpty
                                        //     ? getAttachmentWidget(memberinfo)
                                        //     : SizedBox()
                                        child: memberinfo['feedpost_azureBlobStorageLink'] != "" && memberinfo['feedpost_azureBlobStorageLink'] != null ||
                                                memberinfo['thumbnail_azureBlobStorageLink'] != "" && memberinfo['thumbnail_azureBlobStorageLink'] != null
                                            ? getAttachmentWidget(memberinfo)
                                            : SizedBox()),
                                    UIHelper.verticalSpaceTiny,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              // width: 50,
                                              alignment: Alignment.center,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    isCare = !isCare;
                                                    memberinfo['carestate'] = isCare ? "CaredUser" : "";
                                                    int countCare = isCare ? int.parse(memberinfo['cares_count']) + 1 : int.parse(memberinfo['cares_count']) - 1;
                                                    memberinfo['cares_count'] = countCare.toString();
                                                  });
                                                  //await model.setcare(memberinfo['_id'], isCare);
                                                  model.setcare(memberinfo['_id'], isCare);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(2.0),
                                                  child: Column(
                                                    children: [
                                                      //
                                                      isCare
                                                          ? Icon(
                                                              Icons.volunteer_activism,
                                                              color: activeColor,
                                                              size: 18,
                                                            )
                                                          : Icon(
                                                              Icons.volunteer_activism,
                                                              color: Colors.black38,
                                                              size: 18,
                                                            ),
                                                      memberinfo['cares_count'] != null ? Text("Care (" + memberinfo['cares_count']!.toString() + ")").fontSize(11) : Text("Care (0)").fontSize(11)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            UIHelper.horizontalSpaceSmall,
                                            Container(
                                              // width: 50,
                                              alignment: Alignment.center,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    isLike = !isLike;
                                                    memberinfo['likestate'] = isLike ? "LikedUser" : "";

                                                    int countLike = isLike ? int.parse(memberinfo['likes_count']) + 1 : int.parse(memberinfo['likes_count']) - 1;

                                                    memberinfo['likes_count'] = countLike.toString();
                                                    //mem{'coun='}+1;
                                                  });
                                                  //await model.setlike(memberinfo['_id'], isLike);
                                                  await model.setlike(memberinfo['_id'], isLike);
                                                  setState(() {});
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Column(
                                                    children: [
                                                      isLike
                                                          ? Icon(
                                                              Icons.thumb_up,
                                                              color: activeColor,
                                                              size: 18,
                                                            )
                                                          : Icon(
                                                              Icons.thumb_up_outlined,
                                                              color: Colors.black38,
                                                              size: 18,
                                                            ),
                                                      // Text("Like").fontSize(11)
                                                      memberinfo['likes_count'] != null ? Text("Like (" + memberinfo['likes_count']!.toString() + ")").fontSize(11) : Text("Like (0)").fontSize(11)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            UIHelper.horizontalSpaceSmall,
                                            Container(
                                              // width: 70,
                                              alignment: Alignment.center,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    isDonate = !isDonate;
                                                    memberinfo['donatestate'] = isDonate ? "DonatedUser" : "";
                                                    int countDonate = isDonate ? int.parse(memberinfo['donates_count']) + 1 : int.parse(memberinfo['donates_count']) - 1;
                                                    memberinfo['donates_count'] = countDonate.toString();
                                                  });
                                                  //await model.setdonate(memberinfo['_id'], isDonate);
                                                  model.setdonate(memberinfo['_id'], isDonate);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Column(
                                                    children: [
                                                      isDonate
                                                          ? Icon(
                                                              Icons.clean_hands,
                                                              color: activeColor,
                                                              size: 18,
                                                            )
                                                          : Icon(
                                                              Icons.clean_hands_outlined,
                                                              color: Colors.black38,
                                                              size: 18,
                                                            ),
                                                      // Text("Donate").fontSize(11)
                                                      memberinfo['donates_count'] != null ? Text("Donate (" + memberinfo['donates_count'].toString() + ")").fontSize(11) : Text("Donate (0)").fontSize(11)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            UIHelper.horizontalSpaceSmall,
                                            //share
                                            Container(
                                              //   width: 50,
                                              alignment: Alignment.center,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  String basePath = ApiService.fileStorageEndPoint;

                                                  Loader.show(context);
                                                  List<String> paths =
                                                      //await model.shareDocs('$basePath/image_cropper_1643887697637_1643887700595.jpg');
                                                      await model.shareDocs(memberinfo["feedpost_azureBlobStorageLink"].isNotEmpty
                                                          ? '$basePath' + memberinfo["feedpost_azureBlobStorageLink"]
                                                          : '$basePath' + memberinfo["thumbnail_azureBlobStorageLink"]);
                                                  //await model.shareDocs('https://i.ytimg.com/vi/fq4N0hgOWzU/maxresdefault.jpg');
                                                  Loader.hide();
                                                  if (memberinfo["feedpost_azureBlobStorageLink"] != "" || memberinfo["thumbnail_azureBlobStorageLink"] != "") {
                                                    Share.shareFiles(paths, subject: 'SWAR Doctor', text: memberinfo['profilestatus'].isNotEmpty ? memberinfo['profilestatus'] : '');
                                                    //subject: 'SWAR Doctor'
                                                  } else {
                                                    await Share.share(memberinfo['profilestatus'].isNotEmpty ? memberinfo['profilestatus'] : '', subject: 'SWAR Doctor');
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(2.0),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.share,
                                                        color: Colors.black38,
                                                        size: 18,
                                                      ),
                                                      // : Icon(
                                                      //     Icons.clean_hands_outlined,
                                                      //     color: Colors.black38,
                                                      //     size: 18,
                                                      //   ),
                                                      Text("Share").fontSize(11)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            UIHelper.horizontalSpaceSmall,
                                            Container(
                                              //   width: 50,
                                              alignment: Alignment.center,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  await Get.to(() {
                                                    return FeedcommentView(
                                                      commentinfo: memberinfo,
                                                    );
                                                  });
                                                  await model.getuserfeedList(true);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Column(
                                                    children: [
                                                      //Image.asset('assets/comment_icon.png'),
                                                      Icon(
                                                        Icons.chat_outlined,
                                                        color: Colors.black38,
                                                        size: 18,
                                                      ),
                                                      memberinfo['count'] != null ? Text('Comment (' + memberinfo['count']!.toString() + ")").fontSize(11) : Text('Comment (0)').fontSize(11)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }))
                    // )
                    ),
                // )
              ],
            ),
          ));
        },
        viewModelBuilder: () => ActivityFeedWidgetModel());
  }
}

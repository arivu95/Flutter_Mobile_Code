import 'dart:io';

import 'package:documents_module/src/ui/uploads/camera_capture_view2.dart';
import 'package:documents_module/src/ui/uploads/capture_upload_view.dart';
import 'package:documents_module/src/ui/uploads/uploads_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/frideos/extended_asyncwidgets.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/shared/flutter_loader.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/inappbrowser.dart';
import 'package:swarapp/shared/pdf_viewer.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:filesize/filesize.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:video_compress/video_compress.dart';
import 'package:member_module/src/ui/members/widgets/video_player_widget.dart';
import 'package:showcaseview/showcase.dart';
import 'package:showcaseview/showcase_widget.dart';

class UploadsView extends StatefulWidget {
  const UploadsView({Key? key}) : super(key: key);

  @override
  _UploadsViewState createState() => _UploadsViewState();
}

class _UploadsViewState extends State<UploadsView> {
  UploadsViewmodel modelRef = UploadsViewmodel();
  PreferencesService preferencesService = locator<PreferencesService>();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  TextEditingController statusController = TextEditingController();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _one = GlobalKey();
  BuildContext? myContext;
  List<PlatformFile>? _paths;
  String isvideo = '';
  dynamic membersList;
  String dropdown_member_id = "";
  List getAlertmessage = [];
  String toolbar = '';
  String _counter = "video";
  File? _thumbnailFile;
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

  final List<String> _dropdownValues = [
    "Member One",
    "Member Two",
    "Member Three",
  ]; //The
  String _value = "Member One";
  @override
  void initState() {
    super.initState();
    if (preferencesService.userInfo['profilestatus'] != null) {
      statusController.text = preferencesService.userInfo['profilestatus'];
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) => Future.delayed(Duration(milliseconds: 5000), () {
          ShowCaseWidget.of(myContext!)!.startShowCase([_two]);
        }));

    WidgetsBinding.instance!.addPostFrameCallback((_) => Future.delayed(Duration(milliseconds: 6000), () {
          ShowCaseWidget.of(myContext!)!.startShowCase([_one]);
        }));
    getAlertmessage = preferencesService.alertContentList!.where((msg) => msg['type'] == "Upload image").toList();
    toolbar = getAlertmessage[0]['content'];
  }

  Widget PdfDialog(BuildContext context, String fileUrl) {
    return Dialog(
      insetPadding: EdgeInsets.all(15),
      child: Container(
        child: Stack(
            // child: SingleChildScrollView(
            children: [
              SingleChildScrollView(
                child: SfPdfViewer.network(
                  fileUrl,
                  key: _pdfViewerKey,
                ),
              ),
              Positioned(
                right: 0.0,
                //top: 0.5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      radius: 14.0,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
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
              // Container(padding: EdgeInsets.all(5), child: Text("kjsnfdkjnsd")),
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

  Widget TitleField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(children: [
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back,
          ),
        ),
        UIHelper.horizontalSpaceSmall,
        Text('Uploads').fontSize(15).bold(),
      ]),
    );
  }

  Widget showSearchField(BuildContext context, UploadsViewmodel model) {
    List<dynamic> members = preferencesService.memebersListStream!.value!;

    return StreamedWidget(
        stream: preferencesService.memebersListStream!.outStream!,
        builder: (context, snapshot) {
          List<dynamic> members = preferencesService.memebersListStream!.value!;
          // List<dynamic> members = snapshot.data! as List<dynamic>;
          return Row(
            children: [
              Text('    Hi').fontSize(18).padding(left: 1, right: 1),
              UIHelper.horizontalSpaceSmall,
              members.length > 1
                  ? DropdownButton(
                      // value:model.selectedMembers==null ||model.selectedMembers.isEmpty ?preferencesService.dropdown_user_id :model.selectedMembers,
                      value: preferencesService.dropdown_user_id,
                      //  value:snapshot.data!,
                      // value: model.selectedMembers,
                      items: members.map((e) {
                        return new DropdownMenuItem(
                          value: e['_id'],
                          child: new Text(e['member_first_name']).fontSize(18).bold(),
                          //child: new Text("newmem").fontSize(13),
                        );
                      }).toList(),
                      onChanged: (value) {
                        print(value);

                        setState(() {
                          model.selectedMembers = value.toString();
                          preferencesService.dropdown_user_id = value.toString();
                          //isChange = true;
                        });
                        model.getRecentUploads();
                        // model.getMembersList(false);
                        int found = members.indexWhere((val) => val['_id'] == model.selectedMembers);
                        print(found); // Output you will get is 1
                        String selectedMemberName = members[found]['member_first_name'];
                        String selectedMemberDob = members[found]['date_of_birth'];
                        String selectedMemberAge = members[found]['age'].toString();
                        print(selectedMemberName);
                        setState(() {
                          model.selectedMemberName = selectedMemberName;
                          model.selectedMemberDob = selectedMemberDob;
                          model.selectedMemberAge = selectedMemberAge;
                          //preferencesService.dropdown_user_id=
                          // isChange = true;
                        });
                        dropdown_member_id = model.selectedMembers;
                        //  preferencesService.dropdown_user_id = model.selectedMembers;
                        preferencesService.dropdown_user_name = model.selectedMemberName;
                        preferencesService.dropdownuserName.value = model.selectedMemberName.toString();
                        preferencesService.dropdown_user_dob = model.selectedMemberDob;
                        preferencesService.dropdown_user_age = model.selectedMemberAge;
                        print('selected Membr ID IS-------------' + preferencesService.dropdown_user_id.toString());
                      })
                  : Text(members.length > 0 ? members[0]['member_first_name'].toString() : preferencesService.userInfo['name']).fontSize(18).bold()
            ],
          );
        });
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

  Widget recentItem(BuildContext context, int index, dynamic data) {
    String fileName = data['fileName'] ?? '';
    String thumbnail = data['thumbnail_link'] ?? '';
    String thumbnailPreview = '';
    if (fileName.length > 10) {
      fileName = fileName.substring(0, 9);
    }
    //VID_2022-04-0601-26-09_1649231788533.jpg

    if (thumbnail != null && thumbnail != "") {
      thumbnailPreview = '${ApiService.fileStorageEndPoint}$thumbnail';
    }
    Jiffy date = Jiffy(data['createdAt']);
    String imgUrl = '';
    List imageUrls = data['azureBlobStorageLink'];
    String url = imageUrls.first.toString();
    if (imageUrls.length > 0) {
      imgUrl = '${ApiService.fileStorageEndPoint}${imageUrls.first.toString()}';
    }
    print('isajd --------' + imgUrl);
    return GestureDetector(
      onTap: () async {
        String basePath = ApiService.fileStorageEndPoint;

        (imgUrl.toLowerCase().contains('.pdf'))
            ?
            // await showDialog(
            //     context: context,
            //     builder: (_) => PdfDialog(context, img_url),
            //   )
            await Get.to(() => PdfViewr(url: imgUrl, file_name: fileName))
            //await launch('https://docs.google.com/viewer?url=$img_url')
            : (imgUrl.toLowerCase().contains('.docx')) || (imgUrl.toLowerCase().contains('.xls')) || (imgUrl.toLowerCase().contains('.xlsx'))
                ? launchExternalDoc('https://docs.google.com/viewer?url=$imgUrl&time=${DateTime.now()}')
                : imgUrl.contains('.mp4')
                    ? await showGeneralDialog(
                        context: context,
                        pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                          return VideoPlayerWidget(
                            videoUrl: '$basePath$url',
                          );
                        })
                    : await showDialog(
                        context: context,
                        builder: (_) => ImageDialog(context, imgUrl),
                      );
      },
      child: Column(
        //return Column(
        children: [
          // UIHelper.verticalSpaceTiny,
          //img_url.toLowerCase().contains('.jpg') ||  img_url.toLowerCase().contains('.png')
          // ? ClipRRect(borderRadius: BorderRadius.circular(8), child: UIHelper.getImage(img_url, 80, 60))
          imgUrl.toLowerCase().contains('.docx')
              ? Image.asset(
                  'assets/word_icon.png',
                  fit: BoxFit.none,
                  height: 60,
                  // width: 80,
                )
              : imgUrl.toLowerCase().contains('.pdf')
                  ? Image.asset(
                      'assets/PDF.png',
                      fit: BoxFit.none,
                      height: 60,
                      // width: 80,
                    )
                  : imgUrl.toLowerCase().contains('.xlsx') || imgUrl.toLowerCase().contains('.xls')
                      ? Image.asset(
                          'assets/excel_icon.png',
                          fit: BoxFit.none,
                          height: 60,
                          // width: 80,
                        )
                      : imgUrl.toLowerCase().contains('.mp4')
                          ? data['thumbnail_link'] != "" && data['thumbnail_link'] != null
                              ? ClipRRect(child: UIHelper.getThumbnailImage(thumbnailPreview, 60, 60))
                              : Container(child: Center(child: Icon(Icons.smart_display, size: 60, color: Colors.grey)))
                          : ClipRRect(child: UIHelper.getImage(imgUrl, 60, 60)),

          UIHelper.verticalSpaceTiny,
          Text(fileName).fontSize(11),
          UIHelper.verticalSpaceTiny,
          Text(date.format('MM/dd/yyy')).fontSize(9),
        ],
      ),
    );
  }

  double sideLength = 50;
  //================get recent documents===========
  Widget showUploadDownloads(BuildContext context, UploadsViewmodel model) {
    return StreamedWidget(
        stream: preferencesService.recentdocListStream!.outStream!,
        builder: (context, snapshot) {
          List<dynamic> recentList = preferencesService.recentdocListStream!.value!;
          return recentList.length > 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Text('Recent Documents').fontWeight(FontWeight.w500),
                    Padding(
                      padding: EdgeInsets.only(left: 18, right: 12),
                      child: Text(' Recent Documents').fontWeight(FontWeight.w500).bold(),
                    ),
                    UIHelper.verticalSpaceSmall,
                    model.isBusy
                        ? Container(
                            height: 100,
                            child: Center(
                              child: UIHelper.swarPreloader(),
                            ),
                          )
                        : Container(
                            width: Screen.width(context),
                            height: 100,
                            padding: EdgeInsets.only(left: 18, right: 12),
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: recentList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: UIHelper.roundedBorderWithColor(8, Color(0xFFEFEFEF)),
                                    margin: EdgeInsets.only(right: 8),
                                    width: 80,
                                    // height: 84,
                                    child: recentItem(context, index, recentList[index]),
                                  );
                                }),
                          ),

                    UIHelper.hairLineWidget(),
                  ],
                )
              : Column();
        });
  }

  void getbar() {
    List<dynamic> membersLen = preferencesService.memebersListStream!.value!;
    if (membersLen.length < 1) {
      SwarAppStaticBar();
    } else {
      SwarAppBar(1);
    }
  }

  Future reloadMemberList() async {
    await modelRef.getMembersList(false);
    setState(() {
      membersList = modelRef.listmembers.toList();
      print('===========memberlist value is======' + membersList.length.toString());
      //modelRef.selectedMembers
    });
  }

//============
  _compressVideo(UploadsViewmodel model) async {
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

      // ProgressLoader.show(context);
      // final response = await model.uploadDocuments(_counter, '606d64f2a8adce0a7d52bce4', 'Attach');
      // ProgressLoader.hide();

    }
  }

//============
  @override
  Widget build(BuildContext context) {
    print('+++++++++++++++++upload page' + locator<PreferencesService>().isUploadReload.value.toString());
    if (locator<PreferencesService>().isUploadReload.value == true) {
      locator<PreferencesService>().isUploadReload.value = false;
      modelRef.getMembersList(false);
      // reloadMemberList();
    }
    return ShowCaseWidget(builder: Builder(builder: (context) {
      myContext = context;
      return Scaffold(
        // appBar:  SwarAppBar(1) ,
        appBar: SwarAppStaticBar(),
        body: ViewModelBuilder<UploadsViewmodel>.reactive(
            onModelReady: (model) async {
              modelRef = model;
              await model.init();
              await model.getMembersList(true);
              print('build member call________________');
              // if (model.listmembers.length > 0) {
              //   setState(() {
              //     model.selectedMembers = model.listmembers.first;
              //   });
              // }
            },
            builder: (context, model, child) {
              return model.isBusy
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      // padding: EdgeInsets.only(left: 17, right: 16),
                      //child: SingleChildScrollView(
                      child: Column(
                        children: [
                          UIHelper.verticalSpaceSmall,
                          UIHelper.horizontalSpaceSmall,
                          model.isBusy
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : TitleField(context),
                          UIHelper.verticalSpaceSmall,
                          showSearchField(context, model),
                          UIHelper.verticalSpaceSmall,
                          model.isBusy
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : showUploadDownloads(context, model),
                          //  UIHelper.verticalSpaceSmall,
                          // members.length>1 ?
                          //   UIHelper.hairLineWidget(): Container(),
                          UIHelper.verticalSpaceMedium,
                          Image.asset('assets/happy_to_meet.png'),
                          UIHelper.verticalSpaceLarge,
                          // Expanded(child: SizedBox()),

                          Row(
                            // mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              UIHelper.horizontalSpaceSmall,
                              preferencesService.user_login != ''
                                  ? Showcase(
                                      key: _two,
                                      // title: 'Click here to Subscribe',
                                      description: toolbar,
                                      child: InkWell(
                                          onTap: () async {
                                            print(model.stored_tot.toString());
                                            bool isVideo = false;
                                            try {
                                              preferencesService.user_login = '';
                                              preferencesService.paths.clear();
                                              preferencesService.paths = [];
                                              _paths = (await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: true, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx', 'mp4']))?.files;
                                              if (_paths!.length < 6) {
                                                for (int k = 0; k < _paths!.length; k++) {
                                                  String gt = filesize(_paths![k].size);

                                                  double limitMb = 75.0; // 1Gb ** 75 mb

                                                  //check if  kb
                                                  if (gt.contains('KB') || gt.contains('kb')) {
                                                    // locator<PreferencesService>().isSubscriptionMarkedInSwar()
                                                    //     ? limit_mb = 1000000.00 //1 gb =>kb  *subscribed
                                                    limitMb = 75000.00; //75mb =>kb
                                                  }
                                                  String val = gt.replaceAll(RegExp("[a-zA-Z]"), "");
                                                  val = val.trim();
                                                  if (double.parse(val) <= limitMb) {
                                                    if (_paths![k].path!.toString().contains("mp4") || _paths![k].path!.toString().contains("mp3")) {
                                                      //_compressVideo(model);
                                                      ProgressLoader.show(context);
                                                      await VideoCompress.setLogLevel(0);
                                                      //compressing
                                                      final MediaInfo? info = await VideoCompress.compressVideo(
                                                        _paths![k].path!.toString(),
                                                        quality: VideoQuality.MediumQuality,
                                                        deleteOrigin: false,
                                                        includeAudio: true,
                                                      );

                                                      print("---path file" + info!.path.toString());
                                                      if (info != null) {
                                                        setState(() {
                                                          _counter = info.path!;
                                                        });

                                                        //thumbnail generating
                                                        _thumbnailFile = await VideoCompress.getFileThumbnail(_counter);
                                                        String thumbFilePath = _thumbnailFile!.path;
                                                        preferencesService.paths.insert(0, info.path.toString());
                                                        // preferencesService.thumbnail_paths.insert(0, info!.path.toString());
                                                        preferencesService.thumbnail_paths.addAll({info.path.toString(): thumbFilePath});
                                                        //{'asdf':324};
                                                        //
                                                      }
                                                      ProgressLoader.hide();
                                                    } else {
                                                      setState(() {
                                                        isvideo = "no";
                                                      });

                                                      preferencesService.paths.insert(0, _paths![k].path!);
                                                      // preferencesService.thumbnail_paths.insert(0, _paths![k].path!);
                                                    }
                                                  } else {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return CustomDialogBox(
                                                            title: "Not Allowed !",
                                                            descriptions: "File size cannot be uploaded greater than 75 MB",
                                                            descriptions1: "",
                                                            text: "OK",
                                                          );
                                                        });
                                                    setState(() {
                                                      isvideo = "";
                                                    });
                                                    return;
                                                  }
                                                }

                                                await Get.to(() => CaptureUploadView(camera_mode: "Attach"));
                                                model.getRecentUploads();
                                              } else {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return CustomDialogBox(
                                                        title: "Not Allowed !",
                                                        descriptions: "Files can be allowed within 5",
                                                        descriptions1: "",
                                                        text: "OK",
                                                      );
                                                    });
                                                setState(() {
                                                  isvideo = "";
                                                });
                                              }
                                            } catch (e) {
                                              print(e.toString());
                                            }
                                          },
                                          child: Image.asset(
                                            'assets/attach_file.png',
                                            width: 84,
                                            height: 70,
                                            fit: BoxFit.cover,
                                          )))
                                  : GestureDetector(
                                      onTap: () async {
                                        print(model.stored_tot.toString());
                                        bool isVideo = false;
                                        try {
                                          preferencesService.paths.clear();
                                          preferencesService.paths = [];
                                          _paths = (await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: true, allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'xls', 'xlsx', 'mp4']))?.files;
                                          if (_paths!.length < 6) {
                                            for (int k = 0; k < _paths!.length; k++) {
                                              String gt = filesize(_paths![k].size);

                                              double limitMb = 75.0; // 1Gb ** 75 mb

                                              //check if  kb
                                              if (gt.contains('KB') || gt.contains('kb')) {
                                                // locator<PreferencesService>().isSubscriptionMarkedInSwar()
                                                //     ? limit_mb = 1000000.00 //1 gb =>kb  *subscribed
                                                limitMb = 75000.00; //75mb =>kb
                                              }
                                              String val = gt.replaceAll(RegExp("[a-zA-Z]"), "");
                                              val = val.trim();
                                              if (double.parse(val) <= limitMb) {
                                                if (_paths![k].path!.toString().contains("mp4") || _paths![k].path!.toString().contains("mp3")) {
                                                  //_compressVideo(model);
                                                  ProgressLoader.show(context);
                                                  await VideoCompress.setLogLevel(0);
                                                  //compressing
                                                  final MediaInfo? info = await VideoCompress.compressVideo(
                                                    _paths![k].path!.toString(),
                                                    quality: VideoQuality.MediumQuality,
                                                    deleteOrigin: false,
                                                    includeAudio: true,
                                                  );

                                                  print("---path file" + info!.path.toString());
                                                  if (info != null) {
                                                    setState(() {
                                                      _counter = info.path!;
                                                    });

                                                    //thumbnail generating
                                                    _thumbnailFile = await VideoCompress.getFileThumbnail(_counter);
                                                    String thumbFilePath = _thumbnailFile!.path;
                                                    preferencesService.paths.insert(0, info.path.toString());
                                                    // preferencesService.thumbnail_paths.insert(0, info!.path.toString());
                                                    preferencesService.thumbnail_paths.addAll({info.path.toString(): thumbFilePath});
                                                    //{'asdf':324};
                                                    //
                                                  }
                                                  ProgressLoader.hide();
                                                } else {
                                                  setState(() {
                                                    isvideo = "no";
                                                  });

                                                  preferencesService.paths.insert(0, _paths![k].path!);
                                                  // preferencesService.thumbnail_paths.insert(0, _paths![k].path!);
                                                }
                                              } else {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return CustomDialogBox(
                                                        title: "Not Allowed !",
                                                        descriptions: "File size cannot be uploaded greater than 75 MB",
                                                        descriptions1: "",
                                                        text: "OK",
                                                      );
                                                    });
                                                setState(() {
                                                  isvideo = "";
                                                });
                                                return;
                                              }
                                            }

                                            await Get.to(() => CaptureUploadView(camera_mode: "Attach"));
                                            model.getRecentUploads();
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return CustomDialogBox(
                                                    title: "Not Allowed !",
                                                    descriptions: "Files can be allowed within 5",
                                                    descriptions1: "",
                                                    text: "OK",
                                                  );
                                                });
                                            setState(() {
                                              isvideo = "";
                                            });
                                          }
                                        } catch (e) {
                                          print(e.toString());
                                        }
                                      },
                                      child: Image.asset(
                                        'assets/attach_file.png',
                                        width: 84,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      )),
                              preferencesService.user_login != ''
                                  ? Container(
                                      child: Showcase(
                                          key: _one,
                                          // title: 'Click here to Subscribe',
                                          description: toolbar,
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 8, left: 0, right: 0, top: 0),
                                            child: InkWell(
                                              onTap: () async {
                                                preferencesService.paths = [];
                                                preferencesService.user_login = '';
                                                await Get.to(() => CameraCaptureViewTwo());
                                                model.getRecentUploads();
                                              },
                                              child: Image.asset(
                                                'assets/attach_camera.png',
                                                width: 84,
                                                height: 70,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )))
                                  : GestureDetector(
                                      child: Image.asset(
                                        'assets/attach_camera.png',
                                        width: 84,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                      onTap: () async {
                                        preferencesService.paths = [];
                                        await Get.to(() => CameraCaptureViewTwo());
                                        model.getRecentUploads();
                                      }),
                              // GestureDetector(
                              //     child: Icon(Icons.access_alarm_rounded, color: Colors.red),
                              //     onTap: () async {
                              //       // preferencesService.paths = [];
                              //       // await Get.to(() => CameraCaptureViewTwo());
                              //       // model.getRecentUploads();
                              //       _compressVideo(model);
                              //     }),
                              UIHelper.horizontalSpaceSmall,
                            ],
                          ),
                          // Text(
                          //   '$_counter',
                          // ),
                        ],
                      ),
                      // ),
                    );
            },
            viewModelBuilder: () => UploadsViewmodel()),
      );
    }));
  }
}

// class MyInAppBrowser extends InAppBrowser {
//   @override
//   Future onBrowserCreated() async {
//     print("Browser Created!");
//   }

//   @override
//   Future onLoadStart(url) async {
//     print("Started $url");
//   }

//   @override
//   Future onLoadStop(url) async {
//     print("Stopped $url");
//     String? html = await webViewController.getHtml();
//     if (html == '<html><head></head><body></body></html>') {
//       webViewController.loadUrl(urlRequest: URLRequest(url: url));
//     }
//   }

//   @override
//   void onLoadError(url, code, message) {
//     print("Can't load $url.. Error: $message");
//   }

//   @override
//   void onProgressChanged(progress) {
//     print("Progress: $progress");
//   }

//   @override
//   void onExit() {
//     print("Browser closed!");
//   }
//}

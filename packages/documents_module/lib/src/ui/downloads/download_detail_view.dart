import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:documents_module/src/ui/downloads/dicom_download_details_view.dart';
import 'package:documents_module/src/ui/downloads/download_detail_viewmodel.dart';
import 'package:documents_module/src/ui/downloads/share_internal_doc_view.dart';
import 'package:documents_module/src/ui/medical_records/covid_record_view.dart';
import 'package:documents_module/src/ui/medical_records/vacc_mat_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:share/share.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/pref_util.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/app_bar.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/inappbrowser.dart';
import 'package:swarapp/shared/pdf_viewer.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:swarapp/shared/custom_dialog_box.dart';
import 'package:swarapp/services/connectycube_services.dart';
import 'package:swarapp/ui/startup/terms_view.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:member_module/src/ui/members/widgets/video_player_widget.dart';

class DownloadDetailView extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final String dicomfilename;
  DownloadDetailView({Key? key, required this.categoryId, required this.categoryTitle, required this.dicomfilename}) : super(key: key);

  @override
  _DownloadDetailViewState createState() => _DownloadDetailViewState();
}

class _DownloadDetailViewState extends State<DownloadDetailView> {
  DownloadDetailViewmodel modelRef = DownloadDetailViewmodel();
  List<String> docIds = [];
  List<String> img_lst = [];
  List<dynamic> data_List = [];
  bool isLongPressOn = false;
  bool isHorizontalScroll = false;
  bool isEditable = false;
  String codeDialog = "";
  String valueText = "";
  String editable = "";
  DateTime currentDate = DateTime.now();
  TextEditingController searchController = TextEditingController();
  TextEditingController _controller = TextEditingController();
  TextEditingController _textFieldController = TextEditingController();
  PageController sliderController = PageController(initialPage: 0, keepPage: false);
  late CubeUser? currentUser;
  ConnectyCubeServices connectyCubeServices = locator<ConnectyCubeServices>();
  List getAlertmessage = [];
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

  void getChatDialogs() async {
    currentUser = await SharedPrefs.getUser();
    await connectyCubeServices.getCubeDialogs();
  }

  //for doalog boxShadow
  Future<void> _displayTextInputDialog(BuildContext context, String filename, String docid, model) async {
    void initState() {
      super.initState();
      _textFieldController = TextEditingController(text: filename);
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit'),
            content: TextField(
              //controller: _textFieldController,
              controller: TextEditingController(text: filename),
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
                // _textFieldController = TextEditingController(text: filename);
              },
              decoration: InputDecoration(hintText: filename),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () async {
                  if (valueText == "") {
                    //cursorColor: Color(0XFFFFCC00);
                    Navigator.pop(context);
                    cursorColor:
                    Colors.red;
                  } else {
                    setState(() {
                      docIds.clear();
                      Navigator.pop(context);
                    });

                    _textFieldController = TextEditingController(text: valueText);
                    _controller = TextEditingController(text: valueText);
                    locator<PreferencesService>().isReload.value == false;
                    await model.renameFile(docid, valueText);
                    widget.categoryId == "62034da4347bca06a597c2ea" ? model.getDicomFilesByCategory(widget.categoryId, widget.dicomfilename) : model.getFilesByCategory(widget.categoryId);

                    valueText = "";
                  }
                },
              ),
            ],
          );
        });
  }

//
  Future<void> _selectDate(BuildContext context, DownloadDetailViewmodel model) async {
    final DateTime? pickedDate = (await showDatePicker(context: context, cancelText: 'Clear', initialDate: currentDate, firstDate: DateTime(1900), lastDate: DateTime.now()));
    if (pickedDate != null) {
      setState(() {
        currentDate = pickedDate;
      });

      print(currentDate);
      Jiffy selectedDt = Jiffy(currentDate);
      searchController.text = '';
      model.filteredDateStr = selectedDt.format('dd MMM yyyy');
      model.sortMode = 'date';
      model.refreshView();
    } else {
      print('Cancel Picked');
      searchController.text = '';
      model.filteredDateStr = '';
      model.sortMode = 'date';
      model.refreshView();
    }
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

// @override
  Widget ImageDialog(BuildContext context, String fileUrl, List imageList) {
    return Dialog(
        backgroundColor: Color.fromRGBO(105, 105, 105, 0.5),
        insetPadding: EdgeInsets.all(15),
        child: Container(
          child: Stack(
            // child: SingleChildScrollView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: PageView.builder(
                    controller: sliderController,
                    itemCount: imageList.length,
                    itemBuilder: (context, position) {
                      return PinchZoom(
                        // image:DecorationImage(),
                        // image: Image.network(file_url),
                        image: Image.network(imageList[position]),
                        zoomedBackgroundColor: Colors.black.withOpacity(0.5),
                        resetDuration: const Duration(milliseconds: 100),
                        maxScale: 2.5,
                        onZoomStart: () {
                          print('Start zooming');
                        },
                        onZoomEnd: () {
                          print('Stop zooming');
                        },
                      );
                    }),
              ),
              Positioned(
                right: 10.0,
                top: 10.5,
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

  Widget PdfDialog(BuildContext context, String fileUrl) {
    final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
    return Dialog(
      insetPadding: EdgeInsets.all(15),
      child: Container(
        child: Stack(
            // child: SingleChildScrollView(
            children: [
              SingleChildScrollView(
                child: SfPdfViewer.network(
                  fileUrl,
                  //'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
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

  Widget showSearchField(BuildContext context, DownloadDetailViewmodel model) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: searchController,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (value) {
          model.updateOnTextSearch(value);
        },
        style: TextStyle(fontSize: 14),
        decoration: new InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
              size: 20,
            ),
            suffixIcon: searchController.text.isEmpty
                ? SizedBox()
                : IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.black38,
                    ),
                    onPressed: () {
                      searchController.text = '';
                      model.updateOnTextSearch('');
                      FocusManager.instance.primaryFocus!.unfocus();
                    }),
            contentPadding: EdgeInsets.only(left: 20),
            enabledBorder: UIHelper.getInputBorder(1, radius: 24, borderColor: Color(0xFFCCCCCC)),
            focusedBorder: UIHelper.getInputBorder(1, radius: 24, borderColor: Color(0xFFCCCCCC)),
            focusedErrorBorder: UIHelper.getInputBorder(1, radius: 24, borderColor: Color(0xFFCCCCCC)),
            errorBorder: UIHelper.getInputBorder(1, radius: 24, borderColor: Color(0xFFCCCCCC)),
            filled: true,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            hintText: "Search documents",
            fillColor: Colors.white70),
      ),
    );
  }

  void onDocSelect(String docid, String imgUrl, dynamic data) {
    if (docIds.contains(docid)) {
      docIds.remove(docid);
      img_lst.remove(imgUrl);
      data_List.remove(data);
    } else {
      docIds.add(docid);
      img_lst.add(imgUrl);
      data_List.add(data);
    }
    setState(() {});
    if (docIds.length == 0) {
      setState(() {
        isLongPressOn = false;
      });
    }
  }

  Widget recentItem(BuildContext context, int index, dynamic data, DownloadDetailViewmodel model) {
    String docid = data['_id'];
    String fileName = data['fileName'] ?? '';
    String thumbnail = data['thumbnail_link'] ?? '';
    String thumbnailPreview = '';
    if (fileName.length > 10) {
      fileName = fileName.substring(0, 9);
    }
    if (thumbnail != null && thumbnail != "") {
      thumbnailPreview = '${ApiService.fileStorageEndPoint}$thumbnail';
    }
    Jiffy date = Jiffy(data['createdAt']);
    String imgUrl = '';
    List imageUrls = data['azureBlobStorageLink'];
    if (imageUrls.length > 0) {
      imgUrl = '${ApiService.fileStorageEndPoint}${imageUrls.first.toString()}';
    }

    return GestureDetector(
      onLongPress: () {
        onDocSelect(docid, imgUrl, data);
        setState(() {
          isLongPressOn = true;
        });
      },
      onTap: () async {
        if (isLongPressOn) {
          onDocSelect(docid, imgUrl, data);
          return;
        }
        (imgUrl.toLowerCase().contains('.pdf'))
            ?
            //  await showDialog(
            //     context: context,
            //     builder: (_) => PdfDialog(context, img_url),
            //   )
            await Get.to(() => PdfViewr(url: imgUrl, file_name: fileName))
            : (imgUrl.toLowerCase().contains('.docx')) || (imgUrl.toLowerCase().contains('.xxls')) || (imgUrl.toLowerCase().contains('.xls'))
                ? launchExternalDoc('https://docs.google.com/viewer?url=$imgUrl&time=${DateTime.now()}')
                : imgUrl.contains('.mp4')
                    ? await showGeneralDialog(
                        context: context,
                        pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                          return VideoPlayerWidget(
                            videoUrl: imgUrl,
                          );
                        })
                    : await showDialog(
                        context: context,
                        builder: (_) {
                          int pageIndex = model.imageUrls.indexOf(imgUrl);
                          if (pageIndex > 0) {
                            sliderController = PageController(initialPage: pageIndex, keepPage: false);
                          }
                          return ImageDialog(context, imgUrl, model.imageUrls);
                        });
      },
      child: Stack(
        children: [
          Column(
            children: [
              imgUrl.toLowerCase().contains('.DCM')
                  ? GestureDetector(
                      onTap: () async {
                        String filename = imageUrls[0];
                        String dicomFilename = filename.split('.DCM').first;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DicomDownloadDetailView(
                                      categoryId: widget.categoryId,
                                      categoryTitle: dicomFilename,
                                      dicomfilename: dicomFilename,
                                    )));
                      },
                      child: Image.asset(
                        'assets/folder.png',
                        height: 60,
                        width: 80,
                      ),
                    )
                  : imgUrl.toLowerCase().contains('.docx')
                      ? Image.asset(
                          'assets/word_icon.png',
                          fit: BoxFit.none,
                          height: 60,
                          width: 80,
                        )
                      : imgUrl.toLowerCase().contains('.pdf')
                          ? Image.asset(
                              'assets/PDF.png',
                              fit: BoxFit.none,
                              height: 60,
                              width: 80,
                            )
                          : imgUrl.toLowerCase().contains('.xxls') || imgUrl.toLowerCase().contains('.xlsx')
                              ? Image.asset(
                                  'assets/excel_icon.png',
                                  fit: BoxFit.none,
                                  height: 60,
                                  width: 80,
                                )
                              // : img_url.toLowerCase().contains('.mp4')
                              //     ? ClipRRect(child: UIHelper.getThumbnailImage(thumbnail_preview, 60, 60))
                              : imgUrl.toLowerCase().contains('.mp4')
                                  ? thumbnailPreview != "" && thumbnailPreview != null
                                      ? ClipRRect(child: UIHelper.getThumbnailImage(thumbnailPreview, 60, 60))
                                      : Container(child: Center(child: Icon(Icons.smart_display, size: 60, color: Colors.grey)))
                                  : ClipRRect(child: UIHelper.getImage(imgUrl, 80, 60)),
              UIHelper.verticalSpaceTiny,
              // Text(fileName).fontSize(11),
              Padding(
                  padding: new EdgeInsets.all(1.0),
                  // child: new Text(fileName).fontSize(11),
                  child: new Text((fileName), overflow: TextOverflow.ellipsis)),
              UIHelper.verticalSpaceTiny,
              // Text(date.format('dd/MM/yyy')).fontSize(9),
              UIHelper.horizontalSpaceSmall,
              GestureDetector(
                child: Icon(
                  Icons.edit,
                  size: 12,
                  color: activeColor,
                ),
                onTap: () {
                  _displayTextInputDialog(context, fileName, docid, model);
                },
              ),
            ],
          ),
          docIds.contains(docid)
              ? SizedBox(
                  width: 80,
                  height: 50,
                  child: Center(
                    child: Image.asset('assets/selected_check.png'),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  Widget showHorizontalList(List<dynamic> records, DownloadDetailViewmodel model) {
    return Container(
      width: Screen.width(context),
      height: 100,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: records.length,
          itemBuilder: (context, index) {
            dynamic data = records[index];
            String docid = data['_id'];
            // String img_url = data['img_url'] ?? '';
            List imageUrls = data['azureBlobStorageLink'];
            String imgUrl = '';
            if (imageUrls.length > 0) {
              // img_url = imageUrls.first.toString();
              imgUrl = '${ApiService.fileStorageEndPoint}${imageUrls.first.toString()}';
            }

            String filename = imgUrl;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: recentItem(context, index, data, model),
            );
          }),
    );
  }

  Widget showFileList(BuildContext context, DownloadDetailViewmodel model) {
    //_controller.addListener(_printValue);
    return model.fileSections.length == 0
        ? Container(
            child: Center(
              child: Text('No files found'),
            ),
          )
        : ListView.builder(
            itemCount: model.fileDates.length,
            itemBuilder: (context, index) {
              String dateStr = model.fileDates[index];
              if (model.fileSections[dateStr] == null) {
                return SizedBox();
              }
              List records = model.fileSections[dateStr]!;
              return Column(
                children: [
                  Row(
                    children: [
                      // UIHelper.horizontalSpaceSmall,
                      // ***internal sharing
                      //
                      Expanded(child: Text(dateStr).fontSize(13).fontWeight(FontWeight.w600)),
                      UIHelper.horizontalSpaceSmall,
                      GestureDetector(
                          onTap: () async {
                            if (docIds.isNotEmpty) {
                              List<String> ids = docIds.toList();
                              await Get.to(() => ShareInternalDocumentsView(docIds: docIds, dataList: data_List, categoryId: widget.categoryId, userListId: model.ccIds));

                              setState(() {
                                docIds.clear();
                                isLongPressOn = false;
                              });
                            } else {
                              // locator<DialogService>().showDialog(title: 'Warning', description: 'Please select anyone file');
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialogBox(
                                      title: "Alert !",
                                      descriptions: "Please select file",
                                      descriptions1: "",
                                      text: "OK",
                                    );
                                  });
                            }
                          },
                          // child: Icon(
                          //   Icons.arrow_back_ios,
                          //   size: 20,
                          // ),
                          child: Image.asset('assets/in_share_one.png')),

                      IconButton(
                        icon: Icon(
                          Icons.share,
                        ),
                        iconSize: 20,
                        onPressed: () async {
                          if (docIds.isNotEmpty) {
                            Loader.show(context);
                            List<String> paths = await model.shareDocs(docIds);
                            Loader.hide();
                            await Share.shareFiles(paths, subject: 'SWAR Doctor');
                            Future.delayed(Duration(milliseconds: 1500), () {
                              setState(() {
                                isLongPressOn = false;
                                docIds.clear();
                              });
                            });
                          } else {
                            //locator<DialogService>().showDialog(title: 'Warning', description: 'Please select anyone file');
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogBox(
                                    title: "Alert !",
                                    descriptions: "Please select file",
                                    descriptions1: "",
                                    text: "OK",
                                  );
                                });
                          }
                        },
                        splashColor: Colors.blue,
                      ),

                      UIHelper.horizontalSpaceSmall,

                      IconButton(
                        icon: Icon(Icons.delete),
                        iconSize: 20,
                        onPressed: () async {
                          if (docIds.isNotEmpty) {
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
                                          setState(() {
                                            docIds.clear();
                                            isLongPressOn = !isLongPressOn;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      FlatButton(
                                        color: Colors.green,
                                        textColor: Colors.white,
                                        child: Text('Yes'),
                                        onPressed: () async {
                                          Loader.show(context);
                                          await model.deleteDocs(docIds);
                                          locator<PreferencesService>().isReload.value = true;
                                          locator<PreferencesService>().isUploadReload.value = true;
                                          locator<PreferencesService>().isDownloadReload.value = true;
                                          Loader.hide();
                                          Navigator.pop(context);
                                          setState(() {
                                            isLongPressOn = !isLongPressOn;
                                            docIds.clear();
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                });
                          } else {
                            // locator<DialogService>().showDialog(title: 'Warning', description: 'Please select anyone file');
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogBox(
                                    title: "Alert !",
                                    descriptions: "Please select file",
                                    descriptions1: "",
                                    text: "OK",
                                  );
                                });
                          }
                        },
                        splashColor: Colors.blue,
                      ),

                      UIHelper.horizontalSpaceSmall,
                      GestureDetector(
                        onTap: () async {
                          print(docIds.toString());
                          //                   final isPermissionStatusGranted = await requestPermissions();
                          // if (isPermissionStatusGranted) {
                          // print("CURETN STATUSUS ^^^^^^^"+model.requestPermissions().toString());
                          final istru = await model.requestPermissions();
                          if (istru) {
                            if (docIds.isNotEmpty) {
                              print(docIds);
                              Loader.show(context);
                              //if allow permissions to download
                              await model.download(docIds);
                              Loader.hide();
                              setState(() {
                                isLongPressOn = !isLongPressOn;
                                docIds.clear();
                              });
                              //locator<DialogService>().showDialog(title: 'Download Complete', description: 'Files stored in downloads folder');
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialogBox(
                                      title: "Download Complete",
                                      descriptions: getAlertmessage[0]['content'],
                                      //"File stored in download folder of your device",
                                      descriptions1: "",
                                      text: "OK",
                                    );
                                  });
                            } else {
                              //locator<DialogService>().showDialog(title: 'Warning', description: 'Please select anyone file');
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialogBox(
                                      title: "Alert !",
                                      descriptions: "Please select file",
                                      descriptions1: "",
                                      text: "OK",
                                    );
                                  });
                            }
                          } else {
                            Loader.hide();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogBox(
                                    title: "Alert !",
                                    descriptions: "Please select allow access to download the file",
                                    descriptions1: "",
                                    text: "OK",
                                  );
                                });
                          }
                        },
                        child: Icon(
                          Icons.download_rounded,
                          size: 20,
                        ),
                      ),
                      UIHelper.horizontalSpaceSmall,
                    ],
                  ),
                  UIHelper.verticalSpaceSmall,
                  isHorizontalScroll
                      ? showHorizontalList(records, model)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            dynamic data = records[index];
                            String docid = data['_id'];
                            // String img_url = data['img_url'] ?? '';
                            List imageUrls = data['azureBlobStorageLink'];
                            String imgUrl = '';
                            if (imageUrls.length > 0) {
                              // img_url = imageUrls.first.toString();
                              imgUrl = '${ApiService.fileStorageEndPoint}${imageUrls.first.toString()}';
                            }
                            Jiffy date = Jiffy(data['createdAt']);
                            String filename = imgUrl;
                            String thumbnail = data['thumbnail_link'] ?? '';
                            String thumbnailPreview = '';
                            if (thumbnail != null && thumbnail != "") {
                              thumbnailPreview = '${ApiService.fileStorageEndPoint}$thumbnail';
                            }
                            return GestureDetector(
                              onLongPress: () {
                                onDocSelect(docid, imgUrl, records[index]);
                                setState(() {
                                  isLongPressOn = true;
                                });
                              },
                              onTap: () async {
                                if (isLongPressOn) {
                                  onDocSelect(docid, imgUrl, records[index]);
                                  return;
                                }
                                String temp = imgUrl.split('/').last;
                                String dicomFilename = temp.split('.DCM').first;
                                (imgUrl.contains('.DCM'))
                                    ? Get.to(() => DicomDownloadDetailView(
                                          categoryId: widget.categoryId,
                                          categoryTitle: dicomFilename,
                                          dicomfilename: dicomFilename,
                                        ))
                                    : (imgUrl.toLowerCase().contains('.pdf'))
                                        ?
                                        // await showDialog(
                                        //     context: context,
                                        //     builder: (_) => PdfDialog(context, img_url),
                                        //   )
                                        await Get.to(() => PdfViewr(url: imgUrl, file_name: filename))
                                        : (imgUrl.toLowerCase().contains('.docx')) || (imgUrl.toLowerCase().contains('.xxls')) || (imgUrl.toLowerCase().contains('.xlsx'))
                                            ? launchExternalDoc('https://docs.google.com/viewer?url=$imgUrl&time=${DateTime.now()}')
                                            : imgUrl.contains('.mp4')
                                                ? await showGeneralDialog(
                                                    context: context,
                                                    pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                                                      return VideoPlayerWidget(
                                                        videoUrl: imgUrl,
                                                      );
                                                    })
                                                : await showDialog(
                                                    context: context,
                                                    builder: (_) {
                                                      int pageIndex = model.imageUrls.indexOf(imgUrl);
                                                      if (pageIndex >= 0) {
                                                        sliderController = PageController(initialPage: pageIndex, keepPage: false);
                                                      }
                                                      return ImageDialog(context, imgUrl, model.imageUrls);
                                                    });
                              },
                              child: Container(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          //decoration: UIHelper.roundedBorderWithColor(6, Colors.black12, borderColor: Colors.black45),
                                          width: 46,
                                          height: 50,
                                          child: imgUrl.contains('.DCM')
                                              ? Image.asset(
                                                  'assets/folder.png',
                                                  height: 60,
                                                  width: 80,
                                                )
                                              : imgUrl.toLowerCase().contains('.docx')
                                                  ? Image.asset(
                                                      'assets/word_icon.png',
                                                      fit: BoxFit.none,
                                                      // height: 60,
                                                      // width: 80,
                                                    )
                                                  : imgUrl.toLowerCase().contains('.pdf')
                                                      ? Image.asset(
                                                          'assets/PDF.png',
                                                          fit: BoxFit.none,
                                                          // height: 60,
                                                          // width: 80,
                                                        )
                                                      : imgUrl.toLowerCase().contains('.xxls') || imgUrl.toLowerCase().contains('.xlsx')
                                                          ? Image.asset(
                                                              'assets/excel_icon.png',
                                                              fit: BoxFit.none,
                                                              // height: 60,
                                                              // width: 80,
                                                            )
                                                          : imgUrl.toLowerCase().contains('.mp4')
                                                              ? thumbnailPreview != "" && thumbnailPreview != null
                                                                  ? ClipRRect(child: UIHelper.getThumbnailImage(thumbnailPreview, 60, 60))
                                                                  : Container(child: Center(child: Icon(Icons.smart_display, size: 55, color: Colors.grey)))
                                                              : ClipRRect(child: UIHelper.getImage(imgUrl, 46, 0)),
                                        ),
                                        // UIHelper.getImage(img_url, 46, 50,)),
                                        docIds.contains(docid)
                                            ? SizedBox(
                                                width: 46,
                                                height: 50,
                                                child: Center(
                                                  child: Image.asset('assets/selected_check.png'),
                                                ),
                                              )
                                            : SizedBox()
                                      ],
                                    ),
                                    UIHelper.horizontalSpaceSmall,
                                    UIHelper.verticalSpaceLarge,
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          !isEditable
                                              ? Text(filename.split('/').last)
                                              : TextFormField(
                                                  initialValue: filename,
                                                  textInputAction: TextInputAction.done,
                                                  controller: _controller,
                                                  onFieldSubmitted: (value) {
                                                    setState(() => {isEditable = false, filename = value});
                                                  }),
                                          // UIHelper.verticalSpaceTiny,
                                          UIHelper.horizontalSpaceMedium,
                                          Row(
                                            children: [
                                              Text(date.format('MM/dd/yyy')).fontSize(9),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    UIHelper.horizontalSpaceSmall,
                                    GestureDetector(
                                      child: Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: activeColor,
                                      ),
                                      onTap: () {
                                        //setState(()=>{isEditable});
                                        //docIds.setState
                                        // setState(()=>{isEditable=true});
                                        _displayTextInputDialog(context, filename, docid, model);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                  UIHelper.hairLineWidget()
                ],
              );
            });
  }

  Widget showVerticalCategoryButtons(DownloadDetailViewmodel model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: () async {
              // Get.to(() => SubscriptionView());
              await Get.to(() => VaccineMaternityListView(cat_Type: "Child Records"));
              widget.categoryId == "62034da4347bca06a597c2ea" ? model.getDicomFilesByCategory(widget.categoryId, widget.dicomfilename) : model.getFilesByCategory(widget.categoryId);
            },
            child: Text('Manage Child Records', style: TextStyle(fontWeight: FontWeight.w500)).textColor(Colors.black),
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(160, 36)),
              backgroundColor: MaterialStateProperty.all(Color(0xFFe7e7e7)),
            )),
        ElevatedButton(
            onPressed: () async {
              await Get.to(() => VaccineMaternityListView(cat_Type: "Maternity"));
              widget.categoryId == "62034da4347bca06a597c2ea" ? model.getDicomFilesByCategory(widget.categoryId, widget.dicomfilename) : model.getFilesByCategory(widget.categoryId);
            },
            child: Text(' Manage  Maternity  Records', style: TextStyle(fontWeight: FontWeight.w500)).textColor(Colors.black),
            style: ButtonStyle(minimumSize: MaterialStateProperty.all(Size(160, 36)), backgroundColor: MaterialStateProperty.all(Color(0xFFe7e7e7)))),
        UIHelper.verticalSpaceLarge
      ],
    );
  }

  Widget showVerticalCovidButtons(DownloadDetailViewmodel model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: () async {
              // Loader.show(context);
              // await model.getCovidVaccine_LabTest();
              // Loader.hide();
              // Loader.show(context);
              //     Future.delayed(Duration(seconds: 3), () {
              //       Loader.hide();
              //     });
              // await Get.to(() => CovidRecordView(categoryId: widget.categoryId,covidVaccineList:model.vaccines,labTestList:model.labtest));
              //  model.isBusy?
              //  Loader.show(context)
              //  :
              //  Loader.hide();
              //await Get.to(() => CovidRecordView(categoryId: widget.categoryId,covidVaccineList:model.vaccines,labTestList:model.labtest));
              await Get.to(() => CovidRecordView(categoryId: widget.categoryId));
              widget.categoryId == "62034da4347bca06a597c2ea" ? model.getDicomFilesByCategory(widget.categoryId, widget.dicomfilename) : model.getFilesByCategory(widget.categoryId);
            },
            child: Text('Manage C.DOC', style: TextStyle(fontWeight: FontWeight.w500)).textColor(Colors.black),
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(160, 36)),
              backgroundColor: MaterialStateProperty.all(Color(0xFFe7e7e7)),
            )),
        UIHelper.verticalSpaceLarge
      ],
    );
  }

// child:
  @override
  Widget build(BuildContext context) {
    if (locator<PreferencesService>().isReload.value == true) {
      widget.categoryId == "62034da4347bca06a597c2ea" ? modelRef.getDicomFilesByCategory(widget.categoryId, widget.dicomfilename) : modelRef.getFilesByCategory(widget.categoryId);
      locator<PreferencesService>().isReload.value = false;
    }
    getAlertmessage = preferencesService.alertContentList!.where((msg) => msg['type'] == "Document_download").toList();
    return Scaffold(
        backgroundColor: subtleColor,
        //appBar: SwarAppBar(2),
        appBar: SwarAppStaticBar(),
        resizeToAvoidBottomInset: false,
        body: ViewModelBuilder<DownloadDetailViewmodel>.reactive(
            onModelReady: (model) {
              modelRef = model;

              widget.categoryId == "62034da4347bca06a597c2ea" ? model.getDicomFilesByCategory(widget.categoryId, widget.dicomfilename) : model.getFilesByCategory(widget.categoryId);
            },
            builder: (context, model, child) {
              return model.isBusy
                  ? Center(
                      child: UIHelper.swarPreloader(),
                    )
                  : Container(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  UIHelper.verticalSpaceMedium,
                                  // Text(" " + preferencesService.dropdown_user_name).textColor(Colors.black).bold().fontSize(16),
                                  // Text(" " + preferencesService.dropdownuserName.value!).textColor(Colors.black).bold().fontSize(16),
                                  Container(
                                      child: StreamBuilder<String?>(
                                          stream: locator<PreferencesService>().userName.outStream,
                                          builder: (context, snapshotname) =>
                                              // !snapshotname.hasData || snapshotname.data == '' ? Text(preferencesService.dropdown_user_name).textColor(Colors.black).bold() : Text(snapshotname.data!).textColor(Colors.black).bold(),
                                              //Text(preferencesService.dropdownuserName.value!).textColor(Colors.black).bold())),
                                              Text(preferencesService.dropdown_user_name).textColor(Colors.black).bold())),
                                ],
                              )
                            ],
                          ),
                          UIHelper.verticalSpaceMedium,
                          showSearchField(context, model),
                          UIHelper.verticalSpaceSmall,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (isLongPressOn) {
                                        setState(() {
                                          docIds.clear();
                                          isLongPressOn = false;
                                        });
                                        return;
                                      }
                                      Get.back();
                                    },
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: 20,
                                    ),
                                  ),
                                  UIHelper.horizontalSpaceSmall,
                                  isLongPressOn
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              docIds.clear();
                                              isLongPressOn = !isLongPressOn;
                                            });
                                          },
                                          child: Text('Cancel').bold().textColor(Colors.red).fontSize(16))
                                      : Text(widget.categoryTitle == "Maternity & Child vaccine record" ? "Maternity/Child Records" : widget.categoryTitle).bold().fontSize(16),
                                ],
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    child: Image.asset('assets/calendar_icon.png'),
                                    onTap: () {
                                      _selectDate(context, model);
                                    },
                                  ),
                                  // UIHelper.horizontalSpaceSmall,
                                  PopupMenuButton(
                                    padding: EdgeInsets.zero,
                                    icon: Image.asset('assets/sort_icon.png'),
                                    onSelected: (value) {
                                      searchController.text = '';
                                      model.sortMode = value.toString();
                                      model.refreshView();
                                    },
                                    itemBuilder: (context) {
                                      return <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'name',
                                          child: Text(
                                            'Sort by\nRecord\nName',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'date',
                                          child: Text(
                                            'Sort by\nDate',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ];
                                    },
                                  ),
                                  // UIHelper.horizontalSpaceSmall,
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isHorizontalScroll = !isHorizontalScroll;
                                      });
                                    },
                                    child: isHorizontalScroll ? Image.asset('assets/list_view_icon.png') : Image.asset('assets/grid_view_icon.png'),
                                  ),
                                ],
                              )
                            ],
                          ),
                          // UIHelper.verticalSpaceSmall,
                          UIHelper.hairLineWidget(),
                          UIHelper.verticalSpaceSmall,
                          Expanded(child: showFileList(context, model)),
                          UIHelper.verticalSpaceSmall,

                          //widget.categoryTitle == "Maternity & child vaccine record" ? showVerticalCategoryButtons() : UIHelper.verticalSpaceSmall,
                          widget.categoryTitle == "Maternity & Child vaccine record"
                              ? showVerticalCategoryButtons(model)
                              : widget.categoryTitle == "C.DOC"
                                  ? showVerticalCovidButtons(model)
                                  : UIHelper.verticalSpaceSmall,
                        ],
                      ),
                    );
            },
            viewModelBuilder: () => DownloadDetailViewmodel()));
  }
}

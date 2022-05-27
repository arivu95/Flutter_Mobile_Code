import 'package:documents_module/src/ui/uploads/uploads_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class RecentDownloadWidget extends StatefulWidget {
   RecentDownloadWidget({Key? key}) : super(key: key);
   
  @override
  RecentDownloadWidgetState createState() => RecentDownloadWidgetState();
}
class RecentDownloadWidgetState extends State<RecentDownloadWidget> {
  @override

  UploadsViewmodel modelRef = UploadsViewmodel();
   Widget ImageDialog(BuildContext context,String fileUrl) {
    return Dialog(
      backgroundColor: Color.fromRGBO(105,105,105, 0.5),
        insetPadding: EdgeInsets.all(15),
        child: Container(
            child: Stack(
        // child: SingleChildScrollView(
        children:[
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
                onTap: (){
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

Widget PdfDialog(BuildContext context,String fileUrl) {
final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
    return Dialog(
     
       insetPadding: EdgeInsets.all(15),
        child: Container(
          child: Stack(
        // child: SingleChildScrollView(
        children:[
              SingleChildScrollView(
                child:
             SfPdfViewer.network(fileUrl,
           //'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
            key: _pdfViewerKey,
            ),
          ),
             Positioned(
                right: 0.0,
                //top: 0.5,
                child: GestureDetector(
                onTap: (){
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
        ]       
      ),
    ),
    );
  }

  Widget recentDownloadItem(BuildContext context, dynamic data) {
    String fileName = data['fileName'] ?? '';
    if (fileName.length > 10) {
      fileName = fileName.substring(0, 9);
    }
    Jiffy date = Jiffy(data['createdAt']);
    String imgUrl = '';
    List imageUrls = data['azureBlobStorageLink'];
    if (imageUrls.length > 0) {
      imgUrl = '${ApiService.fileStorageEndPoint}${imageUrls.first.toString()}';
    }
    //return Column(
        return GestureDetector(
        onTap: () async {
                       await showDialog(
                        context: context,
                        builder: (_) => ImageDialog(context,imgUrl),
                       
                     );
        },
   
    child: Column(
      children: [
    
  imgUrl.toLowerCase().contains('.docx') ?
           Image.asset(
                'assets/word_icon.png',
                fit: BoxFit.none,
                height: 60,
                // width: 80,
              )
            : imgUrl.toLowerCase().contains('.pdf') ?
             Image.asset(
                'assets/PDF.png',
                fit: BoxFit.none,
                height: 60,
                // width: 80,
              )
              : imgUrl.toLowerCase().contains('.xxls')||  imgUrl.toLowerCase().contains('.xlsx') ?
                 Image.asset(
                'assets/excel_icon.png',
                fit: BoxFit.none,
                height: 60,
                // width: 80,
              )
            :
        ClipRRect(borderRadius: BorderRadius.circular(8), child: UIHelper.getImage(imgUrl, 80, 60)),
        UIHelper.verticalSpaceTiny,
        Text(fileName).fontSize(11),
        UIHelper.verticalSpaceTiny,
        Text(date.format('MM/dd/yyy')).fontSize(9),
      ],
    )
    );
  }

  
//*****************for recent upload documents
 Widget recentItem(BuildContext context, int index, dynamic data) {
    String fileName = data['fileName'] ?? '';
    if (fileName.length > 10) {
      fileName = fileName.substring(0, 9);
    }
    Jiffy date = Jiffy(data['createdAt']);
    String imgUrl = '';
    List imageUrls = data['azureBlobStorageLink'];
    
    if (imageUrls.length > 0) {
      imgUrl = '${ApiService.fileStorageEndPoint}${imageUrls.first.toString()}';
    }
    print('isajd --------'+imgUrl);
    //return Column(
      //return Column(
          return GestureDetector(
         onTap: () async {
           (imgUrl.toLowerCase().contains('.pdf')) ?
                       await showDialog(
                        context: context,
                        builder: (_) => PdfDialog(context,imgUrl),
                     )  :
                     
                      (imgUrl.toLowerCase().contains('.docx'))|| (imgUrl.toLowerCase().contains('.xxls'))
                     ||(imgUrl.toLowerCase().contains('.xlsx'))
                     
                      ?
                   await canLaunch(imgUrl) ?
                    await launch('https://docs.google.com/viewer?url=$imgUrl',
                   // forceSafariVC: true, forceWebView: true
                    ) 
                    : 
                    throw 'Could not launch $imgUrl'
                     : 
                      await showDialog(
                        context: context,
                        builder: (_) => ImageDialog(context,imgUrl),
                       
                     );

        },
   
    child: Column(
      children: [
         imgUrl.toLowerCase().contains('.docx') ?
           Image.asset(
                'assets/word_icon.png',
                fit: BoxFit.none,
                height: 60,
                // width: 80,
              )
            : imgUrl.toLowerCase().contains('.pdf') ?
             Image.asset(
                'assets/PDF.png',
                fit: BoxFit.none,
                height: 60,
                // width: 80,
              )
              : imgUrl.toLowerCase().contains('.xxls')||  imgUrl.toLowerCase().contains('.xls') ?
                 Image.asset(
                'assets/excel_icon.png',
                fit: BoxFit.none,
                height: 60,
                // width: 80,
              )
            :
              ClipRRect(borderRadius: BorderRadius.circular(8), child: UIHelper.getImage(imgUrl, 80, 60)),

        UIHelper.verticalSpaceTiny,
        Text(fileName).fontSize(11),
        UIHelper.verticalSpaceTiny,
        Text(date.format('MM/dd/yyy')).fontSize(9),
      ],
    )
    );
  }
  //*********************recent upload documents **************/
  //******* page build 
  @override
  Widget build(BuildContext context) {
     if(locator<PreferencesService>().isReload.value == true){
       locator<PreferencesService>().isReload.value = false;
        modelRef.getRecentUploads();
      }
    return ViewModelBuilder<UploadsViewmodel>.reactive(
        onModelReady: (model) {
          model.getRecentUploads();
           modelRef = model;
        },
       
        builder: (context, model, child) {
         //(model.recentDownloads.length>0) ? print("*******************") 
        
          return model.isBusy
              ? SizedBox(
                  height: 137,
                  child: Center(
                    child: UIHelper.swarPreloader(),
                  ),
                )
              : 
                   model.recentUploads.length >0 ?

              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        model.getRecentUploads();
                      },
                      child:
                       Row(
                        children: [
                          UIHelper.horizontalSpaceSmall,
                          Text('Recent Documents').fontWeight(FontWeight.w500),
                        ],
                      )
                    
                    ),
                    UIHelper.verticalSpaceSmall,
                     Container(
                            width: Screen.width(context),
                            height: 110,
                            padding: EdgeInsets.only(left: 12, right: 12),
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: model.recentUploads.length,
                                itemBuilder: (context, index) {
                                  //  model.getRecentUploads();
                                  return Container(
                                    decoration: UIHelper.roundedBorderWithColor(8, Color(0xFFF2F2F2)),
                                    margin: EdgeInsets.only(right: 8),
                                    width: 80,
                                    // height: 84,
                                    //child: recentItem(context, model.recentUploads[index]),
                                     child: recentItem(context, index, model.recentUploads[index]),
                                  );
                                }),
                          ),
                  ],
                )

                : Container( );

        },
        viewModelBuilder: () => UploadsViewmodel());
  }
}

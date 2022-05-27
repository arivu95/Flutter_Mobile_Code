import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/shared/flutter_overlay_loader.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:swarapp/ui/picker/doc_category_viewmodel.dart';
import 'package:swarapp/ui/picker/doc_category_widget.dart';
import 'package:styled_widget/styled_widget.dart';

class DocCategoryView extends StatefulWidget {
  final Function(List<String>) onFilesSelected;
  DocCategoryView({Key? key, required this.onFilesSelected}) : super(key: key);

  @override
  _DocCategoryViewState createState() => _DocCategoryViewState();
}

class _DocCategoryViewState extends State<DocCategoryView> {
  int currentIndex = 0;
  late DocCategoryViewmodel modelRef;
  List<String> docIds = [];

  Widget onShowCategoryItems(BuildContext context, DocCategoryViewmodel model) {
    return Container(
        child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Container(
                width: Screen.width(context),
                decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.transparent),
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = 0;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                          ),
                          Text('Select file from categories').bold(),
                          Expanded(
                            child: SizedBox(),
                          ),
                          GestureDetector(
                              onTap: docIds.length > 0
                                  ? () async {
                                      Loader.show(context);
                                      List<String> filesList = await model.downloadDocs(docIds);
                                      Loader.hide();
                                      widget.onFilesSelected(filesList);
                                    }
                                  : null,
                              child: Icon(Icons.send, color: Colors.red))
                        ],
                      ),
                    ),
                    UIHelper.hairLineWidget(),
                    model.isBusy
                        ? Expanded(
                            child: Center(
                              child: UIHelper.swarPreloader(),
                            ),
                          )
                        : Expanded(
                            child: SingleChildScrollView(
                            child: model.fileList.length == 0
                                ? UIHelper.tagWidget('No Documents Found', Colors.black26)
                                : Column(
                                    children: [
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: model.fileList.length,
                                          itemBuilder: (context, index) {
                                            dynamic data = model.fileList[index];
                                            String docid = data['_id'];
                                            // String img_url = data['img_url'] ?? '';
                                            List imageUrls = data['azureBlobStorageLink'];
                                            String imgUrl = '';
                                            if (imageUrls.length > 0) {
                                              // img_url = imageUrls.first.toString();
                                              imgUrl = '${ApiService.fileStorageEndPoint}${imageUrls.first.toString()}';
                                            }
                                            Jiffy date = Jiffy(data['createdAt']);
                                            String filename = data['fileName'];

                                            return GestureDetector(
                                              onTap: () async {
                                                print(data);
                                                print('the selected documetn are ' + docIds.toString());
                                                if (docIds.contains(docid)) {
                                                  docIds.remove(docid);
                                                } else {
                                                  docIds.add(docid);
                                                }
                                                setState(() {});
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
                                                          child: imgUrl.toLowerCase().contains('.docx')
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
                                                                          ? Container(child: Center(child: Icon(Icons.smart_display, size: 40, color: Colors.grey)))
                                                                          : ClipRRect(borderRadius: BorderRadius.circular(8), child: UIHelper.getImage(imgUrl, 46, 0)),
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
                                                          new GestureDetector(
                                                              onTap: () {
                                                                print(data);
                                                                print('the selected documetn are ' + docIds.toString());
                                                                if (docIds.contains(docid)) {
                                                                  docIds.remove(docid);
                                                                } else {
                                                                  docIds.add(docid);
                                                                }
                                                                setState(() {});
                                                              },

                                                              // child: Text((filename)),
                                                              child: Text(filename)),
                                                          UIHelper.verticalSpaceTiny,
                                                          UIHelper.horizontalSpaceMedium,
                                                          Text(date.format('MM/dd/yyy')).fontSize(9),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          })
                                    ],
                                  ),
                          ))
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Screen.height(context) - 150,
      child: IndexedStack(
        index: currentIndex,
        children: [
          DocCategoryWidget(
            onSelectCategory: (index) {
              setState(() {
                currentIndex = 1;
              });
              String categoryId = modelRef.getCategoryId(index);
              modelRef.getFilesByCategory(categoryId, index);
              print(index);
            },
          ),
          ViewModelBuilder<DocCategoryViewmodel>.reactive(
              onModelReady: (model) async {
                modelRef = model;
                await model.getFileCategory();

                //  String categoryId = modelRef.getCategoryId(index);
                //  modelRef.getFilesByCategory(categoryId);
              },
              builder: (context, model, child) {
                return model.isBusy ? Center(child: CircularProgressIndicator()) : onShowCategoryItems(context, model);
              },
              viewModelBuilder: () => DocCategoryViewmodel())
        ],
      ),
    );
  }
}

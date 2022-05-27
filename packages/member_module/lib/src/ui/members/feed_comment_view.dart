import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/app_static_bar.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'feed_comment_viewmodel.dart';

class FeedcommentView extends StatefulWidget {
  dynamic commentinfo;
  FeedcommentView({Key? key, this.commentinfo}) : super(key: key);

  @override
  _FeedcommentViewState createState() => _FeedcommentViewState();
}

class _FeedcommentViewState extends State<FeedcommentView> {
  final TextEditingController textEditingController = TextEditingController();
  PreferencesService preferencesService = locator<PreferencesService>();
  FeedcommentModel modelRef = FeedcommentModel();

  Widget showActivityFeed(BuildContext context, FeedcommentModel model) {
    if (locator<PreferencesService>().isReload.value == true) {
      locator<PreferencesService>().isReload.value = false;
      modelRef.getfeedComment(widget.commentinfo['_id']);
    }
    return Expanded(
        child: Container(
      padding: EdgeInsets.all(8),
      width: Screen.width(context),
      decoration: UIHelper.roundedBorderWithColorWithShadow(6, fieldBgColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.commentinfo['profilestatus']).fontWeight(FontWeight.w500).padding(all: 6),
          UIHelper.hairLineWidget(),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: model.isBusy
                ? UIHelper.swarPreloader()
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: model.commentsList.length,
                    itemBuilder: (context, index) {
                      dynamic commentlist = model.commentsList[index];
                      String commentBy = commentlist['commentBy'];
                      String username = 'Anonymous';
                      String url = '${ApiService.fileStorageEndPoint}null';
                      if (model.usersList[commentBy] != null) {
                        dynamic commentUserInfo = model.usersList[commentBy];
                        username = commentUserInfo['name'] ?? '';
                        url = commentUserInfo['get_azure_link'];
                      }
                      //dynamic imgurl = commentlist['profile_img'];
                      //dynamic img_url = '${ApiService.fileStorageEndPoint}${imgurl}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          //margin: EdgeInsets.only(bottom: 8),
                          decoration: UIHelper.roundedBorderWithColor(8, Colors.white, borderColor: Colors.black12),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(borderRadius: BorderRadius.circular(20.0), child: UIHelper.getProfileImageWithInitials(url, 25, 25, username)),
                                  UIHelper.horizontalSpaceSmall,
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(username)
                                          //Text(commentlist['name'])
                                          .fontSize(12)
                                          .fontWeight(FontWeight.w500),
                                      UIHelper.verticalSpaceTiny,
                                      Text(commentlist['comment']).fontSize(13),
                                      UIHelper.verticalSpaceSmall,
                                    ],
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ))
        ],
      ),
    ));
  }

  Widget buildInput(FeedcommentModel model) {
    return Container(
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: 'Type your comments...',
                  contentPadding: EdgeInsets.only(left: 20),
                  enabledBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFE7E7E7)),
                  focusedBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFE7E7E7)),
                  focusedErrorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFE7E7E7)),
                  errorBorder: UIHelper.getInputBorder(0, radius: 12, borderColor: Color(0xFFE7E7E7)),
                  filled: true,
                  // hintStyle: TextStyle(color: fieldBgColor),
                ),
                onChanged: (text) {
                  // _cubeDialog.sendIsTypingStatus();
                },
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                color: activeColor,
                onPressed: () async {
                  if (textEditingController.text.isNotEmpty) {
                    model.addcomment(textEditingController.text, widget.commentinfo['_id']);
                    textEditingController.clear();
                  } //await modelRef.getfeedComment(widget.commentinfo['_id']);
                },
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black12, width: 0.5)), color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (locator<PreferencesService>().isReload.value == true) {
      locator<PreferencesService>().isReload.value = false;
      modelRef.getfeedComment(widget.commentinfo['_id']);
    }
    return Scaffold(
      //appBar: SwarAppBar(2),
      appBar: SwarAppStaticBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          width: Screen.width(context),
          child: ViewModelBuilder<FeedcommentModel>.reactive(
              onModelReady: (model) {
                modelRef = model;
                model.getfeedComment(widget.commentinfo['_id']);
              },
              builder: (context, model, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UIHelper.addHeader(context, 'Comments', true),
                    UIHelper.verticalSpaceSmall,
                    UIHelper.verticalSpaceSmall,
                    showActivityFeed(context, model),
                    UIHelper.verticalSpaceSmall,
                    buildInput(model),
                    UIHelper.verticalSpaceTiny
                  ],
                );
              },
              viewModelBuilder: () => FeedcommentModel()),
        ),
      ),
    );
  }
}

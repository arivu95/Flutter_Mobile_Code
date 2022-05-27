import 'dart:async';

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/app/consts.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/ui_helpers.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  String videoUrl;

  VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool is_play = false;
  bool _onTouch = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    //_controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  _getCloseButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          alignment: FractionalOffset.topRight,
          child: GestureDetector(
            // child: Icon(
            //   Icons.disabled_by_default,
            //   color: activeColor,
            // ),
            child: CircleAvatar(
              radius: 14.0,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, color: Colors.white, size: 20),
            ),
            onTap: () {
              _controller.pause();
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDialog() {
    return AlertDialog(
        backgroundColor: transparentColor,
        insetPadding: EdgeInsets.all(2),
        elevation: 15,
        titlePadding: const EdgeInsets.all(0.0),
        title: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _getCloseButton(),
                Padding(
                  padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                  child: Column(
                    children: [],
                  ),
                )
              ],
            ),
          ),
        ),
        contentPadding: EdgeInsets.all(2),
        content: Container(
            width: Screen.width(context) - 30,
            // decoration: UIHelper.roundedBorderWithColor(4, transparentColor),
            child: Wrap(
                // mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  // Text("ohm namo bagavathae")

                  _controller.value.isInitialized
                      ?
                      //  AspectRatio(
                      //     aspectRatio: _controller.value.aspectRatio,
                      //     child: Stack(children: <Widget>[
                      //       GestureDetector(
                      //           onTap: () async {
                      //             // Getprint('444444' + widget.videoUrl);
                      //             is_play ? _controller.play() : _controller.pause();
                      //             is_play = !is_play;
                      //             setState(() {
                      //               _onTouch = !_onTouch;
                      //             });
                      //           },
                      //           child: Container(
                      //             width: Screen.width(context) - 30,
                      //             decoration: UIHelper.roundedBorderWithColor(4, greyColor),
                      //             child: VideoPlayer(_controller),
                      //           ))
                      //     ]))
                      // : Container(
                      //     child: CircularProgressIndicator(),
                      //   ),

                      AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: Stack(children: <Widget>[
                            VideoPlayer(_controller),

                            // GestureDetector(
                            //   onTap: () async {
                            //     // Getprint('444444' + widget.videoUrl);
                            //     is_play ? _controller.play() : _controller.pause();
                            //     is_play = !is_play;
                            //     setState(() {
                            //       _onTouch = !_onTouch;
                            //     });
                            //   },
                            //   child: VideoPlayer(_controller),
                            // ),
                            // Visibility(
                            //   visible: _onTouch,
                            //   child: Container(
                            //     color: Colors.grey.withOpacity(0.5),
                            //     alignment: Alignment.center,
                            //     child: FlatButton(
                            //       shape: CircleBorder(side: BorderSide(color: Colors.white)),
                            //       child: Icon(
                            //         _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            //         color: Colors.white,
                            //       ),
                            //       onPressed: () {
                            //         _timer?.cancel();
                            //         // Auto dismiss overlay after 1 second
                            //         _timer = Timer.periodic(Duration(milliseconds: 1000), (_) {
                            //           setState(() {
                            //             _onTouch = false;
                            //           });
                            //         });

                            //         showGeneralDialog(
                            //             context: context,
                            //             pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                            //               return _buildDialog();
                            //             });
                            //       },
                            //     ),
                            //   ),
                            // ),
                            ValueListenableBuilder(
                              valueListenable: _controller,
                              builder: (context, VideoPlayerValue value, child) {
                                String strDur = value.position.toString();
                                String totalDur = value.duration.toString();
                                var valDur = strDur.replaceFirst(RegExp(r"\.[^]*"), "");
                                var totDur = totalDur.replaceFirst(RegExp(r"\.[^]*"), "");
                                return Text('  ' + valDur.toString() + " " + " / " + totDur.toString()).textColor(Colors.white);
                              },
                            ),
                          ]))
                      : Center(
                          child: Container(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                ])));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        // child: _controller.value.isInitialized
        //     ? AspectRatio(
        //         aspectRatio: _controller.value.aspectRatio,
        //         child: Stack(children: <Widget>[
        //           GestureDetector(
        //             onTap: () async {
        //               // Getprint('444444' + widget.videoUrl);
        //               is_play ? _controller.play() : _controller.pause();
        //               is_play = !is_play;
        //               setState(() {
        //                 _onTouch = !_onTouch;
        //               });
        //             },
        //             child: VideoPlayer(_controller),
        //           ),
        //           Visibility(
        //             visible: _onTouch,
        //             child: Container(
        //               color: Colors.grey.withOpacity(0.5),
        //               alignment: Alignment.center,
        //               child: FlatButton(
        //                 shape: CircleBorder(side: BorderSide(color: Colors.white)),
        //                 child: Icon(
        //                   _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        //                   color: Colors.white,
        //                 ),
        //                 onPressed: () {
        //                   _timer?.cancel();
        //                   // Auto dismiss overlay after 1 second
        //                   _timer = Timer.periodic(Duration(milliseconds: 1000), (_) {
        //                     setState(() {
        //                       _onTouch = false;
        //                     });
        //                   });

        //                   showGeneralDialog(
        //                       context: context,
        //                       pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        //                         return _buildDialog();
        //                       });
        //                 },
        //               ),
        //             ),
        //           ),
        //           ValueListenableBuilder(
        //             valueListenable: _controller,
        //             builder: (context, VideoPlayerValue value, child) {
        //               String str_dur = value.position.toString();
        //               String total_dur = value.duration.toString();
        //               var val_dur = str_dur?.replaceFirst(RegExp(r"\.[^]*"), "");
        //               var tot_dur = total_dur?.replaceFirst(RegExp(r"\.[^]*"), "");
        //               return Text('  ' + val_dur.toString() + " " + " / " + tot_dur.toString()).textColor(Colors.white);
        //             },
        //           ),
        //         ]))
        //     : Container(
        //         child: CircularProgressIndicator(),
        //       ),
        child: Container(child: _buildDialog()));
  }
}

// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:swarapp/shared/ui_helpers.dart';
// import 'package:video_player/video_player.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

// class VideoPlayerWidget extends StatefulWidget {
//   String videoUrl;
//   VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

//   @override
//   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   late VideoPlayerController _controller;
// //GenThumbnailImage _futreImage;
//   get Screen => null;
//   ImageFormat _format = ImageFormat.JPEG;
//   int _quality = 10;
//   int _size = 0;
//   String _tempDir = "";
//   String filePath = "";
//   @override
//   void initState() {
//     super.initState();
//     getTemporaryDirectory().then((d) => _tempDir = d.path);

//     // _controller = VideoPlayerController.network(widget.videoUrl)
//     //   ..initialize().then((_) {
//     //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//     //     //   setState(() {});
//     //   });
//   }

//   get_url() async {
//     final fileName = await VideoThumbnail.thumbnailFile(
//       video: widget.videoUrl,
//       thumbnailPath: (await getTemporaryDirectory()).path,
//       imageFormat: ImageFormat.JPEG,
//       maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
//       quality: 75,
//     );
//     print(fileName);
//     return Column(
//       children: [
//         UIHelper.getImage(fileName!, 300, 300),
//       ],
//     );
//   }

//   // Future genThumbnail() async {
//   //   //WidgetsFlutterBinding.ensureInitialized();
//   //   final fileName = await VideoThumbnail.thumbnailFile(
//   //     video: widget.videoUrl,
//   //     thumbnailPath: (await getTemporaryDirectory()).path,
//   //     imageFormat: ImageFormat.JPEG,
//   //     maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
//   //     quality: 75,
//   //   );
//   //   Uint8List bytes;
//   //   final Completer completer = Completer();
//   //   //if (r.thumbnailPath != null) {
//   //   final thumbnailPath = await VideoThumbnail.thumbnailFile(
//   //     video: widget.videoUrl,
//   //     thumbnailPath: (await getTemporaryDirectory()).path,
//   //     imageFormat: ImageFormat.JPEG,
//   //     // maxHeight: r.maxHeight,
//   //     // maxWidth: r.maxWidth,
//   //     // timeMs: r.timeMs,
//   //     // quality: r.quality
//   //     maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
//   //     quality: 75,
//   //   );

//   //   print("thumbnail file is located: $thumbnailPath");

//   //   final file = File(thumbnailPath!);
//   //   bytes = file.readAsBytesSync();
//   //   // } else {
//   //   //   bytes = await VideoThumbnail.thumbnailData(
//   //   //       video: r.video,
//   //   //       imageFormat: r.imageFormat,
//   //   //       maxHeight: r.maxHeight,
//   //   //       maxWidth: r.maxWidth,
//   //   //       timeMs: r.timeMs,
//   //   //       quality: r.quality);
//   //   // }

//   //   int _imageDataSize = bytes.length;
//   //   print("image size: $_imageDataSize");

//   //   final _image = Image.memory(bytes);
//   //   _image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _) {
//   //     completer.complete(ThumbnailResult(
//   //       image: _image,
//   //       dataSize: _imageDataSize,
//   //       height: info.image.height,
//   //       width: info.image.width,
//   //     ));
//   //   }));
//   //   return completer.future;
//   // }

//   @override
//   Widget build(BuildContext context) {
// //    final fil = get_url();

//     return Center(
//       // child: _controller.value.isInitialized
//       //     ? AspectRatio(
//       //         aspectRatio: _controller.value.aspectRatio,
//       //         child: VideoPlayer(_controller),
//       //       )
//       //     : Container(
//       //         child: CircularProgressIndicator(),
//       //       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           filePath != null
//               ? Image.file(
//                   File(filePath),
//                   width: 500,
//                   height: 300,
//                   fit: BoxFit.cover,
//                 )
//               : Text('No Floatting Button Click'),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               FloatingActionButton(
//                 tooltip: "Generate a file of thumbnail",
//                 onPressed: () async {
//                   final thumbnail = await VideoThumbnail.thumbnailFile(
//                       video: widget.videoUrl,
//                       thumbnailPath: _tempDir,
//                       imageFormat: _format,
//                       maxHeight: 400,
//                       maxWidth: Screen.width(context) - 8,
//                       // maxHeightOrWidth: _size,
//                       quality: _quality);
//                   setState(() {
//                     final file = File(thumbnail!);
//                     filePath = file.path;
//                   });
//                 },
//                 child: Text('Click'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

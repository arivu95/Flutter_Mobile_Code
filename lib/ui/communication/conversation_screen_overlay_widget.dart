import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:swarapp/app/consts.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/ui/communication/conversation_screen.dart';
import 'package:swarapp/ui/communication/incoming_call_screen.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class ConversationScreenOverlayWidget extends StatefulWidget {
  final Function onClear;
  // final Widget widget;
  final P2PSession session;
  final bool isIncoming;
  ConversationScreenOverlayWidget({Key? key, required this.onClear, required this.session, required this.isIncoming}) : super(key: key);

  @override
  _ConversationScreenOverlayWidgetState createState() => _ConversationScreenOverlayWidgetState();
}

class _ConversationScreenOverlayWidgetState extends State<ConversationScreenOverlayWidget> {
  PreferencesService preferencesService = locator<PreferencesService>();

  double width = 0;
  double oldWidth = 0;
  double oldHeight = 0;
  double height = 0;

  bool isInPipMode = false;
  final key = GlobalKey();

  Offset offset = Offset(0, 0);

  Widget? player;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      final widgetSize = _getWidgetSize(key);
      if (widgetSize != null) {
        setState(() {
          if (width == 0 || height == 0) {
            oldWidth = width = MediaQuery.of(context).size.width;
            oldHeight = height = MediaQuery.of(context).size.height;
          }
        });
      }
    });
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    return true;
  }

  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  Size? _getWidgetSize(GlobalKey key) {
    final keyContext = key.currentContext;
    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      return box.size;
    } else {
      return null;
    }
  }

  _onExitPipMode() {
    Future.microtask(() {
      setState(() {
        isInPipMode = false;
        width = oldWidth;
        height = oldHeight;
        offset = Offset(0, 0);
      });
    });
    Future.delayed(Duration(milliseconds: 250), () {
      preferencesService.disablePip();
    });
  }

  _onPipMode() {
    double aspectRatio = preferencesService.aspectRatio;

    print("true   $aspectRatio");
//    Provider.of<OverlayHandlerProvider>(context, listen: false).enablePip();
    Future.delayed(Duration(milliseconds: 100), () {
      print("true   Future.microtask");

      setState(() {
        isInPipMode = true;
        width = oldWidth - 32.0;
        height = PIPConstants.VIDEO_TITLE_HEIGHT_PIP;
        print(oldHeight - height - PIPConstants.BOTTOM_PADDING_PIP);
        // offset = Offset(16, oldHeight - height - PIPConstants.BOTTOM_PADDING_PIP);
        offset = Offset(16, 20);
//        height = (Constants.VIDEO_HEIGHT_PIP/aspectRatio) + 33;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (width == 0 || height == 0) {
      oldWidth = width = MediaQuery.of(context).size.width;
      oldHeight = height = MediaQuery.of(context).size.height;
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: StreamBuilder<bool?>(
          stream: preferencesService.inPipMode!.outStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data! != isInPipMode) {
                isInPipMode = snapshot.data!;
                if (isInPipMode)
                  _onPipMode();
                else
                  _onExitPipMode();
              }
            }
            return AnimatedPositioned(
              duration: Duration(milliseconds: 150),
              left: offset.dx,
              top: offset.dy,
              child: Material(
                elevation: isInPipMode ? 5.0 : 0.0,
                child: AnimatedContainer(
                  height: height,
                  width: width,
                  child: ConversationCallScreen(widget.session, widget.isIncoming),
                  duration: Duration(milliseconds: 250),
                ),
              ),
            );
          }),
    );
  }
}

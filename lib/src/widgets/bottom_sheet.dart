import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gmpay/flutter_gmpay.dart';

class TransparentRoute extends PageRoute<void> {
  TransparentRoute({
    required this.builder,
    super.settings,
  }) : super(fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final result = builder(context);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: result,
      ),
    );
  }
}

Future showNavBottomSheet({
  required BuildContext context,
  required NavBottomSheetController navBottomSheetController,
  bool isDismissible = false,
  Color backdropColor = Colors.greenAccent,
  double bottomSheetHeight = 420.0,
  bool? bottomSheetBodyHasScrollView,
  ScrollController? bottomSheetBodyScrollController,
  Widget? bottomSheetHeader,
  Widget? bottomSheetBody,
}) {
  if (bottomSheetBodyHasScrollView! &&
      bottomSheetBodyScrollController == null) {
    assert(bottomSheetBodyScrollController != null);
    // return null;
  }

  double maxHeight =
      MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
  bottomSheetHeight =
      bottomSheetHeight > maxHeight ? maxHeight : bottomSheetHeight;

  return Navigator.of(context).push(TransparentRoute(
      builder: (BuildContext context) => TestPage(
          navBottomSheetController: navBottomSheetController,
          isDismissible: isDismissible,
          backdropColor: backdropColor,
          bottomSheetHeight: bottomSheetHeight,
          bottomSheetHeader: bottomSheetHeader!,
          bottomSheetBodyHasScrollView: bottomSheetBodyHasScrollView,
          bottomSheetBodyScrollController: bottomSheetBodyScrollController!,
          bottomSheetBody: bottomSheetBody!)));
}

class TestPage extends StatefulWidget {
  final NavBottomSheetController? navBottomSheetController;
  final bool? isDismissible;
  final Color? backdropColor;
  final Widget? bottomSheetHeader;
  final double? bottomSheetHeight;
  final Widget? bottomSheetBody;
  final bool? bottomSheetBodyHasScrollView;
  final ScrollController? bottomSheetBodyScrollController;

  const TestPage(
      {Key? key,
      this.navBottomSheetController,
      this.isDismissible,
      this.backdropColor,
      this.bottomSheetHeader,
      this.bottomSheetHeight,
      this.bottomSheetBody,
      this.bottomSheetBodyHasScrollView,
      this.bottomSheetBodyScrollController})
      : super(key: key);

  @override
  TestPageState createState() => TestPageState();
}

class TestPageState extends State<TestPage> with TickerProviderStateMixin {
  NavBottomSheetController? get _navBottomSheetController =>
      widget.navBottomSheetController;
  AnimationController? _animationController;
  ScrollController? get _scrollController =>
      widget.bottomSheetBodyScrollController;
  CurvedAnimation? _curve;
  Animation<double>? _animation;
  double _scrollOffset = 0.0;
  double _offset = 0.0;
  bool _isBacked = false;

  @override
  void dispose() {
    Gmpay.instance.verifyTransactionTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _offset = widget.bottomSheetHeight!;
    _navBottomSheetController?.addListener(_navBottomSheetControllerListener);
    _scrollController?.addListener(_scrollControllerListener);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _curve =
        CurvedAnimation(parent: _animationController!, curve: Curves.easeOut);

    _updateOffset(widget.bottomSheetHeight!, 0.0);
  }

  _navBottomSheetControllerListener() {
    if (_navBottomSheetController?.eventType == 'close') {
      if (_offset == 0.0) {
        _updateOffset(0.0, widget.bottomSheetHeight!);
      }
    }
  }

  _scrollControllerListener() {
    _scrollOffset = _scrollController!.position.pixels;
    if (_scrollOffset < 0) {
      _scrollController!.jumpTo(0);
    }
  }

  _updateOffset(double begin, double end) {
    _animationController!.value = 0.0;
    _animation = Tween(begin: begin, end: end).animate(_curve!)
      ..addListener(() {
        _offset = _animation!.value;
        setState(() {});
      });
    _animationController?.forward();
    Timer(const Duration(milliseconds: 350), () {
      if (end >= widget.bottomSheetHeight! && !_isBacked) {
        _isBacked = true;
        setState(() {});
        Navigator.of(context).pop(_navBottomSheetController?.parameter);
        _scrollController?.removeListener(_scrollControllerListener);
        _navBottomSheetController
            ?.removeListener(_navBottomSheetControllerListener);
      }
    });
  }

  _onPointerMove(PointerMoveEvent e, [bool flag = false]) {
    if (_scrollOffset <= 0 && e.delta.dy > 0 || flag) {
      _offset += e.delta.dy;
    } else if (e.delta.dy < 0 && _offset > 0) {
      _offset += e.delta.dy;
    }

    if (_offset < 0) {
      _offset = 0.0;
    }
    setState(() {});
  }

  _onPointerUp(PointerUpEvent e) {
    if (_offset == 0) {
      return;
    }
    if (_offset >= widget.bottomSheetHeight! * 0.4) {
      _updateOffset(_offset, widget.bottomSheetHeight!);
    } else {
      _updateOffset(_offset, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Material(
          color: Colors.black38,
          child: Column(
            children: <Widget>[
              if (widget.isDismissible == true)
                Expanded(child: GestureDetector(
                  onTap: () {
                    _updateOffset(_offset, widget.bottomSheetHeight!);
                  },
                )),
              Transform.translate(
                offset: Offset(0.0, _offset),
                child: Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * .5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (widget.bottomSheetHeader != null)
                        Listener(
                            onPointerMove: (PointerMoveEvent e) {
                              _onPointerMove(e, true);
                            },
                            onPointerUp: _onPointerUp,
                            child: widget.bottomSheetHeader!),
                      if (widget.bottomSheetBody != null)
                        Expanded(child: widget.bottomSheetBody!),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavBottomSheetController extends ChangeNotifier {
  dynamic _parameter;
  String? _eventType;
  String? get eventType => _eventType;
  dynamic get parameter => _parameter;

  close([dynamic parameter]) {
    _parameter = parameter;
    _eventType = 'close';
    notifyListeners();
  }
}

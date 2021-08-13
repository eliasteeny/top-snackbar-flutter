import 'package:flutter/cupertino.dart';

/// Widget for nice tap effect. It decrease widget scale while tapping
class TapBounceContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  TapBounceContainer({
    required this.child,
    this.onTap,
  });

  @override
  _TapBounceContainerState createState() => _TapBounceContainerState();
}

class _TapBounceContainerState extends State<TapBounceContainer>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  final animationDuration = Duration(milliseconds: 200);

  bool isPaning = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: animationDuration,
      reverseDuration:
          Duration(milliseconds: animationDuration.inMilliseconds ~/ 2),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onPanEnd: _onPanEnd,
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) async {
    print("on tap uo");
    await _closeSnackBar();
  }

  void _onPanEnd(DragEndDetails details) async {
    isPaning = true;
    await _closeSnackBar();
  }

  Future _closeSnackBar() async {
    // _controller.reverse();
    await Future.delayed(
        Duration(milliseconds: animationDuration.inMilliseconds ~/ 2));
    if (!isPaning) widget.onTap?.call();
  }
}

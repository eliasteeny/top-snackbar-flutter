import 'package:flutter/material.dart';

/// Popup widget that you can use by default to show some information
class CustomSnackBar extends StatefulWidget {
  final Color backgroundColor;
  final Widget child;

  const CustomSnackBar.success({
    Key? key,
    required this.child,
    this.backgroundColor = const Color(0xff00E676),
  });

  const CustomSnackBar.info({
    Key? key,
    required this.child,
    this.backgroundColor = const Color(0xff2196F3),
  });

  const CustomSnackBar.error({
    Key? key,
    required this.child,
    this.backgroundColor = const Color(0xffff5252),
  });

  @override
  _CustomSnackBarState createState() => _CustomSnackBarState();
}

class _CustomSnackBarState extends State<CustomSnackBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0.0, 8.0),
            spreadRadius: 1,
            blurRadius: 30,
          ),
        ],
      ),
      width: double.infinity,
      child: Material(type: MaterialType.transparency, child: widget.child),
    );
  }
}

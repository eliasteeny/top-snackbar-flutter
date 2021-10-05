import 'dart:async';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';

/// Displays a widget that will be passed to [child] parameter above the current
/// contents of the app, with transition animation
///
/// The [child] argument is used to pass widget that you want to show
///
/// The [showOutAnimationDuration] argument is used to specify duration of
/// enter transition
///
/// The [hideOutAnimationDuration] argument is used to specify duration of
/// exit transition
///
/// The [displayDuration] argument is used to specify duration displaying
///
/// The [additionalTopPadding] argument is used to specify amount of top
/// padding that will be added for SafeArea values
///
/// The [onTap] callback of [TopSnackBar]
///
/// The [overlayState] argument is used to add specific overlay state.
/// If you will not pass it, it will try to get the current overlay state from
/// passed [BuildContext]

class TopSnackBarService {
  static final TopSnackBarService _singleton = TopSnackBarService._internal();

  factory TopSnackBarService() {
    return _singleton;
  }

  TopSnackBarService._internal();

  List<SnackBarInstance> notificationsQueue = [];

  bool _isShowingNotifications = false;
  bool _isHighPriorityShowing = false;

  _showNotifications() async {
    _isShowingNotifications = true;
    print("showwing notifications");
    if (notificationsQueue.isEmpty) {
      _isShowingNotifications = false;
      return;
    }
    SnackBarInstance currentSnackBar = notificationsQueue[0];

    await currentSnackBar.showOverlay();

    if (notificationsQueue.length > 0) notificationsQueue.removeAt(0);
    return _showNotifications();
  }

  void showTopSnackBar(
    BuildContext context,
    Widget child, {
    Duration showOutAnimationDuration = const Duration(milliseconds: 1200),
    Duration hideOutAnimationDuration = const Duration(milliseconds: 550),
    Duration displayDuration = const Duration(milliseconds: 3000),
    double additionalTopPadding = 16.0,
    VoidCallback? onTap,
    OverlayState? overlayState,
    bool isHighPriority = false,
  }) async {
    if (isHighPriority) {
      if (notificationsQueue.isNotEmpty) {
        notificationsQueue.forEach((element) {
          if (element.controller.isMounted) {
            element.controller.dismissNotification!();
          }
        });

        notificationsQueue.removeWhere((element) => true);
      }
      _isHighPriorityShowing = true;
      SnackBarInstance instance = await _showTopSnackBar(
        context,
        child,
        showOutAnimationDuration: showOutAnimationDuration,
        hideOutAnimationDuration: hideOutAnimationDuration,
        displayDuration: displayDuration,
        additionalTopPadding: additionalTopPadding,
        onTap: onTap,
        overlayState: overlayState,
        isHighPriority: isHighPriority,
      )
        ..setUp();

      await instance.showOverlay();
      _isHighPriorityShowing = false;

      if (notificationsQueue.length > 0) {
        if (!_isShowingNotifications) _showNotifications();
      }
      return;
    }

    notificationsQueue.add(
      await _showTopSnackBar(
        context,
        child,
        showOutAnimationDuration: showOutAnimationDuration,
        hideOutAnimationDuration: hideOutAnimationDuration,
        displayDuration: displayDuration,
        additionalTopPadding: additionalTopPadding,
        onTap: onTap,
        overlayState: overlayState,
        isHighPriority: isHighPriority,
      ),
    );

    if (!(_isShowingNotifications || _isHighPriorityShowing))
      _showNotifications();
  }

  Future<SnackBarInstance> _showTopSnackBar(
    BuildContext context,
    Widget child, {
    Duration showOutAnimationDuration = const Duration(milliseconds: 1200),
    Duration hideOutAnimationDuration = const Duration(milliseconds: 550),
    Duration displayDuration = const Duration(milliseconds: 3000),
    double additionalTopPadding = 16.0,
    VoidCallback? onTap,
    OverlayState? overlayState,
    bool isHighPriority = false,
  }) async {
    overlayState ??= Overlay.of(context);

    return SnackBarInstance(
      context,
      child,
      showOutAnimationDuration: showOutAnimationDuration,
      hideOutAnimationDuration: hideOutAnimationDuration,
      displayDuration: displayDuration,
      additionalTopPadding: additionalTopPadding,
      onTap: onTap,
      overlayState: overlayState,
      isHighPriority: isHighPriority,
    )..setUp();
  }
}

class SnackBarInstance {
  final BuildContext context;
  final Widget child;

  final Duration showOutAnimationDuration;
  final Duration hideOutAnimationDuration;
  final Duration displayDuration;
  final double additionalTopPadding;
  final VoidCallback? onTap;
  final OverlayState? overlayState;
  final bool isHighPriority;
  // Future showOverlay;

  SnackBarInstance(
    this.context,
    this.child, {
    this.showOutAnimationDuration = const Duration(milliseconds: 1200),
    this.hideOutAnimationDuration = const Duration(milliseconds: 550),
    this.displayDuration = const Duration(milliseconds: 3000),
    this.additionalTopPadding = 16.0,
    this.onTap,
    this.overlayState,
    this.isHighPriority = false,
  });

  Completer completer = Completer();
  late OverlayEntry overlayEntry;

  final SnackBarController controller = SnackBarController();

  setUp() {
    overlayEntry = OverlayEntry(
      builder: (builderContext) {
        return TopSnackBar(
          child: child,
          onDismissed: () => overlayEntry.remove(),
          showOutAnimationDuration: showOutAnimationDuration,
          hideOutAnimationDuration: hideOutAnimationDuration,
          displayDuration: displayDuration,
          additionalTopPadding: additionalTopPadding,
          onTap: onTap,
          completer: completer,
          controller: this,
        );
      },
    );
  }

  Future<void> showOverlay() {
    overlayState?.insert(overlayEntry);
    return completer.future;
  }
}

class SnackBarController {
  void Function()? dismissNotification;
  bool isMounted = false;
  SnackBarController();
}

/// Widget that controls all animations
class TopSnackBar extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismissed;
  final showOutAnimationDuration;
  final hideOutAnimationDuration;
  final displayDuration;
  final additionalTopPadding;
  final VoidCallback? onTap;
  final Completer completer;
  final SnackBarInstance controller;

  TopSnackBar({
    Key? key,
    required this.child,
    required this.onDismissed,
    required this.showOutAnimationDuration,
    required this.hideOutAnimationDuration,
    required this.displayDuration,
    required this.additionalTopPadding,
    required this.completer,
    required this.controller,
    this.onTap,
  }) : super(key: key);

  @override
  _TopSnackBarState createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<TopSnackBar>
    with SingleTickerProviderStateMixin {
  late Animation offsetAnimation;
  late AnimationController animationController;
  double? topPosition;

  bool isSnackBarDismissed = false;

  @override
  void initState() {
    topPosition = widget.additionalTopPadding;
    _setupAndStartAnimation();
    super.initState();

    widget.controller.controller.dismissNotification =
        () => animationController.reverse();
    widget.controller.controller.isMounted = true;
  }

  void _setupAndStartAnimation() async {
    animationController = AnimationController(
      vsync: this,
      duration: widget.showOutAnimationDuration,
      reverseDuration: widget.hideOutAnimationDuration,
    );

    Tween<Offset> offsetTween = Tween<Offset>(
      begin: Offset(0.0, -1.0),
      end: Offset(0.0, 0.0),
    );

    offsetAnimation = offsetTween.animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.elasticOut,
        reverseCurve: Curves.linearToEaseOut,
      ),
    )..addStatusListener(animationListener);

    animationController.forward();
  }

  animationListener(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      await Future.delayed(widget.displayDuration);
      if (!isSnackBarDismissed && mounted) {
        animationController.reverse();
        if (mounted) {
          setState(() {
            topPosition = 0;
          });
        }
      }
    }

    if (status == AnimationStatus.dismissed) {
      widget.onDismissed.call();
      onSnackBarClosed();
    }
  }

  final Key dismissableKey = UniqueKey();
  final Key verticalDismissableKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return isSnackBarDismissed
        ? Container()
        : AnimatedPositioned(
            duration: widget.hideOutAnimationDuration * 1.5,
            curve: Curves.linearToEaseOut,
            top: topPosition,
            left: 16,
            right: 16,
            child: SlideTransition(
              position: offsetAnimation as Animation<Offset>,
              child: SafeArea(
                child: TapBounceContainer(
                  onTap: () {
                    widget.onTap?.call();
                    animationController.reverse();
                  },
                  child: Dismissible(
                    key: verticalDismissableKey,
                    onDismissed: onSnackBarDismissed,
                    direction: DismissDirection.up,
                    child: Dismissible(
                      onDismissed: onSnackBarDismissed,
                      key: dismissableKey,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  onSnackBarDismissed(DismissDirection direction) {
    animationController.stop();
    isSnackBarDismissed = true;
    setState(() {});
    onSnackBarClosed();
    widget.onDismissed.call();
  }

  onSnackBarClosed() {
    widget.completer.complete();
  }

  @override
  void dispose() {
    animationController.dispose();
    widget.controller.controller.isMounted = false;
    super.dispose();
  }
}

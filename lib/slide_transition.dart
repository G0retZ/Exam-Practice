import 'package:flutter/material.dart';

SlidePage<T> buildSlidePage<T>({
  required BuildContext context,
  required Widget child,
  required Offset sourceOffset,
  String? name,
  Object? arguments,
  String? restorationId,
  LocalKey? key,
}) =>
    SlidePage<T>(
      child: child,
      sourceOffset: sourceOffset,
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
    );

class SlidePage<T> extends Page<T> {
  const SlidePage({
    required this.child,
    required this.sourceOffset,
    this.transitionDuration = const Duration(milliseconds: 300),
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final Duration transitionDuration;
  final Offset sourceOffset;

  @override
  Route<T> createRoute(BuildContext context) => RawDialogRoute<T>(
        settings: this,
        pageBuilder:
            (BuildContext c, Animation<double> a, Animation<double> s) =>
                SafeArea(child: child),
        transitionBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: sourceOffset,
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: FadeTransition(
              opacity: Tween(begin: 0.5, end: 1.0).animate(curvedAnimation),
              child: child,
            ),
          );
        },
        transitionDuration: transitionDuration,
        barrierDismissible: false,
      );
}

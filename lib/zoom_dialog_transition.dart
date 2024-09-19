import 'dart:ui';

import 'package:flutter/material.dart';

ZoomDialogPage<T> buildZoomDialog<T>({
  required BuildContext context,
  required Widget child,
  required Offset sourceOffset,
  String? name,
  Object? arguments,
  String? restorationId,
  LocalKey? key,
}) =>
    ZoomDialogPage<T>(
      child: child,
      sourceOffset: sourceOffset,
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
    );

class ZoomDialogPage<T> extends Page<T> {
  const ZoomDialogPage({
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
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) =>
            BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                maintainBottomViewPadding: true,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.5, 0.5),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
}

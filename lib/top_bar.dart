import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopBar extends StatelessWidget {
  final String title;

  const TopBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 4,
      child: SizedBox(
        height: 56,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: GoRouter.of(context).pop,
              icon: const Icon(Icons.arrow_back),
            ),
            const Spacer(flex: 1),
            TopBarText(title),
            const Spacer(flex: 1),
            const SizedBox(width: 56),
          ],
        ),
      ),
    );
  }
}

class TopBarText extends StatelessWidget {
  final String title;
  final Color? color;

  const TopBarText(
    this.title, {
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
}

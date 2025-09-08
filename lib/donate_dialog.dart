import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:para_exams/data.dart';

class DonateDialog extends StatelessWidget {
  final Data data;

  const DonateDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context) => Container(
        width: 320,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'I\'m glad to see you\'re using this app 😊',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Hope it helps you well to prepare for exams! ✌️',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'So please consider to appreciate my efforts with a donation ❤️',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: () {
                final router = GoRouter.of(context);
                data.updateUsage(-8).then((_) {
                  router.pop(true);
                  router.push('/web', extra: {'type': 'donate'});
                });
              },
              child: Image(
                image: AssetImage('assets/images/donate_button.png'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                data.updateUsage(-4);
                GoRouter.of(context).pop(true);
              },
              child: const Text("Skip this time"),
            ),
          ],
        ),
      );
}

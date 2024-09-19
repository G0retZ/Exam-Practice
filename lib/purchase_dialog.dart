import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'common.dart';
import 'data.dart';

class PurchaseDialog extends StatefulWidget {
  final Data data;
  final String url;

  PurchaseDialog({
    super.key,
    required this.data,
    required String item,
  }) : url = item
            .let(Uri.decodeFull)
            .let(base64Decode)
            .let(String.fromCharCodes);

  @override
  State<PurchaseDialog> createState() => _PurchaseDialogState();
}

sealed class PurchaseState {}

class PurchaseStatePending extends PurchaseState {}

class PurchaseStateParseError extends PurchaseState {}

class PurchaseStateNetworkError extends PurchaseState {}

class PurchaseStateSuccess extends PurchaseState {}

class _PurchaseDialogState extends State<PurchaseDialog> {
  late PurchaseState state;
  final textController = TextEditingController();

  @override
  void initState() {
    _retry();
    super.initState();
  }

  void _retry() {
    setState(() => state = PurchaseStatePending());
    widget.data.addExams(widget.url, 5).then(
          (it) => it
              .map<PurchaseState>((_) => PurchaseStateSuccess())
              .getOrElse((exception) => switch (exception) {
                    HttpException() => PurchaseStateParseError(),
                    ParseException() => PurchaseStateParseError(),
                    Exception() => PurchaseStateNetworkError(),
                  })
              .also((st) => setState(() => state = st)),
        );
  }

  void _sendEmail(String comment) async => await sendEmail(
        subject: 'Purchase error',
        object: widget.url.split('/').last.replaceAll(RegExp(r'\.json.*'), ''),
        comment: comment,
      );

  @override
  Widget build(BuildContext context) => Container(
        width: 320,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
        ),
        child: switch (state) {
          PurchaseStatePending() => Wrap(children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(32),
                child: const CircularProgressIndicator(),
              )
            ]),
          PurchaseStateParseError() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Something went wrong 😧',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Please contact us with this form to collect the purchased item.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    labelText: 'Email and comment',
                  ),
                  minLines: 3,
                  maxLines: 3,
                  onSubmitted: (it) {
                    _sendEmail(it);
                    GoRouter.of(context).pop(false);
                  },
                  controller: textController,
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () {
                    _sendEmail(textController.text);
                    GoRouter.of(context).pop(false);
                  },
                  child: const Text("📤  Send"),
                ),
              ],
            ),
          PurchaseStateNetworkError() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Network failed 😔',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Check your network connection and try again.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => GoRouter.of(context).pop(false),
                      child: const Text("❌  Close"),
                    ),
                    OutlinedButton(
                      onPressed: _retry,
                      child: const Text("️🧩  Retry"),
                    ),
                  ],
                )
              ],
            ),
          PurchaseStateSuccess() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Purchase is successful 🎉',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Now you have more exams to practice 🤩',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Good luck on exams! ✌️',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () {
                    GoRouter.of(context).pop(true);
                  },
                  child: const Text("Thanks  👍"),
                ),
              ],
            ),
        },
      );
}

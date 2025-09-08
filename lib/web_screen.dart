import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:para_exams/common.dart';
import 'package:para_exams/data.dart';
import 'package:para_exams/top_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

const deepLinkPrefix = 'https://exams.paragliding.g0retz.app';

const urlTypes = {
  'donate': [
    '☕️   Support with donation',
    'https://ko-fi.com/g0retz#checkoutModal',
  ],
  'license': [
    '⚖️   License',
    'https://github.com/G0retZ/Exam-Practice?tab=GPL-3.0-1-ov-file#readme',
  ],
  'sources': [
    '💽   Source code',
    'https://github.com/G0retZ/Exam-Practice',
  ],
};

class WebScreen extends StatefulWidget {
  final Data data;
  final String type;

  const WebScreen({
    super.key,
    required this.data,
    required this.type,
  });

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(deepLinkPrefix)) {
              final ctx = context;
              final route = request.url.replaceAll(deepLinkPrefix, '');
              GoRouter.of(ctx).push<bool>(route).then(
                    (it) =>
                        it
                            ?.takeIf((it) => it)
                            ?.also((_) => GoRouter.of(ctx).pop()) ??
                        it,
                  );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(urlTypes[widget.type]![1]));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: true,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(title: urlTypes[widget.type]![0]),
              Expanded(
                child: WebViewWidget(controller: controller),
              ),
            ],
          ),
        ),
      );
}

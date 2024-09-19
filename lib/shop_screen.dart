import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:para_exams/common.dart';
import 'package:para_exams/data.dart';
import 'package:para_exams/top_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

const deepLinkPrefix = 'https://exams.paragliding.g0retz.app';

const urlTypes = {
  'l1.pt': [
    '🛍️   Get more tests',
    'https://ko-fi.com/g0retz/shop/portuguêsnível1',
  ],
  'l2.pt': [
    '🛍️   Get more tests',
    'https://ko-fi.com/g0retz/shop/portuguêsnível2',
  ],
  'l1.en': [
    '🛍️   Get more tests',
    'https://ko-fi.com/g0retz/shop/englishlevel1',
  ],
  'l2.en': [
    '🛍️   Get more tests',
    'https://ko-fi.com/g0retz/shop/englishlevel2',
  ],
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

class ShopScreen extends StatefulWidget {
  final Data data;
  final String type;
  final bool isShop;

  ShopScreen({
    super.key,
    required this.data,
    required this.type,
  }) : isShop = urlTypes.keys.take(5).contains(type);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
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
            if (widget.isShop && request.url.startsWith(deepLinkPrefix)) {
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:para_exams/purchase_dialog.dart';
import 'package:para_exams/zoom_dialog_transition.dart';

import 'about_screen.dart';
import 'data.dart';
import 'exam_screen.dart';
import 'exams_screen.dart';
import 'help_screen.dart';
import 'main_screen.dart';
import 'palette.dart';
import 'shop_screen.dart';
import 'slide_transition.dart';
import 'snack_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final data = Data();
  await data.init();
  runApp(MyApp(data: data));
}

class MyApp extends StatelessWidget {
  final Data data;
  final GoRouter _router;

  MyApp({super.key, required this.data})
      : _router = GoRouter(
          routes: [
            ShellRoute(
              builder: (context, GoRouterState state, child) =>
                  Scaffold(backgroundColor: Colors.transparent, body: child),
              routes: [
                GoRoute(
                  path: '/',
                  pageBuilder: (context, state) => buildSlidePage<void>(
                    key: state.pageKey,
                    name: state.fullPath,
                    sourceOffset: const Offset(1, 0),
                    context: context,
                    child: MainScreen(
                      key: const Key('/'),
                      data: data,
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'exams',
                      pageBuilder: (context, state) {
                        final map = state.extra! as Map<String, dynamic>;
                        final id = map['id'] as String;

                        return buildSlidePage<void>(
                          key: state.pageKey,
                          name: state.fullPath,
                          sourceOffset: const Offset(1, 0),
                          context: context,
                          child: ExamsScreen(
                            key: Key(id),
                            data: data,
                            id: id,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'exam',
                      pageBuilder: (context, state) {
                        final map = state.extra! as Map<String, dynamic>;
                        final id = map['id'] as String;
                        final title = map['title'] as String;

                        return buildSlidePage<void>(
                          key: state.pageKey,
                          name: state.fullPath,
                          sourceOffset: const Offset(1, 0),
                          context: context,
                          child: ExamScreen(
                            key: Key(id),
                            title: title,
                            exam: data.exams[id]!,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'help',
                      pageBuilder: (context, state) => buildSlidePage<void>(
                        key: state.pageKey,
                        name: state.fullPath,
                        sourceOffset: const Offset(1, 0),
                        context: context,
                        child: const HelpScreen(),
                      ),
                    ),
                    GoRoute(
                      path: 'about',
                      pageBuilder: (context, state) => buildSlidePage<void>(
                        key: state.pageKey,
                        name: state.fullPath,
                        sourceOffset: const Offset(1, 0),
                        context: context,
                        child: const AboutScreen(),
                      ),
                    ),
                    GoRoute(
                      path: 'shop',
                      pageBuilder: (context, state) {
                        final map = state.extra! as Map<String, dynamic>;
                        final type = map['type'] as String;

                        return buildSlidePage<void>(
                          key: state.pageKey,
                          name: state.fullPath,
                          sourceOffset: const Offset(1, 0),
                          context: context,
                          child: ShopScreen(
                            data: data,
                            type: type,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'purchase',
                      pageBuilder: (context, state) {
                        final item = state.uri.queryParameters['item']!;

                        return buildZoomDialog<bool>(
                          key: state.pageKey,
                          name: state.fullPath,
                          sourceOffset: const Offset(1, 0),
                          context: context,
                          child: PurchaseDialog(
                            data: data,
                            item: item,
                          ),
                        );
                      },
                    ),
                  ]
                ),
              ],
            ),
          ],
        );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Paragliding Exams',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Palette.purple40,
          brightness: Brightness.light,
          dynamicSchemeVariant: DynamicSchemeVariant.content,
          contrastLevel: 0.5,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Palette.purple80,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.content,
          contrastLevel: 0.5,
        ),
        useMaterial3: true,
      ),
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      scaffoldMessengerKey: scaffoldMessengerKey,
      builder: (context, child) => Stack(
        children: <Widget>[child ?? const SizedBox()],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:para_exams/top_bar.dart';

import 'data.dart';
import 'model.dart';

class ExamsScreen extends StatefulWidget {
  final Data data;
  final String id;

  String get title => data.menus[id]!.name;

  String get shortTitle => data.menus[id]!.shortName;

  List<Exam> get items => data.menus[id]!.items;

  const ExamsScreen({
    super.key,
    required this.data,
    required this.id,
  });

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  @override
  Widget build(BuildContext context) => PopScope(
        canPop: true,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TopBar(title: widget.title),
              const Spacer(flex: 1),
              MenuView(
                id: widget.id,
                title: widget.shortTitle,
                items: widget.items,
              ),
              const Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => GoRouter.of(context).push('/help'),
                      child: const Text('📚   Help'),
                    ),
                    OutlinedButton(
                      onPressed: () => GoRouter.of(context).push('/about'),
                      child: const Text('📜   About'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
}

class MenuView extends StatelessWidget {
  final String id;
  final String title;
  final List<Exam> items;

  const MenuView({
    super.key,
    required this.id,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Coming coon..",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    } else {
      return Column(
        children: [
          ...items.map((it) {
            final date =
                DateFormat.yMMMMd(it.lang).format(DateTime.parse(it.date));
            final shortDate =
                DateFormat.yMd(it.lang).format(DateTime.parse(it.date));
            final name = '$title - $date';
            final shortName = '$title - $shortDate';
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: () {
                    var extra = {'id': '${it.date}.$id', 'title': shortName};
                    GoRouter.of(context).push('/exam', extra: extra);
                  },
                  child: Text(name),
                ),
              ),
            );
          }),
        ],
      );
    }
  }
}

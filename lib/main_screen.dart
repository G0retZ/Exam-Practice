import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:para_exams/palette.dart';

import 'common.dart';
import 'data.dart';
import 'model.dart';

sealed class AppState {}

class AppStatePending extends AppState {}

class AppStateError extends AppState {}

class AppStateOutdated extends AppState {
  String date;

  AppStateOutdated({required this.date});
}

class AppStateFresh extends AppState {}

class MainScreen extends StatefulWidget {
  final Data data;

  const MainScreen({
    super.key,
    required this.data,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late AppState state;

  @override
  void initState() {
    _retry();
    super.initState();
  }

  void _retry() {
    setState(() => state = AppStatePending());
    widget.data.loadData().then(
          (result) => result
              .map<AppState>(
                (res) =>
                    res?.let((it) => AppStateOutdated(date: it)) ??
                    AppStateFresh(),
              )
              .getOrElse((exception) => AppStateError())
              .also((st) => setState(() => state = st)),
        );
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: true,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MainTopBar(state: state, retry: _retry),
              const Spacer(flex: 1),
              Image.asset(
                'assets/images/app_icon.png',
                width: 128,
                height: 128,
              ),
              const Spacer(flex: 1),
              MenuView(
                data: widget.data,
                state: state,
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
  final Data data;
  final AppState state;

  Iterable<MapEntry<String, MenuItem>> get items => data.menus.entries;

  const MenuView({
    super.key,
    required this.data,
    required this.state,
  });

  @override
  Widget build(BuildContext context) => switch (state) {
        AppStatePending() => Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            child: const CircularProgressIndicator(),
          ),
        AppStateError() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                'Please report an issue to us\nto resolve it ASAP.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => sendEmail(
                  subject: "App failure",
                  object: "Menu load failed",
                  comment: "",
                ),
                child: const Text('🙋 Report an issue'),
              ),
            ],
          ),
        AppState() => items.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Coming coon..",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : Column(
                children: [
                  ...items.map((it) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            var extra = {'id': it.key};
                            GoRouter.of(context).push('/exams', extra: extra);
                          },
                          child: Text(it.value.name),
                        ),
                      ))
                ],
              ),
      };
}

class MainTopBar extends StatelessWidget {
  final AppState state;
  final void Function() retry;

  const MainTopBar({
    super.key,
    required this.state,
    required this.retry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: switch (state) {
        AppStatePending() => Palette.getMissed(context),
        AppStateError() => Palette.getIncorrect(context),
        AppStateOutdated() => Palette.getMissed(context),
        AppStateFresh() => Palette.getCorrect(context),
      },
      elevation: 0,
      child: SizedBox(
        height: 56,
        child: InkWell(
          onTap: () {
            if (state is! AppStatePending) retry();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 56),
              const Spacer(flex: 1),
              Text(
                switch (state) {
                  AppStatePending() => 'Updating data...',
                  AppStateError() => 'Internal failure. Try again',
                  AppStateOutdated() =>
                    'Last updated on ${(state as AppStateOutdated).date}',
                  AppStateFresh() => 'Data is updated!',
                },
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Spacer(flex: 1),
              state is! AppStatePending
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.refresh),
                    )
                  : const SizedBox(width: 56),
            ],
          ),
        ),
      ),
    );
  }
}

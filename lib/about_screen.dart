import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:link_text/link_text.dart';
import 'package:para_exams/top_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: true,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const TopBar(title: '📜   About'),
              const Spacer(flex: 3),
              const Text(
                'Made by Sergei Mitrofanov',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'It took me 200 hours of pure efforts\nto make this app 😔\nTo process all the exams materials,\n turn them into code etc. 🫣',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Good luck on the exam!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'And Happy flying!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(flex: 2),
              LinkText(
                'Special thanks to Ricardo Diniz and his school\nfor providing materials and app testing\nhttps://www.espiral.com.pt',
                onLinkTap: (it) => launchUrlString(it),
                textAlign: TextAlign.center,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                linkStyle: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              const SizedBox(height: 32),
              const Text(
                'If you like this app I will greatly appreciate\nif you decide to support my efforts 🥹',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => GoRouter.of(context)
                    .push('/web', extra: {'type': 'donate'}),
                child: const Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Support with'),
                    SizedBox(width: 8),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '☕️',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => GoRouter.of(context)
                        .push('/web', extra: {'type': 'license'}),
                    child: const Text('⚖️   License'),
                  ),
                  TextButton(
                    onPressed: () => GoRouter.of(context)
                        .push('/web', extra: {'type': 'sources'}),
                    child: const Text('💽   Source code'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
}

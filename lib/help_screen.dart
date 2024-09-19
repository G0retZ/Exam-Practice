import 'package:flutter/material.dart';
import 'package:para_exams/palette.dart';
import 'package:para_exams/top_bar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: true,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const TopBar(title: '📚   Help'),
              Expanded(
                child: ListView(
                  children: [
                    TextLegend(
                      color: Palette.getPassed(context),
                      text: "Passed Exam or Section 50%",
                      note: "(50% = It has 50% of correct answers)",
                    ),
                    TextLegend(
                      color: Palette.getFailed(context),
                      text: "Failed Exam or Section 50%",
                      note: "(50% = It has 50% of correct answers)",
                    ),
                    ColorLegend(
                      color: Palette.getCorrect(context),
                      text: "Passed Question",
                    ),
                    ColorLegend(
                      color: Palette.getMissed(context),
                      text: "Missed Question",
                    ),
                    ColorLegend(
                      color: Palette.getIncorrect(context),
                      text: "Failed Question",
                    ),
                    ColorLegend(
                      color: Palette.getCorrectStrong(context),
                      text: "Correct answer",
                    ),
                    ColorLegend(
                      color: Palette.getIncorrectStrong(context),
                      text: "Wrong answer",
                    ),
                    ColorLegend(
                      color: Palette.getSelectedStrong(context),
                      text: "Selected answer",
                    ),
                    ColorLegend(
                      color: Palette.getMissedStrong(context),
                      text: "Missed correct answer",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class TextLegend extends StatelessWidget {
  final Color color;
  final String text;
  final String note;

  const TextLegend({
    super.key,
    required this.color,
    required this.text,
    required this.note,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(24),
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 20, color: color),
            ),
            Text(
              note,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
}

class ColorLegend extends StatelessWidget {
  final Color color;
  final String text;

  const ColorLegend({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(24),
        color: color,
        child: Text(text),
      );
}

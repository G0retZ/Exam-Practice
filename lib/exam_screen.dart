import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:para_exams/data.dart';

import 'common.dart';
import 'model.dart';
import 'palette.dart';
import 'top_bar.dart';

class ExamState {
  final Exam exam;
  final bool isRevealed;

  ExamState(this.exam, this.isRevealed);

  ExamState.init(this.exam) : isRevealed = false {
    exam.reset();
  }

  ExamState next() {
    if (isRevealed) exam.reset();
    return ExamState(exam, !isRevealed);
  }
}

class ExamScreen extends StatefulWidget {
  final String title;
  final Exam exam;
  final Data data;

  const ExamScreen({
    super.key,
    required this.title,
    required this.exam,
    required this.data,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late ExamState state;

  @override
  void initState() {
    state = ExamState.init(widget.exam);
    super.initState();
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
              ExamView(title: widget.title, state: state),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ListView(children: [
                        ...state.exam.sections.map((it) => SectionView(
                              section: it,
                              isRevealed: state.isRevealed,
                            )),
                        const SizedBox(height: 80),
                      ]),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: FilledButton(
                          onPressed: () {
                            if (!state.isRevealed) {
                              final router = GoRouter.of(context);
                              widget.data
                                  .updateUsage(1)
                                  .then((_) => widget.data.isOverused)
                                  .then((it) => router.takeIf((_) => it))
                                  .then((it) => it?.push('/donate'));
                            }
                            setState(() => state = state.next());
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              state.isRevealed ? '🪣  Clear' : '🔮  Submit',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class ExamView extends StatelessWidget {
  final String title;
  final ExamState state;

  const ExamView({
    super.key,
    required this.title,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
            TopBarText(
              title,
              color: state.isRevealed
                  ? state.exam.isPassed
                      ? Palette.getPassed(context)
                      : Palette.getFailed(context)
                  : null,
            ),
            const Spacer(flex: 1),
            TopBarText(
              '${(state.exam.scoreRate * 100).toInt()}%',
              color: state.isRevealed
                  ? state.exam.isPassed
                      ? Palette.getPassed(context)
                      : Palette.getFailed(context)
                  : Palette.unspecified,
            ),
            const SizedBox(width: 16)
          ],
        ),
      ),
    );
  }
}

class SectionView extends StatelessWidget {
  final Section section;
  final bool isRevealed;

  const SectionView({
    super.key,
    required this.section,
    required this.isRevealed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          alignment: Alignment.center,
          child: Text(
            isRevealed
                ? '${section.name} ${(section.scoreRate * 100).toInt()}%'
                : section.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: isRevealed
                  ? section.isPassed
                      ? Palette.getPassed(context)
                      : Palette.getFailed(context)
                  : null,
            ),
          ),
        ),
        ...section.questions.map(
          (it) => QuestionView(
            question: it,
            isRevealed: isRevealed,
          ),
        ),
      ],
    );
  }
}

class QuestionView extends StatefulWidget {
  final Question question;
  final bool isRevealed;

  const QuestionView({
    super.key,
    required this.question,
    required this.isRevealed,
  });

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: widget.isRevealed
              ? switch (widget.question.isSuccessful) {
                  true => Palette.getCorrect(context),
                  false => Palette.getIncorrect(context),
                  null => Palette.getMissed(context),
                }
              : Theme.of(context).colorScheme.surfaceContainer,
          alignment: Alignment.centerLeft,
          child: Text(
            widget.question.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        widget.question.image?.let(
              (it) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Image.asset('assets/images/$it'),
              ),
            ) ??
            const SizedBox(),
        _getTable() ?? const SizedBox(),
        ...widget.question.answers.entries.map(
          (it) => InkWell(
            onTap: () {
              if (!widget.isRevealed) {
                setState(() {
                  if (widget.question.selectedAnswer == it.key) {
                    widget.question.selectedAnswer = null;
                  } else {
                    widget.question.selectedAnswer = it.key;
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              color: _getColor(context, it.key),
              child: Row(
                children: [
                  Text(
                    '${it.key})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      it.value,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          height: 1,
          margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
          color: Theme.of(context).dividerColor,
        )
      ],
    );
  }

  Widget? _getTable() => widget.question.table?.let(
        (it) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Table(
            border: TableBorder(
              top: BorderSide(color: Theme.of(context).dividerColor),
              bottom: BorderSide(color: Theme.of(context).dividerColor),
              left: BorderSide(color: Theme.of(context).dividerColor),
              right: BorderSide(color: Theme.of(context).dividerColor),
              horizontalInside:
                  BorderSide(color: Theme.of(context).dividerColor),
            ),
            children: it
                .map(
                  (it) => TableRow(
                    children: it
                        .map(
                          (it) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Text(
                                it,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        ),
      );

  Color _getColor(BuildContext context, String current) {
    if (widget.isRevealed) {
      if (current == widget.question.selectedAnswer) {
        return widget.question.selectedAnswer == widget.question.correctAnswer
            ? Palette.getCorrectStrong(context)
            : Palette.getIncorrectStrong(context);
      } else {
        return current == widget.question.correctAnswer
            ? Palette.getMissedStrong(context)
            : Palette.unspecified;
      }
    } else {
      return current == widget.question.selectedAnswer
          ? Palette.getSelectedStrong(context)
          : Palette.unspecified;
    }
  }
}

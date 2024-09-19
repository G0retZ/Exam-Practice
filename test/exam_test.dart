import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:para_exams/model.dart';

final Random _rnd = Random();

void main() {
  test('Test passed exam score rate', () {
    final exam = _generateExam("0", true);
    expect(0.8, exam.scoreRate);
    expect(true, exam.isPassed);
  });

  test('Test passed section score and rate', () {
    final section = _generateSection("0", true);
    expect(0.8, section.scoreRate);
    expect(16, section.score);
    expect(true, section.isPassed);
  });

  test('Test passed question score', () {
    final questions = _generateQuestion("0", true);
    expect(2.0, questions.score);
  });
}

Exam _generateExam(String id, bool passed) => Exam(
      lang: id,
      level: 1,
      date: "Test exam $id",
      sections: List.generate(
        10,
        (it) => _generateSection(it.toString(), passed),
      ),
    );

Section _generateSection(String id, bool passed) => Section(
      name: "Test section $id",
      questions: List.generate(
        10,
        (it) => _generateQuestion(it.toString(), it < (passed ? 8 : 6)),
      ),
    );

Question _generateQuestion(String id, bool correct) {
  final correctAnswer = switch (_rnd.nextInt(4)) {
    0 => "a",
    1 => "b",
    2 => "c",
    int() => "d",
  };
  return Question(
    text: "Question $id",
    answers: {
      "a": "A",
      "b": "B",
      "c": "C",
      "d": "D",
    },
    correctAnswer: correctAnswer,
    selectedAnswer: correct ? correctAnswer : null,
  );
}

import 'dart:convert';
import 'dart:math';

import 'package:objectbox/objectbox.dart';

import 'common.dart';

@Entity()
class LastCheckEntity {
  @Id()
  int id = 0;
  String date;

  LastCheckEntity({
    this.id = 0,
    required this.date,
  });
}

@Entity()
class UsageEntity {
  @Id()
  int id = 0;
  int count;

  UsageEntity({
    this.id = 0,
    required this.count,
  });
}

@Entity()
class ExamsSourceEntity {
  @Id()
  int id = 0;
  int version;
  String path;
  String examId;
  String data;

  ExamsSourceEntity({
    this.id = 0,
    required this.path,
    required this.version,
    required this.examId,
    this.data = '',
  });

  void setExam(ExamsSource item) {
    examId = item.id;
    version = item.version;
    data = jsonEncode(item);
  }

  ExamsSource getExam() => ExamsSource.fromJson(jsonDecode(data));
}

class MenuItem {
  final String name;
  final String shortName;
  Set<Exam> items = {};

  MenuItem({
    required this.name,
    required this.shortName,
  });

  MenuItem.fromJson(Map<String, dynamic> json)
      : name = json.getString('name'),
        shortName = json.getString('shortName');

  Map<String, dynamic> toJson() => {
        'name': name,
        'shortName': shortName,
      };
}

class ExamsSource {
  final String id;
  final int version;
  List<Exam> exams = [];

  ExamsSource({
    required this.id,
    required this.version,
  });

  ExamsSource.fromJson(Map<String, dynamic> json)
      : id = json.getString('id'),
        version = json.getInt('version'),
        exams = json.getMaps('exams').map((it) => Exam.fromJson(it)).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'version': version,
        'exams': exams,
      };
}

class Exam {
  final String lang;
  final int level;
  final String date;

  final List<Section> sections;

  Exam({
    required this.lang,
    required this.level,
    required this.date,
    required this.sections,
  });

  Exam.fromJson(Map<String, dynamic> json)
      : lang = json.getString('lang'),
        level = json.getInt('level'),
        date = json.getString('date'),
        sections =
            json.getMaps('sections').map((it) => Section.fromJson(it)).toList();

  Map<String, dynamic> toJson() => {
        'lang': lang,
        'level': level,
        'date': date,
        'sections': sections,
      };

  double get scoreRate =>
      _score /
      sections.map((it) => it.maxScore).reduce((acc, item) => acc + item);

  double get _score =>
      sections.map((it) => it.score).reduce((acc, item) => acc + item);

  bool get isPassed =>
      sections.map((it) => it.isPassed).reduce((acc, item) => acc && item) &&
      _score >= 0.75;

  void reset() {
    for (var it in sections) {
      it.reset();
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exam &&
          runtimeType == other.runtimeType &&
          lang == other.lang &&
          level == other.level &&
          date == other.date;

  @override
  int get hashCode => lang.hashCode ^ level.hashCode ^ date.hashCode;
}

class Section {
  final String name;
  final List<Question> questions;

  Section({required this.name, required this.questions});

  Section.fromJson(Map<String, dynamic> json)
      : name = json.getString('name'),
        questions = json
            .getMaps('questions')
            .map((it) => Question.fromJson(it))
            .toList();

  Map<String, dynamic> toJson() => {
        'name': name,
        'questions': questions,
      };

  double get maxScore =>
      questions.map((it) => it.maxScore).reduce((acc, item) => acc + item);

  double get score =>
      questions.map((it) => it.score).reduce((acc, item) => acc + item);

  double get scoreRate =>
      score /
      questions.map((it) => it.maxScore).reduce((acc, value) => acc + value);

  bool get isPassed => scoreRate >= 0.7;

  void reset() {
    for (var it in questions) {
      it.reset();
    }
  }
}

class Question {
  final String text;
  final String? image;
  final List<List<String>>? table;
  final Map<String, String> answers;
  final String correctAnswer;
  String? selectedAnswer;

  final maxScore = 2.0;

  Question({
    required this.text,
    this.image,
    this.table,
    required this.answers,
    required this.correctAnswer,
    this.selectedAnswer,
  }) {
    assert(correctAnswer.isNotEmpty, "No answer is provided");
    assert(answers.length == 4, "Wrong answers count");
    answers.forEach(
      (key, value) {
        assert(key.isNotEmpty, "key is blank");
        assert(value.isNotEmpty, "value is blank");
      },
    );
  }

  Question.fromJson(Map<String, dynamic> json)
      : text = json.getString('text'),
        image = json.getStringOrNull('image'),
        table = json.getStringsTable('table'),
        answers =
            json.getMap('answers').map((key, value) => MapEntry(key, value)),
        correctAnswer = json.getString('correctAnswer') {
    assert(correctAnswer.isNotEmpty, "No answer is provided");
    assert(answers.length == 4, "Wrong answers count");
    answers.forEach(
      (key, value) {
        assert(key.isNotEmpty, "key is blank");
        assert(value.isNotEmpty, "value is blank");
      },
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'image': image,
        'table': table,
        'answers': answers,
        'correctAnswer': correctAnswer,
      };

  bool? get isSuccessful {
    if (selectedAnswer == correctAnswer) {
      return true;
    } else if (selectedAnswer == null) {
      return null;
    } else {
      return false;
    }
  }

  double get score {
    if (selectedAnswer == correctAnswer) {
      return 2.0;
    } else if (selectedAnswer == null) {
      return 0.0;
    } else {
      return -0.5;
    }
  }

  void reset() => selectedAnswer = null;
}

Random _rnd = Random();

Question get randomQuestion => Question(
      text: getRandomString(_rnd.nextInt(25) + 25),
      answers: {
        "a": getRandomString(_rnd.nextInt(25) + 25),
        "b": getRandomString(_rnd.nextInt(25) + 25),
        "c": getRandomString(_rnd.nextInt(25) + 25),
        "d": getRandomString(_rnd.nextInt(25) + 25),
      },
      correctAnswer: "a",
    );

Section get randomSection => Section(
      name: getRandomString(_rnd.nextInt(25) + 25),
      questions: List.generate(5 + _rnd.nextInt(5), (it) => randomQuestion),
    );

Exam get randomExam => Exam(
      lang: getRandomString(_rnd.nextInt(5) + 5),
      level: _rnd.nextInt(2) + 1,
      date: getRandomString(_rnd.nextInt(25) + 25),
      sections: List.generate(2 + _rnd.nextInt(3), (it) => randomSection),
    );

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:para_exams/common.dart';
import 'package:path/path.dart' as path_dart;
import 'package:path_provider/path_provider.dart';

import 'model.dart';
import 'objectbox.g.dart';

const examsData = [
  'aHR0cHM6Ly9hcGkuZ2l0aHViLmNvbS9yZXBvcy9HMHJldFovcGFyYS1leGFtcy9jb250ZW50cy9mcmVlL2wxLmVuLmZyZWUuanNvbg%3D%3D',
  'aHR0cHM6Ly9hcGkuZ2l0aHViLmNvbS9yZXBvcy9HMHJldFovcGFyYS1leGFtcy9jb250ZW50cy9mcmVlL2wxLnB0LmZyZWUuanNvbg%3D%3D',
  'aHR0cHM6Ly9hcGkuZ2l0aHViLmNvbS9yZXBvcy9HMHJldFovcGFyYS1leGFtcy9jb250ZW50cy9mcmVlL2wyLmVuLmZyZWUuanNvbg%3D%3D',
  'aHR0cHM6Ly9hcGkuZ2l0aHViLmNvbS9yZXBvcy9HMHJldFovcGFyYS1leGFtcy9jb250ZW50cy9mcmVlL2wyLnB0LmZyZWUuanNvbg%3D%3D',
];

const _remotePath =
    "https://api.github.com/repos/G0retZ/Exam-Practice/contents/assets/data";

Exception? _lastError;
String _settings =
    'SkpaXWByTE1aSWZJS11NfpNRkk5PYHhyfE9ihUlLiIhugWaEiHKHgmOShlJMY2xMiHFbk01rjG2MjopRTH9wTINMT2lQTWpQa2+Rf0+NfXNdbA==';

class Data {
  final Map<String, Exam> exams = {};
  final Map<String, MenuItem> menus = {};
  late final Box<ExamsSourceEntity> _entitiesBox;
  late final Box<LastCheckEntity> _lastCheckBox;
  late final Box<UsageEntity> _usageEntity;

  Future<void> init() async {
    await initializeDateFormatting();
    final docsDir = await getApplicationDocumentsDirectory();
    final Store store =
        await openStore(directory: path_dart.join(docsDir.path, 'data-db'));
    _settings = _settings
        .let(base64Decode)
        .let(String.fromCharCodes)
        .runes
        .map((it) => it - DateTime.now().year + 2000)
        .let(String.fromCharCodes);
    _entitiesBox = store.box<ExamsSourceEntity>();
    _lastCheckBox = store.box<LastCheckEntity>();
    _usageEntity = store.box<UsageEntity>();
  }

  Future<Result<String?>> loadData() async {
    exams.clear();
    menus.clear();
    Result<String?> result = const Success(null);
    final menuResult = await _loadMenus();
    switch (menuResult) {
      case Success<Map<String, MenuItem>>():
        menus.addAll(menuResult.value);
      case Failure<Map<String, MenuItem>>():
        return menuResult.cast();
    }
    final timeStamp = DateFormat.yMMMd('en_GB').format(DateTime.now());
    var lastCheck =
        await _lastCheckBox.getAsync(1) ?? LastCheckEntity(date: timeStamp);
    final examEntities = await _entitiesBox.getAllAsync();
    final List<int> examsToRemove = [];
    if (examEntities.isEmpty) {
      final paths = examsData
          .map(Uri.decodeFull)
          .map(base64Decode)
          .map(String.fromCharCodes);
      for (final path in paths) {
        final examsResult = (await _loadExams(path, 5));
        switch (examsResult) {
          case Success<ExamsSource>():
            final exams = examsResult.getOrNull()!;
            examEntities.add(
              ExamsSourceEntity(
                path: path,
                version: exams.version,
                examId: exams.id,
              )..setExam(exams),
            );
          case Failure<ExamsSource>():
            result = examsResult.cast();
        }
      }
    } else {
      final updateResult = await _loadVersions(1);
      switch (updateResult) {
        case Success<Map<String, int>>():
          for (var entity in examEntities) {
            final version = updateResult.value[entity.examId];
            if (version == null) {
              examsToRemove.add(entity.id);
            } else if (version > entity.version) {
              final examsResult = (await _loadExams(entity.path, 2))
                  .map((source) => entity.setExam(source));
              if (examsResult is Failure) {
                result = Success(lastCheck.date);
              }
            }
          }
          if (result is Success && result.getOrNull() == null) {
            lastCheck.date = timeStamp;
          }
        case Failure<Map<String, int>>():
          result = updateResult.map((_) => '').mapError((_) => lastCheck.date);
      }
    }
    examEntities.removeWhere((it) => examsToRemove.contains(it.id));
    examEntities.map((it) => it.getExam()).forEach((exams) {
      final id = exams.id;
      final sorted = exams.exams..sort((a, b) => b.date.compareTo(a.date));
      menus[id]?.items.addAll(sorted);
      for (var exam in sorted) {
        this.exams['${exam.date}.$id'] = exam;
      }
    });
    await _entitiesBox.removeManyAsync(examsToRemove);
    await _entitiesBox.putManyAsync(examEntities);
    await _lastCheckBox.putAsync(lastCheck);
    return result;
  }

  Future<void> updateUsage(int count) async {
    final usage = await _usageEntity.getAsync(1)
      ?..count += count;
    await _usageEntity.putAsync(usage ?? UsageEntity(count: count));
  }

  Future<bool> get isOverused =>
      _usageEntity.getAsync(1).then((it) => (it?.count ?? 0) > 16);

  Future<Result<Map<String, MenuItem>>> _loadMenus() =>
      loadFile('$_remotePath/menus.json', 2).then(
        (result) => result.then(
          (data) => parseJson<Map<String, MenuItem>>(
            data,
            (json) => (json as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, MenuItem.fromJson(value)),
            ),
          ),
        ),
      );

  Future<Result<Map<String, int>>> _loadVersions(int retries) =>
      loadFile('$_remotePath/versions.json', retries).then(
        (result) => result.then(
          (data) => parseJson(
            data,
            (json) => (json as Map<String, dynamic>)
                .map<String, int>((key, value) => MapEntry(key, value)),
          ),
        ),
      );

  Future<Result<ExamsSource>> _loadExams(String path, int retries) =>
      loadFile(path, retries).then(
        (result) => result.then(
          (data) => parseJson(
            data,
            (json) => ExamsSource.fromJson(json),
          ),
        ),
      );
}

String get _optionsKey => 'Wo6NgYiLgpN6jYKIhw=='
    .let(base64Decode)
    .let(String.fromCharCodes)
    .runes
    .map((it) => it - DateTime.now().year + 2000)
    .let(String.fromCharCodes);

String get _options => 'W356i36LOYCCjYGOe3iJeo14'
    .let(base64Decode)
    .let(String.fromCharCodes)
    .runes
    .map((it) => it - DateTime.now().year + 2000)
    .let(String.fromCharCodes)
    .let((it) => '$it$_settings');

Result<T> parseJson<T>(String data, T Function(dynamic json) parse) {
  try {
    var decode = json.decode(data);
    var value = parse(decode);
    return Success(value);
  } on Exception catch (exception, stackTrace) {
    _lastError = exception;
    debugPrint('Parse Exception: $exception');
    debugPrintStack(stackTrace: stackTrace);
    return Failure(ParseException(exception));
  } catch (exception, stackTrace) {
    debugPrint('Parse Failure: $exception');
    debugPrintStack(stackTrace: stackTrace);
    return Failure(ParseException(Exception(exception)));
  }
}

Future<Result<String>> loadFile(String path, int retries) async {
  try {
    final response = await http.get(
      Uri.parse(path),
      headers: {
        _optionsKey: _options,
        'Accept': 'application/vnd.github.v3.raw+json',
      },
    );
    if (response.statusCode == 200) {
      return Success(response.body);
    } else if (retries > 0) {
      return await loadFile(path, retries - 1);
    } else {
      var exception = HttpException(
        '${response.statusCode}: ${response.reasonPhrase}',
        uri: response.request?.url,
      );
      _lastError = exception;
      debugPrint('Http Failure: $exception');
      debugPrintStack(stackTrace: StackTrace.current);
      return Failure(exception);
    }
  } on Exception catch (exception, stackTrace) {
    _lastError = exception;
    debugPrint('Network Exception: $exception');
    debugPrintStack(stackTrace: stackTrace);
    return Failure(exception);
  } catch (exception, stackTrace) {
    _lastError = Exception(exception);
    debugPrint('Network Failure: $exception');
    debugPrintStack(stackTrace: stackTrace);
    return Failure(Exception(exception));
  }
}

Future<void> sendEmail({
  required String subject,
  required String object,
  required String comment,
}) async {
  final error = switch (_lastError) {
    ParseException() => (_lastError as ParseException).cause,
    Exception() => _lastError,
    null => null
  };
  final Email email = Email(
    body: 'I have a trouble with $object'
        '\n\n$comment'
        '\n\nError: $error',
    subject: subject,
    recipients: ['goretz.m@gmail.com'],
    isHTML: false,
  );

  await FlutterEmailSender.send(email);
}

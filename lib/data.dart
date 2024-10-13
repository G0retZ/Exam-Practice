import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:para_exams/common.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'model.dart';
import 'objectbox.g.dart';

const builtInExams = [
  "l1.pt.free",
  "l1.en.free",
  "l2.pt.free",
  "l2.en.free",
];

const _remotePath =
    "https://api.github.com/repos/G0retZ/Exam-Practice/contents/assets/data";
const _localPath = "assets/data";

Exception? _lastError;
String _settings =
    'SUlZXF9xS0xZSIOIbX2Rj2x6i1yEhXdrbUuDSVCHkG+HY3yEgIR/jGVPSWt9ekpQhkhmS2ZggV+EXV9QeYZQkmhwcGxoS0xtX3FQgV2ShYOPfg==';

class Data {
  final Map<String, Exam> exams = {};
  final Map<String, MenuItem> menus = {};
  late final Box<ExamsSourceEntity> _entitiesBox;
  late final Box<LastCheckEntity> _lastCheckBox;

  Future<void> init() async {
    await initializeDateFormatting();
    final docsDir = await getApplicationDocumentsDirectory();
    final Store store =
        await openStore(directory: path.join(docsDir.path, 'data-db'));
    _settings = _settings
        .let(base64Decode)
        .let(String.fromCharCodes)
        .runes
        .map((it) => it - DateTime.now().year + 2000)
        .let(String.fromCharCodes);
    _entitiesBox = store.box<ExamsSourceEntity>();
    _lastCheckBox = store.box<LastCheckEntity>();
  }

  Future<Result<String?>> loadData() async {
    exams.clear();
    menus.clear();
    final result = await _loadMenus();
    switch (result) {
      case Success<Map<String, MenuItem>>():
        menus.addAll(result.value);
      case Failure<Map<String, MenuItem>>():
        return result.cast();
    }
    if (_entitiesBox.getAll().isEmpty) {
      for (var path in builtInExams) {
        final result = (await _loadExamsFromAssets('$_localPath/$path.json'))
            .map<void>((exam) {
          final entity = ExamsSourceEntity(
            path: '$_remotePath/$path.json',
            version: exam.version,
            examId: exam.id,
            data: '',
          )..setExam(exam);
          _entitiesBox.put(entity);
        });
        if (result is Failure) return result.cast();
      }
    }

    var lastCheck = _lastCheckBox.get(1) ??
        LastCheckEntity(date: DateFormat.yMMMd('en_GB').format(DateTime.now()))
            .also((it) => _lastCheckBox.put(it));
    final Set<String> versionsKeys = {};
    final updateResult = await (await _loadVersionsFromNetwork(1))
        .thenAsync<String?>((versions) async {
      versionsKeys.addAll(versions.keys);
      final examEntities = _entitiesBox.getAll();
      for (var entity in examEntities) {
        final id =
            entity.path.split('/').last.replaceAll(RegExp(r'\.json.*'), '');
        if ((versions[id] ?? 0) > entity.version) {
          final result =
              (await _loadExamsFromNetwork(entity.path, 2)).map((source) {
            entity.setExam(source);
            _entitiesBox.put(entity);
            return true;
          });
          if (result is Failure) return Success(lastCheck.date);
        }
      }
      lastCheck.date = DateFormat.yMMMd('en_GB').format(DateTime.now());
      _lastCheckBox.put(lastCheck);
      return const Success(null);
    });
    _entitiesBox.getAll().map((it) => it.getExam()).forEach((exams) {
      final id = exams.id;
      menus[id]?.items.addAll(exams.exams);
      menus[id]?.paidExams.addAll(
            versionsKeys
                .where((it) => it.contains(id) && it.startsWith('20'))
                .map((it) => it.substring(0, 10).replaceAll('.', '-')),
          );
      for (var exam in exams.exams) {
        this.exams['${exam.date}.$id'] = exam;
      }
    });
    return updateResult.mapError((_) => lastCheck.date);
  }

  Future<Result<void>> addExams(String url, int retries) async =>
      (await _loadExamsFromNetwork(url, retries)).map((exams) {
        final entity = ExamsSourceEntity(
          path: url,
          version: exams.version,
          examId: exams.id,
          data: '',
        )..setExam(exams);
        _entitiesBox.put(entity);
        menus[exams.id]?.items.addAll(exams.exams);
        for (var exam in exams.exams) {
          this.exams['${exam.date}.${exams.id}'] = exam;
        }
      });

  Future<Result<Map<String, int>>> _loadVersionsFromNetwork(int retries) async {
    return (await loadNetworkFile('$_remotePath/versions.json', retries)).then(
      (data) => parseJson(
        data,
        (json) => (json as Map<String, dynamic>)
            .map<String, int>((key, value) => MapEntry(key, value)),
      ),
    );
  }

  Future<Result<ExamsSource>> _loadExamsFromNetwork(
      String url, int retries) async {
    return (await loadNetworkFile(url, retries)).then(
      (data) => parseJson(
        data,
        (json) => ExamsSource.fromJson(json),
      ),
    );
  }

  Future<Result<ExamsSource>> _loadExamsFromAssets(String file) async =>
      (await loadAssetFile(file)).then(
        (data) => parseJson(
          data,
          (json) => ExamsSource.fromJson(json),
        ),
      );

  Future<Result<Map<String, MenuItem>>> _loadMenus() async =>
      (await loadAssetFile('$_localPath/menus.json')).then(
        (data) => parseJson<Map<String, MenuItem>>(
          data,
          (json) => (json as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, MenuItem.fromJson(value)),
          ),
        ),
      );
}

String get _optionsKey => 'WY2MgIeKgZJ5jIGHhg=='
    .let(base64Decode)
    .let(String.fromCharCodes)
    .runes
    .map((it) => it - DateTime.now().year + 2000)
    .let(String.fromCharCodes);

String get _options => 'Wn15in2KOH+BjICNeneIeYx3'
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

Future<Result<String>> loadAssetFile(String path) async {
  try {
    return Success(await rootBundle.loadString(path));
  } on Exception catch (exception, stackTrace) {
    _lastError = exception;
    debugPrint('Asset Exception: $exception');
    debugPrintStack(stackTrace: stackTrace);
    return Failure(exception);
  } catch (exception, stackTrace) {
    _lastError = Exception(exception);
    debugPrint('Asset Failure: $exception');
    debugPrintStack(stackTrace: stackTrace);
    return Failure(Exception(exception));
  }
}

Future<Result<String>> loadNetworkFile(String url, int retries) async {
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        _optionsKey: _options,
        'Accept': 'application/vnd.github.v3.raw+json',
      },
    );
    if (response.statusCode == 200) {
      return Success(response.body);
    } else if (retries > 0) {
      return await loadNetworkFile(url, retries - 1);
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

import 'dart:async';
import 'dart:math';

class Messenger<T> {
  final StreamController<T> _dataController = StreamController<T>.broadcast();

  Stream<T> get receive => _dataController.stream;

  void send(T message) {
    _dataController.sink.add(message);
  }

  void dispose() {
    _dataController.close();
  }
}

extension ObjectExt<T> on T {
  R let<R>(R Function(T it) op) => op(this);

  void run(void Function(T it) op) => op(this);

  T? takeIf(bool Function(T it) op) => op(this) ? this : null;

  T also(void Function(T it) op) {
    op(this);
    return this;
  }

  R? as<R>() => this is R ? this as R : null;
}

sealed class Result<S> {
  const Result();

  S? getOrNull() => switch (this) {
        Success() => (this as Success).value,
        Failure() => null,
      };

  S getOrElse(S Function(Exception e) transformError) => switch (this) {
        Success() => (this as Success).value,
        Failure() => transformError((this as Failure).exception),
      };

  Result<R> map<R>(R Function(S s) transform) {
    try {
      return switch (this) {
        Success() => Success(transform((this as Success).value)),
        Failure() => Failure((this as Failure).exception),
      };
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  Result<S> mapError(S Function(Exception e) operation) {
    try {
      return switch (this) {
        Success() => this,
        Failure() => Success(operation((this as Failure).exception)),
      };
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  Result<R> then<R>(Result<R> Function(S s) operation) {
    try {
      return switch (this) {
        Success() => operation((this as Success).value),
        Failure() => Failure((this as Failure).exception),
      };
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  Future<Result<R>> thenAsync<R>(
      Future<Result<R>> Function(S s) operation) async {
    try {
      return switch (this) {
        Success() => await operation((this as Success).value),
        Failure() => Failure((this as Failure).exception),
      };
    } on Exception catch (e) {
      return Failure(e);
    }
  }
}

final class Success<S> extends Result<S> {
  const Success(this.value);

  final S value;
}

final class Failure<S> extends Result<S> {
  const Failure(this.exception);

  final Exception exception;

  Result<R> cast<R>() => Failure(exception);
}

class ParseException implements Exception {
  final Exception cause;

  ParseException(this.cause);
}

extension MapExt on Map<String, dynamic> {
  T? getNullable<T>(String key) => this[key] as T?;

  T getNotNull<T>(String key) =>
      ArgumentError.checkNotNull(this[key] as T?, key);

  bool getBool(String key) => getNotNull<bool>(key);

  String getString(String key) => getNotNull<String>(key);

  String? getStringOrNull(String key) => getNullable<String>(key);

  int getInt(String key) => getNotNull<int>(key);

  double getDouble(String key) => getNotNull<double>(key);

  List<List<String>>? getStringsTable(String key) => getNullable<List>(key)
      ?.map((it) => it as List)
      .map((it) => it.cast<String>())
      .toList();

  Map<String, dynamic> getMap(String key) =>
      getNotNull<Map>(key).cast<String, dynamic>();

  List<Map<String, dynamic>> getMaps(String key) =>
      getNotNull<List>(key).cast<Map<String, dynamic>>();
}

const _chars =
    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890 ';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
      ),
    );

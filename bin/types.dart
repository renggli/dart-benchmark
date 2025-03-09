// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:more/collection.dart';

abstract class Result<T> {
  bool get isSuccess;
}

class Success<T> extends Result<T> {
  @override
  bool get isSuccess => true;
}

class Failure extends Result<Never> {
  @override
  bool get isSuccess => false;
}

final random = Random(42);
final inputs = IntegerRange(1024 * 1024)
    .map<Result<String>>((_) {
      if (random.nextBool()) {
        return Success<String>();
      } else {
        return Failure();
      }
    })
    .toList(growable: false);

Benchmark exercise(bool Function(Result<String>) underTest) =>
    () => inputs.forEach(underTest);

void main() {
  experiments(
    experiments: {
      'constant': exercise((result) => true),
      // method
      'isSuccess': exercise((result) => result.isSuccess),
      // is-operator
      'is Success': exercise((result) => result is Success),
      // is-operator with Object
      'is Success<Object>': exercise((result) => result is Success<Object>),
      // is-operator with Object?
      'is Success<Object?>': exercise((result) => result is Success<Object?>),
      // is-operator with dynamic
      'is Success<dynamic>': exercise((result) => result is Success<dynamic>),
      // is-operator with String
      'is Success<String>': exercise((result) => result is Success<String>),
    },
  );
}

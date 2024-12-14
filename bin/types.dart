// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:more/collection.dart';
import 'package:petitparser/petitparser.dart';

final random = Random(42);
const context = Context('', 0);
final inputs = IntegerRange(1024 * 1024).map<Result<String>>((_) {
  if (random.nextBool()) {
    return context.success<String>('success');
  } else {
    return context.failure('failure');
  }
}).toList(growable: false);

Benchmark exercise(bool Function(Result<String>) underTest) =>
    () => inputs.forEach(underTest);

void main() {
  experiments(
    experiments: {
      'constant': exercise((result) => true),
      // Method
      'isSuccess': exercise((result) => result.isSuccess),
      'isFailure': exercise((result) => result.isFailure),
      // is-operator
      'is Success': exercise((result) => result is Success),
      'is Failure': exercise((result) => result is Failure),
      // is-operator with dynamic
      'is Success<dynamic>': exercise((result) => result is Success<dynamic>),
      // is-operator with type
      'is Success<T>': exercise((result) => result is Success<String>),
      // is-operator with Object?
      'is Success<Object?>': exercise((result) => result is Success<Object?>),
    },
  );
}

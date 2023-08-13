import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:more/collection.dart';
import 'package:petitparser/petitparser.dart';

final random = Random(42);
const context = Context('', 0);
final inputs = IntegerRange(1024 * 1024)
    .map<Result<String>>((_) => random.nextBool()
        ? context.success<String>('success')
        : context.failure<String>('failure'))
    .toList(growable: false);

Benchmark exercise(bool Function(Result<String>) underTest) =>
    () => inputs.forEach(underTest);

void main() {
  experiments(
    control: exercise((result) => true),
    experiments: {
      // Method
      'isSuccess': exercise((result) => result.isSuccess),
      'isFailure': exercise((result) => result.isFailure),
      // is-operator
      'is Success': exercise((result) => result is Success),
      'is Failure': exercise((result) => result is Failure),
      // is-operator with dynamic
      'is Success<dynamic>': exercise((result) => result is Success<dynamic>),
      'is Failure<dynamic>': exercise((result) => result is Failure<dynamic>),
      // is-operator with type
      'is Success<T>': exercise((result) => result is Success<String>),
      'is Failure<T>': exercise((result) => result is Failure<String>),
      // is-operator with Object?
      'is Success<Object?>': exercise((result) => result is Success<Object?>),
      'is Failure<Object?>': exercise((result) => result is Failure<Object?>),
    },
  );
}

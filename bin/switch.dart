import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:more/collection.dart';
import 'package:petitparser/petitparser.dart';

final random = Random(42);
const context = Context('', 0);
final input = IntegerRange(1024 * 1024)
    .map<Result<String>>((_) => random.nextBool()
        ? context.success<String>('success', random.nextInt(0xffff))
        : context.failure<String>('failure', random.nextInt(0xffff)))
    .toList(growable: false);

Benchmark exercise(int Function(Result<String>) underTest) => () {
      for (var i = 0; i < input.length; i++) {
        underTest(input[i]);
      }
    };

void main() {
  experiments(
    control: exercise((result) => result.isSuccess ? result.position : -1),
    experiments: {
      // Object pattern
      'switch1.a': exercise((result) => switch (result) {
            Success(position: final position) => position,
            Failure() => -1,
          }),
      'switch1.b': exercise((result) => switch (result) {
            Success(position: final position) => position,
            _ => -1,
          }),
      // Class pattern
      'switch2.a': exercise((result) => switch (result) {
            final Success s => s.position,
            Failure _ => -1,
          }),
      'switch2.b': exercise((result) => switch (result) {
            final Success s => s.position,
            _ => -1,
          }),
      // Class pattern with generics
      'switch3.a': exercise((result) => switch (result) {
            final Success<String> s => s.position,
            Failure<String> _ => -1,
          }),
      'switch3.b': exercise((result) => switch (result) {
            final Success<String> s => s.position,
            _ => -1,
          }),
    },
  );
}

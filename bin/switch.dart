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

Benchmark exercise(int Function(Result<String>) underTest) =>
    () => inputs.forEach(underTest);

void main() {
  experiments(
    control: exercise((result) => result is Failure ? -1 : result.position),
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
            final Success s => s.position, // ignore: strict_raw_type
            Failure _ => -1,
          }),
      'switch2.b': exercise((result) => switch (result) {
            final Success s => s.position, // ignore: strict_raw_type
            _ => -1,
          }),
      // Class pattern with generics
      'switch3.a': exercise((result) => switch (result) {
            final Success<String> s => s.position,
            Failure _ => -1,
          }),
      'switch3.b': exercise((result) => switch (result) {
            final Success<String> s => s.position,
            _ => -1,
          }),
    },
  );
}

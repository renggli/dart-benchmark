import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:more/collection.dart';
import 'package:petitparser/petitparser.dart';

final random = Random(42);
final input = IntegerRange(1024 * 1024)
    .map((_) => String.fromCharCode(random.nextInt(0xff)))
    .join();

const stringPattern = 'benchmark';
void string() => input.indexOf(stringPattern);

final regexpPattern = RegExp('benchmark');
void regexp() => input.indexOf(regexpPattern);

final parserPattern = 'benchmark'.toParser().toPattern();
void parser() => input.indexOf(parserPattern);

void main() {
  experiments(
    control: string,
    experiments: {
      'RegExp': regexp,
      'PetitParser': parser,
    },
  );
}

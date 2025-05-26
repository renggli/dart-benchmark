import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';

final random = Random(42);
final chars = [
  ...List.generate(200, (i) => random.nextInt(0x10ffff)),
  ...List.generate(300, (i) => random.nextInt(0xffff)),
  ...List.generate(500, (i) => random.nextInt(0xff)),
  ...List.filled(250, 'a'.codeUnits.single),
  ...List.filled(250, '😀'.runes.single),
].map(String.fromCharCode).shuffled(random).join();

final defaultParser = char('a');
final defaultIgnoreCaseParser = char('a', ignoreCase: true);
final unicodeParser = char('a', unicode: true);
final unicodeIgnoreCaseParser = char('a', unicode: true, ignoreCase: true);

Benchmark createParseOnBenchmark(Parser<String> parser, String input) => () {
  for (var i = 0; i < input.length; i++) {
    parser.parseOn(Context(input, i));
  }
};

Benchmark createFastParseOnBenchmark(Parser<String> parser, String input) =>
    () {
      for (var i = 0; i < input.length; i++) {
        parser.fastParseOn(input, i);
      }
    };

void main() {
  experiments(
    title: 'parseOn',
    experiments: {
      'default': createParseOnBenchmark(defaultParser, chars),
      'ignoreCase': createParseOnBenchmark(defaultIgnoreCaseParser, chars),
      'unicode': createParseOnBenchmark(unicodeParser, chars),
      'unicode, ignoreCase': createParseOnBenchmark(
        unicodeIgnoreCaseParser,
        chars,
      ),
    },
  );
  experiments(
    title: 'fastParseOn',
    experiments: {
      'default': createFastParseOnBenchmark(defaultParser, chars),
      'ignoreCase': createFastParseOnBenchmark(defaultIgnoreCaseParser, chars),
      'unicode': createFastParseOnBenchmark(unicodeParser, chars),
      'unicode, ignoreCase': createFastParseOnBenchmark(
        unicodeIgnoreCaseParser,
        chars,
      ),
    },
  );
}

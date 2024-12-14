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

final singleCharacterParser = SingleCharacterParser(
    SingleCharPredicate('a'.codeUnits.single), '"a" expected');
final unicodeCharacterParserWithSingle = UnicodeCharacterParser(
    SingleCharPredicate('a'.codeUnits.single), '"a" expected');
final unicodeCharacterParserWithSurrogate = UnicodeCharacterParser(
    SingleCharPredicate('😀'.runes.single), '"😀" expected');

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
      'SingleCharacterParser':
          createParseOnBenchmark(singleCharacterParser, chars),
      'UnicodeCharacterParser (single)':
          createParseOnBenchmark(unicodeCharacterParserWithSingle, chars),
      'UnicodeCharacterParser (surrogate)':
          createParseOnBenchmark(unicodeCharacterParserWithSurrogate, chars),
    },
  );
  experiments(
    title: 'fastParseOn',
    experiments: {
      'SingleCharacterParser':
          createFastParseOnBenchmark(singleCharacterParser, chars),
      'UnicodeCharacterParser (single)':
          createFastParseOnBenchmark(unicodeCharacterParserWithSingle, chars),
      'UnicodeCharacterParser (surrogate)': createFastParseOnBenchmark(
          unicodeCharacterParserWithSurrogate, chars),
    },
  );
}

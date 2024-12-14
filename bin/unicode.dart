import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:characters/characters.dart';
import 'package:collection/collection.dart';

final random = Random(42);
final input = [
  ...List.generate(200, (i) => random.nextInt(0x10ffff)),
  ...List.generate(300, (i) => random.nextInt(0xffff)),
  ...List.generate(500, (i) => random.nextInt(0xff)),
].map(String.fromCharCode).shuffled(random).join();

@pragma('vm:never-inline')
void consume<T>(T value) {}

void benchCodeUnits() {
  for (final codeUnit in input.codeUnits) {
    consume(codeUnit);
  }
}

void benchCodeUnitAt() {
  for (var i = 0; i < input.length; i++) {
    consume(input.codeUnitAt(i));
  }
}

void benchRunes() {
  for (final rune in input.runes) {
    consume(rune);
  }
}

void benchCharacters() {
  for (final character in input.characters) {
    consume(character);
  }
}

void main() {
  experiments(
    experiments: {
      'codeUnits': benchCodeUnits,
      'codeUnitAt': benchCodeUnitAt,
      'runes': benchRunes,
      'characters': benchCharacters,
    },
  );
}

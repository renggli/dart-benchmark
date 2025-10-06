import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:test/test.dart';

void main() {
  test('experiments', () {
    experiments(
      title: 'Smoke Test',
      experiments: {
        'Round': () {
          pi.round();
        },
        'Floor': () {
          pi.floor();
        },
        'Ceil': () {
          pi.ceil();
        },
        'Truncate': () {
          pi.truncate();
        },
      },
      warmup: const Duration(milliseconds: 10),
      measure: const Duration(milliseconds: 20),
    );
  });
}

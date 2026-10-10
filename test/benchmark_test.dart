import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:checks/checks.dart';
import 'package:data/stats.dart';
import 'package:test/scaffolding.dart';

import 'test_utils.dart';

void main() {
  group('benchmark', () {
    test('measures samples', () {
      final samples = benchmark(
        () {
          pi.round();
        },
        warmup: const Duration(milliseconds: 5),
        measure: const Duration(milliseconds: 10),
        samples: 5,
      );
      check(samples)
        ..length.equals(5)
        ..allPositive();
    });
  });

  group('result', () {
    test('formats jackknife estimate', () {
      final samples = [10.0, 10.0, 10.0, 10.0];
      final jackknife = Jackknife<double>(
        samples,
        (list) => list.arithmeticMean(),
      );
      final formatted = result(jackknife, unit: 'μs');
      check(formatted).equals('10.000μs [10.000μs; 10.000μs]');
    });

    test('custom precision', () {
      final samples = [5.5, 5.5, 5.5];
      final jackknife = Jackknife<double>(
        samples,
        (list) => list.arithmeticMean(),
      );
      final formatted = result(jackknife, precision: 1, unit: '%');
      check(formatted).equals('5.5% [5.5%; 5.5%]');
    });
  });

  group('experiments', () {
    test('smoke test', () {
      check(() {
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
          warmup: const Duration(milliseconds: 5),
          measure: const Duration(milliseconds: 10),
          samples: 3,
        );
      }).returnsNormally();
    });

    test('without title', () {
      check(() {
        experiments(
          experiments: {'No-op': () {}},
          warmup: const Duration(milliseconds: 5),
          measure: const Duration(milliseconds: 10),
          samples: 2,
        );
      }).returnsNormally();
    });
  });
}

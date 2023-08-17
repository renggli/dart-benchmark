import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:collection/collection.dart';
import 'package:more/comparator.dart';

final random = Random(42);
final values = List.generate(1000, (i) => 1000.0 * random.nextDouble())..sort();
final tests = List.generate(1000, (i) => 1000.0 * random.nextDouble())
    .followedBy(values)
    .toList();

void packageCollection() {
  int doubleCompare(double a, double b) => a.compareTo(b);
  for (final test in tests) {
    values.binarySearch(test, doubleCompare);
  }
}

void packageComparatorCompare() {
  const comparator = naturalCompare;
  for (final test in tests) {
    comparator.binarySearch(values, test);
  }
}

void packageComparatorComparable() {
  const comparator = naturalComparable<num>;
  for (final test in tests) {
    comparator.binarySearch(values, test);
  }
}

void main() {
  experiments(
    control: packageCollection,
    experiments: {
      'Compare': packageComparatorCompare,
      'Comparable': packageComparatorComparable,
    },
  );
}

import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:collection/collection.dart';
import 'package:more/comparator.dart';
import 'package:more/ordering.dart';

final random = Random(42);
final values = List.generate(1000, (i) => 1000.0 * random.nextDouble())..sort();
final tests = List.generate(1000, (i) => 1000.0 * random.nextDouble())
    .followedBy(values)
    .toList();

void packageCollection() {
  int doubleCompare(double a, double b) => a.compareTo(b);
  for (var test in tests) {
    values.binarySearch(test, doubleCompare);
  }
}

void packageOrdering() {
  // ignore: deprecated_member_use
  final ordering = Ordering.natural<double>();
  for (var test in tests) {
    ordering.binarySearch(values, test);
  }
}

void packageComparable() {
  const comparator = naturalComparable<num>;
  for (var test in tests) {
    comparator.binarySearch(values, test);
  }
}

void main() {
  experiments(
    control: packageCollection,
    experiments: {
      'Ordering': packageOrdering,
      'Comparable': packageComparable,
    },
  );
}

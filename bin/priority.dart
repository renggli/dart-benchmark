import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:collection/collection.dart';
import 'package:more/collection.dart';

final random = Random(42);
final values = 1.to(1000).toList()..shuffle(random);

Benchmark priorityQueueAddRemove(PriorityQueue<int> Function() factory) => () {
      final queue = factory();
      for (final value in values) {
        queue.add(value);
      }
      for (var i = 0; i < values.length; i++) {
        queue.removeFirst();
      }
    };

Benchmark priorityQueueUpdate(PriorityQueue<int> Function() factory) {
  final queue = factory();
  queue.addAll(values);
  return () {
    for (final value in values) {
      queue.remove(value);
      queue.add(value);
    }
  };
}

void main() {
  experiments(
    title: 'push-pop',
    control: priorityQueueAddRemove(PriorityQueue.new),
    experiments: {
      'Heap': priorityQueueAddRemove(Heap.new),
      'SortedList': priorityQueueAddRemove(SortedList.new),
    },
  );
  experiments(
    title: 'update',
    control: priorityQueueUpdate(PriorityQueue.new),
    experiments: {
      'Heap': priorityQueueUpdate(Heap.new),
      'SortedList': priorityQueueUpdate(SortedList.new),
    },
  );
}

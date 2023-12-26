import 'dart:collection';
import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:collection/collection.dart';
import 'package:more/collection.dart';

final random = Random(42);
final values = 1.to(1000).toList()..shuffle(random);

Benchmark queueAddRemoveFirst(Queue<int> Function() factory) => () {
      final queue = factory();
      for (final value in values) {
        queue.addFirst(value);
      }
      for (var i = 0; i < values.length; i++) {
        queue.removeFirst();
      }
    };

Benchmark queueAddRemoveLast(Queue<int> Function() factory) => () {
      final queue = factory();
      for (final value in values) {
        queue.addLast(value);
      }
      for (var i = 0; i < values.length; i++) {
        queue.removeLast();
      }
    };

void main() {
  experiments(
    title: 'add-remove first',
    control: queueAddRemoveFirst(ListQueue.new),
    experiments: {
      'QueueList': queueAddRemoveFirst(QueueList.new),
      'DoubleLinkedQueue': queueAddRemoveFirst(DoubleLinkedQueue.new),
    },
  );
  experiments(
    title: 'add-remove last',
    control: queueAddRemoveLast(ListQueue.new),
    experiments: {
      'QueueList': queueAddRemoveLast(QueueList.new),
      'DoubleLinkedQueue': queueAddRemoveLast(DoubleLinkedQueue.new),
    },
  );
}

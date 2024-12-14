import 'dart:io';

import 'package:data/stats.dart';
import 'package:more/more.dart';

typedef Benchmark = void Function();

const defaultWarmup = Duration(milliseconds: 100);
const defaultMeasure = Duration(milliseconds: 500);
const defaultSamples = 25;

/// Compares the execution time of `control` vs `experiments`.
void experiments({
  String? title,
  required Map<String, Benchmark> experiments,
  Duration warmup = defaultWarmup,
  Duration measure = defaultMeasure,
  int samples = defaultSamples,
}) {
  if (title != null) {
    stdout.writeln(title);
    stdout.writeln('-' * title.length);
  }
  List<double>? controlSamples;
  final width = experiments.keys.map((name) => name.length).max() + 1;
  for (final MapEntry(key: name, value: experiment) in experiments.entries) {
    stdout.write(name.padRight(width));
    final experimentSamples = benchmark(experiment,
        warmup: warmup, measure: measure, samples: samples);
    final experimentJackknife =
        Jackknife<double>(experimentSamples, (list) => list.arithmeticMean());
    stdout.writeln(result(experimentJackknife, unit: 'μs'));

    if (controlSamples != null) {
      stdout.write(' '.padRight(width));
      final percentChangeSamples = List.generate(
          samples,
          (i) =>
              100.0 *
              (controlSamples![i] - experimentSamples[i]) /
              controlSamples[i]);
      final percentChangeJackknife = Jackknife<double>(
          percentChangeSamples, (list) => list.arithmeticMean());
      stdout.writeln(result(percentChangeJackknife, unit: '%'));
    } else {
      controlSamples = experimentSamples;
    }
  }
  stdout.writeln();
}

String result(Jackknife<double> jackknife,
    {int precision = 3, required String unit}) {
  final printer =
      FixedNumberPrinter(precision: precision, separator: ',').after(unit);
  return '${printer(jackknife.estimate)} '
      '[${printer(jackknife.lowerBound)}; '
      '${printer(jackknife.upperBound)}]';
}

/// Measures the time it takes to run [function] in microseconds.
///
/// It does so in two steps:
///
///  - the code is warmed up for the duration of [warmup]; and
///  - the code is benchmarked for the duration of [measure].
///
/// The resulting duration is the average time measured to run [function] once.
List<double> benchmark(
  Benchmark function, {
  Duration warmup = defaultWarmup,
  Duration measure = defaultMeasure,
  int samples = defaultSamples,
}) {
  _benchmark(function, warmup);
  final benchmarkSamples = <double>[];
  for (var i = 0; i < samples; i++) {
    benchmarkSamples.add(_benchmark(function, measure));
  }
  return benchmarkSamples;
}

@pragma('vm:never-inline')
@pragma('vm:no-interrupts')
double _benchmark(Benchmark function, Duration duration) {
  final watch = Stopwatch();
  final micros = duration.inMicroseconds;
  var count = 0;
  var elapsed = 0;
  watch.start();
  while (elapsed < micros) {
    function();
    elapsed = watch.elapsedMicroseconds;
    count++;
  }
  return elapsed / count;
}

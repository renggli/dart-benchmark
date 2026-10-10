import 'package:checks/checks.dart';

/// Extension on [Subject] of `List<double>` providing domain-specific checks for benchmark samples.
extension BenchmarkSamplesChecks on Subject<List<double>> {
  /// Asserts that all samples are positive numbers.
  void allPositive() {
    every((s) => s.isGreaterThan(0.0));
  }
}

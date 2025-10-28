import 'dart:io';

import 'package:health_tracker_reports/dev/coverage/lcov_filter.dart';

/// Filters the generated `coverage/lcov.info` to exclude generated files.
///
/// Usage:
/// ```sh
/// dart run tool/filter_coverage.dart [input] [output] [suffix...]
/// ```
/// - `input`:  Optional path to the LCOV file (defaults to
///   `coverage/lcov.info`).
/// - `output`: Optional output path (defaults to overwriting the input file).
/// - `suffix`: Additional suffixes to exclude. If omitted, the defaults
///   (`.g.dart`, `.freezed.dart`) are used.
Future<void> main(List<String> args) async {
  final inputPath = args.isNotEmpty ? args[0] : 'coverage/lcov.info';
  final outputPath = args.length > 1 ? args[1] : inputPath;
  final suffixes = args.length > 2
      ? args.sublist(2)
      : const ['.g.dart', '.freezed.dart'];

  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Input LCOV file not found: $inputPath');
    exitCode = 1;
    return;
  }

  final contents = await inputFile.readAsString();
  final filtered =
      filterLcov(contents, excludeSuffixes: List.unmodifiable(suffixes));

  final outputFile = File(outputPath);
  await outputFile.writeAsString(filtered);

  stdout.writeln(
    'Filtered LCOV written to ${outputFile.path} '
    '(excluded suffixes: ${suffixes.join(', ')})',
  );
}

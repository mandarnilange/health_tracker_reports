/// Utilities for filtering LCOV coverage reports by excluding generated files.
///
/// This library is used by the coverage pipeline to strip entries that belong
/// to generated sources (for example `*.g.dart` or `*.freezed.dart`), ensuring
/// the reported metrics reflect only testable production code.
/// Filters an LCOV report, removing any records whose source file path ends
/// with one of the provided [excludeSuffixes].
///
/// The function preserves ordering and metadata (e.g. `TN:` headers) while
/// dropping complete `SF:` sections for generated files so that downstream
/// tooling (like `genhtml`) receives a consistent, filtered report.
String filterLcov(
  String lcovContent, {
  List<String> excludeSuffixes = const ['.g.dart', '.freezed.dart'],
}) {
  final lines = lcovContent.split('\n');
  final buffer = StringBuffer();
  var includeCurrentRecord = true;

  for (final rawLine in lines) {
    final line = rawLine;
    if (line.startsWith('SF:')) {
      final filePath = line.substring(3);
      includeCurrentRecord = !_shouldExclude(filePath, excludeSuffixes);
    }

    if (includeCurrentRecord) {
      buffer.writeln(line);
    }

    if (line == 'end_of_record') {
      includeCurrentRecord = true;
    }
  }

  return buffer.toString();
}

bool _shouldExclude(String filePath, List<String> excludeSuffixes) {
  for (final suffix in excludeSuffixes) {
    if (filePath.trim().endsWith(suffix)) {
      return true;
    }
  }
  return false;
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstraction over [FilePicker] to simplify testing and dependency management.
class ReportFilePicker {
  const ReportFilePicker();

  /// Opens a file picker restricted to supported report formats.
  Future<String?> pickReportPath() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null) return null;
    return result.files.single.path;
  }
}

/// Provider exposing [ReportFilePicker].
final reportFilePickerProvider = Provider<ReportFilePicker>(
  (ref) => const ReportFilePicker(),
);

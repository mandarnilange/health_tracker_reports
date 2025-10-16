import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

/// Abstraction over [FilePicker] to simplify testing and dependency management.
class ReportFilePicker {
  ReportFilePicker({FilePicker? platform})
      : _platform = platform ?? FilePicker.platform;

  final FilePicker _platform;
  bool _isPicking = false;

  /// Opens a file picker restricted to supported report formats.
  Future<String?> pickReportPath() async {
    if (_isPicking) return null;
    _isPicking = true;

    try {
      final result = await _platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      return result.files.single.path;
    } on PlatformException {
      rethrow;
    } finally {
      _isPicking = false;
    }
  }
}

/// Provider exposing [ReportFilePicker].
final reportFilePickerProvider = Provider<ReportFilePicker>(
  (ref) => ReportFilePicker(),
);

import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/presentation/providers/file_picker_provider.dart';

class _FakeFilePicker extends FilePicker {
  FilePickerResult? result;
  Completer<FilePickerResult?>? completer;
  PlatformException? exceptionToThrow;

  bool? lastAllowMultiple;
  List<String>? lastAllowedExtensions;
  bool? lastWithData;
  int callCount = 0;

  @override
  Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    bool allowMultiple = false,
    List<String>? allowedExtensions,
    bool lockParentWindow = false,
    bool withData = false,
    bool withReadStream = false,
    bool readSequential = false,
    int compressionQuality = 30,
  }) {
    callCount += 1;
    lastAllowMultiple = allowMultiple;
    lastAllowedExtensions = allowedExtensions;
    lastWithData = withData;

    if (exceptionToThrow != null) {
      final error = exceptionToThrow!;
      exceptionToThrow = null;
      throw error;
    }

    onFileLoading?.call(FilePickerStatus.picking);

    if (completer != null) {
      return completer!.future;
    }

    onFileLoading?.call(FilePickerStatus.done);
    return Future<FilePickerResult?>.value(result);
  }

  @override
  void dispose() {}

  @override
  Future<bool?> clearTemporaryFiles() async => true;

  @override
  Future<String?> getDirectoryPath({
    FileType type = FileType.any,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String?> saveFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    bool lockParentWindow = false,
    Uint8List? bytes,
    bool withData = false,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  group('ReportFilePicker', () {
    late _FakeFilePicker fakePlatform;
    late ReportFilePicker picker;

    setUp(() {
      fakePlatform = _FakeFilePicker();
      picker = ReportFilePicker(platform: fakePlatform);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('configures allowed extensions and disables multiple selection',
        () async {
      fakePlatform.result = FilePickerResult([
        PlatformFile(
          name: 'report.pdf',
          path: '/tmp/report.pdf',
          size: 0,
        ),
      ]);

      final result = await picker.pickReportPath();

      expect(result, '/tmp/report.pdf');
      expect(fakePlatform.lastAllowMultiple, isFalse);
      expect(
        fakePlatform.lastAllowedExtensions,
        equals(['pdf', 'jpg', 'jpeg', 'png']),
      );
      expect(fakePlatform.lastWithData, isFalse);
    });

    test('prevents concurrent picker invocations', () async {
      fakePlatform.completer = Completer<FilePickerResult?>();

      final firstCall = picker.pickReportPath();
      final secondCall = picker.pickReportPath();

      expect(await secondCall, isNull);
      expect(fakePlatform.callCount, 1);

      fakePlatform.completer!.complete(null);
      await firstCall;

      expect(fakePlatform.callCount, 1);
    });

    test('rethrows PlatformException and resets guard', () async {
      fakePlatform.exceptionToThrow = PlatformException(code: 'cancelled');

      await expectLater(
        picker.pickReportPath(),
        throwsA(isA<PlatformException>()),
      );

      fakePlatform.result = FilePickerResult([
        PlatformFile(
          name: 'report.jpg',
          path: '/tmp/report.jpg',
          size: 0,
        ),
      ]);

      final path = await picker.pickReportPath();

      expect(path, '/tmp/report.jpg');
      expect(fakePlatform.callCount, 2);
    });

    test('returns null when picker response is empty', () async {
      fakePlatform.result = FilePickerResult(const []);

      final path = await picker.pickReportPath();

      expect(path, isNull);
      expect(fakePlatform.callCount, 1);
    });
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/share_service.dart';
import 'package:share_plus/share_plus.dart';

class _FakeShareWrapper implements ShareWrapper {
  _FakeShareWrapper({this.shouldThrow = false});

  final bool shouldThrow;
  List<XFile>? shared;

  @override
  Future<void> shareXFiles(List<XFile> files) async {
    if (shouldThrow) {
      throw Exception('share failed');
    }
    shared = files;
  }
}

void main() {
  test('shareFile delegates to wrapper and returns success', () async {
    final wrapper = _FakeShareWrapper();
    final service = ShareServiceImpl(shareWrapper: wrapper);
    final file = XFile('path/to/file');

    final result = await service.shareFile(file);

    expect(result, equals(const Right(null)));
    expect(wrapper.shared, isNotNull);
    expect(wrapper.shared, contains(file));
  });

  test('shareFile surfaces ShareFailure when wrapper throws', () async {
    final wrapper = _FakeShareWrapper(shouldThrow: true);
    final service = ShareServiceImpl(shareWrapper: wrapper);
    final file = XFile('path/to/file');

    final result = await service.shareFile(file);

    expect(result.isLeft(), isTrue);
    expect(result.fold((f) => f, (_) => null), isA<ShareFailure>());
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';

void main() {
  test('ApiKeyMissingFailure includes provider in message and equality', () {
    const failureA = ApiKeyMissingFailure('openai');
    const failureB = ApiKeyMissingFailure('openai');
    const failureC = ApiKeyMissingFailure('claude');

    expect(failureA.message, contains('openai'));
    expect(failureA, equals(failureB));
    expect(failureA, isNot(equals(failureC)));
  });

  test('RateLimitFailure exposes retry timestamp', () {
    final retryAfter = DateTime(2024, 1, 1);
    final failure = RateLimitFailure(retryAfter);

    expect(failure.retryAfter, retryAfter);
    expect(failure.message, contains('Retry after'));
  });

  test('PermissionFailure and StorageFailure wrap custom messages', () {
    const permission = PermissionFailure(
      message: 'Storage permission denied',
    );
    const storage = StorageFailure(
      message: 'Disk full',
    );

    expect(permission.message, 'Storage permission denied');
    expect(storage.message, 'Disk full');
  });
}

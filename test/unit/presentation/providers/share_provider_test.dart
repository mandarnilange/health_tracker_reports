import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/domain/services/share_service.dart';
import 'package:health_tracker_reports/presentation/providers/share_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockShareService extends Mock implements ShareService {}

void main() {
  setUp(() async {
    await getIt.reset();
  });

  test('shareServiceProvider returns instance from getIt', () {
    final mockService = _MockShareService();
    getIt.registerSingleton<ShareService>(mockService);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = container.read(shareServiceProvider);

    expect(result, same(mockService));
  });
}

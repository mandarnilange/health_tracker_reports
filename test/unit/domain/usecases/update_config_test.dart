import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:health_tracker_reports/domain/usecases/update_config.dart';
import 'package:mocktail/mocktail.dart';

class _MockConfigRepository extends Mock implements ConfigRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const AppConfig());
  });

  group('UpdateConfig', () {
    late _MockConfigRepository repository;
    late UpdateConfig usecase;

    setUp(() {
      repository = _MockConfigRepository();
      usecase = UpdateConfig(repository);
    });

    test('calls repository.saveConfig with provided config', () async {
      const config = AppConfig();
      when(() => repository.saveConfig(any())).thenAnswer((_) async => const Right(null));

      final result = await usecase(config);

      expect(result, const Right<Failure, void>(null));
      verify(() => repository.saveConfig(config)).called(1);
    });
  });
}

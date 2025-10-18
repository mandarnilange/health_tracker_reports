import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:health_tracker_reports/domain/usecases/get_health_log_by_id.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthLogRepository extends Mock implements HealthLogRepository {}

void main() {
  late GetHealthLogById usecase;
  late MockHealthLogRepository mockRepository;

  final tLog = HealthLog(
    id: 'log-123',
    timestamp: DateTime(2025, 10, 18, 9, 0),
    vitals: const [],
    notes: 'Test log',
    createdAt: DateTime(2025, 10, 18, 9, 5),
    updatedAt: DateTime(2025, 10, 18, 9, 5),
  );

  setUp(() {
    mockRepository = MockHealthLogRepository();
    usecase = GetHealthLogById(repository: mockRepository);
  });

  test('should retrieve health log by id from repository', () async {
    // Arrange
    when(() => mockRepository.getHealthLogById('log-123'))
        .thenAnswer((_) async => Right(tLog));

    // Act
    final result = await usecase('log-123');

    // Assert
    result.fold(
      (failure) => fail('Expected success but got ${failure.message}'),
      (log) => expect(log, tLog),
    );
    verify(() => mockRepository.getHealthLogById('log-123')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository returns failure', () async {
    // Arrange
    when(() => mockRepository.getHealthLogById('missing'))
        .thenAnswer((_) async => const Left(NotFoundFailure(message: 'Missing')));

    // Act
    final result = await usecase('missing');

    // Assert
    expect(
      result,
      const Left(NotFoundFailure(message: 'Missing')),
    );
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:health_tracker_reports/domain/usecases/delete_health_log.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthLogRepository extends Mock implements HealthLogRepository {}

void main() {
  late DeleteHealthLog usecase;
  late MockHealthLogRepository mockRepository;

  setUp(() {
    mockRepository = MockHealthLogRepository();
    usecase = DeleteHealthLog(repository: mockRepository);
  });

  test('should delete health log via repository', () async {
    // Arrange
    when(() => mockRepository.deleteHealthLog('log-123'))
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await usecase('log-123');

    // Assert
    expect(result, const Right(null));
    verify(() => mockRepository.deleteHealthLog('log-123')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository delete fails', () async {
    // Arrange
    when(() => mockRepository.deleteHealthLog('log-123'))
        .thenAnswer((_) async => const Left(CacheFailure()));

    // Act
    final result = await usecase('log-123');

    // Assert
    expect(result, const Left(CacheFailure()));
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_health_logs.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthLogRepository extends Mock implements HealthLogRepository {}

void main() {
  late GetAllHealthLogs usecase;
  late MockHealthLogRepository mockRepository;

  final baseDate = DateTime(2025, 10, 20, 8);
  final log1 = HealthLog(
    id: '1',
    timestamp: baseDate,
    vitals: const [],
    notes: 'Log 1',
    createdAt: baseDate,
    updatedAt: baseDate,
  );
  final log2 = HealthLog(
    id: '2',
    timestamp: baseDate.subtract(const Duration(hours: 4)),
    vitals: const [],
    notes: 'Log 2',
    createdAt: baseDate.subtract(const Duration(hours: 4)),
    updatedAt: baseDate.subtract(const Duration(hours: 4)),
  );
  final log3 = HealthLog(
    id: '3',
    timestamp: baseDate.add(const Duration(hours: 2)),
    vitals: const [],
    notes: 'Log 3',
    createdAt: baseDate.add(const Duration(hours: 2)),
    updatedAt: baseDate.add(const Duration(hours: 2)),
  );

  setUp(() {
    mockRepository = MockHealthLogRepository();
    usecase = GetAllHealthLogs(repository: mockRepository);
  });

  test('should return health logs sorted by timestamp descending', () async {
    // Arrange
    when(() => mockRepository.getAllHealthLogs()).thenAnswer(
      (_) async => Right([log1, log2, log3]),
    );

    // Act
    final result = await usecase();

    // Assert
    result.fold(
      (failure) => fail('Expected success but got ${failure.message}'),
      (logs) {
        expect(logs.length, 3);
        expect(logs[0], log3);
        expect(logs[1], log1);
        expect(logs[2], log2);
      },
    );
    verify(() => mockRepository.getAllHealthLogs()).called(1);
  });

  test('should return failure when repository call fails', () async {
    // Arrange
    when(() => mockRepository.getAllHealthLogs()).thenAnswer(
      (_) async => const Left(CacheFailure()),
    );

    // Act
    final result = await usecase();

    // Assert
    expect(result, const Left(CacheFailure()));
  });

  test('should return empty list when no logs available', () async {
    // Arrange
    when(() => mockRepository.getAllHealthLogs()).thenAnswer(
      (_) async => const Right(<HealthLog>[]),
    );

    // Act
    final result = await usecase();

    // Assert
    result.fold(
      (failure) => fail('Expected success but got ${failure.message}'),
      (logs) => expect(logs, isEmpty),
    );
  });
}

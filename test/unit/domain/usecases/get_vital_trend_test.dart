import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:health_tracker_reports/domain/usecases/get_vital_trend.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthLogRepository extends Mock implements HealthLogRepository {}

void main() {
  late GetVitalTrend usecase;
  late MockHealthLogRepository mockRepository;

  const oxygenRange = ReferenceRange(min: 95, max: 100);
  final measurement1 = const VitalMeasurement(
    id: '2025-10-18T07:00:00',
    type: VitalType.oxygenSaturation,
    value: 97,
    unit: '%',
    status: VitalStatus.normal,
    referenceRange: oxygenRange,
  );
  final measurement2 = const VitalMeasurement(
    id: '2025-10-17T07:00:00',
    type: VitalType.oxygenSaturation,
    value: 96,
    unit: '%',
    status: VitalStatus.normal,
    referenceRange: oxygenRange,
  );

  setUp(() {
    mockRepository = MockHealthLogRepository();
    usecase = GetVitalTrend(repository: mockRepository);
  });

  test('should fetch vital trend from repository and sort by id ascending', () async {
    // Arrange
    when(
      () => mockRepository.getVitalTrend(
        VitalType.oxygenSaturation,
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => Right([measurement1, measurement2]));

    // Act
    final result = await usecase(
      VitalType.oxygenSaturation,
      startDate: DateTime(2025, 10, 16),
      endDate: DateTime(2025, 10, 19),
    );

    // Assert
    result.fold(
      (failure) => fail('Expected success but got ${failure.message}'),
      (measurements) {
        expect(measurements.length, 2);
        expect(measurements[0], measurement2);
        expect(measurements[1], measurement1);
      },
    );

    verify(
      () => mockRepository.getVitalTrend(
        VitalType.oxygenSaturation,
        startDate: DateTime(2025, 10, 16),
        endDate: DateTime(2025, 10, 19),
      ),
    ).called(1);
  });

  test('should return failure when repository call fails', () async {
    // Arrange
    when(
      () => mockRepository.getVitalTrend(
        VitalType.heartRate,
        startDate: null,
        endDate: null,
      ),
    ).thenAnswer((_) async => const Left(CacheFailure()));

    // Act
    final result = await usecase(VitalType.heartRate);

    // Assert
    expect(result, const Left(CacheFailure()));
  });
}

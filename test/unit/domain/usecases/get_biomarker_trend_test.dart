import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart';
import 'package:mocktail/mocktail.dart';

class MockReportRepository extends Mock implements ReportRepository {}

void main() {
  late GetBiomarkerTrend usecase;
  late MockReportRepository mockReportRepository;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    mockReportRepository = MockReportRepository();
    usecase = GetBiomarkerTrend(
      repository: mockReportRepository,
    );
  });

  final tDate1 = DateTime(2023, 1, 1);
  final tDate2 = DateTime(2023, 2, 1);
  final tDate3 = DateTime(2023, 3, 1);

  final tTrendPoint1 = TrendDataPoint(
    date: tDate1,
    value: 14.5,
    unit: 'g/dL',
    referenceRange: null,
    reportId: 'r1',
    status: BiomarkerStatus.normal,
  );

  final tTrendPoint2 = TrendDataPoint(
    date: tDate2,
    value: 15.2,
    unit: 'g/dL',
    referenceRange: null,
    reportId: 'r2',
    status: BiomarkerStatus.high,
  );

  final tTrendPoint3 = TrendDataPoint(
    date: tDate3,
    value: 13.8,
    unit: 'g/dL',
    referenceRange: null,
    reportId: 'r3',
    status: BiomarkerStatus.low,
  );

  group('GetBiomarkerTrend', () {
    test('should get trend data for a specific biomarker name', () async {
      // Arrange
      const tBiomarkerName = 'Hemoglobin';
      when(
        () => mockReportRepository.getBiomarkerTrend(
          tBiomarkerName,
          startDate: null,
          endDate: null,
        ),
      ).thenAnswer((_) async => Right([tTrendPoint1, tTrendPoint2]));

      // Act
      final result = await usecase(tBiomarkerName);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          expect(r.length, 2);
          expect(r[0].reportId, 'r1');
          expect(r[1].reportId, 'r2');
        },
      );
      verify(
        () => mockReportRepository.getBiomarkerTrend(
          tBiomarkerName,
          startDate: null,
          endDate: null,
        ),
      );
    });

    test('should filter by date range when start date is provided', () async {
      // Arrange
      const tBiomarkerName = 'Hemoglobin';
      final tStartDate = DateTime(2023, 1, 15);
      when(
        () => mockReportRepository.getBiomarkerTrend(
          tBiomarkerName,
          startDate: tStartDate,
          endDate: null,
        ),
      ).thenAnswer((_) async => Right([tTrendPoint2, tTrendPoint3]));

      // Act
      final result = await usecase(tBiomarkerName, startDate: tStartDate);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) => expect(r.map((dp) => dp.date), [tDate2, tDate3]),
      );
      verify(
        () => mockReportRepository.getBiomarkerTrend(
          tBiomarkerName,
          startDate: tStartDate,
          endDate: null,
        ),
      ).called(1);
    });

    test('should filter by date range when end date is provided', () async {
      // Arrange
      const tBiomarkerName = 'Hemoglobin';
      final tEndDate = DateTime(2023, 2, 15);
      when(
        () => mockReportRepository.getBiomarkerTrend(
          tBiomarkerName,
          startDate: null,
          endDate: tEndDate,
        ),
      ).thenAnswer((_) async => Right([tTrendPoint1, tTrendPoint2]));

      // Act
      final result = await usecase(tBiomarkerName, endDate: tEndDate);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) => expect(r.map((dp) => dp.date), [tDate1, tDate2]),
      );
      verify(
        () => mockReportRepository.getBiomarkerTrend(
          tBiomarkerName,
          startDate: null,
          endDate: tEndDate,
        ),
      ).called(1);
    });

    test(
        'should filter by date range when both start and end dates are provided',
        () async {
      // Arrange
      const tBiomarkerName = 'Hemoglobin';
      final tStartDate = DateTime(2023, 1, 15);
      final tEndDate = DateTime(2023, 2, 15);
      when(
        () => mockReportRepository.getBiomarkerTrend(
          tBiomarkerName,
          startDate: tStartDate,
          endDate: tEndDate,
        ),
      ).thenAnswer((_) async => Right([tTrendPoint2]));

      // Act
      final result = await usecase(
        tBiomarkerName,
        startDate: tStartDate,
        endDate: tEndDate,
      );

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) => expect(r.single.date, tDate2),
      );
      verify(
        () => mockReportRepository.getBiomarkerTrend(
          tBiomarkerName,
          startDate: tStartDate,
          endDate: tEndDate,
        ),
      ).called(1);
    });

    test('should sort trend data points by date in chronological order',
        () async {
      // Arrange
      const tBiomarkerName = 'Hemoglobin';
      when(
        () => mockReportRepository.getBiomarkerTrend(
          tBiomarkerName,
          startDate: null,
          endDate: null,
        ),
      ).thenAnswer(
        (_) async => Right([tTrendPoint3, tTrendPoint1, tTrendPoint2]),
      );

      // Act
      final result = await usecase(tBiomarkerName);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) => expect(r.map((dp) => dp.date), [tDate1, tDate2, tDate3]),
      );
    });

    test('should return empty list when biomarker is not found in any report',
        () async {
      // Arrange
      const tBiomarkerName = 'Vitamin D';
      when(
        () => mockReportRepository.getBiomarkerTrend(
          tBiomarkerName,
          startDate: null,
          endDate: null,
        ),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await usecase(tBiomarkerName);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) => expect(r, isEmpty),
      );
    });

    test('should propagate cache failure from repository', () async {
      // Arrange
      const tBiomarkerName = 'Hemoglobin';
      when(() => mockReportRepository.getBiomarkerTrend(
            tBiomarkerName,
            startDate: null,
            endDate: null,
          )).thenAnswer((_) async => Left(CacheFailure()));

      // Act
      final result = await usecase(tBiomarkerName);

      // Assert
      expect(result, Left(CacheFailure()));
      verify(
        () => mockReportRepository.getBiomarkerTrend(
          tBiomarkerName,
          startDate: null,
          endDate: null,
        ),
      );
    });

    test('should include all biomarker properties in trend data point',
        () async {
      // Arrange
      const tBiomarkerName = 'Hemoglobin';
      when(
        () => mockReportRepository.getBiomarkerTrend(
          tBiomarkerName,
          startDate: null,
          endDate: null,
        ),
      ).thenAnswer((_) async => Right([tTrendPoint1]));

      // Act
      final result = await usecase(tBiomarkerName);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          expect(r.length, 1);
          final dataPoint = r[0];
          expect(dataPoint.date, tDate1);
          expect(dataPoint.value, 14.5);
          expect(dataPoint.unit, 'g/dL');
          expect(dataPoint.reportId, 'r1');
          expect(dataPoint.status, BiomarkerStatus.normal);
        },
      );
    });
  });
}

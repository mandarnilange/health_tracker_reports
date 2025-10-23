import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_comparison.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/domain/usecases/compare_biomarker_across_reports.dart';
import 'package:mocktail/mocktail.dart';

class MockReportRepository extends Mock implements ReportRepository {}

void main() {
  late CompareBiomarkerAcrossReports usecase;
  late MockReportRepository mockReportRepository;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    mockReportRepository = MockReportRepository();
    usecase = CompareBiomarkerAcrossReports(
      repository: mockReportRepository,
    );
  });

  final date1 = DateTime(2024, 1, 15);
  final date2 = DateTime(2024, 2, 15);
  final date3 = DateTime(2024, 3, 15);

  final refRange = ReferenceRange(min: 13.0, max: 17.0);

  final biomarker1 = Biomarker(
    id: 'b1',
    name: 'Hemoglobin',
    value: 14.5,
    unit: 'g/dL',
    referenceRange: refRange,
    measuredAt: date1,
  );

  final biomarker2 = Biomarker(
    id: 'b2',
    name: 'Hemoglobin',
    value: 15.2,
    unit: 'g/dL',
    referenceRange: refRange,
    measuredAt: date2,
  );

  final biomarker3 = Biomarker(
    id: 'b3',
    name: 'Hemoglobin',
    value: 14.8,
    unit: 'g/dL',
    referenceRange: refRange,
    measuredAt: date3,
  );

  final report1 = Report(
    id: 'r1',
    date: date1,
    labName: 'Lab A',
    biomarkers: [biomarker1],
    originalFilePath: '/path/to/r1.pdf',
    createdAt: date1,
    updatedAt: date1,
  );

  final report2 = Report(
    id: 'r2',
    date: date2,
    labName: 'Lab B',
    biomarkers: [biomarker2],
    originalFilePath: '/path/to/r2.pdf',
    createdAt: date2,
    updatedAt: date2,
  );

  final report3 = Report(
    id: 'r3',
    date: date3,
    labName: 'Lab C',
    biomarkers: [biomarker3],
    originalFilePath: '/path/to/r3.pdf',
    createdAt: date3,
    updatedAt: date3,
  );

  group('CompareBiomarkerAcrossReports', () {
    test('should compare biomarker across 2 reports successfully', () async {
      // Arrange
      const biomarkerName = 'Hemoglobin';
      final reportIds = ['r1', 'r2'];
      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Right(report1));
      when(() => mockReportRepository.getReportById('r2'))
          .thenAnswer((_) async => Right(report2));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (comparison) {
          expect(comparison.biomarkerName, biomarkerName);
          expect(comparison.comparisons.length, 2);
          expect(comparison.comparisons[0].reportId, 'r1');
          expect(comparison.comparisons[0].value, 14.5);
          expect(comparison.comparisons[0].deltaFromPrevious, null);
          expect(comparison.comparisons[0].percentageChangeFromPrevious, null);
          expect(comparison.comparisons[1].reportId, 'r2');
          expect(comparison.comparisons[1].value, 15.2);
          expect(
              comparison.comparisons[1].deltaFromPrevious, closeTo(0.7, 0.01));
          expect(comparison.comparisons[1].percentageChangeFromPrevious,
              closeTo(4.83, 0.01));
        },
      );

      verify(() => mockReportRepository.getReportById('r1'));
      verify(() => mockReportRepository.getReportById('r2'));
    });

    test('should compare biomarker across 3+ reports successfully', () async {
      // Arrange
      const biomarkerName = 'Hemoglobin';
      final reportIds = ['r1', 'r2', 'r3'];
      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Right(report1));
      when(() => mockReportRepository.getReportById('r2'))
          .thenAnswer((_) async => Right(report2));
      when(() => mockReportRepository.getReportById('r3'))
          .thenAnswer((_) async => Right(report3));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (comparison) {
          expect(comparison.comparisons.length, 3);
          expect(comparison.comparisons[2].reportId, 'r3');
          expect(comparison.comparisons[2].value, 14.8);
          expect(
              comparison.comparisons[2].deltaFromPrevious, closeTo(-0.4, 0.01));
          expect(comparison.comparisons[2].percentageChangeFromPrevious,
              closeTo(-2.63, 0.01));
        },
      );
    });

    test('should sort reports chronologically by date', () async {
      // Arrange - provide reports in wrong order
      const biomarkerName = 'Hemoglobin';
      final reportIds = ['r3', 'r1', 'r2']; // Out of order
      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Right(report1));
      when(() => mockReportRepository.getReportById('r2'))
          .thenAnswer((_) async => Right(report2));
      when(() => mockReportRepository.getReportById('r3'))
          .thenAnswer((_) async => Right(report3));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (comparison) {
          // Should be sorted chronologically
          expect(comparison.comparisons[0].reportDate, date1);
          expect(comparison.comparisons[1].reportDate, date2);
          expect(comparison.comparisons[2].reportDate, date3);
          // Deltas should be calculated in sorted order
          expect(comparison.comparisons[0].deltaFromPrevious, null);
          expect(
              comparison.comparisons[1].deltaFromPrevious, closeTo(0.7, 0.01));
          expect(
              comparison.comparisons[2].deltaFromPrevious, closeTo(-0.4, 0.01));
        },
      );
    });

    test('should handle missing biomarker in some reports', () async {
      // Arrange
      const biomarkerName = 'Hemoglobin';
      final reportIds = ['r1', 'r2', 'r3'];

      // Report 2 doesn't have Hemoglobin
      final report2WithoutHb = report2.copyWith(biomarkers: []);

      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Right(report1));
      when(() => mockReportRepository.getReportById('r2'))
          .thenAnswer((_) async => Right(report2WithoutHb));
      when(() => mockReportRepository.getReportById('r3'))
          .thenAnswer((_) async => Right(report3));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (comparison) {
          // Should only include reports that have the biomarker
          expect(comparison.comparisons.length, 2);
          expect(comparison.comparisons[0].reportId, 'r1');
          expect(comparison.comparisons[1].reportId, 'r3');
          // Delta should be from r1 to r3, not r2 to r3
          expect(
              comparison.comparisons[1].deltaFromPrevious, closeTo(0.3, 0.01));
        },
      );
    });

    test('should calculate correct deltas between consecutive reports',
        () async {
      // Arrange
      const biomarkerName = 'Hemoglobin';
      final reportIds = ['r1', 'r2', 'r3'];
      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Right(report1));
      when(() => mockReportRepository.getReportById('r2'))
          .thenAnswer((_) async => Right(report2));
      when(() => mockReportRepository.getReportById('r3'))
          .thenAnswer((_) async => Right(report3));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (comparison) {
          // First report has no delta
          expect(comparison.comparisons[0].deltaFromPrevious, null);
          expect(comparison.comparisons[0].percentageChangeFromPrevious, null);

          // Second report: 15.2 - 14.5 = 0.7
          expect(
              comparison.comparisons[1].deltaFromPrevious, closeTo(0.7, 0.01));
          // (0.7 / 14.5) * 100 = 4.83%
          expect(comparison.comparisons[1].percentageChangeFromPrevious,
              closeTo(4.83, 0.01));

          // Third report: 14.8 - 15.2 = -0.4
          expect(
              comparison.comparisons[2].deltaFromPrevious, closeTo(-0.4, 0.01));
          // (-0.4 / 15.2) * 100 = -2.63%
          expect(comparison.comparisons[2].percentageChangeFromPrevious,
              closeTo(-2.63, 0.01));
        },
      );
    });

    test('should return failure when no reports selected', () async {
      // Arrange
      const biomarkerName = 'Hemoglobin';
      final reportIds = <String>[];

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (r) => fail('should return a failure'),
      );
    });

    test('should return failure when biomarker not found in any report',
        () async {
      // Arrange
      const biomarkerName = 'Vitamin D';
      final reportIds = ['r1', 'r2'];
      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Right(report1));
      when(() => mockReportRepository.getReportById('r2'))
          .thenAnswer((_) async => Right(report2));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (r) => fail('should return a failure'),
      );
    });

    test('should determine increasing trend', () async {
      // Arrange - create reports with increasing values
      final increasingBio1 = biomarker1.copyWith(value: 14.0);
      final increasingBio2 = biomarker2.copyWith(value: 14.5);
      final increasingBio3 = biomarker3.copyWith(value: 15.0);

      final incReport1 = report1.copyWith(biomarkers: [increasingBio1]);
      final incReport2 = report2.copyWith(biomarkers: [increasingBio2]);
      final incReport3 = report3.copyWith(biomarkers: [increasingBio3]);

      const biomarkerName = 'Hemoglobin';
      final reportIds = ['r1', 'r2', 'r3'];
      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Right(incReport1));
      when(() => mockReportRepository.getReportById('r2'))
          .thenAnswer((_) async => Right(incReport2));
      when(() => mockReportRepository.getReportById('r3'))
          .thenAnswer((_) async => Right(incReport3));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (comparison) {
          expect(comparison.overallTrend, TrendDirection.increasing);
        },
      );
    });

    test('should determine decreasing trend', () async {
      // Arrange - create reports with decreasing values
      final decreasingBio1 = biomarker1.copyWith(value: 15.0);
      final decreasingBio2 = biomarker2.copyWith(value: 14.5);
      final decreasingBio3 = biomarker3.copyWith(value: 14.0);

      final decReport1 = report1.copyWith(biomarkers: [decreasingBio1]);
      final decReport2 = report2.copyWith(biomarkers: [decreasingBio2]);
      final decReport3 = report3.copyWith(biomarkers: [decreasingBio3]);

      const biomarkerName = 'Hemoglobin';
      final reportIds = ['r1', 'r2', 'r3'];
      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Right(decReport1));
      when(() => mockReportRepository.getReportById('r2'))
          .thenAnswer((_) async => Right(decReport2));
      when(() => mockReportRepository.getReportById('r3'))
          .thenAnswer((_) async => Right(decReport3));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (comparison) {
          expect(comparison.overallTrend, TrendDirection.decreasing);
        },
      );
    });

    test('should determine stable trend when values vary minimally', () async {
      // Arrange - create reports with stable values (within 5% variance)
      final stableBio1 = biomarker1.copyWith(value: 14.5);
      final stableBio2 = biomarker2.copyWith(value: 14.6);
      final stableBio3 = biomarker3.copyWith(value: 14.4);

      final stableReport1 = report1.copyWith(biomarkers: [stableBio1]);
      final stableReport2 = report2.copyWith(biomarkers: [stableBio2]);
      final stableReport3 = report3.copyWith(biomarkers: [stableBio3]);

      const biomarkerName = 'Hemoglobin';
      final reportIds = ['r1', 'r2', 'r3'];
      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Right(stableReport1));
      when(() => mockReportRepository.getReportById('r2'))
          .thenAnswer((_) async => Right(stableReport2));
      when(() => mockReportRepository.getReportById('r3'))
          .thenAnswer((_) async => Right(stableReport3));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (comparison) {
          expect(comparison.overallTrend, TrendDirection.stable);
        },
      );
    });

    test('should determine fluctuating trend when values go up and down',
        () async {
      // Arrange - already have fluctuating data in default test data
      const biomarkerName = 'Hemoglobin';
      final reportIds = ['r1', 'r2', 'r3'];
      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Right(report1));
      when(() => mockReportRepository.getReportById('r2'))
          .thenAnswer((_) async => Right(report2));
      when(() => mockReportRepository.getReportById('r3'))
          .thenAnswer((_) async => Right(report3));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (comparison) {
          // 14.5 -> 15.2 (up) -> 14.8 (down) = fluctuating
          expect(comparison.overallTrend, TrendDirection.fluctuating);
        },
      );
    });

    test('should determine insufficient trend for single data point', () async {
      // Arrange
      const biomarkerName = 'Hemoglobin';
      final reportIds = ['r1'];
      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Right(report1));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (comparison) {
          expect(comparison.overallTrend, TrendDirection.insufficient);
        },
      );
    });

    test('should propagate cache failure from repository', () async {
      // Arrange
      const biomarkerName = 'Hemoglobin';
      final reportIds = ['r1', 'r2'];
      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Left(CacheFailure()));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      expect(result, Left(CacheFailure()));
    });

    test('should include biomarker status in comparison data points', () async {
      // Arrange
      final lowBio = biomarker1.copyWith(value: 12.0); // Below min
      final highBio = biomarker2.copyWith(value: 18.0); // Above max

      final lowReport = report1.copyWith(biomarkers: [lowBio]);
      final highReport = report2.copyWith(biomarkers: [highBio]);

      const biomarkerName = 'Hemoglobin';
      final reportIds = ['r1', 'r2'];
      when(() => mockReportRepository.getReportById('r1'))
          .thenAnswer((_) async => Right(lowReport));
      when(() => mockReportRepository.getReportById('r2'))
          .thenAnswer((_) async => Right(highReport));

      // Act
      final result = await usecase(biomarkerName, reportIds);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (comparison) {
          expect(comparison.comparisons[0].status, BiomarkerStatus.low);
          expect(comparison.comparisons[1].status, BiomarkerStatus.high);
        },
      );
    });
  });
}

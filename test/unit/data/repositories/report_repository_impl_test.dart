import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/local/report_local_datasource.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/data/models/biomarker_model.dart';
import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:health_tracker_reports/data/repositories/report_repository_impl.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:mocktail/mocktail.dart';

class MockReportLocalDataSource extends Mock implements ReportLocalDataSource {}

void main() {
  late ReportRepositoryImpl repository;
  late MockReportLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockReportLocalDataSource();
    repository = ReportRepositoryImpl(localDataSource: mockLocalDataSource);
    registerFallbackValue(ReportModel.fromEntity(Report(
      id: '1',
      date: DateTime.now(),
      labName: 'Test Lab',
      biomarkers: [],
      originalFilePath: '/path/to/file',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )));
  });

  group('getBiomarkerTrend', () {
    final referenceRangeModel = ReferenceRangeModel(min: 13.0, max: 17.0);
    final hemoglobinBiomarker = BiomarkerModel(
      id: 'bio-1',
      name: 'Hemoglobin',
      value: 14.5,
      unit: 'g/dL',
      referenceRange: referenceRangeModel,
      measuredAt: DateTime(2023, 1, 1),
    );
    final hemoglobinBiomarkerLater = BiomarkerModel(
      id: 'bio-2',
      name: 'Hemoglobin',
      value: 15.2,
      unit: 'g/dL',
      referenceRange: referenceRangeModel,
      measuredAt: DateTime(2023, 3, 1),
    );
    final glucoseBiomarker = BiomarkerModel(
      id: 'bio-3',
      name: 'Glucose',
      value: 95.0,
      unit: 'mg/dL',
      referenceRange: ReferenceRangeModel(min: 70.0, max: 100.0),
      measuredAt: DateTime(2023, 1, 1),
    );

    final reportModel1 = ReportModel(
      id: 'report-1',
      date: DateTime(2023, 1, 1),
      labName: 'Lab A',
      biomarkers: [hemoglobinBiomarker, glucoseBiomarker],
      originalFilePath: '/tmp/report1.pdf',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    final reportModel2 = ReportModel(
      id: 'report-2',
      date: DateTime(2023, 3, 1),
      labName: 'Lab B',
      biomarkers: [hemoglobinBiomarkerLater],
      originalFilePath: '/tmp/report2.pdf',
      createdAt: DateTime(2023, 3, 1),
      updatedAt: DateTime(2023, 3, 1),
    );

    test('should aggregate biomarker data across reports', () async {
      when(() => mockLocalDataSource.getAllReports())
          .thenAnswer((_) async => [reportModel1, reportModel2]);

      final result = await repository.getBiomarkerTrend('Hemoglobin');

      result.fold(
        (failure) => fail('expected success, got failure'),
        (dataPoints) {
          expect(dataPoints, hasLength(2));
          expect(
            dataPoints.first,
            isA<TrendDataPoint>()
                .having((dp) => dp.reportId, 'reportId', 'report-1')
                .having((dp) => dp.value, 'value', 14.5),
          );
          expect(
            dataPoints.last.reportId,
            'report-2',
          );
        },
      );
      verify(() => mockLocalDataSource.getAllReports()).called(1);
    });

    test('should filter by date range when start and end provided', () async {
      when(() => mockLocalDataSource.getAllReports())
          .thenAnswer((_) async => [reportModel1, reportModel2]);

      final result = await repository.getBiomarkerTrend(
        'Hemoglobin',
        startDate: DateTime(2023, 2, 1),
        endDate: DateTime(2023, 4, 1),
      );

      result.fold(
        (failure) => fail('expected success, got failure'),
        (dataPoints) {
          expect(dataPoints, hasLength(1));
          expect(dataPoints.single.reportId, 'report-2');
        },
      );
    });

    test('should return empty list when biomarker not found', () async {
      when(() => mockLocalDataSource.getAllReports())
          .thenAnswer((_) async => [reportModel1, reportModel2]);

      final result = await repository.getBiomarkerTrend('Vitamin D');

      result.fold(
        (failure) => fail('expected success, got failure'),
        (dataPoints) => expect(dataPoints, isEmpty),
      );
    });

    test('should handle case-insensitive biomarker names', () async {
      when(() => mockLocalDataSource.getAllReports())
          .thenAnswer((_) async => [reportModel1]);

      final result = await repository.getBiomarkerTrend('hemoglobin');

      result.fold(
        (failure) => fail('expected success, got failure'),
        (dataPoints) {
          expect(dataPoints, hasLength(1));
          expect(dataPoints.single.reportId, 'report-1');
        },
      );
    });

    test('should return CacheFailure when data source throws', () async {
      when(() => mockLocalDataSource.getAllReports())
          .thenThrow(CacheException());

      final result = await repository.getBiomarkerTrend('Hemoglobin');

      expect(result, Left(CacheFailure()));
    });
  });

  group('saveReport', () {
    final tReport = Report(
      id: '1',
      date: DateTime.now(),
      labName: 'Test Lab',
      biomarkers: [],
      originalFilePath: '/path/to/file',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test(
        'should return the report when the call to local data source is successful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.saveReport(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.saveReport(tReport);

      // Assert
      expect(result, Right(tReport));
    });

    test(
        'should return a CacheFailure when the call to local data source is unsuccessful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.saveReport(any()))
          .thenThrow(CacheException());

      // Act
      final result = await repository.saveReport(tReport);

      // Assert
      expect(result, Left(CacheFailure()));
    });
  });

  group('getAllReports', () {
    final tReportModelList = [
      ReportModel(
        id: '1',
        date: DateTime.now(),
        labName: 'Test Lab',
        biomarkers: [],
        originalFilePath: '/path/to/file',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    final tReportList = tReportModelList.map((e) => e.toEntity()).toList();

    test(
        'should return a list of reports when the call to local data source is successful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.getAllReports())
          .thenAnswer((_) async => tReportModelList);

      // Act
      final result = await repository.getAllReports();

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) => expect(r, tReportList),
      );
    });

    test(
        'should return a CacheFailure when the call to local data source is unsuccessful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.getAllReports())
          .thenThrow(CacheException());

      // Act
      final result = await repository.getAllReports();

      // Assert
      expect(result, Left(CacheFailure()));
    });
  });

  group('getReportById', () {
    final tReportId = '1';
    final tReportModel = ReportModel(
      id: tReportId,
      date: DateTime.now(),
      labName: 'Test Lab',
      biomarkers: [],
      originalFilePath: '/path/to/file',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final tReport = tReportModel.toEntity();

    test(
        'should return a report when the call to local data source is successful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.getReportById(any()))
          .thenAnswer((_) async => tReportModel);

      // Act
      final result = await repository.getReportById(tReportId);

      // Assert
      expect(result, Right(tReport));
    });

    test(
        'should return a CacheFailure when the call to local data source is unsuccessful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.getReportById(any()))
          .thenThrow(CacheException());

      // Act
      final result = await repository.getReportById(tReportId);

      // Assert
      expect(result, Left(CacheFailure()));
    });
  });

  group('deleteReport', () {
    final tReportId = '1';

    test('should return void when the call to local data source is successful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.deleteReport(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.deleteReport(tReportId);

      // Assert
      expect(result, Right(null));
    });

    test(
        'should return a CacheFailure when the call to local data source is unsuccessful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.deleteReport(any()))
          .thenThrow(CacheException());

      // Act
      final result = await repository.deleteReport(tReportId);

      // Assert
      expect(result, Left(CacheFailure()));
    });
  });

  group('updateReport', () {
    final tReport = Report(
      id: '1',
      date: DateTime.now(),
      labName: 'Test Lab',
      biomarkers: [],
      originalFilePath: '/path/to/file',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should return void when the call to local data source is successful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.updateReport(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.updateReport(tReport);

      // Assert
      expect(result, Right(null));
    });

    test(
        'should return a CacheFailure when the call to local data source is unsuccessful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.updateReport(any()))
          .thenThrow(CacheException());

      // Act
      final result = await repository.updateReport(tReport);

      // Assert
      expect(result, Left(CacheFailure()));
    });
  });
}

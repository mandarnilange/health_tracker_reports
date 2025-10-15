import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/local/report_local_datasource.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/data/repositories/report_repository_impl.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
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

    test('should return the report when the call to local data source is successful', () async {
      // Arrange
      when(() => mockLocalDataSource.saveReport(any())).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveReport(tReport);

      // Assert
      expect(result, Right(tReport));
    });

    test('should return a CacheFailure when the call to local data source is unsuccessful', () async {
      // Arrange
      when(() => mockLocalDataSource.saveReport(any())).thenThrow(CacheException());

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

    test('should return a list of reports when the call to local data source is successful', () async {
      // Arrange
      when(() => mockLocalDataSource.getAllReports()).thenAnswer((_) async => tReportModelList);

      // Act
      final result = await repository.getAllReports();

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) => expect(r, tReportList),
      );
    });

    test('should return a CacheFailure when the call to local data source is unsuccessful', () async {
      // Arrange
      when(() => mockLocalDataSource.getAllReports()).thenThrow(CacheException());

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

    test('should return a report when the call to local data source is successful', () async {
      // Arrange
      when(() => mockLocalDataSource.getReportById(any())).thenAnswer((_) async => tReportModel);

      // Act
      final result = await repository.getReportById(tReportId);

      // Assert
      expect(result, Right(tReport));
    });

    test('should return a CacheFailure when the call to local data source is unsuccessful', () async {
      // Arrange
      when(() => mockLocalDataSource.getReportById(any())).thenThrow(CacheException());

      // Act
      final result = await repository.getReportById(tReportId);

      // Assert
      expect(result, Left(CacheFailure()));
    });
  });

  group('deleteReport', () {
    final tReportId = '1';

    test('should return void when the call to local data source is successful', () async {
      // Arrange
      when(() => mockLocalDataSource.deleteReport(any())).thenAnswer((_) async => {});

      // Act
      final result = await repository.deleteReport(tReportId);

      // Assert
      expect(result, Right(null));
    });

    test('should return a CacheFailure when the call to local data source is unsuccessful', () async {
      // Arrange
      when(() => mockLocalDataSource.deleteReport(any())).thenThrow(CacheException());

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

    test('should return void when the call to local data source is successful', () async {
      // Arrange
      when(() => mockLocalDataSource.updateReport(any())).thenAnswer((_) async => {});

      // Act
      final result = await repository.updateReport(tReport);

      // Assert
      expect(result, Right(null));
    });

    test('should return a CacheFailure when the call to local data source is unsuccessful', () async {
      // Arrange
      when(() => mockLocalDataSource.updateReport(any())).thenThrow(CacheException());

      // Act
      final result = await repository.updateReport(tReport);

      // Assert
      expect(result, Left(CacheFailure()));
    });
  });
}
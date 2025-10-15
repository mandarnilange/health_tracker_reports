import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/local/report_local_datasource.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockBox<T> extends Mock implements Box<T> {}

class FakeReportModel extends Fake implements ReportModel {}

void main() {
  late ReportLocalDataSourceImpl dataSource;
  late MockBox<ReportModel> mockBox;

  setUpAll(() {
    registerFallbackValue(FakeReportModel());
  });

  setUp(() {
    mockBox = MockBox<ReportModel>();
    dataSource = ReportLocalDataSourceImpl(box: mockBox);
  });

  group('saveReport', () {
    final tReportModel = ReportModel(
      id: '1',
      date: DateTime.now(),
      labName: 'Test Lab',
      biomarkers: [],
      originalFilePath: '/path/to/file',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should save a report to the box', () async {
      // Arrange
      when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

      // Act
      await dataSource.saveReport(tReportModel);

      // Assert
      verify(() => mockBox.put(tReportModel.id, tReportModel)).called(1);
    });

    test('should throw a CacheException when put throws an error', () async {
      // Arrange
      when(() => mockBox.put(any(), any())).thenThrow(Exception());

      // Act
      final call = dataSource.saveReport;

      // Assert
      expect(() => call(tReportModel), throwsA(isA<CacheException>()));
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

    test('should return all reports from the box', () async {
      // Arrange
      when(() => mockBox.values).thenReturn(tReportModelList);

      // Act
      final result = await dataSource.getAllReports();

      // Assert
      expect(result, tReportModelList);
    });

    test('should throw a CacheException when getting all reports fails',
        () async {
      // Arrange
      when(() => mockBox.values).thenThrow(Exception());

      // Act
      final call = dataSource.getAllReports;

      // Assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('getReportById', () {
    final tReportModel = ReportModel(
      id: '1',
      date: DateTime.now(),
      labName: 'Test Lab',
      biomarkers: [],
      originalFilePath: '/path/to/file',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should return a report from the box by id', () async {
      // Arrange
      when(() => mockBox.get(any())).thenReturn(tReportModel);

      // Act
      final result = await dataSource.getReportById('1');

      // Assert
      expect(result, tReportModel);
    });

    test('should throw a CacheException when getting a report by id fails',
        () async {
      // Arrange
      when(() => mockBox.get(any())).thenThrow(Exception());

      // Act
      final call = dataSource.getReportById;

      // Assert
      expect(() => call('1'), throwsA(isA<CacheException>()));
    });
  });

  group('deleteReport', () {
    test('should delete a report from the box', () async {
      // Arrange
      when(() => mockBox.delete(any())).thenAnswer((_) async => {});

      // Act
      await dataSource.deleteReport('1');

      // Assert
      verify(() => mockBox.delete('1')).called(1);
    });

    test('should throw a CacheException when deleting a report fails',
        () async {
      // Arrange
      when(() => mockBox.delete(any())).thenThrow(Exception());

      // Act
      final call = dataSource.deleteReport;

      // Assert
      expect(() => call('1'), throwsA(isA<CacheException>()));
    });
  });

  group('updateReport', () {
    final tReportModel = ReportModel(
      id: '1',
      date: DateTime.now(),
      labName: 'Test Lab',
      biomarkers: [],
      originalFilePath: '/path/to/file',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should update a report in the box', () async {
      // Arrange
      when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

      // Act
      await dataSource.updateReport(tReportModel);

      // Assert
      verify(() => mockBox.put(tReportModel.id, tReportModel)).called(1);
    });

    test('should throw a CacheException when updating a report fails',
        () async {
      // Arrange
      when(() => mockBox.put(any(), any())).thenThrow(Exception());

      // Act
      final call = dataSource.updateReport;

      // Assert
      expect(() => call(tReportModel), throwsA(isA<CacheException>()));
    });
  });
}

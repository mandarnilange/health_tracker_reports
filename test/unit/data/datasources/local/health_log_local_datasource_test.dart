import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/data/datasources/local/health_log_local_datasource.dart';
import 'package:health_tracker_reports/data/models/health_log_model.dart';
import 'package:health_tracker_reports/data/models/vital_measurement_model.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockBox<T> extends Mock implements Box<T> {}

class FakeHealthLogModel extends Fake implements HealthLogModel {}

void main() {
  late HealthLogLocalDataSource dataSource;
  late MockBox<HealthLogModel> mockBox;

  setUpAll(() {
    registerFallbackValue(FakeHealthLogModel());
  });

  setUp(() {
    mockBox = MockBox<HealthLogModel>();
    dataSource = HealthLogLocalDataSourceImpl(box: mockBox);
  });

  final tHealthLogModel = HealthLogModel(
    id: 'log-1',
    timestamp: DateTime(2025, 10, 20, 7, 30),
    vitals: [
      VitalMeasurementModel(
        id: 'vital-1',
        vitalTypeIndex: 0,
        value: 118,
        unit: 'mmHg',
        statusIndex: 0,
      ),
    ],
    notes: 'Morning reading',
    createdAt: DateTime(2025, 10, 20, 7, 35),
    updatedAt: DateTime(2025, 10, 20, 7, 35),
  );

  group('saveHealthLog', () {
    test('should save the health log into the box', () async {
      // Arrange
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      // Act
      await dataSource.saveHealthLog(tHealthLogModel);

      // Assert
      verify(() => mockBox.put(tHealthLogModel.id, tHealthLogModel)).called(1);
    });

    test('should throw CacheException when put throws', () async {
      // Arrange
      when(() => mockBox.put(any(), any())).thenThrow(Exception());

      // Act
      final call = dataSource.saveHealthLog;

      // Assert
      expect(() => call(tHealthLogModel), throwsA(isA<CacheException>()));
    });
  });

  group('getAllHealthLogs', () {
    final tLogs = [tHealthLogModel];

    test('should return all health logs from the box', () async {
      // Arrange
      when(() => mockBox.values).thenReturn(tLogs);

      // Act
      final result = await dataSource.getAllHealthLogs();

      // Assert
      expect(result, tLogs);
    });

    test('should throw CacheException when accessing values throws', () async {
      // Arrange
      when(() => mockBox.values).thenThrow(Exception());

      // Act
      final call = dataSource.getAllHealthLogs;

      // Assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('getHealthLogById', () {
    test('should return health log when found', () async {
      // Arrange
      when(() => mockBox.get(any())).thenReturn(tHealthLogModel);

      // Act
      final result = await dataSource.getHealthLogById('log-1');

      // Assert
      expect(result, tHealthLogModel);
    });

    test('should throw CacheException when log not found', () async {
      // Arrange
      when(() => mockBox.get(any())).thenReturn(null);

      // Act
      final call = dataSource.getHealthLogById;

      // Assert
      expect(() => call('missing-id'), throwsA(isA<CacheException>()));
    });

    test('should throw CacheException when box throws', () async {
      // Arrange
      when(() => mockBox.get(any())).thenThrow(Exception());

      // Act
      final call = dataSource.getHealthLogById;

      // Assert
      expect(() => call('log-1'), throwsA(isA<CacheException>()));
    });
  });

  group('deleteHealthLog', () {
    test('should delete health log from the box', () async {
      // Arrange
      when(() => mockBox.delete(any())).thenAnswer((_) async {});

      // Act
      await dataSource.deleteHealthLog('log-1');

      // Assert
      verify(() => mockBox.delete('log-1')).called(1);
    });

    test('should throw CacheException when delete throws', () async {
      // Arrange
      when(() => mockBox.delete(any())).thenThrow(Exception());

      // Act
      final call = dataSource.deleteHealthLog;

      // Assert
      expect(() => call('log-1'), throwsA(isA<CacheException>()));
    });
  });

  group('updateHealthLog', () {
    test('should update health log in the box', () async {
      // Arrange
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      // Act
      await dataSource.updateHealthLog(tHealthLogModel);

      // Assert
      verify(() => mockBox.put(tHealthLogModel.id, tHealthLogModel)).called(1);
    });

    test('should throw CacheException when put throws', () async {
      // Arrange
      when(() => mockBox.put(any(), any())).thenThrow(Exception());

      // Act
      final call = dataSource.updateHealthLog;

      // Assert
      expect(() => call(tHealthLogModel), throwsA(isA<CacheException>()));
    });
  });
}

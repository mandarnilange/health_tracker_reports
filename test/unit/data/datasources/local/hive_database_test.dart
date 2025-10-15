import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/local/hive_database.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockHiveInterface extends Mock implements HiveInterface {}

class MockBox<T> extends Mock implements Box<T> {}

void main() {
  group('HiveDatabase', () {
    late MockHiveInterface mockHive;
    late MockBox<Map<dynamic, dynamic>> mockReportsBox;
    late MockBox<Map<dynamic, dynamic>> mockConfigBox;

    setUp(() {
      mockHive = MockHiveInterface();
      mockReportsBox = MockBox<Map<dynamic, dynamic>>();
      mockConfigBox = MockBox<Map<dynamic, dynamic>>();
    });

    group('initialization', () {
      test('should initialize Hive with the provided path', () async {
        // Arrange
        const testPath = '/test/path';
        when(() => mockHive.init(testPath)).thenAnswer((_) async => {});
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.reportsBoxName))
            .thenAnswer((_) async => mockReportsBox);
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.configBoxName))
            .thenAnswer((_) async => mockConfigBox);

        // Act
        await HiveDatabase.initialize(testPath, hiveInstance: mockHive);

        // Assert
        verify(() => mockHive.init(testPath)).called(1);
      });

      test('should open reports box during initialization', () async {
        // Arrange
        const testPath = '/test/path';
        when(() => mockHive.init(testPath)).thenAnswer((_) async => {});
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.reportsBoxName))
            .thenAnswer((_) async => mockReportsBox);
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.configBoxName))
            .thenAnswer((_) async => mockConfigBox);

        // Act
        await HiveDatabase.initialize(testPath, hiveInstance: mockHive);

        // Assert
        verify(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.reportsBoxName))
            .called(1);
      });

      test('should open config box during initialization', () async {
        // Arrange
        const testPath = '/test/path';
        when(() => mockHive.init(testPath)).thenAnswer((_) async => {});
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.reportsBoxName))
            .thenAnswer((_) async => mockReportsBox);
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.configBoxName))
            .thenAnswer((_) async => mockConfigBox);

        // Act
        await HiveDatabase.initialize(testPath, hiveInstance: mockHive);

        // Assert
        verify(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.configBoxName))
            .called(1);
      });

      test('should store box references after opening', () async {
        // Arrange
        const testPath = '/test/path';
        when(() => mockHive.init(testPath)).thenAnswer((_) async => {});
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.reportsBoxName))
            .thenAnswer((_) async => mockReportsBox);
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.configBoxName))
            .thenAnswer((_) async => mockConfigBox);

        // Act
        await HiveDatabase.initialize(testPath, hiveInstance: mockHive);

        // Assert
        expect(HiveDatabase.reportsBox, mockReportsBox);
        expect(HiveDatabase.configBox, mockConfigBox);
      });
    });

    group('box access', () {
      test('should provide access to reports box', () async {
        // Arrange
        const testPath = '/test/path';
        when(() => mockHive.init(testPath)).thenAnswer((_) async => {});
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.reportsBoxName))
            .thenAnswer((_) async => mockReportsBox);
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.configBoxName))
            .thenAnswer((_) async => mockConfigBox);

        // Act
        await HiveDatabase.initialize(testPath, hiveInstance: mockHive);
        final box = HiveDatabase.reportsBox;

        // Assert
        expect(box, mockReportsBox);
      });

      test('should provide access to config box', () async {
        // Arrange
        const testPath = '/test/path';
        when(() => mockHive.init(testPath)).thenAnswer((_) async => {});
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.reportsBoxName))
            .thenAnswer((_) async => mockReportsBox);
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.configBoxName))
            .thenAnswer((_) async => mockConfigBox);

        // Act
        await HiveDatabase.initialize(testPath, hiveInstance: mockHive);
        final box = HiveDatabase.configBox;

        // Assert
        expect(box, mockConfigBox);
      });
    });

    group('box names', () {
      test('should have correct reports box name', () {
        // Assert
        expect(HiveDatabase.reportsBoxName, 'reports');
      });

      test('should have correct config box name', () {
        // Assert
        expect(HiveDatabase.configBoxName, 'config');
      });
    });

    group('close', () {
      test('should close all boxes', () async {
        // Arrange
        const testPath = '/test/path';
        when(() => mockHive.init(testPath)).thenAnswer((_) async => {});
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.reportsBoxName))
            .thenAnswer((_) async => mockReportsBox);
        when(() => mockHive.openBox<Map<dynamic, dynamic>>(HiveDatabase.configBoxName))
            .thenAnswer((_) async => mockConfigBox);
        when(() => mockHive.close()).thenAnswer((_) async => {});

        await HiveDatabase.initialize(testPath, hiveInstance: mockHive);

        // Act
        await HiveDatabase.close(hiveInstance: mockHive);

        // Assert
        verify(() => mockHive.close()).called(1);
      });
    });
  });
}

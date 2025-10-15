import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/local/config_local_datasource.dart';
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockBox<T> extends Mock implements Box<T> {}

class FakeAppConfigModel extends Fake implements AppConfigModel {}

void main() {
  late ConfigLocalDataSourceImpl dataSource;
  late MockBox<AppConfigModel> mockBox;

  setUpAll(() {
    registerFallbackValue(FakeAppConfigModel());
  });

  setUp(() {
    mockBox = MockBox<AppConfigModel>();
    dataSource = ConfigLocalDataSourceImpl(box: mockBox);
  });

  group('getConfig', () {
    final tAppConfigModel = AppConfigModel(darkModeEnabled: true);

    test('should return an AppConfigModel from the box', () async {
      // Arrange
      when(() => mockBox.get(any())).thenReturn(tAppConfigModel);

      // Act
      final result = await dataSource.getConfig();

      // Assert
      expect(result, tAppConfigModel);
    });

    test('should return a default AppConfigModel when the box is empty',
        () async {
      // Arrange
      when(() => mockBox.get(any())).thenReturn(null);

      // Act
      final result = await dataSource.getConfig();

      // Assert
      expect(result, AppConfigModel());
    });

    test('should throw a CacheException when getting the config fails',
        () async {
      // Arrange
      when(() => mockBox.get(any())).thenThrow(Exception());

      // Act
      final call = dataSource.getConfig;

      // Assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('saveConfig', () {
    final tAppConfigModel = AppConfigModel(darkModeEnabled: true);

    test('should save an AppConfigModel to the box', () async {
      // Arrange
      when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

      // Act
      await dataSource.saveConfig(tAppConfigModel);

      // Assert
      verify(() =>
              mockBox.put(ConfigLocalDataSourceImpl.configKey, tAppConfigModel))
          .called(1);
    });

    test('should throw a CacheException when saving the config fails',
        () async {
      // Arrange
      when(() => mockBox.put(any(), any())).thenThrow(Exception());

      // Act
      final call = dataSource.saveConfig;

      // Assert
      expect(() => call(tAppConfigModel), throwsA(isA<CacheException>()));
    });
  });
}

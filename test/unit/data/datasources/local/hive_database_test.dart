import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'package:health_tracker_reports/data/datasources/local/hive_database.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/data/models/biomarker_model.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

class MockHive extends Mock implements HiveInterface {}

class MockBox<T> extends Mock implements Box<T> {}

void main() {
  late HiveDatabase hiveDatabase;
  late MockHive mockHive;

  setUp(() {
    mockHive = MockHive();
    hiveDatabase = HiveDatabase(hive: mockHive);
    registerFallbackValue(ReportModelAdapter());
    registerFallbackValue(AppConfigModelAdapter());
    registerFallbackValue(BiomarkerModelAdapter());
    registerFallbackValue(ReferenceRangeModelAdapter());
    registerFallbackValue(LlmProviderAdapter());
  });

  group('HiveDatabase', () {
    test('should register all required adapters', () async {
      // Arrange
      when(() => mockHive.registerAdapter<ReportModel>(any())).thenReturn(null);
      when(() => mockHive.registerAdapter<AppConfigModel>(any()))
          .thenReturn(null);
      when(() => mockHive.registerAdapter<BiomarkerModel>(any()))
          .thenReturn(null);
      when(() => mockHive.registerAdapter<ReferenceRangeModel>(any()))
          .thenReturn(null);
      when(() => mockHive.registerAdapter<LlmProvider>(any())).thenReturn(null);

      // Act
      await hiveDatabase.init();

      // Assert
      verifyNever(() => mockHive.init(any()));
      verify(() => mockHive.registerAdapter<ReportModel>(any())).called(1);
      verify(() => mockHive.registerAdapter<AppConfigModel>(any())).called(1);
      verify(() => mockHive.registerAdapter<BiomarkerModel>(any())).called(1);
      verify(() => mockHive.registerAdapter<ReferenceRangeModel>(any()))
          .called(1);
      verify(() => mockHive.registerAdapter<LlmProvider>(any())).called(1);
    });

    test('should open boxes', () async {
      // Arrange
      when(() => mockHive.openBox<ReportModel>(any()))
          .thenAnswer((_) async => MockBox<ReportModel>());
      when(() => mockHive.openBox<AppConfigModel>(any()))
          .thenAnswer((_) async => MockBox<AppConfigModel>());

      // Act
      await hiveDatabase.openBoxes();

      // Assert
      verify(() => mockHive.openBox<ReportModel>(HiveDatabase.reportBoxName))
          .called(1);
      verify(() => mockHive.openBox<AppConfigModel>(HiveDatabase.configBoxName))
          .called(1);
    });
  });
}

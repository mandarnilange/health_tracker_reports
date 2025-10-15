import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/models/biomarker_model.dart';
import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';

void main() {
  group('BiomarkerModel', () {
    const tId = 'test-id-123';
    const tName = 'Hemoglobin';
    const tValue = 14.5;
    const tUnit = 'g/dL';
    const tReferenceRange = ReferenceRange(min: 12.0, max: 16.0);
    const tReferenceRangeModel = ReferenceRangeModel(min: 12.0, max: 16.0);
    final tMeasuredAt = DateTime(2025, 10, 15, 10, 30);

    final tBiomarker = Biomarker(
      id: tId,
      name: tName,
      value: tValue,
      unit: tUnit,
      referenceRange: tReferenceRange,
      measuredAt: tMeasuredAt,
    );

    final tBiomarkerModel = BiomarkerModel(
      id: tId,
      name: tName,
      value: tValue,
      unit: tUnit,
      referenceRange: tReferenceRangeModel,
      measuredAt: tMeasuredAt,
    );

    final tJson = {
      'id': tId,
      'name': tName,
      'value': tValue,
      'unit': tUnit,
      'referenceRange': {
        'min': 12.0,
        'max': 16.0,
      },
      'measuredAt': tMeasuredAt.toIso8601String(),
    };

    group('fromEntity', () {
      test('should create BiomarkerModel from Biomarker entity', () {
        // Act
        final result = BiomarkerModel.fromEntity(tBiomarker);

        // Assert
        expect(result, isA<BiomarkerModel>());
        expect(result.id, tBiomarker.id);
        expect(result.name, tBiomarker.name);
        expect(result.value, tBiomarker.value);
        expect(result.unit, tBiomarker.unit);
        expect(result.referenceRange, isA<ReferenceRangeModel>());
        expect(result.referenceRange.min, tBiomarker.referenceRange.min);
        expect(result.referenceRange.max, tBiomarker.referenceRange.max);
        expect(result.measuredAt, tBiomarker.measuredAt);
      });

      test('should create model that equals another model with same values', () {
        // Act
        final result = BiomarkerModel.fromEntity(tBiomarker);

        // Assert
        expect(result, tBiomarkerModel);
      });

      test('should preserve all biomarker properties from entity', () {
        // Arrange
        final entityWithDifferentValues = Biomarker(
          id: 'id-456',
          name: 'Glucose',
          value: 95.5,
          unit: 'mg/dL',
          referenceRange: const ReferenceRange(min: 70.0, max: 100.0),
          measuredAt: DateTime(2024, 12, 31, 8, 0),
        );

        // Act
        final result = BiomarkerModel.fromEntity(entityWithDifferentValues);

        // Assert
        expect(result.id, 'id-456');
        expect(result.name, 'Glucose');
        expect(result.value, 95.5);
        expect(result.unit, 'mg/dL');
        expect(result.referenceRange.min, 70.0);
        expect(result.referenceRange.max, 100.0);
        expect(result.measuredAt, DateTime(2024, 12, 31, 8, 0));
      });

      test('should inherit isOutOfRange getter from Biomarker', () {
        // Act
        final result = BiomarkerModel.fromEntity(tBiomarker);

        // Assert
        expect(result.isOutOfRange, false);
      });

      test('should inherit status getter from Biomarker', () {
        // Act
        final result = BiomarkerModel.fromEntity(tBiomarker);

        // Assert
        expect(result.status, BiomarkerStatus.normal);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // Act
        final result = tBiomarkerModel.toJson();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result, tJson);
      });

      test('should return JSON with correct keys', () {
        // Act
        final result = tBiomarkerModel.toJson();

        // Assert
        expect(result.containsKey('id'), true);
        expect(result.containsKey('name'), true);
        expect(result.containsKey('value'), true);
        expect(result.containsKey('unit'), true);
        expect(result.containsKey('referenceRange'), true);
        expect(result.containsKey('measuredAt'), true);
        expect(result.keys.length, 6);
      });

      test('should serialize referenceRange as nested JSON object', () {
        // Act
        final result = tBiomarkerModel.toJson();

        // Assert
        expect(result['referenceRange'], isA<Map<String, dynamic>>());
        expect(result['referenceRange']['min'], 12.0);
        expect(result['referenceRange']['max'], 16.0);
      });

      test('should serialize measuredAt as ISO8601 string', () {
        // Act
        final result = tBiomarkerModel.toJson();

        // Assert
        expect(result['measuredAt'], isA<String>());
        expect(result['measuredAt'], tMeasuredAt.toIso8601String());
      });

      test('should preserve decimal values in JSON', () {
        // Arrange
        final modelWithDecimals = BiomarkerModel(
          id: 'test',
          name: 'Test',
          value: 14.567,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 10.5, max: 20.7),
          measuredAt: tMeasuredAt,
        );

        // Act
        final result = modelWithDecimals.toJson();

        // Assert
        expect(result['value'], 14.567);
        expect(result['referenceRange']['min'], 10.5);
        expect(result['referenceRange']['max'], 20.7);
      });

      test('should handle different DateTime values', () {
        // Arrange
        final differentDateTime = DateTime(2020, 1, 1, 0, 0, 0);
        final model = BiomarkerModel(
          id: tId,
          name: tName,
          value: tValue,
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: differentDateTime,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['measuredAt'], differentDateTime.toIso8601String());
      });
    });

    group('fromJson', () {
      test('should return a valid BiomarkerModel from JSON', () {
        // Act
        final result = BiomarkerModel.fromJson(tJson);

        // Assert
        expect(result, isA<BiomarkerModel>());
        expect(result, tBiomarkerModel);
      });

      test('should correctly parse all fields from JSON', () {
        // Act
        final result = BiomarkerModel.fromJson(tJson);

        // Assert
        expect(result.id, tId);
        expect(result.name, tName);
        expect(result.value, tValue);
        expect(result.unit, tUnit);
        expect(result.referenceRange.min, 12.0);
        expect(result.referenceRange.max, 16.0);
        expect(result.measuredAt, tMeasuredAt);
      });

      test('should parse nested referenceRange from JSON', () {
        // Act
        final result = BiomarkerModel.fromJson(tJson);

        // Assert
        expect(result.referenceRange, isA<ReferenceRange>());
        expect(result.referenceRange.min, 12.0);
        expect(result.referenceRange.max, 16.0);
      });

      test('should parse measuredAt from ISO8601 string', () {
        // Act
        final result = BiomarkerModel.fromJson(tJson);

        // Assert
        expect(result.measuredAt, isA<DateTime>());
        expect(result.measuredAt, tMeasuredAt);
      });

      test('should parse decimal values from JSON', () {
        // Arrange
        final jsonWithDecimals = {
          'id': 'test',
          'name': 'Test',
          'value': 14.567,
          'unit': 'g/dL',
          'referenceRange': {
            'min': 10.5,
            'max': 20.7,
          },
          'measuredAt': tMeasuredAt.toIso8601String(),
        };

        // Act
        final result = BiomarkerModel.fromJson(jsonWithDecimals);

        // Assert
        expect(result.value, 14.567);
        expect(result.referenceRange.min, 10.5);
        expect(result.referenceRange.max, 20.7);
      });

      test('should parse integer values as doubles from JSON', () {
        // Arrange
        final jsonWithIntegers = {
          'id': tId,
          'name': tName,
          'value': 14,
          'unit': tUnit,
          'referenceRange': {
            'min': 12,
            'max': 16,
          },
          'measuredAt': tMeasuredAt.toIso8601String(),
        };

        // Act
        final result = BiomarkerModel.fromJson(jsonWithIntegers);

        // Assert
        expect(result.value, 14.0);
        expect(result.referenceRange.min, 12.0);
        expect(result.referenceRange.max, 16.0);
      });

      test('should handle different DateTime formats from JSON', () {
        // Arrange
        final differentDateTime = DateTime(2020, 1, 1, 0, 0, 0);
        final jsonWithDifferentDate = {
          ...tJson,
          'measuredAt': differentDateTime.toIso8601String(),
        };

        // Act
        final result = BiomarkerModel.fromJson(jsonWithDifferentDate);

        // Assert
        expect(result.measuredAt, differentDateTime);
      });
    });

    group('JSON serialization round-trip', () {
      test('should preserve all data through toJson and fromJson', () {
        // Act
        final json = tBiomarkerModel.toJson();
        final result = BiomarkerModel.fromJson(json);

        // Assert
        expect(result, tBiomarkerModel);
      });

      test('should preserve decimal values through round-trip', () {
        // Arrange
        final modelWithDecimals = BiomarkerModel(
          id: 'test',
          name: 'Test',
          value: 14.567,
          unit: 'g/dL',
          referenceRange: const ReferenceRangeModel(min: 10.5, max: 20.7),
          measuredAt: tMeasuredAt,
        );

        // Act
        final json = modelWithDecimals.toJson();
        final result = BiomarkerModel.fromJson(json);

        // Assert
        expect(result, modelWithDecimals);
        expect(result.value, 14.567);
        expect(result.referenceRange.min, 10.5);
        expect(result.referenceRange.max, 20.7);
      });

      test('should preserve DateTime through round-trip', () {
        // Arrange
        final specificDateTime = DateTime(2025, 3, 15, 14, 30, 45, 123);
        final model = BiomarkerModel(
          id: tId,
          name: tName,
          value: tValue,
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: specificDateTime,
        );

        // Act
        final json = model.toJson();
        final result = BiomarkerModel.fromJson(json);

        // Assert
        expect(result.measuredAt.year, specificDateTime.year);
        expect(result.measuredAt.month, specificDateTime.month);
        expect(result.measuredAt.day, specificDateTime.day);
        expect(result.measuredAt.hour, specificDateTime.hour);
        expect(result.measuredAt.minute, specificDateTime.minute);
        expect(result.measuredAt.second, specificDateTime.second);
      });

      test('should preserve nested referenceRange through round-trip', () {
        // Arrange
        final modelWithComplexRange = BiomarkerModel(
          id: tId,
          name: tName,
          value: tValue,
          unit: tUnit,
          referenceRange: const ReferenceRange(min: 0.01, max: 999.99),
          measuredAt: tMeasuredAt,
        );

        // Act
        final json = modelWithComplexRange.toJson();
        final result = BiomarkerModel.fromJson(json);

        // Assert
        expect(result.referenceRange.min, 0.01);
        expect(result.referenceRange.max, 999.99);
      });
    });

    group('inheritance from Biomarker', () {
      test('should be a subtype of Biomarker', () {
        // Assert
        expect(tBiomarkerModel, isA<Biomarker>());
      });

      test('should have access to isOutOfRange getter', () {
        // Arrange - value within range
        final normalModel = BiomarkerModel(
          id: tId,
          name: tName,
          value: 14.0,
          unit: tUnit,
          referenceRange: const ReferenceRange(min: 12.0, max: 16.0),
          measuredAt: tMeasuredAt,
        );

        // Arrange - value below range
        final lowModel = BiomarkerModel(
          id: tId,
          name: tName,
          value: 10.0,
          unit: tUnit,
          referenceRange: const ReferenceRange(min: 12.0, max: 16.0),
          measuredAt: tMeasuredAt,
        );

        // Arrange - value above range
        final highModel = BiomarkerModel(
          id: tId,
          name: tName,
          value: 18.0,
          unit: tUnit,
          referenceRange: const ReferenceRange(min: 12.0, max: 16.0),
          measuredAt: tMeasuredAt,
        );

        // Assert
        expect(normalModel.isOutOfRange, false);
        expect(lowModel.isOutOfRange, true);
        expect(highModel.isOutOfRange, true);
      });

      test('should have access to status getter', () {
        // Arrange - normal status
        final normalModel = BiomarkerModel(
          id: tId,
          name: tName,
          value: 14.0,
          unit: tUnit,
          referenceRange: const ReferenceRange(min: 12.0, max: 16.0),
          measuredAt: tMeasuredAt,
        );

        // Arrange - low status
        final lowModel = BiomarkerModel(
          id: tId,
          name: tName,
          value: 10.0,
          unit: tUnit,
          referenceRange: const ReferenceRange(min: 12.0, max: 16.0),
          measuredAt: tMeasuredAt,
        );

        // Arrange - high status
        final highModel = BiomarkerModel(
          id: tId,
          name: tName,
          value: 18.0,
          unit: tUnit,
          referenceRange: const ReferenceRange(min: 12.0, max: 16.0),
          measuredAt: tMeasuredAt,
        );

        // Assert
        expect(normalModel.status, BiomarkerStatus.normal);
        expect(lowModel.status, BiomarkerStatus.low);
        expect(highModel.status, BiomarkerStatus.high);
      });

      test('should maintain Equatable equality', () {
        // Arrange
        final model1 = BiomarkerModel(
          id: tId,
          name: tName,
          value: tValue,
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: tMeasuredAt,
        );

        final model2 = BiomarkerModel(
          id: tId,
          name: tName,
          value: tValue,
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: tMeasuredAt,
        );

        final model3 = BiomarkerModel(
          id: 'different-id',
          name: tName,
          value: tValue,
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: tMeasuredAt,
        );

        // Assert
        expect(model1, model2);
        expect(model1, isNot(model3));
      });

      test('should have access to copyWith method', () {
        // Act
        final result = tBiomarkerModel.copyWith(value: 15.0);

        // Assert
        expect(result.value, 15.0);
        expect(result.id, tId);
        expect(result.name, tName);
      });
    });
  });
}

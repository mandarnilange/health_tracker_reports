import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';

void main() {
  group('ReferenceRangeModel', () {
    const tMin = 10.0;
    const tMax = 20.0;

    const tReferenceRange = ReferenceRange(
      min: tMin,
      max: tMax,
    );

    const tReferenceRangeModel = ReferenceRangeModel(
      min: tMin,
      max: tMax,
    );

    final tJson = {
      'min': tMin,
      'max': tMax,
    };

    group('fromEntity', () {
      test('should create ReferenceRangeModel from ReferenceRange entity', () {
        // Act
        final result = ReferenceRangeModel.fromEntity(tReferenceRange);

        // Assert
        expect(result, isA<ReferenceRangeModel>());
        expect(result.min, tReferenceRange.min);
        expect(result.max, tReferenceRange.max);
      });

      test('should create model that equals another model with same values',
          () {
        // Act
        final result = ReferenceRangeModel.fromEntity(tReferenceRange);

        // Assert
        expect(result, tReferenceRangeModel);
      });

      test('should preserve decimal values from entity', () {
        // Arrange
        const entityWithDecimals = ReferenceRange(
          min: 10.5,
          max: 20.7,
        );

        // Act
        final result = ReferenceRangeModel.fromEntity(entityWithDecimals);

        // Assert
        expect(result.min, 10.5);
        expect(result.max, 20.7);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // Act
        final result = tReferenceRangeModel.toJson();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result, tJson);
      });

      test('should return JSON with correct keys', () {
        // Act
        final result = tReferenceRangeModel.toJson();

        // Assert
        expect(result.containsKey('min'), true);
        expect(result.containsKey('max'), true);
        expect(result.keys.length, 2);
      });

      test('should preserve decimal values in JSON', () {
        // Arrange
        const modelWithDecimals = ReferenceRangeModel(
          min: 10.5,
          max: 20.7,
        );

        // Act
        final result = modelWithDecimals.toJson();

        // Assert
        expect(result['min'], 10.5);
        expect(result['max'], 20.7);
      });

      test('should handle very small decimal values', () {
        // Arrange
        const modelWithSmallDecimals = ReferenceRangeModel(
          min: 0.01,
          max: 0.99,
        );

        // Act
        final result = modelWithSmallDecimals.toJson();

        // Assert
        expect(result['min'], 0.01);
        expect(result['max'], 0.99);
      });

      test('should handle large values', () {
        // Arrange
        const modelWithLargeValues = ReferenceRangeModel(
          min: 1000.0,
          max: 99999.99,
        );

        // Act
        final result = modelWithLargeValues.toJson();

        // Assert
        expect(result['min'], 1000.0);
        expect(result['max'], 99999.99);
      });
    });

    group('fromJson', () {
      test('should return a valid ReferenceRangeModel from JSON', () {
        // Act
        final result = ReferenceRangeModel.fromJson(tJson);

        // Assert
        expect(result, isA<ReferenceRangeModel>());
        expect(result, tReferenceRangeModel);
      });

      test('should correctly parse min and max values from JSON', () {
        // Act
        final result = ReferenceRangeModel.fromJson(tJson);

        // Assert
        expect(result.min, tMin);
        expect(result.max, tMax);
      });

      test('should parse decimal values from JSON', () {
        // Arrange
        final jsonWithDecimals = {
          'min': 10.5,
          'max': 20.7,
        };

        // Act
        final result = ReferenceRangeModel.fromJson(jsonWithDecimals);

        // Assert
        expect(result.min, 10.5);
        expect(result.max, 20.7);
      });

      test('should parse integer values as doubles from JSON', () {
        // Arrange
        final jsonWithIntegers = {
          'min': 10,
          'max': 20,
        };

        // Act
        final result = ReferenceRangeModel.fromJson(jsonWithIntegers);

        // Assert
        expect(result.min, 10.0);
        expect(result.max, 20.0);
      });

      test('should handle very small decimal values from JSON', () {
        // Arrange
        final jsonWithSmallDecimals = {
          'min': 0.01,
          'max': 0.99,
        };

        // Act
        final result = ReferenceRangeModel.fromJson(jsonWithSmallDecimals);

        // Assert
        expect(result.min, 0.01);
        expect(result.max, 0.99);
      });

      test('should handle large values from JSON', () {
        // Arrange
        final jsonWithLargeValues = {
          'min': 1000.0,
          'max': 99999.99,
        };

        // Act
        final result = ReferenceRangeModel.fromJson(jsonWithLargeValues);

        // Assert
        expect(result.min, 1000.0);
        expect(result.max, 99999.99);
      });
    });

    group('JSON serialization round-trip', () {
      test('should preserve data through toJson and fromJson', () {
        // Act
        final json = tReferenceRangeModel.toJson();
        final result = ReferenceRangeModel.fromJson(json);

        // Assert
        expect(result, tReferenceRangeModel);
      });

      test('should preserve decimal values through round-trip', () {
        // Arrange
        const modelWithDecimals = ReferenceRangeModel(
          min: 10.5,
          max: 20.7,
        );

        // Act
        final json = modelWithDecimals.toJson();
        final result = ReferenceRangeModel.fromJson(json);

        // Assert
        expect(result, modelWithDecimals);
        expect(result.min, 10.5);
        expect(result.max, 20.7);
      });

      test('should preserve very small values through round-trip', () {
        // Arrange
        const modelWithSmallValues = ReferenceRangeModel(
          min: 0.01,
          max: 0.99,
        );

        // Act
        final json = modelWithSmallValues.toJson();
        final result = ReferenceRangeModel.fromJson(json);

        // Assert
        expect(result, modelWithSmallValues);
      });

      test('should preserve large values through round-trip', () {
        // Arrange
        const modelWithLargeValues = ReferenceRangeModel(
          min: 1000.0,
          max: 99999.99,
        );

        // Act
        final json = modelWithLargeValues.toJson();
        final result = ReferenceRangeModel.fromJson(json);

        // Assert
        expect(result, modelWithLargeValues);
      });
    });

    group('inheritance from ReferenceRange', () {
      test('should be a subtype of ReferenceRange', () {
        // Assert
        expect(tReferenceRangeModel, isA<ReferenceRange>());
      });

      test('should have access to isOutOfRange method', () {
        // Assert
        expect(tReferenceRangeModel.isOutOfRange(5.0), true);
        expect(tReferenceRangeModel.isOutOfRange(15.0), false);
        expect(tReferenceRangeModel.isOutOfRange(25.0), true);
      });

      test('should maintain Equatable equality', () {
        // Arrange
        const model1 = ReferenceRangeModel(min: 10.0, max: 20.0);
        const model2 = ReferenceRangeModel(min: 10.0, max: 20.0);
        const model3 = ReferenceRangeModel(min: 15.0, max: 25.0);

        // Assert
        expect(model1, model2);
        expect(model1, isNot(model3));
      });
    });
  });
}

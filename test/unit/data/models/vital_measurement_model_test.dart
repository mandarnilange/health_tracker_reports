import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:health_tracker_reports/data/models/vital_measurement_model.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';

void main() {
  group('VitalMeasurementModel', () {
    const tId = 'vital-123';
    const tType = VitalType.heartRate;
    const tValue = 72.0;
    const tUnit = 'bpm';
    const tStatus = VitalStatus.warning;
    const tReferenceRange = ReferenceRange(min: 60, max: 100);
    const tReferenceRangeModel = ReferenceRangeModel(min: 60, max: 100);

    const tEntity = VitalMeasurement(
      id: tId,
      type: tType,
      value: tValue,
      unit: tUnit,
      status: tStatus,
      referenceRange: tReferenceRange,
    );

    final tModel = VitalMeasurementModel(
      id: tId,
      vitalTypeIndex: tType.index,
      value: tValue,
      unit: tUnit,
      statusIndex: tStatus.index,
      referenceRange: tReferenceRangeModel,
    );

    final tJson = {
      'id': tId,
      'vitalTypeIndex': tType.index,
      'value': tValue,
      'unit': tUnit,
      'statusIndex': tStatus.index,
      'referenceRange': {
        'min': tReferenceRange.min,
        'max': tReferenceRange.max,
      },
    };

    group('fromEntity', () {
      test('should create model from entity', () {
        // Act
        final result = VitalMeasurementModel.fromEntity(tEntity);

        // Assert
        expect(result.id, tModel.id);
        expect(result.vitalTypeIndex, tModel.vitalTypeIndex);
        expect(result.value, tModel.value);
        expect(result.unit, tModel.unit);
        expect(result.statusIndex, tModel.statusIndex);
        expect(result.referenceRange, tModel.referenceRange);
      });

      test('should handle null reference range', () {
        // Arrange
        const entityWithoutRange = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
        );

        // Act
        final result = VitalMeasurementModel.fromEntity(entityWithoutRange);

        // Assert
        expect(result.referenceRange, isNull);
      });
    });

    group('fromJson', () {
      test('should parse model from json map', () {
        // Act
        final result = VitalMeasurementModel.fromJson(tJson);

        // Assert
        expect(result, tModel);
      });
    });

    group('toJson', () {
      test('should convert model to json map', () {
        // Act
        final result = tModel.toJson();

        // Assert
        expect(result, tJson);
      });
    });

    group('toEntity', () {
      test('should convert model back to entity', () {
        // Act
        final result = tModel.toEntity();

        // Assert
        expect(result, tEntity);
      });
    });
  });
}

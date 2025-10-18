import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/models/health_log_model.dart';
import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:health_tracker_reports/data/models/vital_measurement_model.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';

void main() {
  group('HealthLogModel', () {
    const tLogId = 'log-123';
    final tTimestamp = DateTime(2025, 10, 20, 7, 30);
    final tCreatedAt = DateTime(2025, 10, 20, 8, 0);
    final tUpdatedAt = DateTime(2025, 10, 20, 8, 5);
    const tNotes = 'Morning vitals after workout';

    final tVitals = [
      VitalMeasurement(
        id: 'vital-1',
        type: VitalType.bloodPressureSystolic,
        value: 118,
        unit: 'mmHg',
        status: VitalStatus.normal,
        referenceRange: const ReferenceRange(min: 90, max: 120),
      ),
      VitalMeasurement(
        id: 'vital-2',
        type: VitalType.heartRate,
        value: 88,
        unit: 'bpm',
        status: VitalStatus.warning,
        referenceRange: const ReferenceRange(min: 60, max: 100),
      ),
    ];

    final tVitalModels = [
      VitalMeasurementModel(
        id: 'vital-1',
        vitalTypeIndex: VitalType.bloodPressureSystolic.index,
        value: 118,
        unit: 'mmHg',
        statusIndex: VitalStatus.normal.index,
        referenceRange: const ReferenceRangeModel(min: 90, max: 120),
      ),
      VitalMeasurementModel(
        id: 'vital-2',
        vitalTypeIndex: VitalType.heartRate.index,
        value: 88,
        unit: 'bpm',
        statusIndex: VitalStatus.warning.index,
        referenceRange: const ReferenceRangeModel(min: 60, max: 100),
      ),
    ];

    final tEntity = HealthLog(
      id: tLogId,
      timestamp: tTimestamp,
      vitals: tVitals,
      notes: tNotes,
      createdAt: tCreatedAt,
      updatedAt: tUpdatedAt,
    );

    final tModel = HealthLogModel(
      id: tLogId,
      timestamp: tTimestamp,
      vitals: tVitalModels,
      notes: tNotes,
      createdAt: tCreatedAt,
      updatedAt: tUpdatedAt,
    );

    final tJson = {
      'id': tLogId,
      'timestamp': tTimestamp.toIso8601String(),
      'vitals': [
        {
          'id': 'vital-1',
          'vitalTypeIndex': VitalType.bloodPressureSystolic.index,
          'value': 118,
          'unit': 'mmHg',
          'statusIndex': VitalStatus.normal.index,
          'referenceRange': {'min': 90, 'max': 120},
        },
        {
          'id': 'vital-2',
          'vitalTypeIndex': VitalType.heartRate.index,
          'value': 88,
          'unit': 'bpm',
          'statusIndex': VitalStatus.warning.index,
          'referenceRange': {'min': 60, 'max': 100},
        },
      ],
      'notes': tNotes,
      'createdAt': tCreatedAt.toIso8601String(),
      'updatedAt': tUpdatedAt.toIso8601String(),
    };

    group('fromEntity', () {
      test('should create model from entity', () {
        // Act
        final result = HealthLogModel.fromEntity(tEntity);

        // Assert
        expect(result.id, tModel.id);
        expect(result.timestamp, tModel.timestamp);
        expect(result.notes, tModel.notes);
        expect(result.vitals.length, tModel.vitals.length);
        expect(result.createdAt, tModel.createdAt);
        expect(result.updatedAt, tModel.updatedAt);
      });

      test('should convert vitals to VitalMeasurementModel list', () {
        // Act
        final result = HealthLogModel.fromEntity(tEntity);

        // Assert
        expect(result.vitals, isA<List<VitalMeasurementModel>>());
        expect(result.vitals.first.id, tVitalModels.first.id);
      });

      test('should handle null notes', () {
        // Arrange
        final entityWithoutNotes = tEntity.copyWith(notes: null);

        // Act
        final result = HealthLogModel.fromEntity(entityWithoutNotes);

        // Assert
        expect(result.notes, isNull);
      });
    });

    group('fromJson', () {
      test('should parse model from json map', () {
        // Act
        final result = HealthLogModel.fromJson(tJson);

        // Assert
        expect(result, tModel);
      });
    });

    group('toJson', () {
      test('should serialize model to json map', () {
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

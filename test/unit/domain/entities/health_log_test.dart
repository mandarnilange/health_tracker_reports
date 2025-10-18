import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';

void main() {
  group('HealthLog', () {
    const tId = 'health-log-123';
    final tTimestamp = DateTime(2025, 10, 18, 7, 30);
    final tCreatedAt = DateTime(2025, 10, 18, 7, 30);
    final tUpdatedAt = DateTime(2025, 10, 18, 7, 30);
    const tNotes = 'Morning reading after exercise';

    // Helper to create test vital measurements
    VitalMeasurement createVitalMeasurement({
      required String id,
      required VitalType type,
      required double value,
      required String unit,
      required VitalStatus status,
      ReferenceRange? referenceRange,
    }) {
      return VitalMeasurement(
        id: id,
        type: type,
        value: value,
        unit: unit,
        status: status,
        referenceRange: referenceRange,
      );
    }

    final tNormalVitals = [
      createVitalMeasurement(
        id: 'vital-1',
        type: VitalType.bloodPressureSystolic,
        value: 120,
        unit: 'mmHg',
        status: VitalStatus.normal,
        referenceRange: const ReferenceRange(min: 90, max: 120),
      ),
      createVitalMeasurement(
        id: 'vital-2',
        type: VitalType.bloodPressureDiastolic,
        value: 80,
        unit: 'mmHg',
        status: VitalStatus.normal,
        referenceRange: const ReferenceRange(min: 60, max: 80),
      ),
      createVitalMeasurement(
        id: 'vital-3',
        type: VitalType.oxygenSaturation,
        value: 98,
        unit: '%',
        status: VitalStatus.normal,
        referenceRange: const ReferenceRange(min: 95, max: 100),
      ),
    ];

    final tMixedVitals = [
      createVitalMeasurement(
        id: 'vital-1',
        type: VitalType.bloodPressureSystolic,
        value: 140,
        unit: 'mmHg',
        status: VitalStatus.warning,
        referenceRange: const ReferenceRange(min: 90, max: 120),
      ),
      createVitalMeasurement(
        id: 'vital-2',
        type: VitalType.bloodPressureDiastolic,
        value: 80,
        unit: 'mmHg',
        status: VitalStatus.normal,
        referenceRange: const ReferenceRange(min: 60, max: 80),
      ),
      createVitalMeasurement(
        id: 'vital-3',
        type: VitalType.oxygenSaturation,
        value: 92,
        unit: '%',
        status: VitalStatus.critical,
        referenceRange: const ReferenceRange(min: 95, max: 100),
      ),
    ];

    test('should create a valid HealthLog with all fields', () {
      // Act
      final healthLog = HealthLog(
        id: tId,
        timestamp: tTimestamp,
        vitals: tNormalVitals,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Assert
      expect(healthLog.id, tId);
      expect(healthLog.timestamp, tTimestamp);
      expect(healthLog.vitals, tNormalVitals);
      expect(healthLog.notes, tNotes);
      expect(healthLog.createdAt, tCreatedAt);
      expect(healthLog.updatedAt, tUpdatedAt);
    });

    test('should create a valid HealthLog with null notes', () {
      // Act
      final healthLog = HealthLog(
        id: tId,
        timestamp: tTimestamp,
        vitals: tNormalVitals,
        notes: null,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Assert
      expect(healthLog.notes, null);
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      final healthLog1 = HealthLog(
        id: tId,
        timestamp: tTimestamp,
        vitals: tNormalVitals,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );
      final healthLog2 = HealthLog(
        id: tId,
        timestamp: tTimestamp,
        vitals: tNormalVitals,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Assert
      expect(healthLog1, healthLog2);
    });

    test('should not be equal when properties are different', () {
      // Arrange
      final healthLog1 = HealthLog(
        id: tId,
        timestamp: tTimestamp,
        vitals: tNormalVitals,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );
      final healthLog2 = HealthLog(
        id: 'different-id',
        timestamp: tTimestamp,
        vitals: tNormalVitals,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Assert
      expect(healthLog1, isNot(healthLog2));
    });

    group('entryType getter', () {
      test('should return HealthEntryType.healthLog', () {
        // Arrange
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: tNormalVitals,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(healthLog.entryType, HealthEntryType.healthLog);
      });
    });

    group('displayTitle getter', () {
      test('should return "Health Log"', () {
        // Arrange
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: tNormalVitals,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(healthLog.displayTitle, 'Health Log');
      });
    });

    group('displaySubtitle getter', () {
      test('should show top 3 vitals when exactly 3 vitals', () {
        // Arrange
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: tNormalVitals, // 3 vitals
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(
          healthLog.displaySubtitle,
          'BP Systolic, BP Diastolic, SpO2',
        );
      });

      test('should show top 3 vitals with count when more than 3 vitals', () {
        // Arrange
        final vitals = [
          ...tNormalVitals,
          createVitalMeasurement(
            id: 'vital-4',
            type: VitalType.heartRate,
            value: 72,
            unit: 'bpm',
            status: VitalStatus.normal,
          ),
          createVitalMeasurement(
            id: 'vital-5',
            type: VitalType.bodyTemperature,
            value: 98.6,
            unit: '°F',
            status: VitalStatus.normal,
          ),
        ];
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: vitals,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(
          healthLog.displaySubtitle,
          'BP Systolic, BP Diastolic, SpO2 +2',
        );
      });

      test('should show all vitals when less than 3 vitals', () {
        // Arrange
        final vitals = [
          createVitalMeasurement(
            id: 'vital-1',
            type: VitalType.heartRate,
            value: 72,
            unit: 'bpm',
            status: VitalStatus.normal,
          ),
          createVitalMeasurement(
            id: 'vital-2',
            type: VitalType.oxygenSaturation,
            value: 98,
            unit: '%',
            status: VitalStatus.normal,
          ),
        ];
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: vitals,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(healthLog.displaySubtitle, 'Heart Rate, SpO2');
      });

      test('should return empty string when no vitals', () {
        // Arrange
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: [],
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(healthLog.displaySubtitle, '');
      });
    });

    group('hasWarnings getter', () {
      test('should return false when all vitals are normal', () {
        // Arrange
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: tNormalVitals,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(healthLog.hasWarnings, false);
      });

      test('should return true when any vital has warning status', () {
        // Arrange
        final vitals = [
          createVitalMeasurement(
            id: 'vital-1',
            type: VitalType.bloodPressureSystolic,
            value: 140,
            unit: 'mmHg',
            status: VitalStatus.warning,
          ),
          createVitalMeasurement(
            id: 'vital-2',
            type: VitalType.heartRate,
            value: 72,
            unit: 'bpm',
            status: VitalStatus.normal,
          ),
        ];
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: vitals,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(healthLog.hasWarnings, true);
      });

      test('should return true when any vital has critical status', () {
        // Arrange
        final vitals = [
          createVitalMeasurement(
            id: 'vital-1',
            type: VitalType.oxygenSaturation,
            value: 88,
            unit: '%',
            status: VitalStatus.critical,
          ),
          createVitalMeasurement(
            id: 'vital-2',
            type: VitalType.heartRate,
            value: 72,
            unit: 'bpm',
            status: VitalStatus.normal,
          ),
        ];
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: vitals,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(healthLog.hasWarnings, true);
      });

      test('should return false when vitals list is empty', () {
        // Arrange
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: [],
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(healthLog.hasWarnings, false);
      });
    });

    group('outOfRangeVitals getter', () {
      test('should return empty list when all vitals are normal', () {
        // Arrange
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: tNormalVitals,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(healthLog.outOfRangeVitals, isEmpty);
      });

      test('should return only vitals with warning status', () {
        // Arrange
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: tMixedVitals,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(healthLog.outOfRangeVitals.length, 2);
        expect(
          healthLog.outOfRangeVitals[0].status,
          VitalStatus.warning,
        );
        expect(
          healthLog.outOfRangeVitals[1].status,
          VitalStatus.critical,
        );
      });

      test('should return only vitals with critical status', () {
        // Arrange
        final vitals = [
          createVitalMeasurement(
            id: 'vital-1',
            type: VitalType.oxygenSaturation,
            value: 85,
            unit: '%',
            status: VitalStatus.critical,
          ),
          createVitalMeasurement(
            id: 'vital-2',
            type: VitalType.heartRate,
            value: 72,
            unit: 'bpm',
            status: VitalStatus.normal,
          ),
        ];
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: vitals,
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(healthLog.outOfRangeVitals.length, 1);
        expect(
          healthLog.outOfRangeVitals[0].status,
          VitalStatus.critical,
        );
      });

      test('should return empty list when no vitals', () {
        // Arrange
        final healthLog = HealthLog(
          id: tId,
          timestamp: tTimestamp,
          vitals: [],
          notes: tNotes,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // Assert
        expect(healthLog.outOfRangeVitals, isEmpty);
      });
    });

    group('copyWith', () {
      final originalHealthLog = HealthLog(
        id: tId,
        timestamp: tTimestamp,
        vitals: tNormalVitals,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      test('should return a copy with updated id', () {
        // Act
        final updated = originalHealthLog.copyWith(id: 'new-id');

        // Assert
        expect(updated.id, 'new-id');
        expect(updated.timestamp, tTimestamp);
        expect(updated.vitals, tNormalVitals);
      });

      test('should return a copy with updated timestamp', () {
        // Arrange
        final newTimestamp = DateTime(2025, 10, 19);

        // Act
        final updated = originalHealthLog.copyWith(timestamp: newTimestamp);

        // Assert
        expect(updated.timestamp, newTimestamp);
        expect(updated.id, tId);
      });

      test('should return a copy with updated vitals', () {
        // Arrange
        final newVitals = [
          createVitalMeasurement(
            id: 'vital-new',
            type: VitalType.heartRate,
            value: 85,
            unit: 'bpm',
            status: VitalStatus.normal,
          ),
        ];

        // Act
        final updated = originalHealthLog.copyWith(vitals: newVitals);

        // Assert
        expect(updated.vitals, newVitals);
        expect(updated.id, tId);
      });

      test('should return a copy with updated notes', () {
        // Act
        final updated = originalHealthLog.copyWith(notes: 'New notes');

        // Assert
        expect(updated.notes, 'New notes');
        expect(updated.id, tId);
      });

      test('should return a copy with null notes', () {
        // Act
        final updated = originalHealthLog.copyWith(notes: null);

        // Assert
        expect(updated.notes, null);
        expect(updated.id, tId);
      });

      test('should return a copy with updated createdAt', () {
        // Arrange
        final newCreatedAt = DateTime(2025, 10, 19);

        // Act
        final updated = originalHealthLog.copyWith(createdAt: newCreatedAt);

        // Assert
        expect(updated.createdAt, newCreatedAt);
        expect(updated.id, tId);
      });

      test('should return a copy with updated updatedAt', () {
        // Arrange
        final newUpdatedAt = DateTime(2025, 10, 19);

        // Act
        final updated = originalHealthLog.copyWith(updatedAt: newUpdatedAt);

        // Assert
        expect(updated.updatedAt, newUpdatedAt);
        expect(updated.id, tId);
      });

      test('should return exact copy when no parameters provided', () {
        // Act
        final copy = originalHealthLog.copyWith();

        // Assert
        expect(copy, originalHealthLog);
      });
    });

    test('should have correct props for Equatable', () {
      // Arrange
      final healthLog = HealthLog(
        id: tId,
        timestamp: tTimestamp,
        vitals: tNormalVitals,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Assert
      expect(
        healthLog.props,
        [tId, tTimestamp, tNormalVitals, tNotes, tCreatedAt, tUpdatedAt],
      );
    });

    test('should implement HealthEntry interface', () {
      // Arrange
      final healthLog = HealthLog(
        id: tId,
        timestamp: tTimestamp,
        vitals: tNormalVitals,
        notes: tNotes,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Assert
      expect(healthLog, isA<HealthEntry>());
    });
  });
}

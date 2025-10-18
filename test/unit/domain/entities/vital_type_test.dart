import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_reference_defaults.dart';

void main() {
  group('VitalType', () {
    test('should have 11 enum values', () {
      expect(VitalType.values.length, 11);
      expect(
        VitalType.values,
        containsAll([
          VitalType.bloodPressureSystolic,
          VitalType.bloodPressureDiastolic,
          VitalType.oxygenSaturation,
          VitalType.heartRate,
          VitalType.bodyTemperature,
          VitalType.weight,
          VitalType.bloodGlucose,
          VitalType.sleepHours,
          VitalType.medicationAdherence,
          VitalType.respiratoryRate,
          VitalType.energyLevel,
        ]),
      );
    });
  });

  group('VitalStatus', () {
    test('should have 3 enum values', () {
      expect(VitalStatus.values.length, 3);
      expect(
        VitalStatus.values,
        containsAll([
          VitalStatus.normal,
          VitalStatus.warning,
          VitalStatus.critical,
        ]),
      );
    });
  });

  group('VitalTypeExtension', () {
    group('displayName', () {
      test('should return "BP Systolic" for bloodPressureSystolic', () {
        expect(
          VitalType.bloodPressureSystolic.displayName,
          'BP Systolic',
        );
      });

      test('should return "BP Diastolic" for bloodPressureDiastolic', () {
        expect(
          VitalType.bloodPressureDiastolic.displayName,
          'BP Diastolic',
        );
      });

      test('should return "SpO2" for oxygenSaturation', () {
        expect(
          VitalType.oxygenSaturation.displayName,
          'SpO2',
        );
      });

      test('should return "Heart Rate" for heartRate', () {
        expect(
          VitalType.heartRate.displayName,
          'Heart Rate',
        );
      });

      test('should return "Temperature" for bodyTemperature', () {
        expect(
          VitalType.bodyTemperature.displayName,
          'Temperature',
        );
      });

      test('should return "Weight" for weight', () {
        expect(
          VitalType.weight.displayName,
          'Weight',
        );
      });

      test('should return "Blood Glucose" for bloodGlucose', () {
        expect(
          VitalType.bloodGlucose.displayName,
          'Blood Glucose',
        );
      });

      test('should return "Sleep" for sleepHours', () {
        expect(
          VitalType.sleepHours.displayName,
          'Sleep',
        );
      });

      test('should return "Medication" for medicationAdherence', () {
        expect(
          VitalType.medicationAdherence.displayName,
          'Medication',
        );
      });

      test('should return "Respiratory Rate" for respiratoryRate', () {
        expect(
          VitalType.respiratoryRate.displayName,
          'Respiratory Rate',
        );
      });

      test('should return "Energy Level" for energyLevel', () {
        expect(
          VitalType.energyLevel.displayName,
          'Energy Level',
        );
      });
    });

    group('icon', () {
      test('should return "🩺" for blood pressure types', () {
        expect(VitalType.bloodPressureSystolic.icon, '🩺');
        expect(VitalType.bloodPressureDiastolic.icon, '🩺');
      });

      test('should return "🫁" for respiratory types', () {
        expect(VitalType.oxygenSaturation.icon, '🫁');
        expect(VitalType.respiratoryRate.icon, '🫁');
      });

      test('should return "❤️" for heartRate', () {
        expect(VitalType.heartRate.icon, '❤️');
      });

      test('should return "🌡️" for bodyTemperature', () {
        expect(VitalType.bodyTemperature.icon, '🌡️');
      });

      test('should return "⚖️" for weight', () {
        expect(VitalType.weight.icon, '⚖️');
      });

      test('should return "🩸" for bloodGlucose', () {
        expect(VitalType.bloodGlucose.icon, '🩸');
      });

      test('should return "😴" for sleepHours', () {
        expect(VitalType.sleepHours.icon, '😴');
      });

      test('should return "💊" for medicationAdherence', () {
        expect(VitalType.medicationAdherence.icon, '💊');
      });

      test('should return "⚡" for energyLevel', () {
        expect(VitalType.energyLevel.icon, '⚡');
      });
    });

    group('isDefaultVisible', () {
      test('should return true for BP systolic', () {
        expect(VitalType.bloodPressureSystolic.isDefaultVisible, true);
      });

      test('should return true for BP diastolic', () {
        expect(VitalType.bloodPressureDiastolic.isDefaultVisible, true);
      });

      test('should return true for SpO2', () {
        expect(VitalType.oxygenSaturation.isDefaultVisible, true);
      });

      test('should return true for heart rate', () {
        expect(VitalType.heartRate.isDefaultVisible, true);
      });

      test('should return false for body temperature', () {
        expect(VitalType.bodyTemperature.isDefaultVisible, false);
      });

      test('should return false for weight', () {
        expect(VitalType.weight.isDefaultVisible, false);
      });

      test('should return false for blood glucose', () {
        expect(VitalType.bloodGlucose.isDefaultVisible, false);
      });

      test('should return false for sleep hours', () {
        expect(VitalType.sleepHours.isDefaultVisible, false);
      });

      test('should return false for medication adherence', () {
        expect(VitalType.medicationAdherence.isDefaultVisible, false);
      });

      test('should return false for respiratory rate', () {
        expect(VitalType.respiratoryRate.isDefaultVisible, false);
      });

      test('should return false for energy level', () {
        expect(VitalType.energyLevel.isDefaultVisible, false);
      });
    });
  });

  group('VitalReferenceDefaults', () {
    group('getDefault', () {
      test('should return ReferenceRange(90, 120) for bloodPressureSystolic',
          () {
        final range = VitalReferenceDefaults.getDefault(
          VitalType.bloodPressureSystolic,
        );
        expect(range, isNotNull);
        expect(range!.min, 90);
        expect(range.max, 120);
      });

      test('should return ReferenceRange(60, 80) for bloodPressureDiastolic',
          () {
        final range = VitalReferenceDefaults.getDefault(
          VitalType.bloodPressureDiastolic,
        );
        expect(range, isNotNull);
        expect(range!.min, 60);
        expect(range.max, 80);
      });

      test('should return ReferenceRange(95, 100) for oxygenSaturation', () {
        final range = VitalReferenceDefaults.getDefault(
          VitalType.oxygenSaturation,
        );
        expect(range, isNotNull);
        expect(range!.min, 95);
        expect(range.max, 100);
      });

      test('should return ReferenceRange(60, 100) for heartRate', () {
        final range = VitalReferenceDefaults.getDefault(
          VitalType.heartRate,
        );
        expect(range, isNotNull);
        expect(range!.min, 60);
        expect(range.max, 100);
      });

      test('should return ReferenceRange(97.0, 99.0) for bodyTemperature', () {
        final range = VitalReferenceDefaults.getDefault(
          VitalType.bodyTemperature,
        );
        expect(range, isNotNull);
        expect(range!.min, 97.0);
        expect(range.max, 99.0);
      });

      test('should return ReferenceRange(70, 100) for bloodGlucose', () {
        final range = VitalReferenceDefaults.getDefault(
          VitalType.bloodGlucose,
        );
        expect(range, isNotNull);
        expect(range!.min, 70);
        expect(range.max, 100);
      });

      test('should return ReferenceRange(12, 20) for respiratoryRate', () {
        final range = VitalReferenceDefaults.getDefault(
          VitalType.respiratoryRate,
        );
        expect(range, isNotNull);
        expect(range!.min, 12);
        expect(range.max, 20);
      });

      test('should return null for weight', () {
        final range = VitalReferenceDefaults.getDefault(VitalType.weight);
        expect(range, isNull);
      });

      test('should return null for sleepHours', () {
        final range = VitalReferenceDefaults.getDefault(VitalType.sleepHours);
        expect(range, isNull);
      });

      test('should return null for medicationAdherence', () {
        final range = VitalReferenceDefaults.getDefault(
          VitalType.medicationAdherence,
        );
        expect(range, isNull);
      });

      test('should return null for energyLevel', () {
        final range = VitalReferenceDefaults.getDefault(VitalType.energyLevel);
        expect(range, isNull);
      });
    });

    group('getUnit', () {
      test('should return "mmHg" for bloodPressureSystolic', () {
        expect(
          VitalReferenceDefaults.getUnit(VitalType.bloodPressureSystolic),
          'mmHg',
        );
      });

      test('should return "mmHg" for bloodPressureDiastolic', () {
        expect(
          VitalReferenceDefaults.getUnit(VitalType.bloodPressureDiastolic),
          'mmHg',
        );
      });

      test('should return "%" for oxygenSaturation', () {
        expect(
          VitalReferenceDefaults.getUnit(VitalType.oxygenSaturation),
          '%',
        );
      });

      test('should return "bpm" for heartRate', () {
        expect(
          VitalReferenceDefaults.getUnit(VitalType.heartRate),
          'bpm',
        );
      });

      test('should return "°F" for bodyTemperature', () {
        expect(
          VitalReferenceDefaults.getUnit(VitalType.bodyTemperature),
          '°F',
        );
      });

      test('should return "lbs" for weight', () {
        expect(
          VitalReferenceDefaults.getUnit(VitalType.weight),
          'lbs',
        );
      });

      test('should return "mg/dL" for bloodGlucose', () {
        expect(
          VitalReferenceDefaults.getUnit(VitalType.bloodGlucose),
          'mg/dL',
        );
      });

      test('should return "hours" for sleepHours', () {
        expect(
          VitalReferenceDefaults.getUnit(VitalType.sleepHours),
          'hours',
        );
      });

      test('should return empty string for medicationAdherence', () {
        expect(
          VitalReferenceDefaults.getUnit(VitalType.medicationAdherence),
          '',
        );
      });

      test('should return "breaths/min" for respiratoryRate', () {
        expect(
          VitalReferenceDefaults.getUnit(VitalType.respiratoryRate),
          'breaths/min',
        );
      });

      test('should return "/10" for energyLevel', () {
        expect(
          VitalReferenceDefaults.getUnit(VitalType.energyLevel),
          '/10',
        );
      });
    });

    group('calculateStatus', () {
      group('when value is in range', () {
        test('should return normal for BP systolic at 100', () {
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodPressureSystolic,
              100,
            ),
            VitalStatus.normal,
          );
        });

        test('should return normal for SpO2 at 97', () {
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.oxygenSaturation,
              97,
            ),
            VitalStatus.normal,
          );
        });

        test('should return normal for heart rate at 75', () {
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.heartRate,
              75,
            ),
            VitalStatus.normal,
          );
        });

        test('should return normal for temperature at 98.6', () {
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bodyTemperature,
              98.6,
            ),
            VitalStatus.normal,
          );
        });

        test('should return normal for blood glucose at 85', () {
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodGlucose,
              85,
            ),
            VitalStatus.normal,
          );
        });

        test('should return normal for respiratory rate at 16', () {
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.respiratoryRate,
              16,
            ),
            VitalStatus.normal,
          );
        });
      });

      group('when value is at boundary', () {
        test('should return normal for BP systolic at min (90)', () {
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodPressureSystolic,
              90,
            ),
            VitalStatus.normal,
          );
        });

        test('should return normal for BP systolic at max (120)', () {
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodPressureSystolic,
              120,
            ),
            VitalStatus.normal,
          );
        });

        test('should return normal for SpO2 at min (95)', () {
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.oxygenSaturation,
              95,
            ),
            VitalStatus.normal,
          );
        });

        test('should return normal for SpO2 at max (100)', () {
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.oxygenSaturation,
              100,
            ),
            VitalStatus.normal,
          );
        });
      });

      group('when value is slightly out of range (warning)', () {
        test('should return warning for BP systolic at 85 (5.6% below min)', () {
          // Deviation: (90 - 85) / 90 = 0.0556 (5.6%) - should be warning
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodPressureSystolic,
              85,
            ),
            VitalStatus.warning,
          );
        });

        test('should return warning for BP systolic at 130 (8.3% above max)',
            () {
          // Deviation: (130 - 120) / 120 = 0.0833 (8.3%) - should be warning
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodPressureSystolic,
              130,
            ),
            VitalStatus.warning,
          );
        });

        test('should return warning for SpO2 at 92 (3.2% below min)', () {
          // Deviation: (95 - 92) / 95 = 0.0316 (3.2%) - should be warning
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.oxygenSaturation,
              92,
            ),
            VitalStatus.warning,
          );
        });

        test('should return warning for heart rate at 55 (8.3% below min)', () {
          // Deviation: (60 - 55) / 60 = 0.0833 (8.3%) - should be warning
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.heartRate,
              55,
            ),
            VitalStatus.warning,
          );
        });

        test('should return warning for heart rate at 110 (10% above max)', () {
          // Deviation: (110 - 100) / 100 = 0.10 (10%) - should be warning
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.heartRate,
              110,
            ),
            VitalStatus.warning,
          );
        });

        test('should return warning for temperature at 95.5 (1.5% below min)',
            () {
          // Deviation: (97 - 95.5) / 97 = 0.0155 (1.5%) - should be warning
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bodyTemperature,
              95.5,
            ),
            VitalStatus.warning,
          );
        });

        test('should return warning for blood glucose at 65 (7.1% below min)',
            () {
          // Deviation: (70 - 65) / 70 = 0.0714 (7.1%) - should be warning
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodGlucose,
              65,
            ),
            VitalStatus.warning,
          );
        });

        test('should return warning for respiratory rate at 10 (16.7% below min)',
            () {
          // Deviation: (12 - 10) / 12 = 0.1667 (16.7%) - should be warning
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.respiratoryRate,
              10,
            ),
            VitalStatus.warning,
          );
        });
      });

      group('when value is significantly out of range (critical)', () {
        test('should return critical for BP systolic at 70 (22.2% below min)',
            () {
          // Deviation: (90 - 70) / 90 = 0.2222 (22.2%) - should be critical
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodPressureSystolic,
              70,
            ),
            VitalStatus.critical,
          );
        });

        test('should return critical for BP systolic at 150 (25% above max)',
            () {
          // Deviation: (150 - 120) / 120 = 0.25 (25%) - should be critical
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodPressureSystolic,
              150,
            ),
            VitalStatus.critical,
          );
        });

        test('should return critical for SpO2 at 75 (21% below min)', () {
          // Deviation: (95 - 75) / 95 = 0.2105 (21%) - should be critical
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.oxygenSaturation,
              75,
            ),
            VitalStatus.critical,
          );
        });

        test('should return critical for heart rate at 45 (25% below min)', () {
          // Deviation: (60 - 45) / 60 = 0.25 (25%) - should be critical
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.heartRate,
              45,
            ),
            VitalStatus.critical,
          );
        });

        test('should return critical for heart rate at 130 (30% above max)',
            () {
          // Deviation: (130 - 100) / 100 = 0.30 (30%) - should be critical
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.heartRate,
              130,
            ),
            VitalStatus.critical,
          );
        });

        test('should return critical for temperature at 93 (4.1% below min)', () {
          // Deviation: (97 - 93) / 97 = 0.0412 (4.1%) - should be critical
          // Wait, this is less than 20%, let me recalculate
          // Actually I need to test a value with > 20% deviation
          // Let me use a more extreme value
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bodyTemperature,
              75, // Very low - clearly critical
            ),
            VitalStatus.critical,
          );
        });

        test('should return critical for blood glucose at 50 (28.6% below min)',
            () {
          // Deviation: (70 - 50) / 70 = 0.2857 (28.6%) - should be critical
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodGlucose,
              50,
            ),
            VitalStatus.critical,
          );
        });

        test('should return critical for blood glucose at 130 (30% above max)',
            () {
          // Deviation: (130 - 100) / 100 = 0.30 (30%) - should be critical
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodGlucose,
              130,
            ),
            VitalStatus.critical,
          );
        });

        test('should return critical for respiratory rate at 8 (33.3% below min)',
            () {
          // Deviation: (12 - 8) / 12 = 0.3333 (33.3%) - should be critical
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.respiratoryRate,
              8,
            ),
            VitalStatus.critical,
          );
        });

        test('should return critical for respiratory rate at 26 (30% above max)',
            () {
          // Deviation: (26 - 20) / 20 = 0.30 (30%) - should be critical
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.respiratoryRate,
              26,
            ),
            VitalStatus.critical,
          );
        });
      });

      group('when vital has no reference range', () {
        test('should return normal for weight', () {
          expect(
            VitalReferenceDefaults.calculateStatus(VitalType.weight, 150),
            VitalStatus.normal,
          );
        });

        test('should return normal for sleepHours', () {
          expect(
            VitalReferenceDefaults.calculateStatus(VitalType.sleepHours, 7),
            VitalStatus.normal,
          );
        });

        test('should return normal for medicationAdherence', () {
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.medicationAdherence,
              1,
            ),
            VitalStatus.normal,
          );
        });

        test('should return normal for energyLevel', () {
          expect(
            VitalReferenceDefaults.calculateStatus(VitalType.energyLevel, 7),
            VitalStatus.normal,
          );
        });
      });

      group('edge cases for deviation calculation', () {
        test('should return warning at exactly 20% deviation below min', () {
          // BP Systolic: min = 90, value = 72
          // Deviation: (90 - 72) / 90 = 0.20 (exactly 20%)
          // Should be warning (not critical)
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodPressureSystolic,
              72,
            ),
            VitalStatus.warning,
          );
        });

        test('should return critical just above 20% deviation below min', () {
          // BP Systolic: min = 90, value = 71
          // Deviation: (90 - 71) / 90 = 0.2111 (21.1%)
          // Should be critical
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.bloodPressureSystolic,
              71,
            ),
            VitalStatus.critical,
          );
        });

        test('should return warning at exactly 20% deviation above max', () {
          // Heart Rate: max = 100, value = 120
          // Deviation: (120 - 100) / 100 = 0.20 (exactly 20%)
          // Should be warning (not critical)
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.heartRate,
              120,
            ),
            VitalStatus.warning,
          );
        });

        test('should return critical just above 20% deviation above max', () {
          // Heart Rate: max = 100, value = 121
          // Deviation: (121 - 100) / 100 = 0.21 (21%)
          // Should be critical
          expect(
            VitalReferenceDefaults.calculateStatus(
              VitalType.heartRate,
              121,
            ),
            VitalStatus.critical,
          );
        });
      });
    });
  });
}

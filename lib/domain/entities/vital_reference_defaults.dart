import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';

/// Provides default reference ranges and units for vital sign measurements.
///
/// This utility class contains medical standard reference ranges for various
/// vital signs, along with their standard units of measurement. It also
/// provides functionality to calculate the status (normal/warning/critical)
/// of a measurement based on how far it deviates from the reference range.
class VitalReferenceDefaults {
  // Private constructor to prevent instantiation
  VitalReferenceDefaults._();

  /// Returns the default medical reference range for the given [type].
  ///
  /// Returns `null` for vital types that don't have standard reference ranges:
  /// - Weight (varies too much by individual)
  /// - Sleep Hours (subjective to individual needs)
  /// - Medication Adherence (boolean value)
  /// - Energy Level (subjective scale)
  ///
  /// Reference ranges are based on medical standards:
  /// - BP Systolic: 90-120 mmHg
  /// - BP Diastolic: 60-80 mmHg
  /// - SpO2: 95-100%
  /// - Heart Rate: 60-100 bpm
  /// - Temperature: 97-99°F
  /// - Glucose: 70-100 mg/dL (fasting)
  /// - Respiratory Rate: 12-20 breaths/min
  static ReferenceRange? getDefault(VitalType type) {
    switch (type) {
      case VitalType.bloodPressureSystolic:
        return const ReferenceRange(min: 90, max: 120);
      case VitalType.bloodPressureDiastolic:
        return const ReferenceRange(min: 60, max: 80);
      case VitalType.oxygenSaturation:
        return const ReferenceRange(min: 95, max: 100);
      case VitalType.heartRate:
        return const ReferenceRange(min: 60, max: 100);
      case VitalType.bodyTemperature:
        return const ReferenceRange(min: 97.0, max: 99.0);
      case VitalType.bloodGlucose:
        return const ReferenceRange(min: 70, max: 100);
      case VitalType.respiratoryRate:
        return const ReferenceRange(min: 12, max: 20);
      case VitalType.weight:
      case VitalType.sleepHours:
      case VitalType.medicationAdherence:
      case VitalType.energyLevel:
        return null;
    }
  }

  /// Returns the standard unit of measurement for the given vital [type].
  ///
  /// Units returned:
  /// - Blood Pressure: "mmHg"
  /// - Oxygen Saturation: "%"
  /// - Heart Rate: "bpm"
  /// - Temperature: "°F"
  /// - Weight: "lbs"
  /// - Glucose: "mg/dL"
  /// - Sleep: "hours"
  /// - Medication: "" (empty, as it's boolean)
  /// - Respiratory Rate: "breaths/min"
  /// - Energy Level: "/10"
  static String getUnit(VitalType type) {
    switch (type) {
      case VitalType.bloodPressureSystolic:
      case VitalType.bloodPressureDiastolic:
        return 'mmHg';
      case VitalType.oxygenSaturation:
        return '%';
      case VitalType.heartRate:
        return 'bpm';
      case VitalType.bodyTemperature:
        return '°F';
      case VitalType.weight:
        return 'lbs';
      case VitalType.bloodGlucose:
        return 'mg/dL';
      case VitalType.sleepHours:
        return 'hours';
      case VitalType.medicationAdherence:
        return '';
      case VitalType.respiratoryRate:
        return 'breaths/min';
      case VitalType.energyLevel:
        return '/10';
    }
  }

  /// Calculates the status of a vital measurement based on its [value]
  /// and the reference range for its [type].
  ///
  /// Returns:
  /// - [VitalStatus.normal] if the value is within the reference range
  /// - [VitalStatus.warning] if the value is outside the range with deviation <= 20%
  /// - [VitalStatus.critical] if the value is outside the range with deviation > 20%
  /// - [VitalStatus.normal] if no reference range exists for this vital type
  ///
  /// Deviation is calculated as:
  /// - For values below min: `(min - value) / min`
  /// - For values above max: `(value - max) / max`
  ///
  /// This allows for proportional assessment of how far a value is from
  /// the acceptable range, which is more clinically meaningful than
  /// absolute differences.
  static VitalStatus calculateStatus(VitalType type, double value) {
    final range = getDefault(type);
    if (range == null) return VitalStatus.normal;

    if (value < range.min || value > range.max) {
      // Calculate deviation as a percentage
      final deviation = value < range.min
          ? (range.min - value) / range.min
          : (value - range.max) / range.max;

      // Critical if deviation is greater than 20%
      return deviation > 0.2 ? VitalStatus.critical : VitalStatus.warning;
    }

    return VitalStatus.normal;
  }
}

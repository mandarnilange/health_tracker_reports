import 'package:equatable/equatable.dart';
import 'reference_range.dart';

/// Represents an individual vital sign measurement taken at a specific point in time.
///
/// A vital measurement includes the type of vital being measured (e.g., blood pressure,
/// heart rate), the measured value, the unit of measurement, and a status indicating
/// whether the value is within the normal reference range.
class VitalMeasurement extends Equatable {
  /// Unique identifier for this vital measurement
  final String id;

  /// The type of vital sign being measured
  final VitalType type;

  /// The measured value
  final double value;

  /// The unit of measurement (e.g., 'mmHg', 'bpm', '%')
  final String unit;

  /// The status of the measurement (normal, warning, or critical)
  final VitalStatus status;

  /// Optional reference range for this vital measurement
  final ReferenceRange? referenceRange;

  /// Creates a [VitalMeasurement] with the given properties.
  const VitalMeasurement({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.status,
    this.referenceRange,
  });

  /// Returns `true` if the status is not normal (i.e., warning or critical).
  ///
  /// This is a convenience getter to quickly check if a vital measurement
  /// is outside the normal reference range.
  bool get isOutOfRange => status != VitalStatus.normal;

  /// Creates a copy of this vital measurement with the given fields replaced with new values.
  VitalMeasurement copyWith({
    String? id,
    VitalType? type,
    double? value,
    String? unit,
    VitalStatus? status,
    ReferenceRange? referenceRange,
  }) {
    return VitalMeasurement(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      referenceRange: referenceRange ?? this.referenceRange,
    );
  }

  @override
  List<Object?> get props => [id, type, value, unit, status, referenceRange];
}

/// Enum representing the different types of vital signs that can be measured.
enum VitalType {
  /// Systolic blood pressure (upper number in BP reading)
  bloodPressureSystolic,

  /// Diastolic blood pressure (lower number in BP reading)
  bloodPressureDiastolic,

  /// Blood oxygen saturation level (SpO2)
  oxygenSaturation,

  /// Heart rate in beats per minute
  heartRate,

  /// Body temperature
  bodyTemperature,

  /// Body weight
  weight,

  /// Blood glucose level
  bloodGlucose,

  /// Hours of sleep
  sleepHours,

  /// Whether medication was taken (boolean represented as 0 or 1)
  medicationAdherence,

  /// Respiratory rate in breaths per minute
  respiratoryRate,

  /// Self-assessed energy level on a 1-10 scale
  energyLevel,
}

/// Enum representing the status of a vital measurement relative to its reference range.
enum VitalStatus {
  /// Within the normal reference range
  normal,

  /// Slightly outside the reference range
  warning,

  /// Significantly outside the reference range
  critical,
}

/// Extension on VitalType to provide display-related properties.
extension VitalTypeExtension on VitalType {
  /// Returns the human-readable display name for the vital type.
  String get displayName {
    switch (this) {
      case VitalType.bloodPressureSystolic:
        return 'BP Systolic';
      case VitalType.bloodPressureDiastolic:
        return 'BP Diastolic';
      case VitalType.oxygenSaturation:
        return 'SpO2';
      case VitalType.heartRate:
        return 'Heart Rate';
      case VitalType.bodyTemperature:
        return 'Temperature';
      case VitalType.weight:
        return 'Weight';
      case VitalType.bloodGlucose:
        return 'Blood Glucose';
      case VitalType.sleepHours:
        return 'Sleep';
      case VitalType.medicationAdherence:
        return 'Medication';
      case VitalType.respiratoryRate:
        return 'Respiratory Rate';
      case VitalType.energyLevel:
        return 'Energy Level';
    }
  }

  /// Returns the emoji icon representing this vital type.
  String get icon {
    switch (this) {
      case VitalType.bloodPressureSystolic:
      case VitalType.bloodPressureDiastolic:
        return '🩺';
      case VitalType.oxygenSaturation:
      case VitalType.respiratoryRate:
        return '🫁';
      case VitalType.heartRate:
        return '❤️';
      case VitalType.bodyTemperature:
        return '🌡️';
      case VitalType.weight:
        return '⚖️';
      case VitalType.bloodGlucose:
        return '🩸';
      case VitalType.sleepHours:
        return '😴';
      case VitalType.medicationAdherence:
        return '💊';
      case VitalType.energyLevel:
        return '⚡';
    }
  }

  /// Returns whether this vital type should be visible by default in the UI.
  ///
  /// Default visible vitals are:
  /// - Blood Pressure (Systolic)
  /// - Blood Pressure (Diastolic)
  /// - Oxygen Saturation (SpO2)
  /// - Heart Rate
  bool get isDefaultVisible {
    return this == VitalType.bloodPressureSystolic ||
        this == VitalType.bloodPressureDiastolic ||
        this == VitalType.oxygenSaturation ||
        this == VitalType.heartRate;
  }
}

import 'package:equatable/equatable.dart';

/// Represents the reference range (normal range) for a biomarker value.
///
/// A reference range defines the minimum and maximum values that are
/// considered normal for a particular biomarker. Values outside this
/// range are considered out of range (either low or high).
class ReferenceRange extends Equatable {
  /// The minimum acceptable value for the biomarker
  final double min;

  /// The maximum acceptable value for the biomarker
  final double max;

  /// Creates a [ReferenceRange] with the given [min] and [max] values.
  const ReferenceRange({
    required this.min,
    required this.max,
  });

  /// Checks if the given [value] is outside the reference range.
  ///
  /// Returns `true` if the value is less than [min] or greater than [max].
  /// Returns `false` if the value is within the range (inclusive of boundaries).
  bool isOutOfRange(double value) {
    return value < min || value > max;
  }

  @override
  List<Object?> get props => [min, max];
}

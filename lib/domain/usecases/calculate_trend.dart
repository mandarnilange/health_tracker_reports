import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CalculateTrend {
  /// Calculates trend analysis from a list of trend data points.
  ///
  /// Requires at least 2 data points to calculate a meaningful trend.
  /// Returns [ValidationFailure] if:
  /// - The list is empty
  /// - The list has fewer than 2 data points
  /// - The first value is zero (to avoid division by zero)
  ///
  /// The trend direction is determined by percentage change:
  /// - [TrendDirection.increasing]: change > 5%
  /// - [TrendDirection.decreasing]: change < -5%
  /// - [TrendDirection.stable]: change between -5% and 5% (inclusive)
  ///
  /// Percentage change is calculated as: ((last - first) / first) * 100
  Either<Failure, TrendAnalysis> call(List<TrendDataPoint> dataPoints) {
    // Validate input
    if (dataPoints.isEmpty) {
      return const Left(
        ValidationFailure(
          message: 'Cannot calculate trend from empty data points list',
        ),
      );
    }

    if (dataPoints.length < 2) {
      return const Left(
        ValidationFailure(
          message: 'At least 2 data points are required to calculate a trend',
        ),
      );
    }

    // Get first and last values
    final firstValue = dataPoints.first.value;
    final lastValue = dataPoints.last.value;

    // Validate first value is not zero to avoid division by zero
    if (firstValue == 0.0) {
      return const Left(
        ValidationFailure(
          message: 'Cannot calculate percentage change when first value is zero',
        ),
      );
    }

    // Calculate percentage change
    final percentageChange = ((lastValue - firstValue) / firstValue) * 100;

    // Determine trend direction based on percentage change
    final direction = _determineTrendDirection(percentageChange);

    // Create and return trend analysis
    return Right(
      TrendAnalysis(
        direction: direction,
        percentageChange: percentageChange,
        firstValue: firstValue,
        lastValue: lastValue,
        dataPointsCount: dataPoints.length,
      ),
    );
  }

  /// Determines the trend direction based on percentage change.
  ///
  /// - Returns [TrendDirection.increasing] if change > 5%
  /// - Returns [TrendDirection.decreasing] if change < -5%
  /// - Returns [TrendDirection.stable] if change is between -5% and 5% (inclusive)
  TrendDirection _determineTrendDirection(double percentageChange) {
    if (percentageChange > 5.0) {
      return TrendDirection.increasing;
    } else if (percentageChange < -5.0) {
      return TrendDirection.decreasing;
    } else {
      return TrendDirection.stable;
    }
  }
}

import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/get_vital_trend.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CalculateVitalStatistics {
  final GetVitalTrend getVitalTrend;

  CalculateVitalStatistics({required this.getVitalTrend});

  Future<Either<Failure, VitalStatistics>> call(
    VitalType type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final trendResult = await getVitalTrend(
      type,
      startDate: startDate,
      endDate: endDate,
    );

    return trendResult.fold(
      Left.new,
      (measurements) {
        if (measurements.isEmpty) {
          return const Left(
            NotFoundFailure(message: 'No measurements found for vital'),
          );
        }

        final values = measurements.map((m) => m.value).toList();
        final count = values.length;

        final sum = values.reduce((a, b) => a + b);
        final average = sum / count;
        final minValue = values.reduce(min);
        final maxValue = values.reduce(max);
        final firstValue = values.first;
        final lastValue = values.last;
        final percentageChange =
            _calculatePercentageChange(firstValue, lastValue, count);
        final direction = _determineTrendDirection(percentageChange, count);

        final stats = VitalStatistics(
          average: average,
          min: minValue,
          max: maxValue,
          firstValue: firstValue,
          lastValue: lastValue,
          count: count,
          percentageChange: percentageChange,
          trendDirection: direction,
        );

        return Right(stats);
      },
    );
  }

  double _calculatePercentageChange(double first, double last, int count) {
    if (count < 2 || first == 0.0) {
      return 0.0;
    }
    return ((last - first) / first) * 100;
  }

  TrendDirection _determineTrendDirection(double percentageChange, int count) {
    if (count < 2 || percentageChange.abs() <= 5.0) {
      return TrendDirection.stable;
    }
    return percentageChange > 0 ? TrendDirection.increasing : TrendDirection.decreasing;
  }
}

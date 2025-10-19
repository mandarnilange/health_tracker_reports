import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

/// Represents the category of metric included in the trends CSV.
enum TrendMetricType {
  biomarker,
  vital,
}

extension TrendMetricTypeExtension on TrendMetricType {
  String get label {
    switch (this) {
      case TrendMetricType.biomarker:
        return 'biomarker';
      case TrendMetricType.vital:
        return 'vital';
    }
  }
}

/// A single data point used to compute trend statistics.
class TrendMetricPoint extends Equatable {
  final DateTime timestamp;
  final double value;
  final String unit;
  final bool isOutOfRange;

  const TrendMetricPoint({
    required this.timestamp,
    required this.value,
    required this.unit,
    required this.isOutOfRange,
  });

  @override
  List<Object?> get props => [timestamp, value, unit, isOutOfRange];
}

/// Collection of data points representing a single trend series.
class TrendMetricSeries extends Equatable {
  final TrendMetricType type;
  final String name;
  final List<TrendMetricPoint> points;

  const TrendMetricSeries({
    required this.type,
    required this.name,
    required this.points,
  });

  TrendMetricSeries copyWith({
    TrendMetricType? type,
    String? name,
    List<TrendMetricPoint>? points,
  }) {
    return TrendMetricSeries(
      type: type ?? this.type,
      name: name ?? this.name,
      points: points ?? this.points,
    );
  }

  @override
  List<Object?> get props => [type, name, points];
}

/// Use case for exporting pre-calculated trend statistics to CSV.
///
/// Each [TrendMetricSeries] is converted into a single row with summary metrics.
/// The CSV format matches the spec for `trends_statistics.csv`.
@lazySingleton
class ExportTrendsToCsv {
  static const String _csvHeader =
      'metric_type,metric_name,period_start,period_end,num_readings,avg_value,min_value,max_value,std_dev,trend_direction,trend_slope,first_value,last_value,pct_change,out_of_range_count,unit';
  static const String _utf8Bom = '\ufeff';

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final NumberFormat _numberFormat = NumberFormat('0.00');

  Either<Failure, String> call(List<TrendMetricSeries> seriesList) {
    try {
      final buffer = StringBuffer()
        ..write(_utf8Bom)
        ..write(_csvHeader)
        ..write('\r\n');

      for (final series in seriesList) {
        final row = _buildCsvRow(series);
        buffer
          ..write(row)
          ..write('\r\n');
      }

      return Right(buffer.toString());
    } catch (e) {
      return Left(
        ValidationFailure(message: 'Failed to export trends to CSV: $e'),
      );
    }
  }

  String _buildCsvRow(TrendMetricSeries series) {
    if (series.points.isEmpty) {
      final fields = [
        series.type.label,
        series.name,
        'N/A',
        'N/A',
        '0',
        'N/A',
        'N/A',
        'N/A',
        'N/A',
        'N/A',
        'N/A',
        'N/A',
        'N/A',
        'N/A',
        '0',
        '',
      ];

      return fields.map(_escapeCsvField).join(',');
    }

    final sortedPoints = List<TrendMetricPoint>.from(series.points)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final values = sortedPoints.map((p) => p.value).toList();
    final count = values.length;
    final sum = values.reduce((a, b) => a + b);
    final average = sum / count;
    final minValue = values.reduce(min);
    final maxValue = values.reduce(max);
    final firstValue = values.first;
    final lastValue = values.last;
    final stdDev = _calculateStandardDeviation(values);
    final unit = _resolveUnit(sortedPoints);
    final outOfRangeCount =
        sortedPoints.where((p) => p.isOutOfRange).length.toString();

    final periodStart = _dateFormat.format(sortedPoints.first.timestamp);
    final periodEnd = _dateFormat.format(sortedPoints.last.timestamp);

    final slope = _calculateSlope(firstValue, lastValue, count);
    final pctChange = _calculatePercentageChange(firstValue, lastValue, count);
    final trendDirection = _determineTrendDirection(pctChange, count);

    final fields = [
      series.type.label,
      series.name,
      periodStart,
      periodEnd,
      count.toString(),
      _formatDouble(average),
      _formatDouble(minValue),
      _formatDouble(maxValue),
      _formatDouble(stdDev),
      trendDirection,
      slope ?? 'N/A',
      _formatDouble(firstValue),
      _formatDouble(lastValue),
      pctChange ?? 'N/A',
      outOfRangeCount,
      unit,
    ];

    return fields.map(_escapeCsvField).join(',');
  }

  String _formatDouble(double value) => _numberFormat.format(value);

  String? _calculatePercentageChange(double first, double last, int count) {
    if (count < 2 || first == 0.0) {
      return null;
    }
    final change = ((last - first) / first) * 100;
    return _formatDouble(change);
  }

  String _determineTrendDirection(String? pctChange, int count) {
    if (count < 2 || pctChange == null) {
      return 'N/A';
    }

    final value = double.tryParse(pctChange);
    if (value == null) {
      return 'N/A';
    }

    if (value > 5.0) {
      return 'INCREASING';
    } else if (value < -5.0) {
      return 'DECREASING';
    }

    return 'STABLE';
  }

  String? _calculateSlope(double first, double last, int count) {
    if (count < 2) {
      return null;
    }
    final slope = (last - first) / (count - 1);
    return _formatDouble(slope);
  }

  double _calculateStandardDeviation(List<double> values) {
    if (values.length <= 1) {
      return 0.0;
    }
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values
        .map((value) => pow(value - mean, 2).toDouble())
        .reduce((a, b) => a + b);
    final variance = squaredDiffs / values.length;
    return sqrt(variance);
  }

  String _resolveUnit(List<TrendMetricPoint> points) {
    for (final point in points) {
      if (point.unit.isNotEmpty) {
        return point.unit;
      }
    }
    return '';
  }

  String _escapeCsvField(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }

    return value;
  }
}

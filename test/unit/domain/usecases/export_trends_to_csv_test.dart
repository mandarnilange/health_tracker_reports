import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';

String stripBom(String value) {
  const bom = '\ufeff';
  if (value.startsWith(bom)) {
    return value.substring(1);
  }
  return value;
}

void main() {
  late ExportTrendsToCsv usecase;

  setUp(() {
    usecase = ExportTrendsToCsv();
  });

  final tStartDate = DateTime(2025, 10, 1, 8, 0);
  final tMidDate = DateTime(2025, 11, 15, 9, 30);
  final tEndDate = DateTime(2026, 1, 10, 14, 45);

  final tBiomarkerSeries = TrendMetricSeries(
    type: TrendMetricType.biomarker,
    name: 'Glucose',
    points: [
      TrendMetricPoint(
        timestamp: tStartDate,
        value: 93.0,
        unit: 'mg/dL',
        isOutOfRange: false,
      ),
      TrendMetricPoint(
        timestamp: tMidDate,
        value: 105.0,
        unit: 'mg/dL',
        isOutOfRange: true,
      ),
      TrendMetricPoint(
        timestamp: tEndDate,
        value: 112.0,
        unit: 'mg/dL',
        isOutOfRange: true,
      ),
    ],
  );

  final tVitalSeries = TrendMetricSeries(
    type: TrendMetricType.vital,
    name: 'Heart Rate',
    points: [
      TrendMetricPoint(
        timestamp: tStartDate,
        value: 72.0,
        unit: 'bpm',
        isOutOfRange: false,
      ),
      TrendMetricPoint(
        timestamp: tMidDate,
        value: 78.0,
        unit: 'bpm',
        isOutOfRange: true,
      ),
      TrendMetricPoint(
        timestamp: tEndDate,
        value: 74.0,
        unit: 'bpm',
        isOutOfRange: false,
      ),
    ],
  );

  final tSinglePointSeries = TrendMetricSeries(
    type: TrendMetricType.biomarker,
    name: 'CRP',
    points: [
      TrendMetricPoint(
        timestamp: tEndDate,
        value: 5.0,
        unit: 'mg/L',
        isOutOfRange: false,
      ),
    ],
  );

  group('ExportTrendsToCsv', () {
    test('should export biomarker and vital trend statistics to CSV', () {
      // Arrange
      final series = [tBiomarkerSeries, tVitalSeries];

      // Act
      final result = usecase(series);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(
            csvContent,
            contains(
              'metric_type,metric_name,period_start,period_end,num_readings,avg_value,min_value,max_value,std_dev,trend_direction,trend_slope,first_value,last_value,pct_change,out_of_range_count,unit',
            ),
          );
          expect(csvContent, contains('biomarker,Glucose'));
          expect(csvContent, contains('vital,Heart Rate'));
          expect(csvContent, contains('2025-10-01 08:00:00'));
          expect(csvContent, contains('2026-01-10 14:45:00'));
          expect(csvContent, contains('3'));
          expect(csvContent, contains('103.33')); // average of biomarker values
          expect(csvContent, contains('93.00'));
          expect(csvContent, contains('112.00'));
          expect(csvContent, contains('7.85')); // std dev rounded
          expect(csvContent, contains('INCREASING'));
          expect(csvContent, contains('9.50'));
          expect(csvContent, contains('93.00'));
          expect(csvContent, contains('112.00'));
          expect(csvContent, contains('20.43'));
          expect(csvContent, contains('2')); // out of range count
          expect(csvContent, contains('mg/dL'));
        },
      );
    });

    test('should calculate trend direction and slope for vitals', () {
      // Arrange
      final series = [tVitalSeries];

      // Act
      final result = usecase(series);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          final normalized = stripBom(csvContent);
          final lines = normalized.split('\r\n').where((line) => line.isNotEmpty).toList();
          expect(lines.length, 2);
          final data = lines[1].split(',');
          expect(data[0], 'vital');
          expect(data[1], 'Heart Rate');
          expect(data[5], '74.67'); // average
          expect(data[6], '72.00'); // min
          expect(data[7], '78.00'); // max
          expect(data[8], contains(RegExp(r'^\d+\.\d{2}$'))); // std dev formatted
          // Trend slope should be (74 - 72) / (3 - 1) = 1.00
          expect(data[10], '1.00');
          expect(data[13], isNot('N/A')); // pct change should be computed
          expect(data[14], '1'); // out_of_range_count
        },
      );
    });

    test('should return N/A for trend metrics when insufficient data', () {
      // Arrange
      final series = [tSinglePointSeries];

      // Act
      final result = usecase(series);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          final normalized = stripBom(csvContent);
          final lines = normalized.split('\r\n').where((line) => line.isNotEmpty).toList();
          expect(lines.length, 2);
          final data = lines[1].split(',');
          expect(data[0], 'biomarker');
          expect(data[1], 'CRP');
          expect(data[4], '1'); // num_readings
          expect(data[8], '0.00'); // std_dev with single point
          expect(data[9], 'N/A'); // trend_direction
          expect(data[10], 'N/A'); // trend_slope
          expect(data[13], 'N/A'); // pct_change
        },
      );
    });

    test('should handle zero first value when calculating pct change', () {
      // Arrange
      final zeroStartSeries = TrendMetricSeries(
        type: TrendMetricType.biomarker,
        name: 'Triglycerides',
        points: [
          TrendMetricPoint(
            timestamp: tStartDate,
            value: 0.0,
            unit: 'mg/dL',
            isOutOfRange: false,
          ),
          TrendMetricPoint(
            timestamp: tEndDate,
            value: 150.0,
            unit: 'mg/dL',
            isOutOfRange: true,
          ),
        ],
      );

      final series = [zeroStartSeries];

      // Act
      final result = usecase(series);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          final normalized = stripBom(csvContent);
          final data = normalized.split('\r\n')[1].split(',');
          expect(data[9], 'N/A'); // trend_direction
          expect(data[10], '150.00'); // slope should still be computed
          expect(data[13], 'N/A'); // pct_change
        },
      );
    });

    test('should return headers only when no series provided', () {
      // Arrange
      final series = <TrendMetricSeries>[];

      // Act
      final result = usecase(series);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          final lines = csvContent.split('\r\n');
          expect(lines.length, 2);
          expect(
            stripBom(lines.first),
            'metric_type,metric_name,period_start,period_end,num_readings,avg_value,min_value,max_value,std_dev,trend_direction,trend_slope,first_value,last_value,pct_change,out_of_range_count,unit',
          );
        },
      );
    });

    test('should prefix UTF-8 BOM and use CRLF line endings', () {
      // Arrange
      final series = [tBiomarkerSeries];

      // Act
      final result = usecase(series);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent.startsWith('\ufeff'), isTrue);
          expect(csvContent.contains('\r\n'), isTrue);
        },
      );
    });

    test('should escape commas and quotes in metric names', () {
      // Arrange
      final specialSeries = tBiomarkerSeries.copyWith(name: 'LDL, "Bad" Cholesterol');
      final series = [specialSeries];

      // Act
      final result = usecase(series);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent, contains('"LDL, ""Bad"" Cholesterol"'));
        },
      );
    });
  });
}

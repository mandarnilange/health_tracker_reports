import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';

void main() {
  group('TrendDataPoint', () {
    final referenceRange = const ReferenceRange(min: 12.0, max: 16.0);
    final measuredAt = DateTime(2024, 5, 10);
    final biomarker = Biomarker(
      id: 'bio-1',
      name: 'Hemoglobin',
      value: 14.2,
      unit: 'g/dL',
      referenceRange: referenceRange,
      measuredAt: measuredAt,
    );

    test('supports value equality', () {
      final dataPoint1 = TrendDataPoint(
        date: measuredAt,
        value: 14.2,
        unit: 'g/dL',
        referenceRange: referenceRange,
        reportId: 'report-1',
        status: BiomarkerStatus.normal,
      );

      final dataPoint2 = TrendDataPoint(
        date: measuredAt,
        value: 14.2,
        unit: 'g/dL',
        referenceRange: referenceRange,
        reportId: 'report-1',
        status: BiomarkerStatus.normal,
      );

      expect(dataPoint1, dataPoint2);
    });

    test('creates from biomarker with matching properties', () {
      final dataPoint = TrendDataPoint.fromBiomarker(
        biomarker: biomarker,
        date: DateTime(2024, 5, 11),
        reportId: 'report-42',
      );

      expect(dataPoint.value, biomarker.value);
      expect(dataPoint.unit, biomarker.unit);
      expect(dataPoint.referenceRange, biomarker.referenceRange);
      expect(dataPoint.status, biomarker.status);
      expect(dataPoint.date, DateTime(2024, 5, 11));
      expect(dataPoint.reportId, 'report-42');
    });

    test('copyWith overrides provided fields only', () {
      final original = TrendDataPoint(
        date: measuredAt,
        value: 14.2,
        unit: 'g/dL',
        referenceRange: referenceRange,
        reportId: 'report-1',
        status: BiomarkerStatus.normal,
      );

      final updated = original.copyWith(
        value: 15.0,
        status: BiomarkerStatus.high,
      );

      expect(updated.value, 15.0);
      expect(updated.status, BiomarkerStatus.high);
      expect(updated.date, original.date);
      expect(updated.unit, original.unit);
      expect(updated.referenceRange, original.referenceRange);
      expect(updated.reportId, original.reportId);
    });
  });
}

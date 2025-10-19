import 'package:flutter_test/flutter_test.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_reports/domain/entities/summary_statistics.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_trend_summary.dart';
import 'package:health_tracker_reports/domain/entities/vital_trend_summary.dart';

void main() {
  group('DashboardCategory', () {
    const tDashboardCategory = DashboardCategory(
      status: 'Normal',
      trend: 'Stable',
      latestValue: '95 mg/dL',
    );

    test('should be a subclass of Equatable', () {
      expect(tDashboardCategory, isA<Equatable>());
    });

    test('should have correct properties', () {
      expect(tDashboardCategory.status, 'Normal');
      expect(tDashboardCategory.trend, 'Stable');
      expect(tDashboardCategory.latestValue, '95 mg/dL');
    });

    test('props should contain all properties', () {
      expect(tDashboardCategory.props, ['Normal', 'Stable', '95 mg/dL']);
    });
  });

  group('HealthStatusDashboard', () {
    const tGlucose = DashboardCategory(status: 'Normal', trend: 'Stable', latestValue: '95');
    const tLipids = DashboardCategory(status: 'High', trend: 'Worsening', latestValue: '210');
    const tDashboard = HealthStatusDashboard(
      glucoseControl: tGlucose,
      lipidPanel: tLipids,
      kidneyFunction: tGlucose, // Reusing for simplicity
      bloodPressure: tGlucose,
      cardiovascular: tGlucose,
    );

    test('should be a subclass of Equatable', () {
      expect(tDashboard, isA<Equatable>());
    });

    test('props should contain all dashboard categories', () {
      expect(tDashboard.props, [tGlucose, tLipids, tGlucose, tGlucose, tGlucose]);
    });
  });

  group('CriticalFinding', () {
    const tCriticalFinding = CriticalFinding(
      priority: 1,
      category: 'Glucose Control',
      finding: 'Fasting: 130 mg/dL',
      actionNeeded: 'Consult physician',
    );

    test('should be a subclass of Equatable', () {
      expect(tCriticalFinding, isA<Equatable>());
    });

    test('props should contain all properties', () {
      expect(tCriticalFinding.props, [1, 'Glucose Control', 'Fasting: 130 mg/dL', 'Consult physician']);
    });
  });

  group('SummaryStatistics', () {
    const tBiomarkerTrend = BiomarkerTrendSummary();
    const tVitalTrend = VitalTrendSummary();
    const tCriticalFinding = CriticalFinding(priority: 1, category: 'Test', finding: 'High', actionNeeded: 'Action');
    const tDashboard = HealthStatusDashboard(
      glucoseControl: DashboardCategory(status: 's', trend: 't', latestValue: 'v'),
      lipidPanel: DashboardCategory(status: 's', trend: 't', latestValue: 'v'),
      kidneyFunction: DashboardCategory(status: 's', trend: 't', latestValue: 'v'),
      bloodPressure: DashboardCategory(status: 's', trend: 't', latestValue: 'v'),
      cardiovascular: DashboardCategory(status: 's', trend: 't', latestValue: 'v'),
    );

    const tSummaryStatistics = SummaryStatistics(
      biomarkerTrends: [tBiomarkerTrend],
      vitalTrends: [tVitalTrend],
      criticalFindings: [tCriticalFinding],
      dashboard: tDashboard,
      totalReports: 5,
      totalHealthLogs: 50,
    );

    test('should be a subclass of Equatable', () {
      expect(tSummaryStatistics, isA<Equatable>());
    });

    test('props should contain all properties', () {
      expect(tSummaryStatistics.props, [
        [tBiomarkerTrend],
        [tVitalTrend],
        [tCriticalFinding],
        tDashboard,
        5,
        50,
      ]);
    });
  });
}
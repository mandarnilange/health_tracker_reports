import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_trend_summary.dart';
import 'package:health_tracker_reports/domain/entities/summary_statistics.dart';
import 'package:health_tracker_reports/domain/entities/vital_trend_summary.dart';

void main() {
  const biomarkerSummary = BiomarkerTrendSummary(
    biomarkerName: 'Glucose',
    trend: null,
  );

  const dashboard = HealthStatusDashboard(
    glucoseControl: DashboardCategory(status: 'High', trend: 'Up', latestValue: '120 mg/dL'),
    lipidPanel: DashboardCategory(status: 'Normal', trend: 'Stable', latestValue: '180 mg/dL'),
    kidneyFunction: DashboardCategory(status: 'Normal', trend: 'Down', latestValue: '1.0 mg/dL'),
    bloodPressure: DashboardCategory(status: 'High', trend: 'Up', latestValue: '130/85 mmHg'),
    cardiovascular: DashboardCategory(status: 'Normal', trend: 'Stable', latestValue: 'N/A'),
  );

  final summary = SummaryStatistics(
    biomarkerTrends: const [biomarkerSummary],
    vitalTrends: const [VitalTrendSummary()],
    criticalFindings: const [
      CriticalFinding(
        priority: 1,
        category: 'Glucose',
        finding: 'High fasting glucose',
        actionNeeded: 'Consult doctor',
      ),
    ],
    dashboard: dashboard,
    totalReports: 5,
    totalHealthLogs: 3,
  );

  test('copyWith overrides provided values', () {
    final updated = summary.copyWith(
      totalReports: 6,
      criticalFindings: const [],
    );

    expect(updated.totalReports, 6);
    expect(updated.criticalFindings, isEmpty);
    expect(updated.dashboard, dashboard);
  });

  test('DashboardCategory and CriticalFinding support equality', () {
    const findingA = CriticalFinding(
      priority: 1,
      category: 'BP',
      finding: 'Elevated',
      actionNeeded: 'Monitor',
    );
    const findingB = CriticalFinding(
      priority: 1,
      category: 'BP',
      finding: 'Elevated',
      actionNeeded: 'Monitor',
    );

    expect(findingA, equals(findingB));

    const category = DashboardCategory(
      status: 'Normal',
      trend: 'Stable',
      latestValue: '120 mg/dL',
    );

    expect(category.props, contains('Normal'));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/summary_statistics.dart';

void main() {
  group('BiomarkerTrendSummary', () {
    const tBiomarkerName = 'Glucose';
    const tCurrentValue = 105.0;
    const tUnit = 'mg/dL';
    const tStatus = 'Normal';
    const tTrend = 'Stable';
    const tPercentChange = 5.0;

    test('should create a valid BiomarkerTrendSummary with all fields', () {
      // Act
      const biomarkerTrend = BiomarkerTrendSummary(
        biomarkerName: tBiomarkerName,
        currentValue: tCurrentValue,
        unit: tUnit,
        status: tStatus,
        trend: tTrend,
        percentChange: tPercentChange,
      );

      // Assert
      expect(biomarkerTrend.biomarkerName, tBiomarkerName);
      expect(biomarkerTrend.currentValue, tCurrentValue);
      expect(biomarkerTrend.unit, tUnit);
      expect(biomarkerTrend.status, tStatus);
      expect(biomarkerTrend.trend, tTrend);
      expect(biomarkerTrend.percentChange, tPercentChange);
    });

    test('should create with null percentChange when no previous value', () {
      // Act
      const biomarkerTrend = BiomarkerTrendSummary(
        biomarkerName: tBiomarkerName,
        currentValue: tCurrentValue,
        unit: tUnit,
        status: tStatus,
        trend: tTrend,
        percentChange: null,
      );

      // Assert
      expect(biomarkerTrend.percentChange, isNull);
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      const trend1 = BiomarkerTrendSummary(
        biomarkerName: tBiomarkerName,
        currentValue: tCurrentValue,
        unit: tUnit,
        status: tStatus,
        trend: tTrend,
        percentChange: tPercentChange,
      );
      const trend2 = BiomarkerTrendSummary(
        biomarkerName: tBiomarkerName,
        currentValue: tCurrentValue,
        unit: tUnit,
        status: tStatus,
        trend: tTrend,
        percentChange: tPercentChange,
      );

      // Assert
      expect(trend1, trend2);
    });

    test('should not be equal when properties are different', () {
      // Arrange
      const trend1 = BiomarkerTrendSummary(
        biomarkerName: tBiomarkerName,
        currentValue: tCurrentValue,
        unit: tUnit,
        status: tStatus,
        trend: tTrend,
        percentChange: tPercentChange,
      );
      const trend2 = BiomarkerTrendSummary(
        biomarkerName: 'Cholesterol',
        currentValue: tCurrentValue,
        unit: tUnit,
        status: tStatus,
        trend: tTrend,
        percentChange: tPercentChange,
      );

      // Assert
      expect(trend1, isNot(trend2));
    });

    test('should have correct props for Equatable', () {
      // Arrange
      const biomarkerTrend = BiomarkerTrendSummary(
        biomarkerName: tBiomarkerName,
        currentValue: tCurrentValue,
        unit: tUnit,
        status: tStatus,
        trend: tTrend,
        percentChange: tPercentChange,
      );

      // Assert
      expect(
        biomarkerTrend.props,
        [
          tBiomarkerName,
          tCurrentValue,
          tUnit,
          tStatus,
          tTrend,
          tPercentChange,
        ],
      );
    });

    group('copyWith', () {
      const original = BiomarkerTrendSummary(
        biomarkerName: tBiomarkerName,
        currentValue: tCurrentValue,
        unit: tUnit,
        status: tStatus,
        trend: tTrend,
        percentChange: tPercentChange,
      );

      test('should return a copy with updated biomarkerName', () {
        // Act
        final updated = original.copyWith(biomarkerName: 'Cholesterol');

        // Assert
        expect(updated.biomarkerName, 'Cholesterol');
        expect(updated.currentValue, tCurrentValue);
      });

      test('should return a copy with updated currentValue', () {
        // Act
        final updated = original.copyWith(currentValue: 120.0);

        // Assert
        expect(updated.currentValue, 120.0);
        expect(updated.biomarkerName, tBiomarkerName);
      });

      test('should return exact copy when no parameters provided', () {
        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, original);
      });
    });
  });

  group('VitalTrendSummary', () {
    const tVitalType = 'BP Systolic';
    const tAverageValue = 120.0;
    const tUnit = 'mmHg';
    const tOutOfRangeCount = 2;
    const tTrend = 'Improving';

    test('should create a valid VitalTrendSummary with all fields', () {
      // Act
      const vitalTrend = VitalTrendSummary(
        vitalType: tVitalType,
        averageValue: tAverageValue,
        unit: tUnit,
        outOfRangeCount: tOutOfRangeCount,
        trend: tTrend,
      );

      // Assert
      expect(vitalTrend.vitalType, tVitalType);
      expect(vitalTrend.averageValue, tAverageValue);
      expect(vitalTrend.unit, tUnit);
      expect(vitalTrend.outOfRangeCount, tOutOfRangeCount);
      expect(vitalTrend.trend, tTrend);
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      const trend1 = VitalTrendSummary(
        vitalType: tVitalType,
        averageValue: tAverageValue,
        unit: tUnit,
        outOfRangeCount: tOutOfRangeCount,
        trend: tTrend,
      );
      const trend2 = VitalTrendSummary(
        vitalType: tVitalType,
        averageValue: tAverageValue,
        unit: tUnit,
        outOfRangeCount: tOutOfRangeCount,
        trend: tTrend,
      );

      // Assert
      expect(trend1, trend2);
    });

    test('should have correct props for Equatable', () {
      // Arrange
      const vitalTrend = VitalTrendSummary(
        vitalType: tVitalType,
        averageValue: tAverageValue,
        unit: tUnit,
        outOfRangeCount: tOutOfRangeCount,
        trend: tTrend,
      );

      // Assert
      expect(
        vitalTrend.props,
        [tVitalType, tAverageValue, tUnit, tOutOfRangeCount, tTrend],
      );
    });

    group('copyWith', () {
      const original = VitalTrendSummary(
        vitalType: tVitalType,
        averageValue: tAverageValue,
        unit: tUnit,
        outOfRangeCount: tOutOfRangeCount,
        trend: tTrend,
      );

      test('should return a copy with updated vitalType', () {
        // Act
        final updated = original.copyWith(vitalType: 'Heart Rate');

        // Assert
        expect(updated.vitalType, 'Heart Rate');
        expect(updated.averageValue, tAverageValue);
      });

      test('should return exact copy when no parameters provided', () {
        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, original);
      });
    });
  });

  group('CriticalFinding', () {
    const tPriority = 1;
    const tCategory = 'Glucose Control';
    const tFinding = 'Fasting: 112 mg/dL (↑12% vs 3mo)';
    const tActionNeeded = 'Consider medication adjustment';

    test('should create a valid CriticalFinding with all fields', () {
      // Act
      const finding = CriticalFinding(
        priority: tPriority,
        category: tCategory,
        finding: tFinding,
        actionNeeded: tActionNeeded,
      );

      // Assert
      expect(finding.priority, tPriority);
      expect(finding.category, tCategory);
      expect(finding.finding, tFinding);
      expect(finding.actionNeeded, tActionNeeded);
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      const finding1 = CriticalFinding(
        priority: tPriority,
        category: tCategory,
        finding: tFinding,
        actionNeeded: tActionNeeded,
      );
      const finding2 = CriticalFinding(
        priority: tPriority,
        category: tCategory,
        finding: tFinding,
        actionNeeded: tActionNeeded,
      );

      // Assert
      expect(finding1, finding2);
    });

    test('should have correct props for Equatable', () {
      // Arrange
      const finding = CriticalFinding(
        priority: tPriority,
        category: tCategory,
        finding: tFinding,
        actionNeeded: tActionNeeded,
      );

      // Assert
      expect(
        finding.props,
        [tPriority, tCategory, tFinding, tActionNeeded],
      );
    });

    group('copyWith', () {
      const original = CriticalFinding(
        priority: tPriority,
        category: tCategory,
        finding: tFinding,
        actionNeeded: tActionNeeded,
      );

      test('should return a copy with updated priority', () {
        // Act
        final updated = original.copyWith(priority: 2);

        // Assert
        expect(updated.priority, 2);
        expect(updated.category, tCategory);
      });

      test('should return exact copy when no parameters provided', () {
        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, original);
      });
    });
  });

  group('DashboardCategory', () {
    const tStatus = 'Normal';
    const tTrend = 'Stable';
    const tLatestValue = '105 mg/dL';

    test('should create a valid DashboardCategory with all fields', () {
      // Act
      const category = DashboardCategory(
        status: tStatus,
        trend: tTrend,
        latestValue: tLatestValue,
      );

      // Assert
      expect(category.status, tStatus);
      expect(category.trend, tTrend);
      expect(category.latestValue, tLatestValue);
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      const category1 = DashboardCategory(
        status: tStatus,
        trend: tTrend,
        latestValue: tLatestValue,
      );
      const category2 = DashboardCategory(
        status: tStatus,
        trend: tTrend,
        latestValue: tLatestValue,
      );

      // Assert
      expect(category1, category2);
    });

    test('should have correct props for Equatable', () {
      // Arrange
      const category = DashboardCategory(
        status: tStatus,
        trend: tTrend,
        latestValue: tLatestValue,
      );

      // Assert
      expect(category.props, [tStatus, tTrend, tLatestValue]);
    });

    group('copyWith', () {
      const original = DashboardCategory(
        status: tStatus,
        trend: tTrend,
        latestValue: tLatestValue,
      );

      test('should return a copy with updated status', () {
        // Act
        final updated = original.copyWith(status: 'High');

        // Assert
        expect(updated.status, 'High');
        expect(updated.trend, tTrend);
      });

      test('should return exact copy when no parameters provided', () {
        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, original);
      });
    });
  });

  group('HealthStatusDashboard', () {
    const tGlucoseControl = DashboardCategory(
      status: 'Normal',
      trend: 'Stable',
      latestValue: '105 mg/dL',
    );
    const tLipidPanel = DashboardCategory(
      status: 'Borderline',
      trend: 'Improving',
      latestValue: '195 mg/dL',
    );
    const tKidneyFunction = DashboardCategory(
      status: 'Normal',
      trend: 'Stable',
      latestValue: 'eGFR: 95',
    );
    const tBloodPressure = DashboardCategory(
      status: 'Normal',
      trend: 'Stable',
      latestValue: '120/80',
    );
    const tCardiovascular = DashboardCategory(
      status: 'Normal',
      trend: 'Stable',
      latestValue: 'HR: 72',
    );

    test('should create a valid HealthStatusDashboard with all fields', () {
      // Act
      const dashboard = HealthStatusDashboard(
        glucoseControl: tGlucoseControl,
        lipidPanel: tLipidPanel,
        kidneyFunction: tKidneyFunction,
        bloodPressure: tBloodPressure,
        cardiovascular: tCardiovascular,
      );

      // Assert
      expect(dashboard.glucoseControl, tGlucoseControl);
      expect(dashboard.lipidPanel, tLipidPanel);
      expect(dashboard.kidneyFunction, tKidneyFunction);
      expect(dashboard.bloodPressure, tBloodPressure);
      expect(dashboard.cardiovascular, tCardiovascular);
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      const dashboard1 = HealthStatusDashboard(
        glucoseControl: tGlucoseControl,
        lipidPanel: tLipidPanel,
        kidneyFunction: tKidneyFunction,
        bloodPressure: tBloodPressure,
        cardiovascular: tCardiovascular,
      );
      const dashboard2 = HealthStatusDashboard(
        glucoseControl: tGlucoseControl,
        lipidPanel: tLipidPanel,
        kidneyFunction: tKidneyFunction,
        bloodPressure: tBloodPressure,
        cardiovascular: tCardiovascular,
      );

      // Assert
      expect(dashboard1, dashboard2);
    });

    test('should have correct props for Equatable', () {
      // Arrange
      const dashboard = HealthStatusDashboard(
        glucoseControl: tGlucoseControl,
        lipidPanel: tLipidPanel,
        kidneyFunction: tKidneyFunction,
        bloodPressure: tBloodPressure,
        cardiovascular: tCardiovascular,
      );

      // Assert
      expect(
        dashboard.props,
        [
          tGlucoseControl,
          tLipidPanel,
          tKidneyFunction,
          tBloodPressure,
          tCardiovascular,
        ],
      );
    });

    group('copyWith', () {
      const original = HealthStatusDashboard(
        glucoseControl: tGlucoseControl,
        lipidPanel: tLipidPanel,
        kidneyFunction: tKidneyFunction,
        bloodPressure: tBloodPressure,
        cardiovascular: tCardiovascular,
      );

      test('should return a copy with updated glucoseControl', () {
        // Arrange
        const newGlucose = DashboardCategory(
          status: 'High',
          trend: 'Worsening',
          latestValue: '150 mg/dL',
        );

        // Act
        final updated = original.copyWith(glucoseControl: newGlucose);

        // Assert
        expect(updated.glucoseControl, newGlucose);
        expect(updated.lipidPanel, tLipidPanel);
      });

      test('should return exact copy when no parameters provided', () {
        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, original);
      });
    });
  });

  group('SummaryStatistics', () {
    const tBiomarkerTrends = [
      BiomarkerTrendSummary(
        biomarkerName: 'Glucose',
        currentValue: 105.0,
        unit: 'mg/dL',
        status: 'Normal',
        trend: 'Stable',
        percentChange: 5.0,
      ),
    ];
    const tVitalTrends = [
      VitalTrendSummary(
        vitalType: 'BP Systolic',
        averageValue: 120.0,
        unit: 'mmHg',
        outOfRangeCount: 2,
        trend: 'Improving',
      ),
    ];
    const tCriticalFindings = [
      CriticalFinding(
        priority: 1,
        category: 'Glucose Control',
        finding: 'Fasting: 112 mg/dL (↑12% vs 3mo)',
        actionNeeded: 'Consider medication adjustment',
      ),
    ];
    const tDashboard = HealthStatusDashboard(
      glucoseControl: DashboardCategory(
        status: 'Normal',
        trend: 'Stable',
        latestValue: '105 mg/dL',
      ),
      lipidPanel: DashboardCategory(
        status: 'Borderline',
        trend: 'Improving',
        latestValue: '195 mg/dL',
      ),
      kidneyFunction: DashboardCategory(
        status: 'Normal',
        trend: 'Stable',
        latestValue: 'eGFR: 95',
      ),
      bloodPressure: DashboardCategory(
        status: 'Normal',
        trend: 'Stable',
        latestValue: '120/80',
      ),
      cardiovascular: DashboardCategory(
        status: 'Normal',
        trend: 'Stable',
        latestValue: 'HR: 72',
      ),
    );
    const tTotalReports = 10;
    const tTotalHealthLogs = 25;

    test('should create a valid SummaryStatistics with all fields', () {
      // Act
      const statistics = SummaryStatistics(
        biomarkerTrends: tBiomarkerTrends,
        vitalTrends: tVitalTrends,
        criticalFindings: tCriticalFindings,
        dashboard: tDashboard,
        totalReports: tTotalReports,
        totalHealthLogs: tTotalHealthLogs,
      );

      // Assert
      expect(statistics.biomarkerTrends, tBiomarkerTrends);
      expect(statistics.vitalTrends, tVitalTrends);
      expect(statistics.criticalFindings, tCriticalFindings);
      expect(statistics.dashboard, tDashboard);
      expect(statistics.totalReports, tTotalReports);
      expect(statistics.totalHealthLogs, tTotalHealthLogs);
    });

    test('should create with empty lists', () {
      // Act
      const statistics = SummaryStatistics(
        biomarkerTrends: [],
        vitalTrends: [],
        criticalFindings: [],
        dashboard: tDashboard,
        totalReports: 0,
        totalHealthLogs: 0,
      );

      // Assert
      expect(statistics.biomarkerTrends, isEmpty);
      expect(statistics.vitalTrends, isEmpty);
      expect(statistics.criticalFindings, isEmpty);
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      const stats1 = SummaryStatistics(
        biomarkerTrends: tBiomarkerTrends,
        vitalTrends: tVitalTrends,
        criticalFindings: tCriticalFindings,
        dashboard: tDashboard,
        totalReports: tTotalReports,
        totalHealthLogs: tTotalHealthLogs,
      );
      const stats2 = SummaryStatistics(
        biomarkerTrends: tBiomarkerTrends,
        vitalTrends: tVitalTrends,
        criticalFindings: tCriticalFindings,
        dashboard: tDashboard,
        totalReports: tTotalReports,
        totalHealthLogs: tTotalHealthLogs,
      );

      // Assert
      expect(stats1, stats2);
    });

    test('should not be equal when properties are different', () {
      // Arrange
      const stats1 = SummaryStatistics(
        biomarkerTrends: tBiomarkerTrends,
        vitalTrends: tVitalTrends,
        criticalFindings: tCriticalFindings,
        dashboard: tDashboard,
        totalReports: tTotalReports,
        totalHealthLogs: tTotalHealthLogs,
      );
      const stats2 = SummaryStatistics(
        biomarkerTrends: tBiomarkerTrends,
        vitalTrends: tVitalTrends,
        criticalFindings: tCriticalFindings,
        dashboard: tDashboard,
        totalReports: 20, // Different
        totalHealthLogs: tTotalHealthLogs,
      );

      // Assert
      expect(stats1, isNot(stats2));
    });

    test('should have correct props for Equatable', () {
      // Arrange
      const statistics = SummaryStatistics(
        biomarkerTrends: tBiomarkerTrends,
        vitalTrends: tVitalTrends,
        criticalFindings: tCriticalFindings,
        dashboard: tDashboard,
        totalReports: tTotalReports,
        totalHealthLogs: tTotalHealthLogs,
      );

      // Assert
      expect(
        statistics.props,
        [
          tBiomarkerTrends,
          tVitalTrends,
          tCriticalFindings,
          tDashboard,
          tTotalReports,
          tTotalHealthLogs,
        ],
      );
    });

    group('copyWith', () {
      const original = SummaryStatistics(
        biomarkerTrends: tBiomarkerTrends,
        vitalTrends: tVitalTrends,
        criticalFindings: tCriticalFindings,
        dashboard: tDashboard,
        totalReports: tTotalReports,
        totalHealthLogs: tTotalHealthLogs,
      );

      test('should return a copy with updated biomarkerTrends', () {
        // Arrange
        const newTrends = [
          BiomarkerTrendSummary(
            biomarkerName: 'Cholesterol',
            currentValue: 180.0,
            unit: 'mg/dL',
            status: 'Normal',
            trend: 'Improving',
            percentChange: -10.0,
          ),
        ];

        // Act
        final updated = original.copyWith(biomarkerTrends: newTrends);

        // Assert
        expect(updated.biomarkerTrends, newTrends);
        expect(updated.vitalTrends, tVitalTrends);
      });

      test('should return a copy with updated totalReports', () {
        // Act
        final updated = original.copyWith(totalReports: 15);

        // Assert
        expect(updated.totalReports, 15);
        expect(updated.totalHealthLogs, tTotalHealthLogs);
      });

      test('should return exact copy when no parameters provided', () {
        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, original);
      });
    });
  });
}

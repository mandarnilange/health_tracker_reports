import 'package:equatable/equatable.dart';

/// Summary statistics for a doctor's report including trends and critical findings.
///
/// This entity aggregates biomarker trends, vital trends, critical findings,
/// and a health status dashboard for a given time period.
class SummaryStatistics extends Equatable {
  /// List of biomarker trend summaries
  final List<BiomarkerTrendSummary> biomarkerTrends;

  /// List of vital trend summaries
  final List<VitalTrendSummary> vitalTrends;

  /// List of critical findings requiring attention
  final List<CriticalFinding> criticalFindings;

  /// Health status dashboard with categorized summaries
  final HealthStatusDashboard dashboard;

  /// Total number of reports in the summary period
  final int totalReports;

  /// Total number of health logs in the summary period
  final int totalHealthLogs;

  /// Creates a [SummaryStatistics] with the given properties.
  const SummaryStatistics({
    required this.biomarkerTrends,
    required this.vitalTrends,
    required this.criticalFindings,
    required this.dashboard,
    required this.totalReports,
    required this.totalHealthLogs,
  });

  /// Creates a copy of this statistics with the given fields replaced with new values.
  SummaryStatistics copyWith({
    List<BiomarkerTrendSummary>? biomarkerTrends,
    List<VitalTrendSummary>? vitalTrends,
    List<CriticalFinding>? criticalFindings,
    HealthStatusDashboard? dashboard,
    int? totalReports,
    int? totalHealthLogs,
  }) {
    return SummaryStatistics(
      biomarkerTrends: biomarkerTrends ?? this.biomarkerTrends,
      vitalTrends: vitalTrends ?? this.vitalTrends,
      criticalFindings: criticalFindings ?? this.criticalFindings,
      dashboard: dashboard ?? this.dashboard,
      totalReports: totalReports ?? this.totalReports,
      totalHealthLogs: totalHealthLogs ?? this.totalHealthLogs,
    );
  }

  @override
  List<Object?> get props => [
        biomarkerTrends,
        vitalTrends,
        criticalFindings,
        dashboard,
        totalReports,
        totalHealthLogs,
      ];
}

/// Trend summary for a specific biomarker.
///
/// Includes current value, status, trend direction, and percent change.
class BiomarkerTrendSummary extends Equatable {
  /// Name of the biomarker (e.g., "Glucose", "Cholesterol")
  final String biomarkerName;

  /// Current (most recent) value
  final double currentValue;

  /// Unit of measurement
  final String unit;

  /// Status based on reference range ("Normal", "High", "Low")
  final String status;

  /// Trend direction ("Improving", "Worsening", "Stable")
  final String trend;

  /// Percent change from previous measurement
  /// Null if no previous value exists
  final double? percentChange;

  /// Creates a [BiomarkerTrendSummary] with the given properties.
  const BiomarkerTrendSummary({
    required this.biomarkerName,
    required this.currentValue,
    required this.unit,
    required this.status,
    required this.trend,
    required this.percentChange,
  });

  /// Creates a copy of this summary with the given fields replaced with new values.
  BiomarkerTrendSummary copyWith({
    String? biomarkerName,
    double? currentValue,
    String? unit,
    String? status,
    String? trend,
    double? percentChange,
  }) {
    return BiomarkerTrendSummary(
      biomarkerName: biomarkerName ?? this.biomarkerName,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      trend: trend ?? this.trend,
      percentChange: percentChange ?? this.percentChange,
    );
  }

  @override
  List<Object?> get props => [
        biomarkerName,
        currentValue,
        unit,
        status,
        trend,
        percentChange,
      ];
}

/// Trend summary for a specific vital measurement type.
///
/// Includes average value, out-of-range count, and trend direction.
class VitalTrendSummary extends Equatable {
  /// Type of vital (e.g., "BP Systolic", "Heart Rate", "Temperature")
  final String vitalType;

  /// Average value over the summary period
  final double averageValue;

  /// Unit of measurement
  final String unit;

  /// Number of measurements that were out of range
  final int outOfRangeCount;

  /// Trend direction ("Improving", "Worsening", "Stable")
  final String trend;

  /// Creates a [VitalTrendSummary] with the given properties.
  const VitalTrendSummary({
    required this.vitalType,
    required this.averageValue,
    required this.unit,
    required this.outOfRangeCount,
    required this.trend,
  });

  /// Creates a copy of this summary with the given fields replaced with new values.
  VitalTrendSummary copyWith({
    String? vitalType,
    double? averageValue,
    String? unit,
    int? outOfRangeCount,
    String? trend,
  }) {
    return VitalTrendSummary(
      vitalType: vitalType ?? this.vitalType,
      averageValue: averageValue ?? this.averageValue,
      unit: unit ?? this.unit,
      outOfRangeCount: outOfRangeCount ?? this.outOfRangeCount,
      trend: trend ?? this.trend,
    );
  }

  @override
  List<Object?> get props => [
        vitalType,
        averageValue,
        unit,
        outOfRangeCount,
        trend,
      ];
}

/// Represents a critical finding that requires attention.
///
/// Critical findings are prioritized and include recommended actions.
class CriticalFinding extends Equatable {
  /// Priority level (1 = highest, 2 = medium, 3 = low)
  final int priority;

  /// Category of the finding (e.g., "Glucose Control", "Kidney Function")
  final String category;

  /// Description of the finding (e.g., "Fasting: 112 mg/dL (↑12% vs 3mo)")
  final String finding;

  /// Recommended action to address the finding
  final String actionNeeded;

  /// Creates a [CriticalFinding] with the given properties.
  const CriticalFinding({
    required this.priority,
    required this.category,
    required this.finding,
    required this.actionNeeded,
  });

  /// Creates a copy of this finding with the given fields replaced with new values.
  CriticalFinding copyWith({
    int? priority,
    String? category,
    String? finding,
    String? actionNeeded,
  }) {
    return CriticalFinding(
      priority: priority ?? this.priority,
      category: category ?? this.category,
      finding: finding ?? this.finding,
      actionNeeded: actionNeeded ?? this.actionNeeded,
    );
  }

  @override
  List<Object?> get props => [priority, category, finding, actionNeeded];
}

/// Health status dashboard with categorized health metrics.
///
/// Provides a high-level overview of major health categories.
class HealthStatusDashboard extends Equatable {
  /// Glucose control status and trend
  final DashboardCategory glucoseControl;

  /// Lipid panel status and trend
  final DashboardCategory lipidPanel;

  /// Kidney function status and trend
  final DashboardCategory kidneyFunction;

  /// Blood pressure status and trend
  final DashboardCategory bloodPressure;

  /// Cardiovascular status and trend
  final DashboardCategory cardiovascular;

  /// Creates a [HealthStatusDashboard] with the given properties.
  const HealthStatusDashboard({
    required this.glucoseControl,
    required this.lipidPanel,
    required this.kidneyFunction,
    required this.bloodPressure,
    required this.cardiovascular,
  });

  /// Creates a copy of this dashboard with the given fields replaced with new values.
  HealthStatusDashboard copyWith({
    DashboardCategory? glucoseControl,
    DashboardCategory? lipidPanel,
    DashboardCategory? kidneyFunction,
    DashboardCategory? bloodPressure,
    DashboardCategory? cardiovascular,
  }) {
    return HealthStatusDashboard(
      glucoseControl: glucoseControl ?? this.glucoseControl,
      lipidPanel: lipidPanel ?? this.lipidPanel,
      kidneyFunction: kidneyFunction ?? this.kidneyFunction,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      cardiovascular: cardiovascular ?? this.cardiovascular,
    );
  }

  @override
  List<Object?> get props => [
        glucoseControl,
        lipidPanel,
        kidneyFunction,
        bloodPressure,
        cardiovascular,
      ];
}

/// Category in the health status dashboard.
///
/// Represents status, trend, and latest value for a health category.
class DashboardCategory extends Equatable {
  /// Current status ("Normal", "Borderline", "High")
  final String status;

  /// Trend direction ("Improving", "Stable", "Worsening")
  final String trend;

  /// Latest value as a formatted string
  final String latestValue;

  /// Creates a [DashboardCategory] with the given properties.
  const DashboardCategory({
    required this.status,
    required this.trend,
    required this.latestValue,
  });

  /// Creates a copy of this category with the given fields replaced with new values.
  DashboardCategory copyWith({
    String? status,
    String? trend,
    String? latestValue,
  }) {
    return DashboardCategory(
      status: status ?? this.status,
      trend: trend ?? this.trend,
      latestValue: latestValue ?? this.latestValue,
    );
  }

  @override
  List<Object?> get props => [status, trend, latestValue];
}

import 'package:equatable/equatable.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';

class BiomarkerTrendSummary extends Equatable {
  final String biomarkerName;
  final TrendAnalysis? trend;

  const BiomarkerTrendSummary({required this.biomarkerName, this.trend});

  @override
  List<Object?> get props => [biomarkerName, trend];
}

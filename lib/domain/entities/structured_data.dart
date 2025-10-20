import 'package:equatable/equatable.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';

class StructuredData extends Equatable {
  final DateTime reportDate;
  final String labName;
  final List<Biomarker> biomarkers;

  const StructuredData({
    required this.reportDate,
    required this.labName,
    required this.biomarkers,
  });

  @override
  List<Object?> get props => [reportDate, labName, biomarkers];
}

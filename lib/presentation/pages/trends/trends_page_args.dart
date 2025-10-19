import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';

enum TrendsTab { biomarkers, vitals }

class TrendsPageArgs {
  const TrendsPageArgs({
    this.initialTab = TrendsTab.biomarkers,
    this.initialBiomarker,
    this.initialVitalType,
  });

  final TrendsTab initialTab;
  final String? initialBiomarker;
  final VitalType? initialVitalType;
}


import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/data/datasources/local/config_local_datasource.dart';
import 'package:health_tracker_reports/data/datasources/local/report_local_datasource.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/normalize_biomarker_name.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';

void main() {
  group('Dependency Injection', () {
    test('should register all dependencies', () async {
      // Arrange
      await configureDependencies();

      // Assert
      expect(getIt.isRegistered<ConfigLocalDataSource>(), isTrue);
      expect(getIt.isRegistered<ReportLocalDataSource>(), isTrue);
      expect(getIt.isRegistered<ConfigRepository>(), isTrue);
      expect(getIt.isRegistered<ReportRepository>(), isTrue);
      expect(getIt.isRegistered<ExtractReportFromFile>(), isTrue);
      expect(getIt.isRegistered<GetAllReports>(), isTrue);
      expect(getIt.isRegistered<NormalizeBiomarkerName>(), isTrue);
      expect(getIt.isRegistered<SaveReport>(), isTrue);
    });
  });
}

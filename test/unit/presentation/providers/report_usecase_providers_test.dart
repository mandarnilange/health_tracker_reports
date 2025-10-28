import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_trend.dart';
import 'package:health_tracker_reports/domain/usecases/compare_biomarker_across_reports.dart';
import 'package:health_tracker_reports/domain/usecases/delete_report.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetAllReports extends Mock implements GetAllReports {}

class _MockGetBiomarkerTrend extends Mock implements GetBiomarkerTrend {}

class _MockSaveReport extends Mock implements SaveReport {}

class _MockDeleteReport extends Mock implements DeleteReport {}

class _MockCalculateTrend extends Mock implements CalculateTrend {}

class _MockCompareReports extends Mock implements CompareBiomarkerAcrossReports {}

void main() {
  setUp(() async {
    await getIt.reset();
  });

  test('providers expose registered report use cases', () {
    final getAll = _MockGetAllReports();
    final getTrend = _MockGetBiomarkerTrend();
    final save = _MockSaveReport();
    final delete = _MockDeleteReport();
    final calc = _MockCalculateTrend();
    final compare = _MockCompareReports();

    getIt
      ..registerSingleton<GetAllReports>(getAll)
      ..registerSingleton<GetBiomarkerTrend>(getTrend)
      ..registerSingleton<SaveReport>(save)
      ..registerSingleton<DeleteReport>(delete)
      ..registerSingleton<CalculateTrend>(calc)
      ..registerSingleton<CompareBiomarkerAcrossReports>(compare);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(getAllReportsProvider), same(getAll));
    expect(container.read(getBiomarkerTrendProvider), same(getTrend));
    expect(container.read(saveReportUseCaseProvider), same(save));
    expect(container.read(deleteReportProvider), same(delete));
    expect(container.read(calculateTrendProvider), same(calc));
    expect(
      container.read(compareBiomarkerAcrossReportsProvider),
      same(compare),
    );
  });
}

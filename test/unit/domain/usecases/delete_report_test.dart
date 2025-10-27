import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/domain/usecases/delete_report.dart';
import 'package:mocktail/mocktail.dart';

class _MockReportRepository extends Mock implements ReportRepository {}

void main() {
  group('DeleteReport', () {
    late _MockReportRepository repository;
    late DeleteReport usecase;

    setUp(() {
      repository = _MockReportRepository();
      usecase = DeleteReport(repository: repository);
    });

    test('delegates to repository', () async {
      when(() => repository.deleteReport(any())).thenAnswer((_) async => const Right(null));

      final result = await usecase('report-id');

      expect(result, const Right<Failure, void>(null));
      verify(() => repository.deleteReport('report-id')).called(1);
    });
  });
}

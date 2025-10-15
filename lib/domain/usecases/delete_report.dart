import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeleteReport {
  final ReportRepository repository;

  DeleteReport({required this.repository});

  Future<Either<Failure, void>> call(String reportId) async {
    return await repository.deleteReport(reportId);
  }
}

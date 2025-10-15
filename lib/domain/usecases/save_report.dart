import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class SaveReport {
  final ReportRepository repository;

  SaveReport({required this.repository});

  Future<Either<Failure, Report>> call(Report report) async {
    if (report.id.isEmpty) {
      final newReport = report.copyWith(id: Uuid().v4());
      return await repository.saveReport(newReport);
    } else {
      return await repository.saveReport(report);
    }
  }
}

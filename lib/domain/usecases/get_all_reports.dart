import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetAllReports {
  final ReportRepository repository;

  GetAllReports({required this.repository});

  Future<Either<Failure, List<Report>>> call() async {
    final result = await repository.getAllReports();
    return result.map((reports) {
      reports.sort((a, b) => b.date.compareTo(a.date));
      return reports;
    });
  }
}

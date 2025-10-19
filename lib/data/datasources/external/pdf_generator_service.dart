import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/summary_statistics.dart';

abstract class PdfGeneratorService {
  Future<Either<Failure, String>> generatePdf(SummaryStatistics stats);
}

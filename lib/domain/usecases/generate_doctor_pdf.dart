import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/pdf_generator_service.dart';
import 'package:health_tracker_reports/domain/entities/doctor_summary_config.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_summary_statistics.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GenerateDoctorPdf {
  final CalculateSummaryStatistics calculateSummaryStatistics;
  final PdfGeneratorService pdfGeneratorService;

  GenerateDoctorPdf({
    required this.calculateSummaryStatistics,
    required this.pdfGeneratorService,
  });

  Future<Either<Failure, String>> call(DoctorSummaryConfig config) async {
    if (config.startDate.isAfter(config.endDate)) {
      return const Left(ValidationFailure(message: 'Start date cannot be after end date'));
    }

    final statsEither = await calculateSummaryStatistics(config);

    return statsEither.fold(
      (failure) => Left(failure),
      (stats) async {
        if (stats.totalReports == 0) {
          return const Left(ValidationFailure(message: 'No reports found in the selected date range'));
        }
        return await pdfGeneratorService.generatePdf(stats, config);
      },
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file_llm.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ExtractReportFromFile {
  ExtractReportFromFile({required ExtractReportFromFileLlm delegate})
      : _delegate = delegate;

  final ExtractReportFromFileLlm _delegate;

  Future<Either<Failure, Report>> call(String filePath) {
    return _delegate(filePath);
  }
}

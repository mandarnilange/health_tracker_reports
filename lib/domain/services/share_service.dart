import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';

/// Platform-agnostic file sharing abstraction
///
/// Note: XFile is passed as dynamic to avoid platform-specific imports in domain.
/// The data layer implementation will handle the concrete XFile type.
abstract class ShareService {
  Future<Either<Failure, void>> shareFile(dynamic file);
}

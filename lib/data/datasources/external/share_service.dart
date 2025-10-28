import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/services/share_service.dart';
import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';

@LazySingleton(as: ShareService)
class ShareServiceImpl implements ShareService {
  final ShareWrapper shareWrapper;

  ShareServiceImpl({required this.shareWrapper});

  @override
  Future<Either<Failure, void>> shareFile(dynamic file) async {
    if (file is! XFile) {
      return const Left(ShareFailure(message: 'Invalid file type'));
    }
    try {
      await shareWrapper.shareXFiles([file]);
      return const Right(null);
    } catch (e) {
      return Left(ShareFailure(message: e.toString()));
    }
  }
}

abstract class ShareWrapper {
  Future<void> shareXFiles(List<XFile> files);
}

class ShareWrapperImpl implements ShareWrapper {
  @override
  Future<void> shareXFiles(List<XFile> files) {
    return Share.shareXFiles(files);
  }
}

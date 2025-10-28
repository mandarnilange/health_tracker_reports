import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/domain/services/share_service.dart';

final shareServiceProvider = Provider<ShareService>((ref) {
  return getIt<ShareService>();
});

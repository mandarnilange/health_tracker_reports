import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/usecases/create_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/delete_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_health_logs.dart';
import 'package:health_tracker_reports/domain/usecases/update_health_log.dart';

final getAllHealthLogsUseCaseProvider = Provider<GetAllHealthLogs>(
  (ref) => getIt<GetAllHealthLogs>(),
);

final createHealthLogUseCaseProvider = Provider<CreateHealthLog>(
  (ref) => getIt<CreateHealthLog>(),
);

final updateHealthLogUseCaseProvider = Provider<UpdateHealthLog>(
  (ref) => getIt<UpdateHealthLog>(),
);

final deleteHealthLogUseCaseProvider = Provider<DeleteHealthLog>(
  (ref) => getIt<DeleteHealthLog>(),
);

final healthLogsProvider =
    StateNotifierProvider<HealthLogsNotifier, AsyncValue<List<HealthLog>>>(
  (ref) => HealthLogsNotifier(
    getAllHealthLogs: ref.read(getAllHealthLogsUseCaseProvider),
    createHealthLog: ref.read(createHealthLogUseCaseProvider),
    updateHealthLog: ref.read(updateHealthLogUseCaseProvider),
    deleteHealthLog: ref.read(deleteHealthLogUseCaseProvider),
  ),
);

class HealthLogsNotifier extends StateNotifier<AsyncValue<List<HealthLog>>> {
  HealthLogsNotifier({
    required GetAllHealthLogs getAllHealthLogs,
    required CreateHealthLog createHealthLog,
    required UpdateHealthLog updateHealthLog,
    required DeleteHealthLog deleteHealthLog,
    Future<void> Function()? onDataChanged,
  })  : _getAllHealthLogs = getAllHealthLogs,
        _createHealthLog = createHealthLog,
        _updateHealthLog = updateHealthLog,
        _deleteHealthLog = deleteHealthLog,
        _onDataChanged = onDataChanged,
        super(const AsyncValue.loading()) {
    loadHealthLogs();
  }

  final GetAllHealthLogs _getAllHealthLogs;
  final CreateHealthLog _createHealthLog;
  final UpdateHealthLog _updateHealthLog;
  final DeleteHealthLog _deleteHealthLog;
  final Future<void> Function()? _onDataChanged;

  Future<void> loadHealthLogs() async {
    state = const AsyncValue.loading();
    final result = await _getAllHealthLogs();
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (logs) => AsyncValue.data(logs),
    );
  }

  Future<void> addHealthLog(CreateHealthLogParams params) async {
    final result = await _createHealthLog(params);
    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) async {
        await loadHealthLogs();
        // Trigger timeline refresh if callback is provided
        await _onDataChanged?.call();
      },
    );
  }

  Future<void> updateHealthLog(UpdateHealthLogParams params) async {
    final result = await _updateHealthLog(params);
    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) async {
        await loadHealthLogs();
        // Trigger timeline refresh if callback is provided
        await _onDataChanged?.call();
      },
    );
  }

  Future<void> deleteHealthLog(String id) async {
    final result = await _deleteHealthLog(id);
    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) async => await loadHealthLogs(),
    );
  }
}

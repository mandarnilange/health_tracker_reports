import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_vital_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/get_vital_trend.dart';

final selectedVitalTypeProvider = StateProvider<VitalType?>((ref) => null);

final getVitalTrendUseCaseProvider = Provider<GetVitalTrend>(
  (ref) => getIt<GetVitalTrend>(),
);

final calculateVitalStatisticsUseCaseProvider = Provider<CalculateVitalStatistics>(
  (ref) => getIt<CalculateVitalStatistics>(),
);

final vitalTrendProvider =
    FutureProvider.family<List<VitalMeasurement>, VitalType>((ref, vitalType) async {
  final getVitalTrend = ref.read(getVitalTrendUseCaseProvider);
  final result = await getVitalTrend(vitalType);
  return result.fold(
    (failure) => throw failure,
    (measurements) => measurements,
  );
});

final vitalStatisticsProvider =
    FutureProvider.family<VitalStatistics, VitalType>((ref, vitalType) async {
  final calculateStats = ref.read(calculateVitalStatisticsUseCaseProvider);
  final result = await calculateStats(vitalType);
  return result.fold(
    (failure) => throw failure,
    (stats) => stats,
  );
});

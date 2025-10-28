import 'dart:ui';

import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/core/utils/clock.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:health_tracker_reports/domain/usecases/create_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/delete_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_health_logs.dart';
import 'package:health_tracker_reports/domain/usecases/update_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/validate_vital_measurement.dart';
import 'package:health_tracker_reports/presentation/pages/health_log/health_log_entry_sheet.dart';
import 'package:health_tracker_reports/presentation/providers/health_log_provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HealthLogEntrySheet', () {
    late FakeHealthLogRepository repository;
    final binding = TestWidgetsFlutterBinding.ensureInitialized()
        as TestWidgetsFlutterBinding;

    setUp(() {
      repository = FakeHealthLogRepository();
      binding.window.physicalSizeTestValue = const Size(800, 1600);
      binding.window.devicePixelRatioTestValue = 1.0;
    });

    tearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    Widget buildWidget({
      required WidgetTester tester,
    }) {
      final clock = _FixedClock(DateTime(2025, 06, 01, 10, 0));
      final validate = ValidateVitalMeasurement();

      final getAll = GetAllHealthLogs(repository: repository);
      final create = CreateHealthLog(
        repository: repository,
        validateVitalMeasurement: validate,
        clock: clock,
        uuid: const Uuid(),
      );
      final update = UpdateHealthLog(
        repository: repository,
        validateVitalMeasurement: validate,
        clock: clock,
        uuid: const Uuid(),
      );
      final delete = DeleteHealthLog(repository: repository);

      return ProviderScope(
        overrides: [
          getAllHealthLogsUseCaseProvider.overrideWithValue(getAll),
          createHealthLogUseCaseProvider.overrideWithValue(create),
          updateHealthLogUseCaseProvider.overrideWithValue(update),
          deleteHealthLogUseCaseProvider.overrideWithValue(delete),
        ],
        child: const MaterialApp(
          home: _BottomSheetHost(),
        ),
      );
    }

    testWidgets('shows validation error when measurements missing',
        (tester) async {
      await tester.pumpWidget(buildWidget(tester: tester));
      await tester.pumpAndSettle();

      final scrollableFinder = find.byType(Scrollable).first;
      final saveFinder = find.text('Save Health Log', skipOffstage: false);
      expect(saveFinder, findsOneWidget);

      await tester.scrollUntilVisible(
        saveFinder,
        200,
        scrollable: scrollableFinder,
      );

      await tester.tap(saveFinder);
      await tester.pump();

      expect(
        find.text('Please enter at least one vital measurement.'),
        findsOneWidget,
      );
      expect(repository.logs, isEmpty);
    });

    testWidgets('saves health log when inputs are provided', (tester) async {
      await tester.pumpWidget(buildWidget(tester: tester));
      await tester.pumpAndSettle();

      final scrollableFinder = find.byType(Scrollable).first;

      final systolicField =
          find.widgetWithText(TextFormField, 'BP Systolic (mmHg)');
      await tester.scrollUntilVisible(
        systolicField,
        150,
        scrollable: scrollableFinder,
      );
      await tester.enterText(
        systolicField,
        '120',
      );

      final diastolicField =
          find.widgetWithText(TextFormField, 'Diastolic (mmHg)');
      await tester.scrollUntilVisible(
        diastolicField,
        150,
        scrollable: scrollableFinder,
      );
      await tester.enterText(
        diastolicField,
        '80',
      );

      final spo2Field = find.widgetWithText(TextFormField, 'SpO2 (%)');
      await tester.scrollUntilVisible(
        spo2Field,
        150,
        scrollable: scrollableFinder,
      );
      await tester.enterText(
        spo2Field,
        '98',
      );

      final saveFinder = find.text('Save Health Log', skipOffstage: false);
      expect(saveFinder, findsOneWidget);
      await tester.scrollUntilVisible(
        saveFinder,
        200,
        scrollable: scrollableFinder,
      );
      await tester.tap(saveFinder);
      await tester.pumpAndSettle();

      expect(repository.logs.length, 1);
      expect(find.text('Health log saved.'), findsOneWidget);
    });
  });
}

class FakeHealthLogRepository implements HealthLogRepository {
  final List<HealthLog> logs = [];

  @override
  Future<dartz.Either<Failure, void>> deleteHealthLog(String id) async {
    logs.removeWhere((log) => log.id == id);
    return const dartz.Right(null);
  }

  @override
  Future<dartz.Either<Failure, List<HealthLog>>> getAllHealthLogs() async {
    final sorted = List<HealthLog>.from(logs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return dartz.Right(sorted);
  }

  @override
  Future<dartz.Either<Failure, HealthLog>> getHealthLogById(String id) async {
    final log = logs.firstWhere((log) => log.id == id);
    return dartz.Right(log);
  }

  @override
  Future<dartz.Either<Failure, List<HealthLog>>> getHealthLogsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final filtered = logs
        .where((log) => !log.timestamp.isBefore(start) && !log.timestamp.isAfter(end))
        .toList();
    return dartz.Right(filtered);
  }

  @override
  Future<dartz.Either<Failure, List<VitalMeasurement>>> getVitalTrend(
    VitalType type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final measurements = <VitalMeasurement>[];
    for (final log in logs) {
      for (final vital in log.vitals) {
        if (vital.type == type) {
          measurements.add(vital);
        }
      }
    }
    return dartz.Right(measurements);
  }

  @override
  Future<dartz.Either<Failure, HealthLog>> saveHealthLog(HealthLog log) async {
    logs.add(log);
    return dartz.Right(log);
  }

  @override
  Future<dartz.Either<Failure, void>> updateHealthLog(HealthLog log) async {
    final index = logs.indexWhere((existing) => existing.id == log.id);
    if (index != -1) {
      logs[index] = log;
    }
    return const dartz.Right(null);
  }
}

class _FixedClock implements Clock {
  _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}

class _BottomSheetHost extends StatefulWidget {
  const _BottomSheetHost();

  @override
  State<_BottomSheetHost> createState() => _BottomSheetHostState();
}

class _BottomSheetHostState extends State<_BottomSheetHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      HealthLogEntrySheet.show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}

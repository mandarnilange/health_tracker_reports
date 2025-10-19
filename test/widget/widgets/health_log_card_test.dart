import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/presentation/widgets/health_log_card.dart';
import 'package:intl/intl.dart';

void main() {
  group('HealthLogCard', () {
    final timestamp = DateTime(2025, 10, 20, 7, 30);
    final log = HealthLog(
      id: 'log-1',
      timestamp: timestamp,
      vitals: const [
        VitalMeasurement(
          id: 'bp-sys',
          type: VitalType.bloodPressureSystolic,
          value: 120,
          unit: 'mmHg',
          status: VitalStatus.normal,
          referenceRange: ReferenceRange(min: 90, max: 120),
        ),
        VitalMeasurement(
          id: 'bp-dia',
          type: VitalType.bloodPressureDiastolic,
          value: 80,
          unit: 'mmHg',
          status: VitalStatus.normal,
          referenceRange: ReferenceRange(min: 60, max: 80),
        ),
        VitalMeasurement(
          id: 'spo2',
          type: VitalType.oxygenSaturation,
          value: 92,
          unit: '%',
          status: VitalStatus.warning,
          referenceRange: ReferenceRange(min: 95, max: 100),
        ),
      ],
      notes: 'Morning after workout',
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    testWidgets('renders compact vital summaries with status indicators',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthLogCard(log: log),
          ),
        ),
      );

      expect(
        find.text(DateFormat('MMM d, yyyy • h:mm a').format(timestamp)),
        findsOneWidget,
      );
      expect(find.text('BP - 120/80'), findsOneWidget);
      expect(find.text('SpO2 - 92%'), findsOneWidget);
      expect(find.byKey(const Key('vital-status-bloodPressure')), findsOneWidget);
      expect(
        find.byKey(const Key('vital-status-oxygenSaturation')),
        findsOneWidget,
      );
    });

    testWidgets('omits legacy chips and notes for a denser layout',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthLogCard(log: log),
          ),
        ),
      );

      expect(find.byType(Chip), findsNothing);
      expect(find.text('Morning after workout'), findsNothing);
    });
  });
}

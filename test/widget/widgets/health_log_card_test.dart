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
          id: 'v1',
          type: VitalType.heartRate,
          value: 78,
          unit: 'bpm',
          status: VitalStatus.normal,
          referenceRange: ReferenceRange(min: 60, max: 100),
        ),
        VitalMeasurement(
          id: 'v2',
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

    testWidgets('renders timestamp and notes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthLogCard(log: log),
          ),
        ),
      );

      expect(find.text(DateFormat('MMM d, yyyy • h:mm a').format(timestamp)),
          findsOneWidget);
      expect(find.text('Morning after workout'), findsOneWidget);
    });

    testWidgets('shows vital summary chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthLogCard(log: log),
          ),
        ),
      );

      expect(find.textContaining('Heart Rate'), findsOneWidget);
      expect(find.textContaining('78 bpm'), findsOneWidget);
      expect(find.textContaining('SpO2'), findsOneWidget);
      expect(find.textContaining('92 %'), findsOneWidget);
    });

    testWidgets('shows warning indicator for out-of-range vitals', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthLogCard(log: log),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });
}

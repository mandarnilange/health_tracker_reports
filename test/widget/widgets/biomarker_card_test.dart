import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/presentation/widgets/biomarker_card.dart';

void main() {
  group('BiomarkerCard', () {
    late Biomarker normalBiomarker;
    late Biomarker highBiomarker;
    late Biomarker lowBiomarker;

    setUp(() {
      final now = DateTime.now();
      final referenceRange = ReferenceRange(min: 10.0, max: 20.0);

      normalBiomarker = Biomarker(
        id: '1',
        name: 'Hemoglobin',
        value: 15.0,
        unit: 'g/dL',
        referenceRange: referenceRange,
        measuredAt: now,
      );

      highBiomarker = Biomarker(
        id: '2',
        name: 'Glucose',
        value: 150.0,
        unit: 'mg/dL',
        referenceRange: ReferenceRange(min: 70.0, max: 100.0),
        measuredAt: now,
      );

      lowBiomarker = Biomarker(
        id: '3',
        name: 'Iron',
        value: 5.0,
        unit: 'mcg/dL',
        referenceRange: ReferenceRange(min: 10.0, max: 30.0),
        measuredAt: now,
      );
    });

    testWidgets('displays biomarker name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerCard(biomarker: normalBiomarker),
          ),
        ),
      );

      expect(find.text('Hemoglobin'), findsOneWidget);
    });

    testWidgets('displays biomarker value with unit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerCard(biomarker: normalBiomarker),
          ),
        ),
      );

      expect(find.textContaining('15.0'), findsOneWidget);
      expect(find.textContaining('g/dL'), findsWidgets);
    });

    testWidgets('displays reference range', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerCard(biomarker: normalBiomarker),
          ),
        ),
      );

      expect(find.textContaining('10.0'), findsOneWidget);
      expect(find.textContaining('20.0'), findsOneWidget);
    });

    testWidgets('shows green background for normal biomarker',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerCard(biomarker: normalBiomarker),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Card),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(
          (container.decoration as BoxDecoration).color, Colors.green.shade50);
    });

    testWidgets('shows red background for high biomarker',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerCard(biomarker: highBiomarker),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Card),
              matching: find.byType(Container),
            )
            .first,
      );

      expect((container.decoration as BoxDecoration).color, Colors.red.shade50);
    });

    testWidgets('shows yellow background for low biomarker',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerCard(biomarker: lowBiomarker),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Card),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(
          (container.decoration as BoxDecoration).color, Colors.yellow.shade50);
    });

    testWidgets('displays status indicator for normal',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerCard(biomarker: normalBiomarker),
          ),
        ),
      );

      expect(find.textContaining('Normal'), findsOneWidget);
    });

    testWidgets('displays status indicator for high',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerCard(biomarker: highBiomarker),
          ),
        ),
      );

      expect(find.textContaining('High'), findsOneWidget);
    });

    testWidgets('displays status indicator for low',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerCard(biomarker: lowBiomarker),
          ),
        ),
      );

      expect(find.textContaining('Low'), findsOneWidget);
    });

    testWidgets('has proper elevation and margin', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerCard(biomarker: normalBiomarker),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2.0);
      expect(card.margin,
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/biomarker_selector.dart';

void main() {
  group('BiomarkerSelector', () {
    testWidgets('shows hint text when no biomarker selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerSelector(
              biomarkerNames: const ['Hemoglobin', 'Glucose'],
              selectedBiomarker: null,
              onBiomarkerSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Select a biomarker'), findsOneWidget);
    });

    testWidgets('displays all provided biomarker options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerSelector(
              biomarkerNames: const ['Hemoglobin', 'Glucose', 'Vitamin D'],
              selectedBiomarker: null,
              onBiomarkerSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Hemoglobin'), findsWidgets);
      expect(find.text('Glucose'), findsWidgets);
      expect(find.text('Vitamin D'), findsWidgets);
    });

    testWidgets('invokes callback when selection changes', (tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiomarkerSelector(
              biomarkerNames: const ['Hemoglobin', 'Glucose'],
              selectedBiomarker: null,
              onBiomarkerSelected: (value) => selected = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Glucose').last);
      await tester.pumpAndSettle();

      expect(selected, 'Glucose');
    });
  });
}

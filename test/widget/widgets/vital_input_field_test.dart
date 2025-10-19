import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/presentation/widgets/vital_input_field.dart';

void main() {
  group('VitalInputField', () {
    testWidgets('renders single value field for heart rate', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalInputField(
              type: VitalType.heartRate,
              initialValue: 78,
              onValueChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);
      expect(
        tester.widget<TextFormField>(textField).controller?.text,
        '78',
      );

      await tester.enterText(textField, '84');
      expect(changedValue, 84);
      expect(find.textContaining('bpm'), findsOneWidget);
    });

    testWidgets('renders dual fields for blood pressure', (tester) async {
      double? systolic;
      double? diastolic;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalInputField(
              type: VitalType.bloodPressureSystolic,
              initialValue: 120,
              initialSecondaryValue: 80,
              onValueChanged: (value) => systolic = value,
              onSecondaryValueChanged: (value) => diastolic = value,
            ),
          ),
        ),
      );

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(2));

      await tester.enterText(fields.at(0), '115');
      await tester.enterText(fields.at(1), '75');

      expect(systolic, 115);
      expect(diastolic, 75);
    });

    testWidgets('renders slider for energy level', (tester) async {
      double lastValue = 5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalInputField(
              type: VitalType.energyLevel,
              initialValue: 5,
              onValueChanged: (value) => lastValue = value,
            ),
          ),
        ),
      );

      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      expect(lastValue, isNonZero);
    });
  });
}

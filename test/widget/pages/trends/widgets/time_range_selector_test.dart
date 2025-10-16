import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/time_range_selector.dart';
import 'package:health_tracker_reports/presentation/providers/trend_provider.dart';

void main() {
  group('TimeRangeSelector', () {
    testWidgets('renders all time range chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeRangeSelector(
              selectedTimeRange: TimeRange.all,
              onTimeRangeSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('3M'), findsOneWidget);
      expect(find.text('6M'), findsOneWidget);
      expect(find.text('1Y'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('highlights the selected time range', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeRangeSelector(
              selectedTimeRange: TimeRange.sixMonths,
              onTimeRangeSelected: (_) {},
            ),
          ),
        ),
      );

      final selectedChip =
          tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '6M'));
      expect(selectedChip.selected, isTrue);
    });

    testWidgets('invokes callback when a new range is selected',
        (tester) async {
      TimeRange? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeRangeSelector(
              selectedTimeRange: TimeRange.all,
              onTimeRangeSelected: (range) => selected = range,
            ),
          ),
        ),
      );

      await tester.tap(find.text('3M'));
      await tester.pumpAndSettle();

      expect(selected, TimeRange.threeMonths);
    });
  });
}

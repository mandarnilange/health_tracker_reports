import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:health_tracker_reports/presentation/pages/export/doctor_pdf_config_page.dart';

void main() {
  testWidgets('DoctorPdfConfigPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DoctorPdfConfigPage(),
        ),
      ),
    );

    expect(find.text('Doctor PDF Config'), findsOneWidget);
    expect(find.text('Select Date Range'), findsOneWidget);
    expect(find.text('Start Date'), findsOneWidget);
    expect(find.text('End Date'), findsOneWidget);

    // Check initial date values (formatted as yyyy-MM-dd)
    final initialStartDate = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 30)));
    final initialEndDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    expect(find.text(initialStartDate), findsOneWidget);
    expect(find.text(initialEndDate), findsOneWidget);
  });

  // You can add more tests here to simulate tapping the date pickers
  // and verifying the date changes, but that requires mocking showDatePicker
  // which is more complex for a basic widget test.
}

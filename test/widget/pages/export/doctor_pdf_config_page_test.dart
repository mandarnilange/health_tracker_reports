import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:health_tracker_reports/presentation/pages/export/doctor_pdf_config_page.dart';

void main() {
  testWidgets('DoctorPdfConfigPage renders controls and actions',
      (tester) async {
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

    // Date pickers show initial formatted values
    final formatter = DateFormat('yyyy-MM-dd');
    expect(
      find.text(
          formatter.format(DateTime.now().subtract(const Duration(days: 30)))),
      findsOneWidget,
    );
    expect(find.text(formatter.format(DateTime.now())), findsOneWidget);

    // Toggles for PDF options
    expect(find.text('Include Vitals'), findsOneWidget);
    expect(find.text('Include Full Data Table'), findsOneWidget);

    // Action buttons
    expect(find.text('Generate PDF'), findsOneWidget);
    expect(find.text('Generate & Share'), findsOneWidget);
  });
}

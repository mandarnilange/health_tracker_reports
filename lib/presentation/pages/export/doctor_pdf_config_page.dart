import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_tracker_reports/domain/usecases/generate_doctor_pdf.dart';
import 'package:health_tracker_reports/data/datasources/external/share_service.dart';
import 'package:health_tracker_reports/domain/entities/doctor_summary_config.dart';
import 'package:share_plus/share_plus.dart';
import 'package:health_tracker_reports/presentation/providers/share_provider.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/presentation/providers/generate_doctor_pdf_provider.dart';

class DoctorPdfConfigPage extends ConsumerStatefulWidget {
  const DoctorPdfConfigPage({super.key});

  @override
  ConsumerState<DoctorPdfConfigPage> createState() => _DoctorPdfConfigPageState();
}

class _DoctorPdfConfigPageState extends ConsumerState<DoctorPdfConfigPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor PDF Config'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final generatePdf = ref.read(generateDoctorPdfProvider);
              final shareService = ref.read(shareServiceProvider);
              final config = DoctorSummaryConfig(
                startDate: _startDate,
                endDate: _endDate,
                selectedReportIds: [], // TODO: Implement report selection
                includeVitals: true, // TODO: Implement toggle
                includeFullDataTable: false, // TODO: Implement toggle
              );

              final result = await generatePdf(config);
              result.fold(
                (failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(failure.message)),
                  );
                },
                (filePath) async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PDF saved to: $filePath')),
                  );
                  await shareService.shareFile(XFile(filePath));
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date Range', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start Date'),
                      TextButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null && picked != _startDate) {
                            setState(() {
                              _startDate = picked;
                            });
                          }
                        },
                        child: Text(formatter.format(_startDate)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('End Date'),
                      TextButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null && picked != _endDate) {
                            setState(() {
                              _endDate = picked;
                            });
                          }
                        },
                        child: Text(formatter.format(_endDate)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

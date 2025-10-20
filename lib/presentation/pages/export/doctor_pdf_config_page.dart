import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_tracker_reports/domain/entities/doctor_summary_config.dart';
import 'package:share_plus/share_plus.dart';
import 'package:health_tracker_reports/presentation/providers/share_provider.dart';
import 'package:health_tracker_reports/presentation/providers/generate_doctor_pdf_provider.dart';

class DoctorPdfConfigPage extends ConsumerStatefulWidget {
  const DoctorPdfConfigPage({super.key});

  @override
  ConsumerState<DoctorPdfConfigPage> createState() =>
      _DoctorPdfConfigPageState();
}

class _DoctorPdfConfigPageState extends ConsumerState<DoctorPdfConfigPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _includeVitals = true;
  bool _includeFullTable = false;
  bool _isGenerating = false;
  _DoctorPdfAction? _activeAction;

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor PDF Config'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Select Date Range',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DatePickerTile(
                    label: 'Start Date',
                    value: formatter.format(_startDate),
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DatePickerTile(
                    label: 'End Date',
                    value: formatter.format(_endDate),
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Include Vitals'),
              value: _includeVitals,
              onChanged: (value) => setState(() => _includeVitals = value),
            ),
            SwitchListTile(
              title: const Text('Include Full Data Table'),
              value: _includeFullTable,
              onChanged: (value) => setState(() => _includeFullTable = value),
            ),
            const SizedBox(height: 24),
            if (_isGenerating)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: const [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: Text('Generating PDF…')),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _buildButtonIcon(_DoctorPdfAction.generate),
                label: const Text('Generate PDF'),
                onPressed: _isGenerating
                    ? null
                    : () => _handleGenerate(shareAfter: false),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: _buildButtonIcon(_DoctorPdfAction.share),
                label: const Text('Generate & Share'),
                onPressed: _isGenerating
                    ? null
                    : () => _handleGenerate(shareAfter: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonIcon(_DoctorPdfAction action) {
    final isActive = _isGenerating && _activeAction == action;
    if (isActive) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    switch (action) {
      case _DoctorPdfAction.generate:
        return const Icon(Icons.download);
      case _DoctorPdfAction.share:
        return const Icon(Icons.share);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = picked;
        if (_startDate.isAfter(_endDate)) {
          _startDate = _endDate;
        }
      }
    });
  }

  Future<void> _handleGenerate({required bool shareAfter}) async {
    setState(() {
      _isGenerating = true;
      _activeAction =
          shareAfter ? _DoctorPdfAction.share : _DoctorPdfAction.generate;
    });

    final config = DoctorSummaryConfig(
      startDate: _startDate,
      endDate: _endDate,
      selectedReportIds: const [], // Future enhancement: allow report selection
      includeVitals: _includeVitals,
      includeFullDataTable: _includeFullTable,
    );

    final generatePdf = ref.read(generateDoctorPdfProvider);
    final result = await generatePdf(config);

    if (!mounted) return;

    await result.fold(
      (failure) async {
        _showSnack(failure.message);
      },
      (filePath) async {
        _showSnack('PDF saved to: $filePath');

        if (shareAfter) {
          final shareService = ref.read(shareServiceProvider);
          final shareResult = await shareService.shareFile(XFile(filePath));
          shareResult.fold(
            (failure) => _showSnack(failure.message),
            (_) {},
          );
        }
      },
    );

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _activeAction = null;
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        OutlinedButton(
          onPressed: onTap,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(value),
          ),
        ),
      ],
    );
  }
}

enum _DoctorPdfAction { generate, share }

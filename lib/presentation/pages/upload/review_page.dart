import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:intl/intl.dart';

/// Page that allows users to review and edit extracted biomarker data before saving.
class ReviewPage extends ConsumerStatefulWidget {
  const ReviewPage({super.key, required this.initialReport});

  final Report initialReport;

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _labNameController;
  late TextEditingController _notesController;
  late List<TextEditingController> _valueControllers;
  late List<TextEditingController> _unitControllers;
  late List<TextEditingController> _minControllers;
  late List<TextEditingController> _maxControllers;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final report = widget.initialReport;

    _labNameController = TextEditingController(text: report.labName);
    _notesController = TextEditingController(text: report.notes ?? '');

    _valueControllers = report.biomarkers
        .map((biomarker) => TextEditingController(
              text: biomarker.value.toString(),
            ))
        .toList();
    _unitControllers = report.biomarkers
        .map((biomarker) => TextEditingController(text: biomarker.unit))
        .toList();
    _minControllers = report.biomarkers
        .map(
          (biomarker) => TextEditingController(
            text: biomarker.referenceRange.min.toString(),
          ),
        )
        .toList();
    _maxControllers = report.biomarkers
        .map(
          (biomarker) => TextEditingController(
            text: biomarker.referenceRange.max.toString(),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _labNameController.dispose();
    _notesController.dispose();
    for (final controller in [
      ..._valueControllers,
      ..._unitControllers,
      ..._minControllers,
      ..._maxControllers,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.initialReport;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Report'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            key: const Key('labNameField'),
                            controller: _labNameController,
                            decoration: const InputDecoration(
                              labelText: 'Lab name',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the lab name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            DateFormat.yMMMMd().format(report.date),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Notes (optional)',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Biomarkers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < report.biomarkers.length; i++) ...[
                    _BiomarkerEditorCard(
                      index: i,
                      biomarker: report.biomarkers[i],
                      valueController: _valueControllers[i],
                      unitController: _unitControllers[i],
                      minController: _minControllers[i],
                      maxController: _maxControllers[i],
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      child: const Text('Save Report'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedBiomarkers = <Biomarker>[];

    for (var i = 0; i < widget.initialReport.biomarkers.length; i++) {
      final original = widget.initialReport.biomarkers[i];
      final parsedValue = double.tryParse(_valueControllers[i].text.trim());
      final parsedMin = double.tryParse(_minControllers[i].text.trim());
      final parsedMax = double.tryParse(_maxControllers[i].text.trim());

      if (parsedValue == null || parsedMin == null || parsedMax == null) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Please ensure all numeric fields contain numbers'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final updatedBiomarker = original.copyWith(
        value: parsedValue,
        unit: _unitControllers[i].text.trim().isEmpty
            ? original.unit
            : _unitControllers[i].text.trim(),
        referenceRange: ReferenceRange(
          min: parsedMin,
          max: parsedMax,
        ),
      );

      updatedBiomarkers.add(updatedBiomarker);
    }

    final updatedReport = widget.initialReport.copyWith(
      labName: _labNameController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      biomarkers: updatedBiomarkers,
      updatedAt: DateTime.now(),
    );

    final result =
        await ref.read(reportsProvider.notifier).saveReport(updatedReport);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save report: ${failure.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report saved successfully!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.of(context).pop();
      },
    );
  }
}

class _BiomarkerEditorCard extends StatelessWidget {
  const _BiomarkerEditorCard({
    required this.index,
    required this.biomarker,
    required this.valueController,
    required this.unitController,
    required this.minController,
    required this.maxController,
  });

  final int index;
  final Biomarker biomarker;
  final TextEditingController valueController;
  final TextEditingController unitController;
  final TextEditingController minController;
  final TextEditingController maxController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              biomarker.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: Key('valueField-$index'),
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Value',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a value';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: Key('unitField-$index'),
              controller: unitController,
              decoration: const InputDecoration(
                labelText: 'Unit',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: Key('minField-$index'),
                    controller: minController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reference min',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter min';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: Key('maxField-$index'),
                    controller: maxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reference max',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter max';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
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

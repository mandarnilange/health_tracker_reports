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
  late List<bool> _isEditingList;

  bool _isSaving = false;
  bool _isEditingHeader = false;

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
    _isEditingList = List.filled(report.biomarkers.length, false);
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
        actions: [
          if (!_isSaving)
            TextButton.icon(
              onPressed: _handleSave,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card - compact display
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lab',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                if (!_isEditingHeader)
                                  Text(
                                    _labNameController.text,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  )
                                else
                                  TextFormField(
                                    key: const Key('labNameField'),
                                    controller: _labNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Lab name',
                                      isDense: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter the lab name';
                                      }
                                      return null;
                                    },
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            key: const Key('editHeaderButton'),
                            icon: Icon(_isEditingHeader ? Icons.check : Icons.edit),
                            onPressed: () {
                              setState(() {
                                _isEditingHeader = !_isEditingHeader;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat.yMMMMd().format(report.date),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      if (_isEditingHeader) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            isDense: true,
                          ),
                        ),
                      ] else if (_notesController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _notesController.text,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Biomarkers section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Biomarkers (${report.biomarkers.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Tap to edit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Compact biomarker list
              for (var i = 0; i < report.biomarkers.length; i++) ...[
                _BiomarkerCompactCard(
                  index: i,
                  biomarker: report.biomarkers[i],
                  valueController: _valueControllers[i],
                  unitController: _unitControllers[i],
                  minController: _minControllers[i],
                  maxController: _maxControllers[i],
                  isEditing: _isEditingList[i],
                  onToggleEdit: () {
                    setState(() {
                      _isEditingList[i] = !_isEditingList[i];
                    });
                  },
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fix errors before saving'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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

class _BiomarkerCompactCard extends StatelessWidget {
  const _BiomarkerCompactCard({
    required this.index,
    required this.biomarker,
    required this.valueController,
    required this.unitController,
    required this.minController,
    required this.maxController,
    required this.isEditing,
    required this.onToggleEdit,
  });

  final int index;
  final Biomarker biomarker;
  final TextEditingController valueController;
  final TextEditingController unitController;
  final TextEditingController minController;
  final TextEditingController maxController;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    final status = biomarker.status;
    final statusColor = _getStatusColor(status);

    return Card(
      child: InkWell(
        onTap: isEditing ? null : onToggleEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      biomarker.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isEditing ? Icons.expand_less : Icons.edit,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (!isEditing) ...[
                // Compact view
                Row(
                  children: [
                    Text(
                      '${biomarker.value.toStringAsFixed(1)} ${biomarker.unit}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '(${biomarker.referenceRange.min.toStringAsFixed(1)}-${biomarker.referenceRange.max.toStringAsFixed(1)})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ] else ...[
                // Edit mode
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        key: Key('valueField-$index'),
                        controller: valueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Value',
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        key: Key('unitField-$index'),
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
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
                          labelText: 'Min',
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        key: Key('maxField-$index'),
                        controller: maxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max',
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onToggleEdit,
                    child: const Text('Done'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BiomarkerStatus status) {
    switch (status) {
      case BiomarkerStatus.normal:
        return Colors.green;
      case BiomarkerStatus.high:
        return Colors.red;
      case BiomarkerStatus.low:
        return Colors.orange;
    }
  }

  String _getStatusText(BiomarkerStatus status) {
    switch (status) {
      case BiomarkerStatus.normal:
        return 'Normal';
      case BiomarkerStatus.high:
        return 'High';
      case BiomarkerStatus.low:
        return 'Low';
    }
  }
}

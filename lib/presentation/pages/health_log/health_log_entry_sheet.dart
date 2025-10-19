import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_reference_defaults.dart';
import 'package:health_tracker_reports/domain/usecases/create_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/update_health_log.dart';
import 'package:health_tracker_reports/presentation/providers/health_log_provider.dart';
import 'package:health_tracker_reports/presentation/widgets/vital_input_field.dart';
import 'package:intl/intl.dart';

class HealthLogEntrySheet extends ConsumerStatefulWidget {
  const HealthLogEntrySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const HealthLogEntrySheet(),
    );
  }

  @override
  ConsumerState<HealthLogEntrySheet> createState() => _HealthLogEntrySheetState();
}

class _HealthLogEntrySheetState extends ConsumerState<HealthLogEntrySheet> {
  final Map<VitalType, _VitalValue> _values = {};
  final Set<VitalType> _selectedVitals = {
    VitalType.bloodPressureSystolic,
    VitalType.oxygenSaturation,
    VitalType.heartRate,
  };
  late DateTime _timestamp;
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _timestamp = DateTime.now();
    _ensureValue(VitalType.bloodPressureSystolic);
    _ensureValue(VitalType.oxygenSaturation);
    _ensureValue(VitalType.heartRate);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.5,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Scaffold(
            body: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildVitalList(context),
                  const SizedBox(height: 16),
                  _buildAddVitalButton(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _onSave,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Health Log'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final formatted = DateFormat('MMM d, yyyy • h:mm a').format(_timestamp);
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Vitals', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(formatted, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: _pickDateTime,
          icon: const Icon(Icons.edit_calendar_outlined),
          tooltip: 'Edit timestamp',
        ),
      ],
    );
  }

  Widget _buildVitalList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _selectedVitals.map((type) {
        final value = _values[type]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: VitalInputField(
            type: type,
            initialValue: value.primary,
            initialSecondaryValue: value.secondary,
            onValueChanged: (v) {
              setState(() {
                value.primary = v;
                value.status = _calculateStatus(type, v);
              });
            },
            onSecondaryValueChanged: (v) {
              setState(() {
                value.secondary = v;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddVitalButton() {
    final remaining = VitalType.values.where((type) {
      if (type == VitalType.bloodPressureDiastolic) {
        return false;
      }
      return !_selectedVitals.contains(type);
    }).toList();

    if (remaining.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<VitalType>(
      onSelected: (type) {
        setState(() {
          _selectedVitals.add(type);
          _ensureValue(type);
        });
      },
      itemBuilder: (context) => remaining
          .map(
            (type) => PopupMenuItem(
              value: type,
              child: Text(type.displayName),
            ),
          )
          .toList(),
      child: const Chip(
        label: Text('Add Another Vital'),
        avatar: Icon(Icons.add),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final context = this.context;
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );

    if (!mounted) return;

    setState(() {
      _timestamp = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _timestamp.hour,
        time?.minute ?? _timestamp.minute,
      );
    });
  }

  Future<void> _onSave() async {
    final messenger = ScaffoldMessenger.of(context);
    if (!_validateInputs()) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter values for all vitals.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final params = CreateHealthLogParams(
      timestamp: _timestamp,
      vitals: _buildVitalInputs(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await ref.read(healthLogsProvider.notifier).addHealthLog(params);

    if (!mounted) return;

    final state = ref.read(healthLogsProvider);
    setState(() => _isSaving = false);

    state.when(
      data: (_) {
        Navigator.of(context).pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Health log saved.')),
        );
      },
      loading: () {},
      error: (error, _) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to save log: $error')),
        );
      },
    );
  }

  bool _validateInputs() {
    for (final type in _selectedVitals) {
      final value = _values[type]!;
      if (!_hasSecondaryField(type)) {
        if (value.primary == null) return false;
      } else {
        if (value.primary == null || value.secondary == null) return false;
      }
    }
    return true;
  }

  List<VitalMeasurementInput> _buildVitalInputs() {
    final inputs = <VitalMeasurementInput>[];

    for (final type in _selectedVitals) {
      final value = _values[type]!;
      if (type == VitalType.bloodPressureSystolic) {
        inputs.addAll([
          VitalMeasurementInput(type: VitalType.bloodPressureSystolic, value: value.primary!),
          VitalMeasurementInput(type: VitalType.bloodPressureDiastolic, value: value.secondary!),
        ]);
      } else {
        inputs.add(
          VitalMeasurementInput(
            type: type,
            value: value.primary!,
            referenceRange: value.referenceRange,
          ),
        );
      }
    }

    return inputs;
  }

  void _ensureValue(VitalType type) {
    _values.putIfAbsent(type, () => _VitalValue(type));
  }

  bool _hasSecondaryField(VitalType type) => type == VitalType.bloodPressureSystolic;

  VitalStatus _calculateStatus(VitalType type, double value) {
    return VitalReferenceDefaults.calculateStatus(type, value);
  }
}

class _VitalValue {
  _VitalValue(this.type) {
    referenceRange = VitalReferenceDefaults.getDefault(type);
    primary = null;
    secondary = null;
  }

  final VitalType type;
  double? primary;
  double? secondary;
  ReferenceRange? referenceRange;
  VitalStatus status = VitalStatus.normal;
}

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_reference_defaults.dart';
import 'package:health_tracker_reports/domain/usecases/create_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/update_health_log.dart';
import 'package:health_tracker_reports/presentation/providers/health_log_provider.dart';
import 'package:health_tracker_reports/presentation/widgets/vital_input_field.dart';
import 'package:intl/intl.dart';

class HealthLogEntrySheet extends ConsumerStatefulWidget {
  const HealthLogEntrySheet({super.key, this.initialLog});

  final HealthLog? initialLog;

  static Future<void> show(BuildContext context, {HealthLog? initialLog}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => HealthLogEntrySheet(initialLog: initialLog),
    );
  }

  @override
  ConsumerState<HealthLogEntrySheet> createState() =>
      _HealthLogEntrySheetState();
}

class _HealthLogEntrySheetState extends ConsumerState<HealthLogEntrySheet> {
  final Map<VitalType, _VitalValue> _values = {};
  late final LinkedHashSet<VitalType> _selectedVitals;
  late DateTime _timestamp;
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;
  bool get _isEditing => widget.initialLog != null;

  @override
  void initState() {
    super.initState();
    _selectedVitals = LinkedHashSet<VitalType>();
    if (widget.initialLog != null) {
      _initialiseFromLog(widget.initialLog!);
    } else {
      _timestamp = DateTime.now();
      _addDefaultVitals();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.5,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildVitalList(context),
              const SizedBox(height: 16),
              _buildAddVitalButton(),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any notes about this reading...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
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
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
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
            Text('Log Vitals',
                style: Theme.of(context).textTheme.headlineSmall),
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
        const SnackBar(
            content: Text('Please enter at least one vital measurement.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();
    final inputs = _buildVitalInputs();
    final notifier = ref.read(healthLogsProvider.notifier);

    if (_isEditing) {
      final initial = widget.initialLog!;
      final params = UpdateHealthLogParams(
        id: initial.id,
        timestamp: _timestamp,
        createdAt: initial.createdAt,
        vitals: inputs,
        notes: notes,
      );
      await notifier.updateHealthLog(params);
    } else {
      final params = CreateHealthLogParams(
        timestamp: _timestamp,
        vitals: inputs,
        notes: notes,
      );
      await notifier.addHealthLog(params);
    }

    if (!mounted) return;

    final state = ref.read(healthLogsProvider);
    setState(() => _isSaving = false);

    state.when(
      data: (_) {
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Health log updated.' : 'Health log saved.',
            ),
          ),
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
    // At least one vital should have a value
    bool hasAtLeastOne = false;

    for (final type in _selectedVitals) {
      final value = _values[type]!;
      if (!_hasSecondaryField(type)) {
        if (value.primary != null) {
          hasAtLeastOne = true;
        }
      } else {
        // For BP, both systolic and diastolic must be provided if any
        if (value.primary != null && value.secondary != null) {
          hasAtLeastOne = true;
        } else if (value.primary != null || value.secondary != null) {
          // If only one BP value is provided, it's invalid
          return false;
        }
      }
    }

    return hasAtLeastOne;
  }

  List<VitalMeasurementInput> _buildVitalInputs() {
    final inputs = <VitalMeasurementInput>[];

    for (final type in _selectedVitals) {
      final value = _values[type]!;
      if (type == VitalType.bloodPressureSystolic) {
        if (value.primary != null && value.secondary != null) {
          inputs.addAll([
            VitalMeasurementInput(
              id: value.primaryId,
              type: VitalType.bloodPressureSystolic,
              value: value.primary!,
              unit: value.unit,
              referenceRange: value.referenceRange,
            ),
            VitalMeasurementInput(
              id: value.secondaryId,
              type: VitalType.bloodPressureDiastolic,
              value: value.secondary!,
              unit: value.secondaryUnit ?? 'mmHg',
              referenceRange: value.secondaryReferenceRange,
            ),
          ]);
        }
      } else {
        if (value.primary != null) {
          inputs.add(
            VitalMeasurementInput(
              id: value.primaryId,
              type: type,
              value: value.primary!,
              unit: value.unit,
              referenceRange: value.referenceRange,
            ),
          );
        }
      }
    }

    return inputs;
  }

  void _ensureValue(VitalType type) {
    _values.putIfAbsent(type, () => _VitalValue(type));
  }

  bool _hasSecondaryField(VitalType type) =>
      type == VitalType.bloodPressureSystolic;

  VitalStatus _calculateStatus(VitalType type, double value) {
    return VitalReferenceDefaults.calculateStatus(type, value);
  }

  void _addDefaultVitals() {
    _selectedVitals
      ..add(VitalType.bloodPressureSystolic)
      ..add(VitalType.oxygenSaturation)
      ..add(VitalType.heartRate);
    for (final type in _selectedVitals) {
      _ensureValue(type);
    }
  }

  void _initialiseFromLog(HealthLog log) {
    _timestamp = log.timestamp;
    if (log.notes != null) {
      _notesController.text = log.notes!;
    }

    final vitalsByType = <VitalType, VitalMeasurement>{};
    for (final vital in log.vitals) {
      vitalsByType[vital.type] = vital;
    }

    if (vitalsByType.containsKey(VitalType.bloodPressureSystolic) ||
        vitalsByType.containsKey(VitalType.bloodPressureDiastolic)) {
      _selectedVitals.add(VitalType.bloodPressureSystolic);
      _ensureValue(VitalType.bloodPressureSystolic);
      final systolic = vitalsByType[VitalType.bloodPressureSystolic];
      final diastolic = vitalsByType[VitalType.bloodPressureDiastolic];
      final value = _values[VitalType.bloodPressureSystolic]!;
      if (systolic != null) {
        value.primary = systolic.value;
        value.primaryId = systolic.id;
        value.unit = systolic.unit;
        value.referenceRange = systolic.referenceRange;
      }
      if (diastolic != null) {
        value.secondary = diastolic.value;
        value.secondaryId = diastolic.id;
        value.secondaryUnit = diastolic.unit;
        value.secondaryReferenceRange = diastolic.referenceRange;
      }
    }

    for (final entry in vitalsByType.entries) {
      final type = entry.key;
      final vital = entry.value;
      if (type == VitalType.bloodPressureSystolic ||
          type == VitalType.bloodPressureDiastolic) {
        continue;
      }

      _selectedVitals.add(type);
      _ensureValue(type);
      final value = _values[type]!;
      value.primary = vital.value;
      value.primaryId = vital.id;
      value.unit = vital.unit;
      value.referenceRange = vital.referenceRange;
    }
  }
}

class _VitalValue {
  _VitalValue(this.type)
      : unit = VitalReferenceDefaults.getUnit(type),
        referenceRange = VitalReferenceDefaults.getDefault(type),
        secondaryUnit = type == VitalType.bloodPressureSystolic
            ? VitalReferenceDefaults.getUnit(VitalType.bloodPressureDiastolic)
            : null,
        secondaryReferenceRange = type == VitalType.bloodPressureSystolic
            ? VitalReferenceDefaults.getDefault(
                VitalType.bloodPressureDiastolic,
              )
            : null;

  final VitalType type;
  double? primary;
  double? secondary;
  String? primaryId;
  String? secondaryId;
  String unit;
  String? secondaryUnit;
  ReferenceRange? referenceRange;
  ReferenceRange? secondaryReferenceRange;
  VitalStatus status = VitalStatus.normal;
}

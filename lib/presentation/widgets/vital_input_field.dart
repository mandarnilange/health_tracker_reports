import 'package:flutter/material.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_reference_defaults.dart';

class VitalInputField extends StatefulWidget {
  const VitalInputField({
    super.key,
    required this.type,
    this.initialValue,
    this.initialSecondaryValue,
    this.onValueChanged,
    this.onSecondaryValueChanged,
  });

  final VitalType type;
  final double? initialValue;
  final double? initialSecondaryValue;
  final ValueChanged<double>? onValueChanged;
  final ValueChanged<double>? onSecondaryValueChanged;

  @override
  State<VitalInputField> createState() => _VitalInputFieldState();
}

class _VitalInputFieldState extends State<VitalInputField> {
  TextEditingController? _primaryController;
  TextEditingController? _secondaryController;
  double? _sliderValue;
  bool? _toggleValue;

  @override
  void initState() {
    super.initState();
    if (_usesSlider(widget.type)) {
      _sliderValue = widget.initialValue ?? 5;
    } else if (_usesToggle(widget.type)) {
      _toggleValue = (widget.initialValue ?? 0) > 0;
    } else {
      _primaryController = TextEditingController(
        text: widget.initialValue?.toStringAsFixed(0) ?? '',
      );
      if (_hasSecondaryField(widget.type)) {
        _secondaryController = TextEditingController(
          text: widget.initialSecondaryValue?.toStringAsFixed(0) ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    _primaryController?.dispose();
    _secondaryController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case VitalType.energyLevel:
        return _buildEnergySlider();
      case VitalType.medicationAdherence:
        return _buildToggle(context, label: 'Medication Taken');
      default:
        return _buildTextFields(context);
    }
  }

  Widget _buildTextFields(BuildContext context) {
    final unit = VitalReferenceDefaults.getUnit(widget.type);
    final label = widget.type.displayName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _primaryController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '$label (${unit.isEmpty ? 'value' : unit})',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            final parsed = double.tryParse(value);
            if (parsed != null) {
              widget.onValueChanged?.call(parsed);
            }
          },
        ),
        if (_secondaryController != null) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _secondaryController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Diastolic (mmHg)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              if (parsed != null) {
                widget.onSecondaryValueChanged?.call(parsed);
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildEnergySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Energy Level', style: Theme.of(context).textTheme.titleMedium),
        Slider(
          min: 1,
          max: 10,
          divisions: 9,
          label: _sliderValue?.round().toString(),
      value: (_sliderValue ?? 5).clamp(1, 10).toDouble(),
          onChanged: (value) {
            setState(() => _sliderValue = value);
            widget.onValueChanged?.call(value);
          },
        ),
      ],
    );
  }

  Widget _buildToggle(BuildContext context, {required String label}) {
    return SwitchListTile(
      title: Text(label),
      value: _toggleValue ?? false,
      onChanged: (value) {
        setState(() => _toggleValue = value);
        widget.onValueChanged?.call(value ? 1 : 0);
      },
    );
  }

  bool _hasSecondaryField(VitalType type) {
    return type == VitalType.bloodPressureSystolic;
  }

  bool _usesSlider(VitalType type) => type == VitalType.energyLevel;

  bool _usesToggle(VitalType type) => type == VitalType.medicationAdherence;
}

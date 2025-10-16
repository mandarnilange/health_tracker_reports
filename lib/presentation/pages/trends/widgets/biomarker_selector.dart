import 'package:flutter/material.dart';

/// Widget that displays a dropdown selector for biomarkers.
///
/// Allows users to select from a list of available biomarker names
/// to view trend data for that specific biomarker.
class BiomarkerSelector extends StatelessWidget {
  /// List of available biomarker names to display in the dropdown
  final List<String> biomarkerNames;

  /// Currently selected biomarker name (can be null if nothing is selected)
  final String? selectedBiomarker;

  /// Callback function when a biomarker is selected
  final void Function(String?) onBiomarkerSelected;

  const BiomarkerSelector({
    super.key,
    required this.biomarkerNames,
    required this.selectedBiomarker,
    required this.onBiomarkerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.biotech,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                value: selectedBiomarker,
                hint: Text(
                  'Select a biomarker',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: biomarkerNames.map((String name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }).toList(),
                onChanged: onBiomarkerSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

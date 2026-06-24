import 'package:flutter/material.dart';

class FeatureToggleChip extends StatelessWidget {
  final String featureId;
  final bool isSelected;
  final bool isDisabled;
  final ValueChanged<bool?> onChanged;
  final String? label;

  const FeatureToggleChip({
    super.key,
    required this.featureId,
    required this.isSelected,
    required this.onChanged,
    this.label,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label ?? featureId),
      selected: isSelected,
      onSelected: isDisabled ? null : onChanged,
      selectedColor: theme.primaryColor.withAlpha(0x33),
      disabledColor: Colors.grey.shade200,
      checkmarkColor: theme.primaryColor,
      labelStyle: TextStyle(
        color: isDisabled
            ? Colors.grey
            : isSelected
                ? theme.primaryColor
                : Colors.black87,
      ),
    );
  }
}
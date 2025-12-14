import 'package:flutter/material.dart';
import '../../models/focus_area.dart';
import '../../utils/constants/app_colors.dart';

class ExpertiseSelector extends StatelessWidget {
  final List<FocusArea> focusAreas;
  final List<String> selectedAreas;
  final Function(String) onSelectionChanged;

  const ExpertiseSelector({
    Key? key,
    required this.focusAreas,
    required this.selectedAreas,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: focusAreas.map((area) {
        final isSelected = selectedAreas.contains(area.id);
        return FilterChip(
          label: Text(area.name),
          selected: isSelected,
          onSelected: (_) => onSelectionChanged(area.id),
          backgroundColor: Colors.white,
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.1),
            ),
          ),
        );
      }).toList(),
    );
  }
}

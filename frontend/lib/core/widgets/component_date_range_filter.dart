import 'package:flutter/material.dart';

import '../utils/format_date.dart';

class ComponentDateRangeFilter extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final ValueChanged<DateTimeRange?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const ComponentDateRangeFilter({
    super.key,
    required this.selectedRange,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  String get _label {
    final range = selectedRange;
    if (range == null) {
      return 'Filtrer par date';
    }
    return '${formatDate(range.start)} → ${formatDate(range.end)}';
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate ?? DateTime(now.year - 5),
      lastDate: lastDate ?? now,
      initialDateRange: selectedRange,
      helpText: 'Sélectionner une période',
      saveText: 'Valider',
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = selectedRange != null;

    return InputChip(
      avatar: Icon(
        Icons.date_range,
        size: 18,
        color: isActive ? colorScheme.onPrimaryContainer : null,
      ),
      label: Text(_label),
      selected: isActive,
      onPressed: () => _pickRange(context),
      onDeleted: isActive ? () => onChanged(null) : null,
      deleteIcon: isActive ? const Icon(Icons.close, size: 18) : null,
      tooltip: isActive
          ? 'Modifier ou retirer le filtre de date'
          : 'Filtrer par plage de dates',
    );
  }
}

bool isDateWithinRange(DateTime date, DateTimeRange? range) {
  if (range == null) {
    return true;
  }

  final day = DateTime(date.year, date.month, date.day);
  final start = DateTime(range.start.year, range.start.month, range.start.day);
  final end = DateTime(range.end.year, range.end.month, range.end.day);

  return !day.isBefore(start) && !day.isAfter(end);
}

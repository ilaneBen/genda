import 'package:flutter/material.dart';

class TimePickerDropdown extends StatelessWidget {
  final TimeOfDay value;
  final ValueChanged<TimeOfDay?> onChanged;

  TimePickerDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<TimeOfDay>(
      value: value,
      onChanged: onChanged,
      items: List.generate(24, (index) {
        final hour = index;
        final minute = 0;
        final time = TimeOfDay(hour: hour, minute: minute);
        return DropdownMenuItem<TimeOfDay>(
          value: time,
          key: ValueKey('$hour:$minute'), // Utilisation de ValueKey pour assurer l'unicité
          child: Text('${time.format(context)}'),
        );
      }).toList(),
    );
  }
}

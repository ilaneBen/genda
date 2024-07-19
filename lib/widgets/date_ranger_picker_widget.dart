import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePickerWidget extends StatefulWidget {
  final Function(List<DateTime>) onDateRangeSelected;

  DateRangePickerWidget({required this.onDateRangeSelected});

  @override
  _DateRangePickerWidgetState createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  List<DateTime> _selectedDates = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () => _selectDateRange(context),
          child: Text('Sélectionner des dates'),
        ),
        SizedBox(height: 16.0),
        if (_selectedDates.isNotEmpty) ...[
          Text('Dates sélectionnées:'),
          Column(
            children: _selectedDates
                .map((date) => Text(DateFormat('dd/MM/yyyy').format(date)))
                .toList(),
          ),
        ],
      ],
    );
  }

  void _selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: now,
        end: now.add(Duration(days: 7)),
      ),
      firstDate: DateTime(now.year),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDates = _getDaysInRange(picked.start, picked.end).toList();
      });
      widget.onDateRangeSelected(_selectedDates);
    }
  }

  Iterable<DateTime> _getDaysInRange(DateTime start, DateTime end) sync* {
    DateTime current = start;
    while (current.isBefore(end.add(Duration(days: 1)))) {
      yield current;
      current = current.add(Duration(days: 1));
    }
  }
}

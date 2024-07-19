import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sélectionner une Date'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1), // Début du calendrier
              lastDay: DateTime.utc(2030, 12, 31), // Fin du calendrier
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                // Permet de marquer la journée sélectionnée
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // Mise à jour de la journée sélectionnée et de la journée focus
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Utilisation de la date sélectionnée (_selectedDay)
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Date Sélectionnée'),
                    content: Text('Vous avez sélectionné : $_selectedDay'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Valider la Sélection'),
            ),
          ],
        ),
      ),
    );
  }
}

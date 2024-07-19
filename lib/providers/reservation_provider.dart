import 'package:flutter/material.dart';

class ReservationProvider with ChangeNotifier {
  List<DateTime> _reservedDates = [];

  List<DateTime> get reservedDates => _reservedDates;

  void addReservation(DateTime dateTime) {
    _reservedDates.add(dateTime);
    notifyListeners();
  }

  bool isDateReserved(DateTime dateTime) {
    return _reservedDates.contains(dateTime);
  }
}

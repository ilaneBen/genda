import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:granity/models/product.dart';
import 'package:granity/providers/cart_provider.dart';
import 'package:granity/screens/cart_screen.dart';
import 'package:granity/providers/reservation_provider.dart';
import 'package:granity/services/reservation_service.dart'; // Assurez-vous d'avoir ce service pour la gestion Firebase

class ProductCard extends StatefulWidget {
  final Product product;

  ProductCard({required this.product});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1)); // Par défaut, le premier des trois prochains jours
  TimeOfDay? _selectedTime; // Créneau horaire sélectionné
  Duration? _selectedDuration; // Durée sélectionnée pour la prestation
  final FirebaseService _firebaseService = FirebaseService(); // Service Firebase pour gérer les réservations

  List<DateTime> getNextThreeDays() {
    DateTime today = DateTime.now();
    return List.generate(3, (index) => today.add(Duration(days: index + 1)));
  }

  List<TimeOfDay> getAvailableTimeSlots(DateTime date, Duration duration) {
    // Définir des créneaux horaires disponibles, vous pouvez ajuster cette liste en fonction de vos besoins
    // Exemple: 1h, 2h15, 3h
    if (duration == Duration(hours: 1)) {
      return [
        TimeOfDay(hour: 9, minute: 0),
        TimeOfDay(hour: 11, minute: 0),
        TimeOfDay(hour: 13, minute: 0),
        TimeOfDay(hour: 15, minute: 0),
        TimeOfDay(hour: 17, minute: 0),
      ];
    } else if (duration == Duration(hours: 2, minutes: 15)) {
      return [
        TimeOfDay(hour: 10, minute: 0),
        TimeOfDay(hour: 13, minute: 0),
        TimeOfDay(hour: 16, minute: 0),
      ];
    } else if (duration == Duration(hours: 3)) {
      return [
        TimeOfDay(hour: 9, minute: 0),
        TimeOfDay(hour: 14, minute: 0),
      ];
    }
    return []; // Retourne une liste vide par défaut
  }

  String formatDate(DateTime date) {
    // Formatage de la date en "lundi 17"
    return DateFormat('EEEE d', 'fr_FR').format(date);
  }

  String formatTime(TimeOfDay time) {
    // Formatage de l'heure en "HH:mm"
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat('HH:mm', 'fr_FR');
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> nextThreeDays = getNextThreeDays();
    List<DateTime> availableDates = nextThreeDays.where((date) {
      return getAvailableTimeSlots(date, _selectedDuration ?? Duration.zero).isNotEmpty;
    }).toList();

    return Card(
      child: Column(
        children: <Widget>[
          Image.network(widget.product.imageUrl),
          Text(widget.product.name),
          Text('\$${widget.product.price.toStringAsFixed(2)}'),
          SizedBox(height: 20),
          Text('Sélectionnez une date : '),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: availableDates.map((date) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = date;
                        _selectedTime = null; // Réinitialiser le créneau horaire lorsque la date change
                        _selectedDuration = null; // Réinitialiser la durée lorsque la date change
                      });
                    },
                    child: Text(
                      formatDate(date),
                      style: TextStyle(
                        color: _selectedDate == date ? Colors.white : Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedDate == date ? Colors.blue : Colors.grey, // Mise en surbrillance de la date sélectionnée
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20),
          if (_selectedDate != null) ...[
            Text('Sélectionnez une durée de prestation : '),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDuration = Duration(hours: 1);
                          _selectedTime = null; // Réinitialiser le créneau horaire lorsque la durée change
                        });
                      },
                      child: Text('1h'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedDuration == Duration(hours: 1) ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDuration = Duration(hours: 2, minutes: 15);
                          _selectedTime = null; // Réinitialiser le créneau horaire lorsque la durée change
                        });
                      },
                      child: Text('2h15'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedDuration == Duration(hours: 2, minutes: 15) ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDuration = Duration(hours: 3);
                          _selectedTime = null; // Réinitialiser le créneau horaire lorsque la durée change
                        });
                      },
                      child: Text('3h'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedDuration == Duration(hours: 3) ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_selectedDuration != null) ...[
            SizedBox(height: 20),
            Text('Sélectionnez un créneau horaire : '),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: getAvailableTimeSlots(_selectedDate, _selectedDuration!).map((time) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedTime = time;
                        });
                      },
                      child: Text(
                        formatTime(time),
                        style: TextStyle(
                          color: _selectedTime == time ? Colors.white : Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTime == time ? Colors.blue : Colors.grey, // Mise en surbrillance du créneau horaire sélectionné
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_selectedTime == null || _selectedDuration == null) {
                // Afficher une alerte si aucune durée ou créneau horaire n'est sélectionné
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Sélection incomplète'),
                    content: Text('Veuillez sélectionner une durée et un créneau horaire.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }

              DateTime selectedDateTime = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              );

              if (Provider.of<ReservationProvider>(context, listen: false)
                  .isDateReserved(selectedDateTime)) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Date non disponible'),
                    content: Text('La date et le créneau horaire sélectionnés sont déjà réservés.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                await _firebaseService.addReservation(selectedDateTime, widget.product.id); // Ajout de la réservation à Firebase
                Provider.of<ReservationProvider>(context, listen: false)
                    .addReservation(selectedDateTime);
                Provider.of<CartProvider>(context, listen: false).addToCart(widget.product);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              }
            },
            child: Text('Réserver et Ajouter au Panier'),
          ),
        ],
      ),
    );
  }
}

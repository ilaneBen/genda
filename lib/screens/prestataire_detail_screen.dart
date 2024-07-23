import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:granity/models/product.dart';
import 'package:granity/services/product_service.dart';
import 'package:granity/models/user.dart';
import 'package:intl/intl.dart';

class PrestataireDetailScreen extends StatefulWidget {
  final CustomUser prestataire;

  PrestataireDetailScreen({required this.prestataire});

  @override
  _PrestataireDetailScreenState createState() => _PrestataireDetailScreenState();
}

class _PrestataireDetailScreenState extends State<PrestataireDetailScreen> {
  late Future<List<Product>> _servicesFuture;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  List<DateTime> _availableDates = [];
  List<String> _availableTimeSlots = [];
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _fetchServices();
  }

  Future<List<Product>> _fetchServices() async {
    final productService = ProductService();
    return await productService.getServicesByUserId(widget.prestataire.uid);
  }

  Future<List<DateTime>> _getAvailableDates(List<DateTime> dates) async {
    final availableDates = <DateTime>[];

    for (final date in dates) {
      final dateKey = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(date);

      try {
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(_selectedProduct!.id)
            .get();

        final timeSlotsData = productDoc.data()?['timeSlots'] as Map<String, dynamic>?;
        if (timeSlotsData != null) {
          final timeSlotsList = timeSlotsData[dateKey] as List<dynamic>?;
          if (timeSlotsList != null) {
            final timeSlots = timeSlotsList.cast<String>().toList();

            final reservations = await _fetchReservationsForProduct();
            final reservedTimeSlots = reservations
                .where((reservation) => reservation['date'] == date.toIso8601String())
                .map((reservation) => reservation['timeSlot'] as String)
                .toSet();

            final availableTimeSlots = timeSlots.where((slot) => !reservedTimeSlots.contains(slot)).toList();

            if (availableTimeSlots.isNotEmpty) {
              availableDates.add(date);
            }
          }
        }
      } catch (e) {
        print('Error checking availability for $date: $e');
      }
    }

    return availableDates;
  }

Future<void> _updateAvailableDates() async {
  if (_selectedProduct == null) return;

  final datesWithAvailableSlots = await _getAvailableDates(_selectedProduct!.availableDates);

  setState(() {
    _availableDates = datesWithAvailableSlots;
    if (_availableDates.isEmpty) {
      _selectedDate = null;
      _availableTimeSlots = [];
    } else if (!_availableDates.contains(_selectedDate)) {
      _selectedDate = null;
      _availableTimeSlots = [];
    }
  });
}


  Future<List<Map<String, dynamic>>> _fetchReservationsForProduct() async {
    try {
      final reservationsQuery = await FirebaseFirestore.instance
          .collection('reservations')
          .where('productId', isEqualTo: _selectedProduct!.id)
          .get();

      return reservationsQuery.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching reservations: $e');
      return [];
    }
  }

  Future<void> _onDateButtonPressed(DateTime date) async {
    final dateKey = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(date);

    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(_selectedProduct!.id)
          .get();

      final timeSlotsData = productDoc.data()?['timeSlots'] as Map<String, dynamic>?;

      if (timeSlotsData != null) {
        timeSlotsData.forEach((key, value) {
        });

        final timeSlotsList = timeSlotsData[dateKey] as List<dynamic>?;

        if (timeSlotsList != null) {
          final timeSlots = timeSlotsList.cast<String>().toList();

          final reservations = await _fetchReservationsForProduct();
          final reservedTimeSlots = reservations
              .where((reservation) => reservation['date'] == date.toIso8601String())
              .map((reservation) => reservation['timeSlot'] as String)
              .toSet();

          final availableTimeSlots = timeSlots.where((slot) => !reservedTimeSlots.contains(slot)).toList();

          setState(() {
            _availableTimeSlots = availableTimeSlots;
            _selectedTimeSlot = null;
            _selectedDate = date;
          });

          if (_availableTimeSlots.isNotEmpty) {
            _showTimeSlotSelectionDialog();
          } else {
            print('No time slots available for the selected date');
          }
        } else {
          print('No time slots found for the selected date');
        }
      } else {
        print('No time slots data available');
      }
    } catch (e) {
      print('Error fetching time slots: $e');
    }
  }

  void _onTimeSlotButtonPressed(String timeSlot) {
    setState(() {
      _selectedTimeSlot = timeSlot;
    });
  }

  Future<void> _saveReservation() async {
    if (_selectedDate == null || _selectedTimeSlot == null || _selectedProduct == null) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'unknown';
      final reservation = {
        'userId': userId,
        'productId': _selectedProduct!.id,
        'date': _selectedDate!.toIso8601String(),
        'timeSlot': _selectedTimeSlot!,
        'prestataireId': widget.prestataire.uid,
      };

      await FirebaseFirestore.instance.collection('reservations').add(reservation);

      await _updateAvailableTimeSlots();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reservation Confirmed'),
            content: Text('Your reservation has been saved successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to save reservation: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
     setState(() {
        _servicesFuture = _fetchServices();
      });
  }

  Future<void> _updateAvailableTimeSlots() async {
    if (_selectedDate == null || _selectedTimeSlot == null || _selectedProduct == null) {
      print('Missing date, time slot, or product');
      return;
    }

    final dateKey = _selectedDate!.toIso8601String().split('T')[0];

    try {
      final productRef = FirebaseFirestore.instance.collection('products').doc(_selectedProduct!.id);
      final productDoc = await productRef.get();
      final timeSlotsData = productDoc.data()?['timeSlots'] as Map<String, dynamic>?;

      if (timeSlotsData != null) {
        final timeSlotsList = timeSlotsData[dateKey] as List<dynamic>?;

        if (timeSlotsList != null) {
          final timeSlots = timeSlotsList.cast<String>().toList();

          if (timeSlots.contains(_selectedTimeSlot)) {
            timeSlots.remove(_selectedTimeSlot);

            await productRef.update({
              'timeSlots.$dateKey': timeSlots.isEmpty ? FieldValue.delete() : timeSlots,
            });

            setState(() {
              _availableTimeSlots = timeSlots;
            });
          } else {
            print('Selected time slot not found in the list');
          }
        } else {
          print('No time slots found for the selected date');
        }
      } else {
        print('No time slots data available');
      }
    } catch (e) {
      print('Error updating time slots: $e');
    }
  }

  void _showDateSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Date'),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _availableDates.map((date) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _onDateButtonPressed(date);
                          Navigator.of(context).pop();
                        },
                        child: Text(DateFormat('yyyy-MM-dd').format(date)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showTimeSlotSelectionDialog() {

    if (_availableTimeSlots.isEmpty) {
      print('No time slots available for the selected date');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Time Slot'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _availableTimeSlots.map((slot) {
              return ElevatedButton(
                onPressed: () {
                  _onTimeSlotButtonPressed(slot);
                  Navigator.of(context).pop();
                  _showConfirmationDialog();
                },
                child: Text(slot),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Your Appointment'),
          content: Text(
            'You selected:\nDate: ${_selectedDate?.toLocal().toString().split(' ')[0]}\nTime Slot: $_selectedTimeSlot',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveReservation();
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prestataire.name),
        backgroundColor: Colors.black,
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Product>>(
          future: _servicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No services available', style: TextStyle(fontSize: 18)));
            } else {
              final services = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.prestataire.imageUrl != null
                        ? Container(
                            width: double.infinity,
                            height: 200,
                            child: Image.network(
                              widget.prestataire.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                'No Image',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                    SizedBox(height: 16.0),
                    Text(
                      'Name: ${widget.prestataire.name}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Role: ${widget.prestataire.role}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Address: ${widget.prestataire.address ?? 'No address'}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Postal Code: ${widget.prestataire.codePostal ?? 'No code postal'}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'City: ${widget.prestataire.ville ?? 'No city'}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Services:',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Column(
                      children: services.map((service) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: service.imageUrl.isNotEmpty
                                    ? Container(
                                        width: 50,
                                        height: 50,
                                        child: Image.network(
                                          service.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Icon(
                                            Icons.image,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                title: Text(service.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                subtitle: Text(service.description),
                                trailing: Text('\€${service.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                                onTap: () {
                                  setState(() {
                                    _selectedProduct = service;
                                    _updateAvailableDates();
                                    _selectedDate = null;
                                    _selectedTimeSlot = null;
                                    _availableTimeSlots = [];
                                  });
                                },
                              ),
                              if (_selectedProduct == service)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Select Date:',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                       SizedBox(height: 8.0),
                                    _availableDates.isEmpty
                                        ? Text(
                                            'Aucune disponibilité',
                                            style: TextStyle(fontSize: 16, color: Colors.red),
                                          )
                                      : SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: _availableDates.map((date) {
                                            return ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedDate = date;
                                                });
                                                _onDateButtonPressed(date);
                                              },
                                              child: Text(DateFormat('yyyy-MM-dd').format(date)),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      SizedBox(height: 16.0),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
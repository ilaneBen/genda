import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String userId;
  final List<DateTime> availableDates;
  final Map<DateTime, List<String>> timeSlots;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.userId,
    required this.availableDates,
    required this.timeSlots,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    // Convert 'availableDates' to a list of DateTime objects
    var availableDatesFromData = (data['availableDates'] as List).map((date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.parse(date);
      } else {
        throw Exception("Invalid date format in availableDates");
      }
    }).toList();

    // Convert 'timeSlots' to a map with DateTime keys and List<String> values
    var timeSlotsFromData = (data['timeSlots'] as Map).map<DateTime, List<String>>((key, value) {
      if (value is List) {
        return MapEntry(DateTime.parse(key), List<String>.from(value));
      } else {
        throw Exception("Invalid time slot format");
      }
    });

    return Product(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      price: data['price'],
      imageUrl: data['imageUrl'],
      userId: data['userId'],
      availableDates: availableDatesFromData,
      timeSlots: timeSlotsFromData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'userId': userId,
      'availableDates': availableDates.map((e) => Timestamp.fromDate(e)).toList(),
      'timeSlots': timeSlots.map((key, value) {
        return MapEntry(
          key.toIso8601String(),
          value,
        );
      }),
    };
  }
}

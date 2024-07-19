import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String userId;
  List<DateTime> availableDates;
  Map<DateTime, List<String>> timeSlots;

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'userId': userId,
      'availableDates': availableDates.map((date) => date.toIso8601String()).toList(),
      'timeSlots': timeSlots.map((date, slots) => MapEntry(date.toIso8601String(), slots)),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      userId: map['userId'],
      availableDates: List<DateTime>.from(map['availableDates'].map((date) => DateTime.parse(date))),
      timeSlots: Map<DateTime, List<String>>.from(map['timeSlots'].map((date, slots) => MapEntry(DateTime.parse(date), List<String>.from(slots)))),
    );
  }
}

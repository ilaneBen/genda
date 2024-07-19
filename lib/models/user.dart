// models/user.dart
import 'dart:ffi';

class CustomUser {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String? imageUrl; // Add imageUrl field
  final String? address; // Add imageUrl field
  final String? codePostal; // Add imageUrl field
  final String? ville; // Add imageUrl field
  final double? distance;

  CustomUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.imageUrl, // Initialize imageUrl field
    this.address, // Initialize imageUrl field
    this.codePostal, // Initialize imageUrl field
    this.ville, // Initialize imageUrl field
    this.distance, // Initialize imageUrl field
  });

  // Factory constructor to create an instance from a map
  factory CustomUser.fromMap(Map<String, dynamic> data) {
    return CustomUser(
      uid: data['id'] ?? '', // Provide a default value if null
      name: data['name'] ?? '', // Provide a default value if null
      email: data['email'] ?? '', // Provide a default value if null
      phoneNumber: data['phoneNumber'] ?? '', // Provide a default value if null
      role: data['role'] ?? '', // Provide a default value if null
      imageUrl: data['imageUrl'], // imageUrl can be null
      address: data['address'], // imageUrl can be null
      codePostal: data['codePostal'], // imageUrl can be null
      ville: data['ville'], // imageUrl can be null
      distance: data['distance'], // imageUrl can be null
    );
  }

  // Method to create a new instance with updated fields
  CustomUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    String? imageUrl,
    String? address,
    String? codePostal,
    String? ville,
    double? distance,
  }) {
    return CustomUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      codePostal: codePostal ?? this.codePostal,
      ville: ville ?? this.ville,
      distance: distance ?? this.distance,
    );
  }
}

// models/user.dart
import 'package:granity/models/product.dart';

class CustomUser {
   String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String? imageUrl;
  final String? address;
  final String? codePostal;
  final String? ville;
  final double? distance;
  final List<Product> services;

  CustomUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.imageUrl,
    this.address,
    this.codePostal,
    this.ville,
    this.distance,
    required this.services,
  });

  factory CustomUser.fromMap(Map<String, dynamic> data, List<Product> services) {
    return CustomUser(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      role: data['role'] ?? '',
      imageUrl: data['imageUrl'],
      address: data['address'],
      codePostal: data['codePostal'],
      ville: data['ville'],
      distance: data['distance'],
      services: services
    );
  }

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
    List<Product>? services,
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
      services: services ?? this.services,
    );
  }
}

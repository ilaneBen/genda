import 'package:flutter/material.dart';
import 'package:granity/models/user.dart';

class PrestataireDetailScreen extends StatelessWidget {
  final CustomUser prestataire;

  PrestataireDetailScreen({required this.prestataire});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(prestataire.name),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Afficher la photo du prestataire
            prestataire.imageUrl != null
                ? Image.network(prestataire.imageUrl!)
                : Placeholder(fallbackHeight: 200.0),
            SizedBox(height: 16.0),
            Text(
              'Name: ${prestataire.name}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Role: ${prestataire.role}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8.0),
            Text(
              'Address: ${prestataire.address ?? 'No address'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8.0),
            Text(
              'Postal Code: ${prestataire.codePostal ?? 'No code postal'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8.0),
            Text(
              'City: ${prestataire.ville ?? 'No city'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16.0),
            // Afficher des prestations, si elles existent
            Text(
              'Services:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            // Remplacez ce Placeholder par les détails des prestations du prestataire
            // Par exemple:
            // Text('Service 1, Service 2, Service 3')
          ],
        ),
      ),
    );
  }
}

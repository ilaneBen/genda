import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:granity/models/service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final CollectionReference _servicesCollection = FirebaseFirestore.instance.collection('services');


  Future<void> addReservation(DateTime dateTime, String productId) async {
    await _firestore.collection('reservations').add({
      'date': dateTime,
      'productId': productId,
    });
  }
   Future<void> addService(Service service) async {
    try {
      await _servicesCollection.add(service.toMap()); // Convertir le service en Map et l'ajouter à Firestore
    } catch (e) {
      print('Erreur lors de l\'ajout de la prestation: $e');
    }
  }
}

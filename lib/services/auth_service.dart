import 'package:granity/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// services/auth_service.dart
class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<CustomUser>> searchPrestatairesByName(String query) async {
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'Prestataire')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    // Map documents to CustomUser and handle potential null values
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CustomUser.fromMap(data);
    }).toList();
  }
}

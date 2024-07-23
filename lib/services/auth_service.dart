import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:granity/models/user.dart';
import 'package:granity/models/product.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

 Future<List<CustomUser>> searchPrestatairesByName(String query) async {
  try {
    // Normalisation de la requête
    final normalizedQuery = query.trim().toLowerCase();

    // Diviser la requête en mots
    final queryWords = normalizedQuery.split(' ');

    // Initialiser une liste pour les résultats filtrés
    List<CustomUser> prestataires = [];

    // Obtenir tous les utilisateurs avec le rôle 'Prestataire'
    final allUsersSnapshot = await FirebaseFirestore.instance.collection('users')
      .where('role', isEqualTo: 'Prestataire')
      .get();

    for (var userDoc in allUsersSnapshot.docs) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final userId = userDoc.id;
      final name = (userData['name'] as String).toLowerCase();

      // Vérifier si le nom de l'utilisateur contient tous les mots-clés de la requête
      bool matches = queryWords.every((word) => name.contains(word));

      if (matches) {
        // Récupération des services pour cet utilisateur
        final serviceSnapshot = await FirebaseFirestore.instance.collection('services')
          .where('userId', isEqualTo: userId)
          .get();

        // Conversion des documents de service en objets Product
        List<Product> services = serviceSnapshot.docs.map((serviceDoc) {
          return Product.fromMap(serviceDoc.data());
        }).toList();

        // Création d'un objet CustomUser et ajout à la liste
        CustomUser prestataire = CustomUser.fromMap(userData, services);
        prestataire.uid = userId;
        prestataires.add(prestataire);
      }
    }

    return prestataires;

  } catch (e) {
    print('Error fetching users: $e');
    return [];
  }
}

}
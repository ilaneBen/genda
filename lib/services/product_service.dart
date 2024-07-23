import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:granity/models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _productCollection =
      FirebaseFirestore.instance.collection('products');

  // Method to retrieve products as a stream
  Stream<List<Product>> getProducts() {
    return _productCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>); // Cast data to Map<String, dynamic>
      }).toList();
    });
  }

  // Method to add a product
  Future<void> addProduct(Product product) async {
    try {
      await _productCollection.add(product.toMap());
    } catch (e) {
      print('Error adding product: $e');
      throw e; // Optionally handle or rethrow the error
    }
  }

  // Method to search products based on a query
  Future<List<Product>> searchProducts(String query) async {
    try {
      final querySnapshot = await _firestore.collection('products').get();
      
      List<Product> products = querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
          .where((product) => product.name.toLowerCase().contains(query.toLowerCase())) // Case-insensitive comparison
          .toList();

      return products;
    } catch (e) {
      print('Error searching products: $e');
      return []; // Return empty list or handle error gracefully
    }
  }

  // Method to retrieve all products
  Future<List<Product>> getAllProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('products').get();

      List<Product> products = snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return products;
    } catch (e) {
      print('Error retrieving products: $e');
      return []; // Return empty list or handle error gracefully
    }
  }

    Future<List<Product>> getServicesByUserId(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        
        final timeSlotsMap = data['timeSlots'] as Map<String, dynamic>;
        final validatedTimeSlots = <DateTime, List<String>>{};

        timeSlotsMap.forEach((key, value) {
          try {
            final date = DateTime.parse(key);

            // Assurez-vous que 'value' est une liste de chaînes, sinon une liste vide
            final slots = value is List ? List<String>.from(value) : <String>[];

            // Validation du format des créneaux horaires

            validatedTimeSlots[date] = slots;
          } catch (e) {
            print('Error validating time slots for $key: $e');
          }
        });

        return Product(
          id: doc.id,
          name: data['name'],
          description: data['description'],
          price: data['price'],
          imageUrl: data['imageUrl'],
          userId: data['userId'],
          availableDates: validatedTimeSlots.keys.toList(),
          timeSlots: validatedTimeSlots,
        );
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }


  Future<List<Map<String, dynamic>>> getAllDocs() async {
    try {
      final querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Ajouter l'ID du document aux données
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching documents: $e');
      return [];
    }
  }
}


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
}

// models/service.dart

class Service {
  final String id;
  final String productId; // ID du produit auquel cette prestation est liée
  final String name;
  final String description;
  final Duration duration;
  final double price;

  Service({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
  });

  // Méthode pour convertir un service en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'description': description,
      'duration': duration.inMinutes, // Enregistrer la durée en minutes par exemple
      'price': price,
    };
  }

  // Méthode pour créer un service à partir d'un Map
  factory Service.fromMap(Map<String, dynamic> data) {
    return Service(
      id: data['id'],
      productId: data['productId'],
      name: data['name'],
      description: data['description'],
      duration: Duration(minutes: data['duration']),
      price: data['price'],
    );
  }
}

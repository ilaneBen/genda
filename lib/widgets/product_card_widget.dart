import 'package:flutter/material.dart';
import 'package:granity/models/product.dart'; // Assurez-vous que ce chemin est correct

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      height: 200, // Hauteur fixe de la carte
      child: Card(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            product.imageUrl != null
                ? Image.network(
                    product.imageUrl!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Price: ${product.price}',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 8.0),
            Divider(),
            ListTile(
              trailing: Icon(Icons.more_vert),
              onTap: () {
                // Ajoutez la logique pour naviguer vers les détails du produit
              },
            ),
          ],
        ),
      ),
    );
  }
}

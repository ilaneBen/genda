import 'package:flutter/material.dart';
import 'package:granity/main.dart';
import 'package:provider/provider.dart';
import 'package:granity/providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Panier'),
        backgroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 30),
          leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white,), // Icône de flèche par défaut
    onPressed: () {
      // Actions lorsque l'utilisateur appuie sur la flèche de retour
      Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                  );

    },
  ),
      ),
      body: cartItems.isEmpty
          ? Center(child: Text('Le panier est vide'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return ListTile(
  title: Text(cartItems[index].name),
  subtitle: Row(
    children: [
      Text('Prix: \$${cartItems[index].price}'),
      SizedBox(width: 8), // Espacement entre le prix et l'image
      Text('\$${cartItems[index].imageUrl}'),
    ],
  ),
);
              },
            ),
            
    );
  }
}

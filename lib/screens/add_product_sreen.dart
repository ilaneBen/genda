import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:granity/models/product.dart';
import 'package:granity/providers/user_provider.dart'; // Si vous avez un UserProvider pour l'authentification
import 'package:uuid/uuid.dart';
import 'package:granity/widgets/date_ranger_picker_widget.dart'; // Assurez-vous d'importer le widget que nous avons créé

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  List<DateTime> _selectedDates = [];
  Map<DateTime, List<String>> _timeSlots = {};

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final User? user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un produit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'URL de l\'image'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une URL d\'image';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DateRangePickerWidget(
                onDateRangeSelected: (dates) {
                  setState(() {
                    _selectedDates = dates;
                  });
                },
              ),
              SizedBox(height: 16.0),
              if (_selectedDates.isNotEmpty) ...[
                Text('Dates sélectionnées:'),
                Column(
                  children: _selectedDates.map((date) => _buildDateTile(date)).toList(),
                ),
              ],
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addProduct(user!.uid);
                  }
                },
                child: Text('Ajouter le produit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTile(DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${DateFormat('dd/MM/yyyy').format(date)}'),
        SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () => _addTimeSlot(date),
          child: Text('Ajouter un créneau horaire'),
        ),
        SizedBox(height: 8.0),
        if (_timeSlots[date]?.isNotEmpty ?? false) ...[
          Text('Créneaux horaires:'),
          Column(
            children: _timeSlots[date]!.map((slot) => Text(slot)).toList(),
          ),
        ],
        Divider(),
      ],
    );
  }

  void _addTimeSlot(DateTime date) {
    final TextEditingController timeController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un créneau horaire'),
          content: TextField(
            controller: timeController,
            decoration: InputDecoration(hintText: 'Ex: 10:00 - 12:00'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Ajouter'),
              onPressed: () {
                setState(() {
                  if (!_timeSlots.containsKey(date)) {
                    _timeSlots[date] = [];
                  }
                  _timeSlots[date]!.add(timeController.text);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addProduct(String userId) async {
    try {
      Product newProduct = Product(
        id: Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text,
        userId: userId,
        availableDates: _selectedDates,
        timeSlots: _timeSlots,
      );

      // Save the new product to Firestore
      await FirebaseFirestore.instance.collection('products').doc(newProduct.id).set(newProduct.toMap());

      // Clear form fields and state variables
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      _selectedDates.clear();
      _timeSlots.clear();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produit ajouté avec succès')));
    } catch (e) {
      print('Erreur lors de l\'ajout du produit : $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec de l\'ajout du produit')));
    }
  }
}

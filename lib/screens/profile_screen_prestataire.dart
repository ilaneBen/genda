import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:granity/providers/user_provider.dart';
import 'package:granity/screens/login_screen.dart';
import 'package:granity/screens/add_product_sreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileScreenPrestataire extends StatefulWidget {
  const ProfileScreenPrestataire({super.key});

  @override
  _ProfileScreenPrestataireState createState() => _ProfileScreenPrestataireState();
}

class _ProfileScreenPrestataireState extends State<ProfileScreenPrestataire> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage(String userId) async {
    if (_selectedImage == null) return;

    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_images').child('$userId.jpg');
      final uploadTask = storageRef.putFile(_selectedImage!);
      final taskSnapshot = await uploadTask;
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Update user profile with the image URL
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUserProfileImage(userId, downloadUrl);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image uploadée avec succès')));
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec du téléchargement de l\'image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.customUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Prestataire'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 30),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (user != null) ...[
              Text(
                'Email: ${user.email ?? 'Email non disponible'}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                'Numéro de téléphone: ${user.phoneNumber ?? 'Non renseigné'}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 32),
              if (_selectedImage != null)
                Image.file(_selectedImage!),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Sélectionner une image de commerce'),
              ),
              SizedBox(height: 16),
              if (_selectedImage != null)
                ElevatedButton(
                  onPressed: () => _uploadImage(user.uid),
                  child: Text('Télécharger l\'image'),
                ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Add Product Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductScreen()),
                  );
                },
                child: Text('Publier une prestation'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Action de déconnexion
                  userProvider.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('Déconnexion'),
              ),
              SizedBox(height: 32),
              // Display services
              Text(
                'Services:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              user.services.isNotEmpty
                  ? Column(
                      children: user.services.map((service) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: service.imageUrl.isNotEmpty
                                ? Image.network(service.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                                : Placeholder(fallbackWidth: 50, fallbackHeight: 50),
                            title: Text(service.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            subtitle: Text(service.description),
                            trailing: Text('\$${service.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                          ),
                        );
                      }).toList(),
                    )
                  : Text('Aucun service disponible', style: TextStyle(fontSize: 18)),
            ] else ...[
              Text('Utilisateur non connecté'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Rediriger vers l'écran de connexion
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('Se connecter'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

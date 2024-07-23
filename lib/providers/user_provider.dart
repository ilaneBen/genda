import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:granity/models/user.dart'; // Import the custom user model
import 'package:granity/models/product.dart'; // Import the custom user model

class UserProvider with ChangeNotifier {
  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  

  CustomUser? _customUser;

  User? get user => _user;
  CustomUser? get customUser => _customUser;
  String? get uid => _user?.uid;
  bool get isLoggedIn => _user != null;

  UserProvider() {
    checkUserAuthState();
  }

  // Connexion avec email et mot de passe
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      await fetchUserData(_user?.uid); // Fetch user data after signing in
      notifyListeners();
    } catch (e) {
      print("Error signing in: $e");
      throw e;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _customUser = null;
    notifyListeners();
  }

  // Inscription avec email et mot de passe
  Future<void> signUpWithEmailAndPassword(String email,String name, String phoneNumber, String password,String address, String codePostal, String ville) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      await _db.collection('users').doc(_user?.uid).set({
       'name': name,
       'email': email, 
        'phoneNumber': phoneNumber,
        'address': address,
        'codePostal': codePostal,
        'ville': ville,
        'role': 'default', // You can set a default role here if needed
        'createdAt': Timestamp.now(),
      });
      await fetchUserData(_user?.uid); // Fetch user data after signing up
      notifyListeners();
    } catch (e) {
      print("Error signing up: $e");
      throw e;
    }
  }

  // Récupérer les données utilisateur
Future<void> fetchUserData(String? userId) async {
  if (userId != null) {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _db.collection('users').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data()!;

        // Récupérer les services associés à l'utilisateur
        final servicesSnapshot = await _db
            .collection('products')
            .where('userId', isEqualTo: userId)
            .get();

        List<Product> services = servicesSnapshot.docs.map((doc) {
          final data = doc.data();
          return Product.fromMap(data); // Assurez-vous que Product.fromMap est correctement défini
        }).toList();

        // Créer l'objet CustomUser avec les données utilisateur et les services
        _customUser = CustomUser(
          uid: userId,
          name: userData['name'] ?? 'No name',
          email: userData['email'] ?? 'No email',
          phoneNumber: userData['phoneNumber'] ?? 'No phone number',
          address: userData['address'],
          codePostal: userData['codePostal'],
          ville: userData['ville'],
          role: userData['role'] ?? 'default',
          services: services,
        );

        notifyListeners();
      } else {
        print('Document does not exist for user ID: $userId');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw e;
    }
  }
}


  // Vérifier l'état d'authentification de l'utilisateur
  void checkUserAuthState() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        _user = user;
        await fetchUserData(user.uid); // Fetch user data if user is authenticated
      } else {
        _user = null;
        _customUser = null;
      }
      notifyListeners();
    });
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile(String name) async {
    if (_auth.currentUser != null) {
      await _db.collection('users').doc(_auth.currentUser?.uid).update({
        'name': name,
      });
      await fetchUserData(_auth.currentUser?.uid); // Refresh user data after updating profile
      notifyListeners();
    }
  }

  // Récupérer un utilisateur spécifique par ID
  Future<CustomUser?> getUser(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data();
        if (userData != null) {
          String name = userData['name'] ?? 'name_defaut';
          String email = userData['email'] ?? 'email_defaut';
          String phoneNumber = userData['phoneNumber'] ?? 'number_defaut';
          String address = userData['address'] ?? 'address_defaut';
          String codePostal = userData['codePostal'] ?? 'codePostal_defaut';
          String ville = userData['ville'] ?? 'ville_defaut';
          String role = userData['role'] ?? 'default';
          List<Product> services = [];
    if (userData['services'] != null) {
      List<dynamic> servicesData = userData['services'];
      services = servicesData.map((item) => Product.fromMap(item)).toList();
    }

          _customUser = CustomUser(
            uid: userId,
            name: name,
            email: email,
            phoneNumber: phoneNumber,
            address: address,
            codePostal: codePostal,
            ville: ville,
            role: role,
            services: services,
          );
          notifyListeners();
          return _customUser;
        } else {
          print('Les données utilisateur sont nulles pour l\'ID utilisateur : $userId');
          return null;
        }
      } else {
        print('Le document n\'existe pas pour l\'ID utilisateur : $userId');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur : $e');
      throw e;
    }
  }
Future<void> fetchUser() async {
  if (uid != null) {
    try {
      // Fetch user data
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;

        // Fetch products for this user
        final productSnapshot = await _db
            .collection('products')
            .where('userId', isEqualTo: uid)
            .get();

        List<Product> services = productSnapshot.docs.map((productDoc) {
          final productData = productDoc.data();
          return Product.fromMap(productData);
        }).toList();

        // Create and set CustomUser
        _customUser = CustomUser.fromMap(userData, services);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }
}

Future<List<CustomUser>> getPrestataires() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'Prestataire')
      .get();


  List<CustomUser> prestataires = [];

  for (var doc in querySnapshot.docs) {
    final userData = doc.data();

    final userId = doc.id;

    final servicesSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('userId', isEqualTo: userId)
        .get();


     // Map service documents to Product objects
        List<Product> services = servicesSnapshot.docs.map((serviceDoc) {
          return Product.fromMap(serviceDoc.data());
        }).toList();

        // Create a CustomUser object and add it to the list
        CustomUser prestataire = CustomUser.fromMap(userData, services);
        prestataire.uid = userId; // Optionally set the ID in the CustomUser object
        prestataires.add(prestataire);
  }

  return prestataires;
}


  Future<void> updateUserProfileImage(String userId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'imageUrl': imageUrl});
      _customUser = _customUser?.copyWith(imageUrl: imageUrl);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'image de profil: $e');
    }
  }
}

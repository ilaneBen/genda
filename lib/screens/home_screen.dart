import 'package:flutter/material.dart';
import 'package:granity/screens/login_screen.dart';
import 'package:granity/screens/profile_screen_client.dart';
import 'package:granity/services/product_service.dart';
import 'package:granity/services/auth_service.dart';
import 'package:granity/widgets/product_cart.dart';
import 'package:granity/models/product.dart';
import 'package:granity/screens/add_product_sreen.dart';
import 'package:granity/screens/profile_screen_prestataire.dart';
import 'package:granity/screens/cart_screen.dart';
import 'package:granity/screens/register_screen.dart';
import 'package:provider/provider.dart';
import 'package:granity/providers/user_provider.dart';
import 'dart:math';
import 'package:granity/models/user.dart';
import 'package:granity/screens/prestataire_detail_screen.dart';
import 'package:geocoding/geocoding.dart' as geocoding; // Préfixe pour geocoding
import 'package:location/location.dart' as location; // Préfixe pour location
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importer LatLng pour la distance

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();
  String _searchQuery = '';
  List<Product> _products = [];
  List<CustomUser> _users = [];
  bool _hasSearched = false;
  List<CustomUser> _prestataires = [];
  location.LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _fetchPrestataires();
    _getCurrentLocation(); // Assurez-vous d'avoir cette méthode pour initialiser _currentLocation
  }

  Future<void> _fetchPrestataires() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final prestataires = await userProvider.getPrestataires();
    print('Fetched prestataires: $prestataires'); // Ajoutez cette ligne
    setState(() {
      _prestataires = prestataires;
    });
  }

Future<void> _searchPrestatairesByName() async {
  if (_searchQuery.isNotEmpty && _currentLocation != null) {
    final users = await _userService.searchPrestatairesByName(_searchQuery);
    print('Users fetched by name: $users'); // Affiche les utilisateurs récupérés

    List<CustomUser> filteredUsers = [];

    for (var user in users) {
      final address = user.address;
      if (address != null && address.isNotEmpty) {
        final coordinates = await _getCoordinatesFromAddress(address);
        if (coordinates != null) {
          print('Coordinates for user "${user.name}": $coordinates');
          final distance = _calculateDistance(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
            coordinates.latitude,
            coordinates.longitude,
          );
          print('Distance to user "${user.name}": $distance km');

          // Mettez à jour la distance dans l'objet utilisateur si nécessaire
          user = user.copyWith(distance: distance); 

          if (distance <= 50000) { // Rayon de 5 km
            filteredUsers.add(user);
          }
        } else {
          print('No coordinates found for address "${address}".');
        }
      } else {
        print('Address for user "${user.name}" is null or empty.');
      }
    }

    print('Filtered users: $filteredUsers'); // Affiche les utilisateurs filtrés
    setState(() {
      _users = filteredUsers;
      _hasSearched = true;
    });
  }
}

  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    try {
      // Vérifier que l'instance de GeocodingPlatform n'est pas nulle
      final geocoding2 = geocoding.GeocodingPlatform.instance;
      if (geocoding2 != null) {
        // Appeler la méthode de manière conditionnelle
        final locations = await geocoding2.locationFromAddress(address);
        if (locations.isNotEmpty) {
          final location = locations.first;
          print('Coordinates for address $address: ${location.latitude}, ${location.longitude}');
          return LatLng(location.latitude, location.longitude);
        }
      } else {
        print('GeocodingPlatform.instance est nul.');
      }
    } catch (e) {
      print('Error getting coordinates from address: $e');
    }
    return null;
  }

  double _calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    const double pi = 3.1415926535897932;
    const double earthRadius = 6371000; // Earth radius in meters

    double toRadians(double degree) => degree * pi / 180.0;

    double lat1 = toRadians(startLat);
    double lon1 = toRadians(startLng);
    double lat2 = toRadians(endLat);
    double lon2 = toRadians(endLng);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = (sin(dLat / 2) * sin(dLat / 2)) +
               (cos(lat1) * cos(lat2) *
                sin(dLon / 2) * sin(dLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c / 1000; // Return distance in kilometers
  }

  Future<void> _getCurrentLocation() async {
    location.Location location1 = location.Location();
    try {
      _currentLocation = await location1.getLocation();
      print(_currentLocation);
      // Utiliser les coordonnées pour obtenir l'adresse
      final currentAddress = await _getAddressFromCoordinates(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      );
      print('Current address: $currentAddress');
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.postalCode}, ${placemark.locality}';
      }
    } catch (e) {
      print('Error getting address from coordinates: $e');
    }
    return 'Unknown location';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: Text('Granity'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 30),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () async {
              if (isLoggedIn) {
                String? userId = userProvider.uid;
                if (userId != null) {
                  CustomUser? currentUser = await userProvider.getUser(userId);
                  if (currentUser != null) {
                    if (currentUser.role == 'Prestataire') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreenPrestataire()),
                      );
                    } else if (currentUser.role == 'Client') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreenClient()),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Utilisateur non trouvé. Veuillez vous reconnecter.'),
                      duration: Duration(seconds: 3),
                    ));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Utilisateur non trouvé. Veuillez vous reconnecter.'),
                    duration: Duration(seconds: 3),
                  ));
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onSubmitted: (value) => _searchPrestatairesByName(),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
            if (_hasSearched && _products.isEmpty && _users.isEmpty)
              Expanded(
                child: Center(
                  child: Text('No results found.', style: TextStyle(
          color: Colors.black, // Couleur blanche pour le texte
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          fontSize: 25, // Vous pouvez ajuster la taille du texte
        ),),
                 
                ),
              ),
            if (_products.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: _products[index]);
                  },
                ),
              ),
if (_users.isNotEmpty)
  Expanded(
    child: ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          leading: user.imageUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(user.imageUrl!),
                )
              : CircleAvatar(
                  child: Icon(Icons.person),
                ),
          title: Text(user.name, style: TextStyle(color: Colors.white)),
          subtitle: Text('Role: ${user.role}', style: TextStyle(color: Colors.white)),
          trailing: user.distance != null
              ? Text('${user.distance!.toStringAsFixed(2)} km', style: TextStyle(color: Colors.white))
              : null,
          tileColor: Colors.black.withOpacity(0.6),
          onTap: () {
            // Naviguer vers la page des détails du prestataire
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrestataireDetailScreen(prestataire: user),
              ),
            );
          },
        );
      },
    ),
  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

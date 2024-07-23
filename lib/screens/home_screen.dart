import 'package:flutter/material.dart';
import 'dart:math';
import 'package:granity/screens/login_screen.dart';
import 'package:granity/screens/profile_screen_client.dart';
import 'package:granity/services/product_service.dart';
import 'package:granity/services/auth_service.dart';
import 'package:granity/screens/add_product_sreen.dart';
import 'package:granity/screens/profile_screen_prestataire.dart';
import 'package:granity/widgets/product_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:granity/providers/user_provider.dart';
import 'package:granity/models/user.dart';
import 'package:granity/screens/prestataire_detail_screen.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart' as location;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();
  bool _isLoading = true;
  String _searchQuery = '';
  List<CustomUser> _prestataires = [];
  List<CustomUser> _filteredUsers = [];
  bool _hasSearched = false;
  location.LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    location.Location location1 = location.Location();
    try {
      _currentLocation = await location1.getLocation();
      await _fetchPrestataires();
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

Future<void> _fetchPrestataires() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final prestataires = await userProvider.getPrestataires();

  List<CustomUser> prestatairesWithDistance = [];
  for (var user in prestataires) {
    final services = await _productService.getServicesByUserId(user.uid);
        user = user.copyWith(services: services);
        final address = '${user.address}, ${user.codePostal}, ${user.ville}';
    if (address != null && address.isNotEmpty) {
      final coordinates = await _getCoordinatesFromAddress(address);
      if (coordinates != null) {
        final distance = _calculateDistance(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
          coordinates.latitude,
          coordinates.longitude,
        );
        user = user.copyWith(distance: distance);
                    print('Adresse: $address');

            print('Distance: $distance, Latitude: ${coordinates.latitude}, Longitude: ${coordinates.longitude}');

        prestatairesWithDistance.add(user);
      } else {
        print('Coordinates not found for address: $address');
      }
    } else {
      print('Address is missing for user: ${user.name}');
    }
  }

  prestatairesWithDistance.sort((a, b) => a.distance!.compareTo(b.distance!));

  setState(() {
    _prestataires = prestatairesWithDistance;
    _filteredUsers = prestatairesWithDistance;
    _isLoading = false;
  });
}



// Fonction pour normaliser la chaîne de recherche
String normalizeString(String input) {
  return input
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '') // Retirer les caractères spéciaux
      .toLowerCase();
}

// Utilisation dans votre fonction de recherche
 Future<void> _searchPrestatairesByName() async {
  if (_searchQuery.isNotEmpty) {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _userService.searchPrestatairesByName(_searchQuery);

      List<CustomUser> filteredUsers = [];
      for (var user in users) {
        final services = await _productService.getServicesByUserId(user.uid);
        user = user.copyWith(services: services);

        final address = '${user.address}, ${user.codePostal}, ${user.ville}';
        if (address != null && address.isNotEmpty) {
          final coordinates = await _getCoordinatesFromAddress(address);
          if (coordinates != null) {
            final distance = _calculateDistance(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
              coordinates.latitude,
              coordinates.longitude,
            );
            user = user.copyWith(distance: distance);

            if (distance <= 50000) {
              filteredUsers.add(user);
            }
          }
        }
      }

      filteredUsers.sort((a, b) => a.distance!.compareTo(b.distance!));

      setState(() {
        _filteredUsers = filteredUsers;  // Assurez-vous que _filteredUsers est bien assigné
        _hasSearched = true;
      });
    } catch (e) {
      print('Error searching prestataires: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  } else {
    setState(() {
      _filteredUsers = _prestataires;  // Réinitialisez _filteredUsers si la requête est vide
      _hasSearched = false;
    });
  }
}
  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    try {
      final locations = await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
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
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: Text('Genda'),
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
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('assets/images/home.jpg'),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    if (_searchQuery.isEmpty) {
                      _hasSearched = false;
                      _filteredUsers = _prestataires;
                    }
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    _hasSearched = true;
                  });
                  _searchPrestatairesByName();
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un préstataire...',
                  filled: true,
                  fillColor: Color.fromARGB(255, 255, 255, 255),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
      ? Center(
          child: CircularProgressIndicator(), // Affiche un cercle de chargement
        )
                  : _filteredUsers.isEmpty
                      ? Center(
                          child: Text(
                            _hasSearched ? 'No results found.' : 'No prestataires available.',
                            style: TextStyle(
                              color: Colors.black,
                              backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                              fontSize: 25,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(8.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 3 / 6,
                          ),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return EstablishmentCard(user: user);
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

class EstablishmentCard extends StatelessWidget {
  final CustomUser user;

  const EstablishmentCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:1000.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6.0, spreadRadius: 2.0)],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrestataireDetailScreen(prestataire: user),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                child: Image.network(
                  user.imageUrl!,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                user.name,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Adresse: ${user.address} ${user.codePostal}, ${user.ville}',
                style: TextStyle(color: Colors.black),
              ),
            ),
            if (user.distance != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${user.distance!.toStringAsFixed(1)} km',
                  style: TextStyle(color: Colors.black, fontSize: 20,),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
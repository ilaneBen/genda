import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:granity/providers/reservation_provider.dart';
import 'package:granity/providers/service_provider.dart';
import 'package:provider/provider.dart';
import 'package:granity/providers/cart_provider.dart';
import 'package:granity/providers/user_provider.dart';
import 'package:granity/screens/home_screen.dart';
import 'package:granity/screens/cart_screen.dart';
import 'package:granity/screens/add_product_sreen.dart';
import 'package:granity/screens/register_screen.dart';
import 'package:granity/screens/login_screen.dart';
import 'package:granity/screens/profile_screen_client.dart';
import 'package:granity/screens/profile_screen_prestataire.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:granity/models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('fr_FR', null);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..checkUserAuthState()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (context) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Granity',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/': (context) => MainScreen(),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.isLoggedIn;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(),
          CartScreen(),
          FutureBuilder<CustomUser?>(
            future: isLoggedIn ? userProvider.getUser(userProvider.uid!) : Future.value(null),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final currentUser = snapshot.data!;
                if (currentUser.role == 'prestataire') {
                  return ProfileScreenPrestataire();
                } else if (currentUser.role == 'client') {
                  return ProfileScreenClient();
                } else {
                  return LoginScreen();
                }
              } else {
                return LoginScreen();
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Ajouter',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:granity/providers/user_provider.dart';
import 'package:granity/screens/login_screen.dart';

class ProfileScreenClient extends StatelessWidget {

  const ProfileScreenClient({super.key});
  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Client'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 30),
      ),
      body: Padding(
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
                style: ElevatedButton.styleFrom(
                  // primary: Colors.black,
                  // onPrimary: Colors.white,
                ),
              ),
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
                style: ElevatedButton.styleFrom(
                  // onSurface: Colors.black,
                  // onPrimary: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

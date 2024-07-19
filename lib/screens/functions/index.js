const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.registerUser = functions.https.onRequest(async (req, res) => {
    const { email, password, phoneNumber, isProvider } = req.body; // Récupérer les données de la requête
    
    try {
      const userCredential = await admin.auth().createUser({
        email: email,
        password: password,
        phoneNumber: phoneNumber
      });
  
      // Définir les custom claims si l'utilisateur est un prestataire
      if (isProvider) {
        await admin.auth().setCustomUserClaims(userCredential.uid, { isProvider: true });
      }
  
      res.status(200).send('Utilisateur inscrit avec succès!');
    } catch (error) {
      console.error('Erreur lors de l\'inscription:', error);
      res.status(500).send('Erreur serveur lors de l\'inscription.');
    }
  });

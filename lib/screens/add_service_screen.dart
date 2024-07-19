// screens/add_service_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:granity/models/service.dart';
import 'package:granity/providers/service_provider.dart';

class AddServiceForm extends StatefulWidget {
  @override
  _AddServiceFormState createState() => _AddServiceFormState();
}

class _AddServiceFormState extends State<AddServiceForm> {
  final _formKey = GlobalKey<FormState>();
  late String _serviceName;
  late String _serviceDescription;
  late Duration _serviceDuration = Duration(hours: 1); // Default duration
  late double _servicePrice;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: 'Nom du service'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le nom du service';
              }
              return null;
            },
            onSaved: (value) {
              _serviceName = value!;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer une description';
              }
              return null;
            },
            onSaved: (value) {
              _serviceDescription = value!;
            },
          ),
          Row(
            children: <Widget>[
              Text('Durée du service: '),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _serviceDuration = Duration(hours: 1);
                  });
                },
                child: Text('1h'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _serviceDuration = Duration(hours: 2);
                  });
                },
                child: Text('2h'),
              ),
              // Add more buttons for other durations if needed
            ],
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Prix'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le prix';
              }
              if (double.tryParse(value) == null) {
                return 'Entrez un montant valide';
              }
              return null;
            },
            onSaved: (value) {
              _servicePrice = double.parse(value!);
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                // Create an instance of Service with the entered values
                Service newService = Service(
                  id: '', // Generate or assign an ID as per your requirements
                  productId: '', // Generate or assign an ID as per your requirements
                  name: _serviceName,
                  description: _serviceDescription,
                  duration: _serviceDuration,
                  price: _servicePrice,
                );

                // Access the ServiceProvider and add the service
                Provider.of<ServiceProvider>(context, listen: false).addService(newService);

                // Show a success message or redirect the user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Prestation ajoutée avec succès'),
                  ),
                );
              }
            },
            child: Text('Ajouter la prestation'),
          ),
        ],
      ),
    );
  }
}

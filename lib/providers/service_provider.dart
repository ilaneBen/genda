// providers/service_provider.dart

import 'package:flutter/material.dart';
import 'package:granity/models/service.dart';

class ServiceProvider extends ChangeNotifier {
  List<Service> _services = []; // List of services

  List<Service> get services => _services;

  void addService(Service service) {
    _services.add(service);
    notifyListeners();
  }

  // Add more methods as needed, e.g., removeService, fetchServices, etc.
}

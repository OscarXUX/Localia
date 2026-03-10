import 'package:flutter/material.dart';
import '../models/business.dart';

// Definimos la clase de evento aquí mismo para evitar errores de importación
class WorldCupEvent {
  final String matchTitle;
  WorldCupEvent({required this.matchTitle});
}

class LocaliaProvider with ChangeNotifier {
  // --- VARIABLES DE ESTADO ---
  double _balance = 2500.0; 
  int _coppelPoints = 450;
  double _totalSocialImpact = 1250.0;
  List<String> _history = ["Carga inicial: +2500.00"];
  bool _isProcessing = false;
  bool _isAdmin = false;
  List<String> _favoriteIds = [];

  // Lista de eventos para el World Cup Ticker (Tourist Screen)
  final List<WorldCupEvent> _events = [
    WorldCupEvent(matchTitle: "🇲🇽 México vs 🇩🇪 Alemania - 18:00 hrs"),
    WorldCupEvent(matchTitle: "🇦🇷 Argentina vs 🇫🇷 Francia - 21:00 hrs"),
  ];

  // Lista de negocios
  final List<Business> _allBusinesses = [
    Business(id: '1', name: 'Tacos El Mundial', category: 'Comida', rating: 4.9, icon: Icons.restaurant, mapX: 0.2, mapY: 0.4, priceLevel: 1),
    Business(id: '2', name: 'Artesanías GTO', category: 'Artesanía', rating: 4.8, icon: Icons.palette, mapX: 0.7, mapY: 0.5, priceLevel: 1),
    Business(id: '3', name: 'Hotel Pénjamo', category: 'Servicio', rating: 4.5, icon: Icons.hotel, mapX: 0.4, mapY: 0.7, priceLevel: 2),
  ];

  // --- GETTERS (Lo que las pantallas necesitan leer) ---
  double get balance => _balance;
  int get coppelPoints => _coppelPoints;
  double get totalSocialImpact => _totalSocialImpact;
  bool get isProcessing => _isProcessing;
  bool get isAdmin => _isAdmin;
  List<String> get history => _history;
  List<String> get favorites => _favoriteIds;
  List<Business> get businesses => _allBusinesses;
  List<Business> get filteredBusinesses => _allBusinesses;
  List<WorldCupEvent> get events => _events; // Este arregla el error de tourist_screen

  // --- MÉTODOS ---
  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleFavorite(String id) {
    _favoriteIds.contains(id) ? _favoriteIds.remove(id) : _favoriteIds.add(id);
    notifyListeners();
  }

  void setRole(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  void addBusiness(Business business) {
    _allBusinesses.add(business);
    notifyListeners();
  }

  Future<void> makePurchase(double amount, String businessName) async {
    if (_balance >= amount) {
      _isProcessing = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1)); 
      _balance -= amount;
      _totalSocialImpact += amount;
      _history.insert(0, "Pago en $businessName: -\$${amount.toStringAsFixed(2)}");
      _coppelPoints += (amount * 0.1).toInt();
      _isProcessing = false;
      notifyListeners();
    }
  }
}
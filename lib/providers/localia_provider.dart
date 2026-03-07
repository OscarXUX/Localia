import 'package:flutter/material.dart';
import '../models/business.dart';
import '../models/event.dart';

class LocaliaProvider with ChangeNotifier {
  bool isAdmin = false;
  int selectedIndex = 0;
  bool isProcessing = false;
  
  // Wallet & Coppel Pay
  double balance = 2500.00;
  int coppelPoints = 150;
  List<String> history = ["Cena en Tacos GTO - 150", "Artesanía Pénjamo - 400"];

  String _searchQuery = "";
  String _selectedCategory = "Todos";
  List<String> favorites = [];

  final List<Business> businesses = [
    Business(id: '1', name: 'Tacos El Mundial', category: 'Comida', icon: Icons.restaurant, rating: 4.9, mapX: 0.2, mapY: 0.35),
    Business(id: '2', name: 'Artesanías GTO', category: 'Artesanía', icon: Icons.brush, rating: 4.7, mapX: 0.7, mapY: 0.45),
    Business(id: '3', name: 'Hotel Pénjamo', category: 'Servicio', icon: Icons.hotel, rating: 4.5, mapX: 0.45, mapY: 0.65),
  ];

  final List<WorldCupEvent> events = [
    WorldCupEvent(id: 'e1', matchTitle: 'México vs Brasil', stadium: 'Estadio León', time: '18:00', date: '15 Junio'),
  ];

  List<Business> get filteredBusinesses => businesses.where((biz) {
    final matchesSearch = biz.name.toLowerCase().contains(_searchQuery.toLowerCase());
    final matchesCat = _selectedCategory == "Todos" || biz.category == _selectedCategory;
    return matchesSearch && matchesCat;
  }).toList();

  void setRole(bool admin) { isAdmin = admin; notifyListeners(); }
  void updateSearch(String q) { _searchQuery = q; notifyListeners(); }
  void updateCategory(String c) { _selectedCategory = c; notifyListeners(); }
  void toggleFavorite(String id) { favorites.contains(id) ? favorites.remove(id) : favorites.add(id); notifyListeners(); }
  bool isFavorite(String id) => favorites.contains(id);
  
  void addBusiness(Business b) { businesses.add(b); notifyListeners(); }

  // ESTA ES LA FUNCIÓN QUE TE DABA ERROR
  Future<void> simulateAction(BuildContext context, String msg) async {
    isProcessing = true; notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    isProcessing = false; notifyListeners();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: const Color(0xFF008F39))
      );
    }
  }

  Future<void> processPayment(BuildContext context, double amount, String bizName) async {
    isProcessing = true; notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    balance -= amount;
    coppelPoints += (amount * 0.1).toInt();
    history.insert(0, "Pago en $bizName - \$$amount");
    isProcessing = false; notifyListeners();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Pago Exitoso con Coppel Pay! ✅"), backgroundColor: Color(0xFF008F39))
      );
    }
  }
}
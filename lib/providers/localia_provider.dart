import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business.dart';

// Modelo para los eventos del mundial
class WorldCupEvent {
  final String matchTitle;
  WorldCupEvent({required this.matchTitle});
}

class LocaliaProvider with ChangeNotifier {
  // ---------------------------------------------------------
  // 1. ESTADO DE LA APP
  // ---------------------------------------------------------
  double _balance = 2500.0;
  int _coppelPoints = 450;
  double _totalSocialImpact = 1250.0;
  bool _isAdmin = false;
  bool _isProcessing = false;
  bool _isLoaded = false;
  bool _showSuccess = false;

  List<Business> _allBusinesses = [];
  List<String> _favoriteIds = [];
  List<String> _history = ["Carga inicial: + 2500.00"];
  
  final List<WorldCupEvent> _events = [
    WorldCupEvent(matchTitle: "🇲🇽 México vs 🇩🇪 Alemania - 18:00 hrs"),
    WorldCupEvent(matchTitle: "🇦🇷 Argentina vs 🇫🇷 Francia - 21:00 hrs"),
  ];

  LocaliaProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromDisk();
    _isLoaded = true;
    print("🚀 LocaliaProvider: Datos listos.");
  }

  // --- GETTERS ---
  double get balance => _balance;
  int get coppelPoints => _coppelPoints;
  double get totalSocialImpact => _totalSocialImpact;
  bool get isAdmin => _isAdmin;
  bool get isProcessing => _isProcessing;
  bool get showSuccess => _showSuccess;
  List<Business> get businesses => _allBusinesses;
  List<Business> get filteredBusinesses => _allBusinesses;
  List<String> get favorites => _favoriteIds;
  List<String> get history => _history;
  List<WorldCupEvent> get events => _events;

  // ---------------------------------------------------------
  // 2. LÓGICA DE PERSISTENCIA
  // ---------------------------------------------------------

  Future<void> _saveToDisk() async {
    if (!_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('balance', _balance);
      await prefs.setInt('points', _coppelPoints);
      await prefs.setDouble('impact', _totalSocialImpact);
      await prefs.setBool('isAdmin', _isAdmin);
      await prefs.setStringList('favorites', _favoriteIds);
      await prefs.setStringList('history', _history);

      List<String> bizJsonList = _allBusinesses.map((b) => jsonEncode(b.toJson())).toList();
      await prefs.setStringList('businesses', bizJsonList);
    } catch (e) {
      debugPrint("❌ Error al guardar: $e");
    }
  }

  Future<void> _loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _balance = prefs.getDouble('balance') ?? 2500.0;
      _coppelPoints = prefs.getInt('points') ?? 450;
      _totalSocialImpact = prefs.getDouble('impact') ?? 1250.0;
      _isAdmin = prefs.getBool('isAdmin') ?? false;
      _favoriteIds = prefs.getStringList('favorites') ?? [];
      _history = prefs.getStringList('history') ?? ["Carga inicial: +2500.00"];

      List<String>? savedBiz = prefs.getStringList('businesses');
      if (savedBiz != null && savedBiz.isNotEmpty) {
        _allBusinesses = savedBiz.map((item) => Business.fromJson(jsonDecode(item))).toList();
      } else {
        _allBusinesses = [
          Business(id: '1', name: 'Tacos El Mundial', category: 'Comida', rating: 4.9, icon: Icons.restaurant, mapX: 0.2, mapY: 0.4),
          Business(id: '2', name: 'Artesanías GTO', category: 'Artesanía', rating: 4.8, icon: Icons.palette, mapX: 0.7, mapY: 0.5),
        ];
      }
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error al cargar: $e");
    }
  }

  // ---------------------------------------------------------
  // 3. MÉTODOS DE ACCIÓN
  // ---------------------------------------------------------

  /// --- NUEVA FUNCIÓN: Agrega una reseña a un negocio específico ---
  void addReviewToBusiness(String businessId, String review) {
    // 1. Buscamos el negocio en la lista por su ID
    final index = _allBusinesses.indexWhere((b) => b.id == businessId);
    
    if (index != -1) {
      final business = _allBusinesses[index];
      
      // 2. Creamos una copia de la lista de reseñas y agregamos la nueva al principio
      final updatedReviews = List<String>.from(business.reviews)..insert(0, review);
      
      // 3. Como los campos del modelo Business son final, creamos una nueva instancia actualizada
      _allBusinesses[index] = Business(
        id: business.id,
        name: business.name,
        category: business.category,
        rating: business.rating,
        icon: business.icon,
        mapX: business.mapX,
        mapY: business.mapY,
        priceLevel: business.priceLevel,
        description: business.description,
        address: business.address,
        phone: business.phone,
        representative: business.representative,
        schedule: business.schedule,
        photos: business.photos,
        reviews: updatedReviews, // <-- Aquí inyectamos la lista con el comentario nuevo
      );
      
      // 4. Guardamos el cambio en el disco y notificamos a la UI
      _saveToDisk();
      notifyListeners();
    }
  }

  void setRole(bool value) {
    _isAdmin = value;
    _saveToDisk();
    notifyListeners();
  }

  void addBusiness(Business business) {
    _allBusinesses.add(business);
    _saveToDisk();
    notifyListeners();
  }

  void deleteBusiness(String id) {
    _allBusinesses.removeWhere((biz) => biz.id == id);
    _saveToDisk();
    notifyListeners();
  }

  void updateBusiness(Business updatedBiz) {
    final index = _allBusinesses.indexWhere((biz) => biz.id == updatedBiz.id);
    if (index != -1) {
      _allBusinesses[index] = updatedBiz;
      _saveToDisk();
      notifyListeners();
    }
  }

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    _saveToDisk();
    notifyListeners();
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void dismissSuccess() {
    _showSuccess = false;
    notifyListeners();
  }

  Future<void> makePurchase(double amount, String businessName) async {
    if (_balance >= amount) {
      _isProcessing = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 1800));

      _balance -= amount;
      _totalSocialImpact += amount;
      _coppelPoints += (amount * 0.1).toInt();
      _history.insert(0, "Pago en $businessName: -\$${amount.toStringAsFixed(2)}");
      
      await _saveToDisk();
      
      _isProcessing = false;
      _showSuccess = true;
      notifyListeners();
    }
  }
}
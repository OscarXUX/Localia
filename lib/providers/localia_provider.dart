import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business.dart';

// Modelo para los eventos del mundial (necesario para el ticker en tourist_screen)
class WorldCupEvent {
  final String matchTitle;
  WorldCupEvent({required this.matchTitle});
}

class LocaliaProvider with ChangeNotifier {
  // ---------------------------------------------------------
  // 1. ESTADO DE LA APP (Variables)
  // ---------------------------------------------------------
  double _balance = 2500.0;
  int _coppelPoints = 450;
  double _totalSocialImpact = 1250.0;
  bool _isAdmin = false;
  bool _isProcessing = false;
  bool _isLoaded = false; // Flag de seguridad para la persistencia

  List<Business> _allBusinesses = [];
  List<String> _favoriteIds = [];
  List<String> _history = ["Carga inicial: + 2500.00"];
  
  final List<WorldCupEvent> _events = [
    WorldCupEvent(matchTitle: "🇲🇽 México vs 🇩🇪 Alemania - 18:00 hrs"),
    WorldCupEvent(matchTitle: "🇦🇷 Argentina vs 🇫🇷 Francia - 21:00 hrs"),
  ];

  // ---------------------------------------------------------
  // 2. CONSTRUCTOR E INICIALIZACIÓN
  // ---------------------------------------------------------
  LocaliaProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromDisk();
    _isLoaded = true; // Una vez cargado, habilitamos el guardado
    print("🚀 LocaliaProvider: Datos listos y persistencia activa.");
  }

  // ---------------------------------------------------------
  // 3. GETTERS (Para que tus pantallas lean los datos)
  // ---------------------------------------------------------
  double get balance => _balance;
  int get coppelPoints => _coppelPoints;
  double get totalSocialImpact => _totalSocialImpact;
  bool get isAdmin => _isAdmin;
  bool get isProcessing => _isProcessing;
  
  List<Business> get businesses => _allBusinesses;
  List<Business> get filteredBusinesses => _allBusinesses;
  List<String> get favorites => _favoriteIds;
  List<String> get history => _history;
  List<WorldCupEvent> get events => _events;

  // ---------------------------------------------------------
  // 4. LÓGICA DE PERSISTENCIA (Shared Preferences + JSON)
  // ---------------------------------------------------------

  Future<void> _saveToDisk() async {
    if (!_isLoaded) return; // No guardamos nada si aún no terminamos de cargar

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('balance', _balance);
      await prefs.setInt('points', _coppelPoints);
      await prefs.setDouble('impact', _totalSocialImpact);
      await prefs.setBool('isAdmin', _isAdmin);
      await prefs.setStringList('favorites', _favoriteIds);
      await prefs.setStringList('history', _history);

      // Serializamos la lista de objetos Business a JSON
      List<String> bizJsonList = _allBusinesses.map((b) => jsonEncode(b.toJson())).toList();
      await prefs.setStringList('businesses', bizJsonList);
      
      debugPrint("💾 Datos guardados en disco.");
    } catch (e) {
      debugPrint("❌ Error al guardar en disco: $e");
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
        // Datos por defecto solo si no hay nada guardado
        _allBusinesses = [
          Business(id: '1', name: 'Tacos El Mundial', category: 'Comida', rating: 4.9, icon: Icons.restaurant, mapX: 0.2, mapY: 0.4, priceLevel: 1),
          Business(id: '2', name: 'Artesanías GTO', category: 'Artesanía', rating: 4.8, icon: Icons.palette, mapX: 0.7, mapY: 0.5, priceLevel: 1),
        ];
      }
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error al cargar de disco: $e");
    }
  }

  // ---------------------------------------------------------
  // 5. MÉTODOS DE ACCIÓN (Negocio)
  // ---------------------------------------------------------

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

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    _saveToDisk();
    notifyListeners();
  }

  // Future<void> makePurchase(double amount, String businessName) async {
  //   if (_balance >= amount) {
  //     _isProcessing = true;
  //     notifyListeners();

  //     // Simulación de red
  //     await Future.delayed(const Duration(milliseconds: 1500));

  //     _balance -= amount;
  //     _totalSocialImpact += amount;
  //     _coppelPoints += (amount * 0.1).toInt();
  //     _history.insert(0, "Pago en $businessName: -\$${amount.toStringAsFixed(2)}");
      
  //     await _saveToDisk();
  //     _isProcessing = false;
  //     notifyListeners();
  //   }
  // }
    void deleteBusiness(String id) {
    _allBusinesses.removeWhere((biz) => biz.id == id);
    _saveToDisk(); // Guardamos el cambio permanentemente
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
  void dismissSuccess() {
   _showSuccess = false;
   notifyListeners(); // Notificamos para que el overlay desaparezca
  }
bool _showSuccess = false;
bool get showSuccess => _showSuccess;

Future<void> makePurchase(double amount, String businessName) async {
  if (_balance >= amount) {
    _isProcessing = true;
    notifyListeners();

    // Simulación de transacción (Red/Banco)
    await Future.delayed(const Duration(milliseconds: 1800));

    _balance -= amount;
    _totalSocialImpact += amount;
    _coppelPoints += (amount * 0.1).toInt();
    _history.insert(0, "Pago en $businessName: -\$${amount.toStringAsFixed(2)}");
    
    await _saveToDisk();
    
    // --- NUEVA LÓGICA DE ANIMACIÓN ---
    _isProcessing = false;
    _showSuccess = true; // Activamos la animación
    notifyListeners();
    
  }
}
}
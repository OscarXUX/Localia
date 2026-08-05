import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // <-- Librería oficial agregada para microservicios
import '../models/business.dart';
import '../config/constants.dart';

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
  bool _isLoadingBackend = false; // <-- Controla el spinner de carga de red

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
    // 1. Cargamos rápido del almacenamiento local lo que tengamos guardado
    await _loadFromDisk();
    _isLoaded = true;
    print("🚀 LocaliaProvider: Caché local lista. Sincronizando con microservicio...");
    
    // 2. Intentamos jalar los datos reales del mapa en segundo plano sin bloquear la UI
    cargarNegociosDesdeBackend();
  }

  // --- GETTERS ---
  double get balance => _balance;
  int get coppelPoints => _coppelPoints;
  double get totalSocialImpact => _totalSocialImpact;
  bool get isAdmin => _isAdmin;
  bool get isProcessing => _isProcessing;
  bool get showSuccess => _showSuccess;
  bool get isLoadingBackend => _isLoadingBackend; // <-- Getter expuesto para la UI
  List<Business> get businesses => _allBusinesses;
  List<Business> get filteredBusinesses => _allBusinesses;
  List<String> get favorites => _favoriteIds;
  List<String> get history => _history;
  List<WorldCupEvent> get events => _events;

  // ---------------------------------------------------------
  // 2. LÓGICA DE PERSISTENCIA Y MICROSERVICIOS
  // ---------------------------------------------------------

  /// Se conecta al microservicio de Node.js para actualizar el catálogo
  Future<void> cargarNegociosDesdeBackend() async {
    _isLoadingBackend = true;
    notifyListeners();

    // Construimos la URL usando el archivo de constantes dinámico
    final url = Uri.parse('${AppConfig.baseUrl}/negocios');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        final List<dynamic> dataJson = decodedBody['data'];
        
        // Mapeamos el arreglo del servidor al modelo interno de Flutter
        _allBusinesses = dataJson.map((json) => Business.fromJson(json)).toList();
        
        // Sobrescribimos en el almacenamiento local para soporte offline
        await _saveToDisk();
      } else {
        debugPrint("❌ Error de respuesta del servidor: ${response.statusCode}");
      }
    } catch (e) {
      // Si el servidor está apagado, se mantendrán los datos cargados desde el disco de manera segura
      debugPrint("❌ No se pudo conectar al microservicio backend: $e");
    } finally {
      _isLoadingBackend = false;
      notifyListeners(); // Redibuja mapas y componentes dinámicamente
    }
  }

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
      debugPrint("❌ Error al guardar en disco duro: $e");
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
        // Datos de respaldo iniciales por si es el primer arranque y no hay red
        _allBusinesses = [
          Business(id: '1', name: 'Tacos El Mundial', category: 'Comida', rating: 4.9, icon: Icons.restaurant, mapX: 0.2, mapY: 0.4),
          Business(id: '2', name: 'Artesanías GTO', category: 'Artesanía', rating: 4.8, icon: Icons.palette, mapX: 0.7, mapY: 0.5),
        ];
      }
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error al cargar de disco duro: $e");
    }
  }

  // ---------------------------------------------------------
  // 3. MÉTODOS DE ACCIÓN
  // ---------------------------------------------------------

  void addReviewToBusiness(String businessId, String review) {
    final index = _allBusinesses.indexWhere((b) => b.id == businessId);
    
    if (index != -1) {
      final business = _allBusinesses[index];
      final updatedReviews = List<String>.from(business.reviews)..insert(0, review);
      
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
        reviews: updatedReviews,
      );
      
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

  void auditarSeguridadSandbox() {
    debugPrint("🔒 AUDITORÍA DE SEGURIDAD NATIVA - SANDBOX LOCALIA");
    debugPrint(" Saldo Disponible Wallet: ${_balance} MXN");
    debugPrint(" Puntos Coppel Acumulados: ${_coppelPoints}");
    debugPrint(" Impacto Social en Sedes Mundial: ${_totalSocialImpact} MXN");
    debugPrint(" Rol de Usuario actual: ${_isAdmin ? 'ADMINISTRADOR' : 'TURISTA'}");
    debugPrint(" Número de PyMEs Registradas en Disco: ${_allBusinesses.length}");
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
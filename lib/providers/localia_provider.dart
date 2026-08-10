import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/business.dart';
import '../config/constants.dart';

// Modelo para los eventos del mundial
class WorldCupEvent {
  final String matchTitle;
  WorldCupEvent({required this.matchTitle});
}

class LocaliaProvider with ChangeNotifier {
  // ---------------------------------------------------------
  // 1. ESTADO DE LA APP Y RED
  // ---------------------------------------------------------
  
  // IP Dinámica: Detecta si estás en el emulador de Android (10.0.2.2) o en tu PC (localhost)
  final String _ip = kIsWeb ? 'localhost' : (defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost');

  // Datos de Wallet (Puerto 3001)
  double _balance = 2500.0;
  int _coppelPoints = 450;
  double _totalSocialImpact = 1250.0;
  List<String> _history = ["Carga inicial: + 2500.00"];

  // Datos de Usuarios (Puerto 3003) y Promociones (Puerto 3004)
  Map<String, dynamic> perfilUsuario = {};
  List<dynamic> cuponesActivos = [];

  // Datos de Negocios (Puerto 3000)
  List<Business> _allBusinesses = [];
  List<String> _favoriteIds = [];

  // Variables de control de UI
  bool _isAdmin = false;
  bool _isProcessing = false;
  bool _isLoaded = false;
  bool _showSuccess = false;
  bool _isLoadingBackend = false; 
  
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
    debugPrint("🚀 LocaliaProvider: Caché local lista. Sincronizando con los 5 microservicios...");
    
    // 2. Intentamos jalar los datos reales de todo el ecosistema en segundo plano
    await sincronizarEcosistema();
  }

  // --- GETTERS (Expuestos para la UI) ---
  double get balance => _balance;
  int get coppelPoints => _coppelPoints;
  double get totalSocialImpact => _totalSocialImpact;
  bool get isAdmin => _isAdmin;
  bool get isProcessing => _isProcessing;
  bool get showSuccess => _showSuccess;
  bool get isLoadingBackend => _isLoadingBackend;
  
  List<Business> get businesses => _allBusinesses;
  List<Business> get filteredBusinesses => _allBusinesses;
  List<String> get favorites => _favoriteIds;
  List<String> get history => _history;
  List<WorldCupEvent> get events => _events;
  
  // Nuevos Getters para el Perfil y Promociones
  Map<String, dynamic> get perfil => perfilUsuario;
  List<dynamic> get cupones => cuponesActivos;

  // ---------------------------------------------------------
  // 2. LÓGICA DE PERSISTENCIA Y MICROSERVICIOS (LECTURA)
  // ---------------------------------------------------------

  /// Se conecta a los múltiples microservicios de Node.js para actualizar la app
  Future<void> sincronizarEcosistema() async {
    _isLoadingBackend = true;
    notifyListeners();

    try {
      // 1. Petición al Microservicio de Negocios (Puerto 3000)
      final resNegocios = await http.get(Uri.parse('http://$_ip:3000/api/v1/negocios'));
      if (resNegocios.statusCode == 200) {
        final List<dynamic> dataJson = json.decode(resNegocios.body)['data'];
        _allBusinesses = dataJson.map((json) => Business.fromJson(json)).toList();
      }

      // 2. Petición al Microservicio de Wallet (Puerto 3001)
      final resWallet = await http.get(Uri.parse('http://$_ip:3001/api/v1/wallet'));
      if (resWallet.statusCode == 200) {
        final dataWallet = json.decode(resWallet.body)['data'];
        _balance = (dataWallet['balance'] as num).toDouble();
        _coppelPoints = dataWallet['coppelPoints'];
        _totalSocialImpact = (dataWallet['totalSocialImpact'] as num).toDouble();
        _history = List<String>.from(dataWallet['history']);
      }

      // 3. Petición al Microservicio de Usuarios (Puerto 3003)
      final resUsuario = await http.get(Uri.parse('http://$_ip:3003/api/v1/usuarios/perfil'));
      if (resUsuario.statusCode == 200) {
        perfilUsuario = json.decode(resUsuario.body)['data'];
      }

      // 4. Petición al Microservicio de Promociones (Puerto 3004)
      final resPromos = await http.get(Uri.parse('http://$_ip:3004/api/v1/promociones'));
      if (resPromos.statusCode == 200) {
        cuponesActivos = json.decode(resPromos.body)['data'];
      }

      // Sobrescribimos en el almacenamiento local para soporte offline
      await _saveToDisk();
      debugPrint("✅ Ecosistema Localia sincronizado con éxito.");
      
    } catch (e) {
      // Si los servidores están apagados, se mantendrán los datos cargados desde el disco duro
      debugPrint("❌ Error al conectar con los microservicios (Usando caché offline): $e");
    } finally {
      _isLoadingBackend = false;
      notifyListeners(); // Redibuja toda la interfaz con los datos frescos
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
  // 3. MÉTODOS DE ACCIÓN Y NEGOCIO (ESCRITURA A BACKEND)
  // ---------------------------------------------------------

  Future<void> addReviewToBusiness(String businessId, String review) async {
    // 1. Actualización visual instantánea en la app (Optimistic UI)
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
      
      await _saveToDisk();
      notifyListeners();
    }

    // 2. Envío al Microservicio de Reseñas (Puerto 3002)
    try {
      await http.post(
        Uri.parse('http://$_ip:3002/api/v1/resenas'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'businessId': businessId,
          'touristName': perfilUsuario.isNotEmpty ? perfilUsuario['name'] : 'Turista Localia',
          'comment': review,
          'rating': 5
        }),
      );
      debugPrint("✅ Reseña publicada en el servidor 3002.");
    } catch (e) {
      debugPrint("⚠️ No se pudo enviar al servidor, pero se guardó en el celular: $e");
    }
  }

  Future<void> addBusiness(Business business) async {
    // 1. Actualización visual instantánea en la app (Optimistic UI)
    _allBusinesses.add(business);
    await _saveToDisk();
    notifyListeners();

    // 2. Envío al Microservicio de Negocios (Puerto 3000)
    try {
      await http.post(
        Uri.parse('http://$_ip:3000/api/v1/negocios'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(business.toJson()), // Convertimos el negocio a JSON para que Node lo entienda
      );
      debugPrint("✅ Negocio publicado en el servidor 3000.");
    } catch (e) {
      debugPrint("⚠️ No se pudo enviar al servidor, pero se guardó en el celular: $e");
    }
  }

  void setRole(bool value) {
    _isAdmin = value;
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
    debugPrint(" Saldo Disponible Wallet: \$$_balance MXN");
    debugPrint(" Puntos Coppel Acumulados: $_coppelPoints");
    debugPrint(" Impacto Social en Sedes Mundial: \$$_totalSocialImpact MXN");
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
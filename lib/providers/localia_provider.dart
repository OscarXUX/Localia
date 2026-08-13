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
  
  final String _ip = kIsWeb ? 'localhost' : (defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost');

  double _balance = 2500.0;
  int _coppelPoints = 450;
  double _totalSocialImpact = 1250.0;
  List<String> _history = ["Carga inicial: + 2500.00"];

  Map<String, dynamic> perfilUsuario = {};
  List<dynamic> cuponesActivos = [];

  List<Business> _allBusinesses = [];
  List<String> _favoriteIds = [];

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
    await _loadFromDisk();
    _isLoaded = true;
    debugPrint("🚀 LocaliaProvider: Caché local lista. Sincronizando con los 5 microservicios...");
    await sincronizarEcosistema();
  }

  // --- GETTERS ---
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
  
  Map<String, dynamic> get perfil => perfilUsuario;
  List<dynamic> get cupones => cuponesActivos;

  // ---------------------------------------------------------
  // 2. LÓGICA DE PERSISTENCIA Y MICROSERVICIOS
  // ---------------------------------------------------------

  Future<void> sincronizarEcosistema() async {
    _isLoadingBackend = true;
    notifyListeners();

    try {
      final resNegocios = await http.get(Uri.parse('http://$_ip:3000/api/v1/negocios'));
      if (resNegocios.statusCode == 200) {
        final List<dynamic> dataJson = json.decode(resNegocios.body)['data'];
        _allBusinesses = dataJson.map((json) => Business.fromJson(json)).toList();
      }

      final resWallet = await http.get(Uri.parse('http://$_ip:3001/api/v1/wallet'));
      if (resWallet.statusCode == 200) {
        final dataWallet = json.decode(resWallet.body)['data'];
        _balance = (dataWallet['balance'] as num).toDouble();
        _coppelPoints = dataWallet['coppelPoints'];
        _totalSocialImpact = (dataWallet['totalSocialImpact'] as num).toDouble();
        _history = List<String>.from(dataWallet['history']);
      }

      // Por defecto, al iniciar carga el perfil premium
      final resUsuario = await http.get(Uri.parse('http://$_ip:3003/api/v1/usuarios/perfil?tipo=premium'));
      if (resUsuario.statusCode == 200) {
        perfilUsuario = json.decode(resUsuario.body)['data'];
      }

      final resPromos = await http.get(Uri.parse('http://$_ip:3004/api/v1/promociones'));
      if (resPromos.statusCode == 200) {
        cuponesActivos = json.decode(resPromos.body)['data'];
      }

      await _saveToDisk();
      debugPrint("✅ Ecosistema Localia sincronizado con éxito.");
      
    } catch (e) {
      debugPrint("❌ Error al conectar con los microservicios: $e");
    } finally {
      _isLoadingBackend = false;
      notifyListeners(); 
    }
  }

  // 🔥 NUEVA FUNCIÓN: Cambiar de Usuario Dinámicamente
  Future<void> cambiarUsuario(String tipoUsuario) async {
    _isLoadingBackend = true;
    notifyListeners(); // Muestra el spinner de carga en la app

    try {
      // Va al microservicio 3003 y le pide el perfil específico
      final resUsuario = await http.get(Uri.parse('http://$_ip:3003/api/v1/usuarios/perfil?tipo=$tipoUsuario'));
      
      if (resUsuario.statusCode == 200) {
        perfilUsuario = json.decode(resUsuario.body)['data'];
        debugPrint("✅ Usuario cambiado exitosamente a: $tipoUsuario");
      }
    } catch (e) {
      debugPrint("❌ Error al cambiar de usuario: $e");
    } finally {
      _isLoadingBackend = false;
      notifyListeners(); // Redibuja la pantalla de perfil con los nuevos datos
    }
  }
  // 🔥 NUEVA FUNCIÓN: Registrar usuario desde el formulario
  Future<void> registrarUsuario(String nombre, String email) async {
    _isLoadingBackend = true;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse('http://$_ip:3003/api/v1/usuarios/registro'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': nombre,
          'email': email,
        }),
      );

      if (res.statusCode == 201) {
        perfilUsuario = json.decode(res.body)['data'];
        debugPrint("✅ Nuevo usuario registrado y logueado exitosamente.");
      }
    } catch (e) {
      debugPrint("❌ Error al registrar usuario: $e");
    } finally {
      _isLoadingBackend = false;
      notifyListeners();
    }
  }
  // 🔥 NUEVA FUNCIÓN: Crear promoción ligada a un negocio
  Future<void> crearPromocion(String businessId, String nombreNegocio, String titulo, String descuento, String descripcion, String expiracion) async {
    _isLoadingBackend = true;
    notifyListeners();

    // Estructuramos el JSON exactamente como lo pide Node.js
    final nuevaPromo = {
      'businessId': businessId,
      'negocio': nombreNegocio,
      'titulo': titulo,
      'descuento': descuento,
      'descripcion': descripcion,
      'expiracion': expiracion
    };

    // 1. Optimistic UI: Lo agregamos a la pantalla al instante
    cuponesActivos.add(nuevaPromo);

    // 2. Lo enviamos al Puerto 3004
    try {
      await http.post(
        Uri.parse('http://$_ip:3004/api/v1/promociones'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(nuevaPromo),
      );
      debugPrint("✅ Promoción de $nombreNegocio creada en el servidor 3004.");
    } catch (e) {
      debugPrint("❌ Error al crear promoción de red: $e");
    } finally {
      _isLoadingBackend = false;
      notifyListeners();
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
  // 3. MÉTODOS DE ACCIÓN Y NEGOCIO
  // ---------------------------------------------------------

  Future<void> addReviewToBusiness(String businessId, String review) async {
    final index = _allBusinesses.indexWhere((b) => b.id == businessId);
    
    if (index != -1) {
      final business = _allBusinesses[index];
      final updatedReviews = List<String>.from(business.reviews)..insert(0, review);
      
      _allBusinesses[index] = Business(
        id: business.id, name: business.name, category: business.category, rating: business.rating,
        icon: business.icon, mapX: business.mapX, mapY: business.mapY, priceLevel: business.priceLevel,
        description: business.description, address: business.address, phone: business.phone,
        representative: business.representative, schedule: business.schedule, photos: business.photos,
        reviews: updatedReviews,
      );
      
      await _saveToDisk();
      notifyListeners();
    }

    try {
      await http.post(
        Uri.parse('http://$_ip:3002/api/v1/resenas'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'businessId': businessId,
          'touristName': perfilUsuario.isNotEmpty ? (perfilUsuario['name'] ?? 'Turista') : 'Turista Localia',
          'comment': review,
          'rating': 5
        }),
      );
    } catch (e) {
      debugPrint("⚠️ Guardado local exitoso. Error de red: $e");
    }
  }

  Future<void> addBusiness(Business business) async {
    _allBusinesses.add(business);
    await _saveToDisk();
    notifyListeners();

    try {
      await http.post(
        Uri.parse('http://$_ip:3000/api/v1/negocios'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(business.toJson()), 
      );
    } catch (e) {
      debugPrint("⚠️ Guardado local exitoso. Error de red: $e");
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

<<<<<<< HEAD
  void auditarSeguridadSandbox() {
    debugPrint("🔒 AUDITORÍA DE SEGURIDAD NATIVA - SANDBOX LOCALIA");
<<<<<<< HEAD
    debugPrint(" Saldo Disponible Wallet: $_balance MXN");
    debugPrint(" Puntos Coppel Acumulados: $_coppelPoints");
    debugPrint(" Impacto Social en Sedes Mundial: $_totalSocialImpact MXN");
=======
    debugPrint(" Saldo Disponible Wallet: \$$_balance MXN");
    debugPrint(" Puntos Coppel Acumulados: $_coppelPoints");
    debugPrint(" Impacto Social en Sedes Mundial: \$$_totalSocialImpact MXN");
>>>>>>> 8684fdd32fc702b6da2d93cc005f05e088edb06c
    debugPrint(" Rol de Usuario actual: ${_isAdmin ? 'ADMINISTRADOR' : 'TURISTA'}");
    debugPrint(" Número de PyMEs Registradas en Disco: ${_allBusinesses.length}");
  }

=======
>>>>>>> a1aececf89050fe87ae7f0447d4bdbc7a79c13e7
  bool isFavorite(String id) => _favoriteIds.contains(id);

  void dismissSuccess() {
    _showSuccess = false;
    notifyListeners();
  }

  // 🔥 MÉTODO ACTUALIZADO: Hacer un pago real al backend
  Future<void> makePurchase(double amount, String businessName) async {
    if (_balance >= amount) {
      _isProcessing = true;
      notifyListeners();

      // 1. Optimistic UI: Actualizamos la pantalla al instante para que se sienta rápido
      _balance -= amount;
      _totalSocialImpact += amount;
      _coppelPoints += (amount * 0.1).toInt();
      _history.insert(0, "Pago en $businessName: -\$${amount.toStringAsFixed(2)}");
      await _saveToDisk();

      // 2. Transacción Backend: Enviamos la orden al microservicio 3001
      try {
        final res = await http.post(
          Uri.parse('http://$_ip:3001/api/v1/wallet/transaccion'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'amount': amount,
            'businessName': businessName,
          }),
        );

        if (res.statusCode == 200) {
          debugPrint("✅ Transacción de \$$amount procesada en el servidor 3001.");
        } else {
          debugPrint("⚠️ El servidor rechazó el pago (Posible falta de fondos).");
        }
      } catch (e) {
        debugPrint("❌ Error de red al procesar pago: $e");
      }

      // Animación de Coppel Pay 
      await Future.delayed(const Duration(milliseconds: 1200));

      _isProcessing = false;
      _showSuccess = true;
      notifyListeners();
    }
  }

  // 🔥 NUEVA FUNCIÓN: Por si quieres agregar un botón de recarga después
  Future<void> recargarCartera(double amount) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse('http://$_ip:3001/api/v1/wallet/recarga'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': amount}),
      );

      if (res.statusCode == 200) {
        final newData = json.decode(res.body)['data'];
        _balance = (newData['balance'] as num).toDouble();
        _history = List<String>.from(newData['history']);
        await _saveToDisk();
        debugPrint("✅ Recarga de \$$amount exitosa.");
      }
    } catch (e) {
      debugPrint("❌ Error al recargar: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
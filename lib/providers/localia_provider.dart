import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/business.dart';
import '../config/constants.dart';
import 'package:http_parser/http_parser.dart';

// Modelo para los eventos deportivos/turísticos
class WorldCupEvent {
  final String matchTitle;
  WorldCupEvent({required this.matchTitle});
}

class LocaliaProvider with ChangeNotifier {
  // ---------------------------------------------------------
  // 1. ESTADO DE LA APP Y RED
  // ---------------------------------------------------------
  
  // Detección automática de la IP según la plataforma (Web, Emulador o Físico)
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
  bool _isAuthenticated = false;
  
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
    debugPrint("🚀 LocaliaProvider: Caché local lista. Sincronizando con la Base de Datos...");
    await sincronizarEcosistema();
  }

  // --- GETTERS ---
  bool get isAuthenticated => _isAuthenticated;
  double get balance => _balance;
  int get coppelPoints => _coppelPoints;
  double get totalSocialImpact => _totalSocialImpact;
  bool get isAdmin => _isAdmin;
  bool get isProcessing => _isProcessing;
  bool get showSuccess => _showSuccess;
  bool get isLoadingBackend => _isLoadingBackend;
  
  List<Business> get businesses => _allBusinesses;
  List<Business> get filteredBusinesses => _allBusinesses; // Aquí puedes meter lógica de filtros de búsqueda después
  List<String> get favorites => _favoriteIds;
  List<String> get history => _history;
  List<WorldCupEvent> get events => _events;
  
  Map<String, dynamic> get perfilUsuarioData => perfilUsuario; 
  List<dynamic> get cupones => cuponesActivos;

  // ---------------------------------------------------------
  // 2. LÓGICA DE PERSISTENCIA Y MICROSERVICIOS
  // ---------------------------------------------------------

// 🔥 LÓGICA REPARADA: Sincronización Silenciosa
  Future<void> sincronizarEcosistema({bool silencioso = false}) async {
    // Si NO es silencioso, avisamos que empezó a cargar
    if (!silencioso) {
      _isLoadingBackend = true;
      notifyListeners();
    }

    try {
      // 1. NEGOCIOS (Puerto 3000) -> Con inner try/catch para evitar bloqueos
      try {
        final resNegocios = await http.get(Uri.parse('http://$_ip:3000/api/v1/negocios'));
        if (resNegocios.statusCode == 200) {
          final List<dynamic> dataJson = json.decode(resNegocios.body)['data'];
          _allBusinesses = dataJson.map((json) => Business.fromJson(json)).toList();
          debugPrint("✅ SQL Server: ${_allBusinesses.length} negocios cargados con éxito.");
        }
      } catch (e) {
        debugPrint("⚠️ Servidor de Negocios desconectado o con error.");
      }

      // 2. BILLETERA VIRTUAL (Puerto 3001)
      try {
        final resWallet = await http.get(Uri.parse('http://$_ip:3001/api/v1/wallet'));
        if (resWallet.statusCode == 200) {
          final dataWallet = json.decode(resWallet.body)['data'];
          _balance = (dataWallet['balance'] as num).toDouble();
          _coppelPoints = dataWallet['coppelPoints'];
          _totalSocialImpact = (dataWallet['totalSocialImpact'] as num).toDouble();
          _history = List<String>.from(dataWallet['history']);
        }
      } catch (e) {
        debugPrint("⚠️ Servidor de Wallet desconectado. Usando caché.");
      }

      // 3. PROMOCIONES (Puerto 3004)
      try {
        final resPromos = await http.get(Uri.parse('http://$_ip:3004/api/v1/promociones'));
        if (resPromos.statusCode == 200) {
          cuponesActivos = json.decode(resPromos.body)['data'];
        }
      } catch (e) {
        debugPrint("⚠️ Servidor de Promos desconectado. Usando caché.");
      }

      await _saveToDisk(); 
      
    } catch (e) {
      debugPrint("❌ Error crítico en sincronizarEcosistema: $e");
    } finally {
      // Si NO es silencioso, avisamos que ya terminó
      if (!silencioso) {
        _isLoadingBackend = false;
        notifyListeners(); 
      }
    }
  }

  // 🔥 LOGIN REPARADO: Sin colisiones de redibujo
  Future<bool> login(String email, String password) async {
    _isLoadingBackend = true;
    notifyListeners(); // 1️⃣ Un solo aviso de carga al inicio

    try {
      final res = await http.post(
        Uri.parse('http://$_ip:3003/api/v1/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        perfilUsuario = json.decode(res.body)['data'];
        _isAdmin = perfilUsuario['role'] == 'admin'; 
        _isAuthenticated = true;
        
        // 2️⃣ Pedimos los negocios, pero le decimos que no congele la pantalla
        await sincronizarEcosistema(silencioso: true); 
        
        return true; // Terminó todo perfecto
      }
    } catch (e) {
      debugPrint("❌ Error al intentar login: $e");
    } finally {
      _isLoadingBackend = false;
      notifyListeners(); // 3️⃣ Un solo aviso de carga al final
    }
    return false;
  }
  // 🔥 NUEVA FUNCIÓN: Subir imagen del negocio al servidor
  Future<String?> subirImagenNegocio(dynamic imageFile) async {
    _isLoadingBackend = true;
    notifyListeners();

    try {
      // Este será el endpoint en Node.js que crearemos en el Paso 2
      final url = Uri.parse('http://$_ip:3000/api/v1/negocios/upload'); 
      final request = http.MultipartRequest('POST', url);

      // Leemos la imagen como bytes (Súper importante para que no crashee en Web)
      final bytes = await imageFile.readAsBytes();

      // Armamos el paquete que Node.js está esperando
      final multipartFile = http.MultipartFile.fromBytes(
        'image', // Este nombre es clave, Node.js lo buscará así
        bytes,
        filename: imageFile.name,
        contentType: MediaType('image', 'jpeg'), 
      );

      request.files.add(multipartFile);

      // Disparamos el archivo hacia el backend
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonRes = json.decode(responseData);

      if (response.statusCode == 200) {
        // Si todo sale bien, Node.js nos devolverá el enlace web de la foto guardada
        debugPrint("✅ Imagen subida con éxito: ${jsonRes['imageUrl']}");
        return jsonRes['imageUrl']; 
      } else {
        debugPrint("⚠️ El servidor rechazó la imagen.");
      }
    } catch (e) {
      debugPrint("❌ Error crítico al subir imagen: $e");
    } finally {
      _isLoadingBackend = false;
      notifyListeners();
    }
    
    return null; // Retorna nulo si falló
  }
  // 🔥 MÉTODO REPARADO: Ahora sí guarda las modificaciones en SQL Server
  Future<void> updateBusiness(Business updatedBiz) async {
    // 1. Actualización optimista: Cambiamos la pantalla al instante para que se sienta rápido
    final index = _allBusinesses.indexWhere((biz) => biz.id == updatedBiz.id);
    if (index != -1) {
      _allBusinesses[index] = updatedBiz;
      await _saveToDisk();
      notifyListeners();
    }

    // 2. Disparamos la actualización al Backend (Node.js)
    try {
      // Usamos el método PUT apuntando al ID específico del negocio
      final res = await http.put(
        Uri.parse('http://$_ip:3000/api/v1/negocios/${updatedBiz.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedBiz.toJson()),
      );

      if (res.statusCode == 200) {
        debugPrint("✅ Negocio editado y guardado permanentemente en SQL Server.");
      } else {
        debugPrint("⚠️ El servidor rechazó la edición. Código: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error de red al intentar editar el negocio: $e");
    }
  }

  // Registro de usuario nuevo
  Future<bool> registrarUsuario(String nombre, String email, String password, String rol) async {
    _isLoadingBackend = true;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse('http://$_ip:3003/api/v1/usuarios/registro'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': nombre,
          'email': email,
          'password': password,
          'role': rol
        }),
      );

      if (res.statusCode == 201) {
        return true; 
      }
    } catch (e) {
      debugPrint("❌ Error al registrar usuario: $e");
    } finally {
      _isLoadingBackend = false;
      notifyListeners();
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _isAdmin = false;
    perfilUsuario = {};
    notifyListeners();
  }

  // Cambiar usuario (Ideal para pruebas rápidas de roles)
  Future<void> cambiarUsuario(String tipoUsuario) async {
    _isLoadingBackend = true;
    notifyListeners(); 

    try {
      final resUsuario = await http.get(Uri.parse('http://$_ip:3003/api/v1/usuarios/perfil?tipo=$tipoUsuario'));
      if (resUsuario.statusCode == 200) {
        perfilUsuario = json.decode(resUsuario.body)['data'];
        _isAdmin = perfilUsuario['role'] == 'admin';
        debugPrint("✅ Usuario cambiado exitosamente a: $tipoUsuario");
      }
    } catch (e) {
      debugPrint("❌ Error al cambiar de usuario: $e");
    } finally {
      _isLoadingBackend = false;
      notifyListeners(); 
    }
  }

  // ---------------------------------------------------------
  // 3. PERSISTENCIA LOCAL (OFFLINE FIRST)
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
      }
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error al cargar de disco duro: $e");
    }
  }

  // ---------------------------------------------------------
  // 4. MÉTODOS DE ACCIÓN Y NEGOCIO
  // ---------------------------------------------------------

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

  Future<void> crearPromocion(String businessId, String nombreNegocio, String titulo, String descuento, String descripcion, String expiracion) async {
    _isLoadingBackend = true;
    notifyListeners();

    final nuevaPromo = {
      'businessId': businessId,
      'negocio': nombreNegocio,
      'titulo': titulo,
      'descuento': descuento,
      'descripcion': descripcion,
      'expiracion': expiracion
    };

    cuponesActivos.add(nuevaPromo);

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

  Future<void> makePurchase(double amount, String businessName) async {
    if (_balance >= amount) {
      _isProcessing = true;
      notifyListeners();

      _balance -= amount;
      _totalSocialImpact += amount;
      _coppelPoints += (amount * 0.1).toInt();
      _history.insert(0, "Pago en $businessName: -\$${amount.toStringAsFixed(2)}");
      await _saveToDisk();

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
        }
      } catch (e) {
        debugPrint("❌ Error de red al procesar pago: $e");
      }

      await Future.delayed(const Duration(milliseconds: 1200));

      _isProcessing = false;
      _showSuccess = true;
      notifyListeners();
    }
  }

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
      }
    } catch (e) {
      debugPrint("❌ Error al recargar: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
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

 
  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    _saveToDisk();
    notifyListeners();
  }

  void dismissSuccess() {
    _showSuccess = false;
    notifyListeners();
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void auditarSeguridadSandbox() {
    debugPrint("🔒 AUDITORÍA DE SEGURIDAD NATIVA - SANDBOX LOCALIA");
    debugPrint(" Saldo Disponible Wallet: \$$_balance MXN");
    debugPrint(" Rol de Usuario actual: ${_isAdmin ? 'ADMINISTRADOR' : 'TURISTA'}");
    debugPrint(" Número de PyMEs Registradas en Disco: ${_allBusinesses.length}");
  }
}
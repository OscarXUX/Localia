import 'package:flutter/material.dart';

/// [Business] es la clase modelo que representa un micro-negocio dentro de Localia.
/// Actúa como un contenedor de datos (Data Class) que facilita el paso de información
/// entre el Administrador, el Mapa y la pantalla de Detalle del Turista.
class Business {

  // 1. ATRIBUTOS (Propiedades del Negocio)
  
  final String id;          // Identificador único (usamos un timestamp o UUID)
  final String name;        // Nombre comercial del local
  final String category;    // Giro del negocio (Restaurante, Artesanías, etc.)
  final double rating;      // Calificación promedio (0.0 a 5.0)
  final IconData icon;      // Icono visual que aparecerá en el mapa
  final double mapX;        // Posición relativa en el eje X del mapa personalizado
  final double mapY;        // Posición relativa en el eje Y del mapa personalizado
  final int priceLevel;     // Nivel de costo ($, $$, $$$)
  
  // Información detallada para el perfil
  final String description;    // Historia o descripción de productos
  final String address;        // Dirección física para el turista
  final String phone;          // Número de contacto
  final String representative; // Nombre del dueño o encargado
  final String rfc;            // Registro Federal de Contribuyentes (Dato legal para Coppel)
  final String schedule;       // Horarios de apertura y cierre
  
  // Listas de datos dinámicos
  final List<String> photos;   // Rutas (paths) o URLs de las imágenes para el carrusel
  final List<String> reviews;  // Lista de textos con los comentarios de los clientes

  // 2. CONSTRUCTOR
  Business({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.icon,
    required this.mapX,
    required this.mapY,
    this.priceLevel = 1,
    this.description = "",
    this.address = "",
    this.phone = "",
    this.representative = "",
    this.rfc = "",
    this.schedule = "09:00 - 21:00",
    this.photos = const [],
    this.reviews = const [],
  });

  // ---------------------------------------------------------
  // 3. SERIALIZACIÓN (De Objeto a Texto JSON)
  // ---------------------------------------------------------
  /// El método [toJson] convierte este objeto en un Mapa (Map).
  /// Esto es necesario porque SharedPreferences solo entiende texto plano,
  /// por lo que transformamos los datos a un formato que se pueda guardar.
  Map<String, dynamic> toJson() => {
    'id': id, 
    'name': name, 
    'category': category, 
    'rating': rating,
    // El IconData no se puede guardar directamente, guardamos su 'codePoint' numérico
    'iconCode': icon.codePoint, 
    'mapX': mapX, 
    'mapY': mapY,
    'priceLevel': priceLevel, 
    'description': description,
    'address': address, 
    'phone': phone, 
    'representative': representative,
    'rfc': rfc, 
    'schedule': schedule, 
    'photos': photos, 
    'reviews': reviews,
  };

  // ---------------------------------------------------------
  // 4. DESERIALIZACIÓN (De Texto JSON a Objeto)
  // ---------------------------------------------------------
  /// El [factory constructor] toma un Mapa (normalmente recuperado de disco)
  /// y reconstruye el objeto [Business] para que la app pueda usarlo de nuevo.
  factory Business.fromJson(Map<String, dynamic> json) {
  // Extraemos la ubicación de forma segura por si viene anidada
  final location = json['location'] as Map<String, dynamic>?;
  
  return Business(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    category: json['category'] ?? '',
    description: json['description'] ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 4.0,
    
    // Asignamos un icono por defecto según la categoría que mande Node.js
    icon: json['category'] == 'Gastronomía' ? Icons.restaurant : Icons.storefront,
    
    // Mapeo temporal: Como el mapa actual es una imagen fija, puedes calcular 
    // una aproximación en lo que integran la telemetría real del mapa interactivo
    mapX: location != null ? 0.4 : 0.5, 
    mapY: location != null ? 0.4 : 0.5,
  );
}
}
import 'package:flutter/material.dart';

/// [Business] es la clase modelo que representa un micro-negocio dentro de Localia.
/// Actúa como un contenedor de datos (Data Class) que facilita el paso de información
/// entre el Administrador, el Mapa y la pantalla de Detalle del Turista.
class Business {

  // 1. ATRIBUTOS (Propiedades del Negocio)
  final String? ownerId; // Le ponemos '?' porque los negocios viejos podrían no tenerlo
  final String id;          
  final String name;        
  final String category;    
  final double rating;      
  final IconData icon;      
  final double mapX;        
  final double mapY;        
  final int priceLevel;     
  
  // Información detallada para el perfil
  final String description;    
  final String address;        
  final String phone;          
  final String representative; 
  final String rfc;            
  final String schedule;       
  
  // Listas de datos dinámicos
  final List<String> photos;   
  final List<String> reviews;  

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
    this.ownerId,
  });

  // ---------------------------------------------------------
  // 3. SERIALIZACIÓN (De Objeto a Texto JSON)
  // ---------------------------------------------------------
  Map<String, dynamic> toJson() => {
    'id': id, 
    'ownerId': ownerId,
    'name': name, 
    'category': category, 
    'rating': rating,
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
  factory Business.fromJson(Map<String, dynamic> json) {
    // 1. Extraemos la ubicación de forma segura por si viene anidada
    final location = json['location'] as Map<String, dynamic>?;
    
    // 2. Compatibilidad de Imágenes: Node.js manda 'image', Flutter usa 'photos'
    List<String> parsedPhotos = [];
    if (json['image'] != null && json['image'].toString().isNotEmpty) {
      parsedPhotos.add(json['image'].toString());
    } else if (json['photos'] != null) {
      parsedPhotos = List<String>.from(json['photos']);
    }

    // 3. Extracción segura de listas
    List<String> parsedReviews = [];
    if (json['reviews'] != null) {
      parsedReviews = List<String>.from(json['reviews']);
    }

    return Business(
      // Datos principales
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString(),
      name: json['name'] ?? 'Negocio sin nombre',
      category: json['category'] ?? 'General',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      
      // 🔥 CRÍTICO: Aquí leemos los datos que antes se ignoraban
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      representative: json['representative'] ?? '',
      rfc: json['rfc'] ?? '',
      schedule: json['schedule'] ?? '09:00 - 18:00',
      priceLevel: json['priceLevel'] ?? 1,
      
      // Asignamos las listas procesadas
      photos: parsedPhotos,
      reviews: parsedReviews,
      
      // Icono dinámico según el giro del negocio
      icon: _getIconForCategory(json['category']?.toString() ?? ''),
      
      // Coordenadas para el mapa (Posición estática temporal)
      mapX: location != null ? 0.4 : 0.5, 
      mapY: location != null ? 0.4 : 0.5,
    );
  }

  // ---------------------------------------------------------
  // 5. HELPERS (Funciones de apoyo)
  // ---------------------------------------------------------
  /// Asigna un ícono visualmente acorde a la categoría que devuelve la base de datos
  static IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'gastronomía':
      case 'restaurante':
      case 'comida':
        return Icons.restaurant_rounded;
      case 'artesanía':
      case 'artesanías':
        return Icons.color_lens_rounded;
      case 'ropa':
      case 'boutique':
        return Icons.checkroom_rounded;
      case 'hotel':
      case 'hospedaje':
        return Icons.hotel_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }
}
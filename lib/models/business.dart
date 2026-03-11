import 'package:flutter/material.dart';

class Business {
  final String id;
  final String name;
  final String category;
  final double rating;
  final IconData icon;
  final double mapX;
  final double mapY;
  final int priceLevel;
  final double price;

  Business({
    required this.id, required this.name, required this.category,
    required this.rating, required this.icon, required this.mapX,
    required this.mapY, this.priceLevel = 1, this.price = 150.0,
  });

  // Convierte el objeto a un mapa (JSON) para guardarlo
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'rating': rating,
    'iconCode': icon.codePoint, // Guardamos el código del icono
    'mapX': mapX,
    'mapY': mapY,
    'priceLevel': priceLevel,
    'price': price,
  };

  // Crea un objeto Business desde un mapa (JSON)
  factory Business.fromJson(Map<String, dynamic> json) => Business(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    rating: json['rating'],
    icon: IconData(json['iconCode'], fontFamily: 'MaterialIcons'),
    mapX: json['mapX'],
    mapY: json['mapY'],
    priceLevel: json['priceLevel'],
    price: json['price']?.toDouble() ?? 150.0,
  );
}
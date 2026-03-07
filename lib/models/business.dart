import 'package:flutter/material.dart';

class Business {
  final String id;
  final String name;
  final String category;
  final double rating;
  final IconData icon;
  // Coordenadas para el mapa (valores de 0.0 a 1.0 para posicionamiento relativo)
  final double mapX;
  final double mapY;

  Business({
    required this.id, 
    required this.name, 
    required this.category, 
    this.rating = 4.5,
    this.icon = Icons.store,
    this.mapX = 0.5,
    this.mapY = 0.5,
  });
}
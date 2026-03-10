import 'package:flutter/material.dart';

class Business {
  final String id;
  final String name;
  final String category;
  final double rating;
  final IconData icon;
  final double mapX;
  final double mapY;
  final int priceLevel; // 1: Económico, 2: Medio, 3: Premium

  Business({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.icon,
    required this.mapX,
    required this.mapY,
    this.priceLevel = 1, // Valor por defecto
  });
}
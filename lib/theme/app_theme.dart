import 'package:flutter/material.dart';

class LocaliaTheme {
  // Colores corporativos intactos
  static const Color coppelGreen = Color(0xFF008F39);
  static const Color coppelYellow = Color(0xFFFFD500);
  
  // Radio maestro extra suave tipo squircle de iOS
  static const double kRadius = 35.0;

  // 🔥 1. GLASS STYLE PREMIUM (Efecto macOS / VisionOS)
  static BoxDecoration glassStyle = BoxDecoration(
    // Fondo ligeramente más translúcido para dejar pasar la luz
    color: Colors.white.withValues(alpha: 0.85),
    borderRadius: BorderRadius.circular(kRadius),
    
    // EL SECRETO DEL REFLEJO: Un borde blanco sutil que simula la luz en el bisel
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.8),
      width: 1.5,
    ),
    
    // SOMBRAS MULTICAPA (El secreto de Apple para profundidad real)
    boxShadow: [
      // Sombra 1: Ambiental (Difuminada y lejana)
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04), 
        blurRadius: 35, 
        spreadRadius: 2,
        offset: const Offset(0, 15)
      ),
      // Sombra 2: Contacto (Corta y oscura para anclar el elemento)
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02), 
        blurRadius: 10, 
        spreadRadius: -2,
        offset: const Offset(0, 4)
      ),
    ],
  );

  // 🔥 2. TARJETA SÓLIDA TIPO WIDGET (Estilo iOS 17)
  // Ideal para contenedores que no ocupan difuminado pero sí máxima elegancia
  static BoxDecoration solidCardStyle = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24.0), 
    border: Border.all(
      color: const Color(0xFFF1F3F5), // Borde gris ultra sutil
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.06), // Tono azulado muy sutil en la sombra
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ],
  );
}
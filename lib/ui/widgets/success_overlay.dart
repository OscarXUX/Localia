import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/localia_provider.dart';

class SuccessOverlay extends StatelessWidget {
  const SuccessOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. BackdropFilter crea el efecto de "vidrio esmerilado" (Blur)
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.white.withOpacity(0.9), // Fondo semi-transparente
        child: Stack(
          children: [
            // --- BOTÓN DE CERRAR (X) ---
            Positioned(
              top: 50,
              right: 25,
              child: IconButton(
                onPressed: () => Provider.of<LocaliaProvider>(context, listen: false).dismissSuccess(),
                icon: const Icon(Icons.close_rounded, color: Colors.black54, size: 30),
              ),
            ),

            // --- CONTENIDO CENTRAL ---
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ANIMACIÓN DE REBOTE (Círculo verde)
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1200),
                      tween: Tween<double>(begin: 0, end: 1),
                      curve: Curves.elasticOut, // Curva de rebote elástico
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFF008F39), // Verde Coppel
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)
                              ],
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 80),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // TÍTULO DEL ESTADO
                    const Text(
                      "¡PAGO COMPLETADO!",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1),
                    ),

                    const SizedBox(height: 15),

                    // TEXTO INFORMATIVO (Recuperado)
                    const Text(
                      "Has apoyado con éxito a la economía local de Guanajuato. Tu transacción mediante Coppel Pay ha sido procesada.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // BOTÓN DE ACCIÓN "ENTENDIDO"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Provider.of<LocaliaProvider>(context, listen: false).dismissSuccess(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Entendido",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
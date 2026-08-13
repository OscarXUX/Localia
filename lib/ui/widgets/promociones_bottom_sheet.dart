import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/localia_provider.dart';
import '../../theme/app_theme.dart';

class PromocionesBottomSheet extends StatelessWidget {
  const PromocionesBottomSheet({super.key});

  // Función estática para mandar a llamar el panel desde cualquier pantalla
  static void mostrar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const PromocionesBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Leemos los cupones que ya descargó el Provider
    final state = Provider.of<LocaliaProvider>(context);
    final cupones = state.cupones;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barrita superior de arrastre
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Cupones Locales",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5),
          ),
          const Text(
            "Descuentos exclusivos para turistas",
            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          
          // Lista dinámica de promociones
          Expanded(
            child: cupones.isEmpty
                ? const Center(child: Text("No hay promociones activas hoy.", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: cupones.length,
                    itemBuilder: (context, index) {
                      final cupon = cupones[index];
                      return _buildCuponCard(cupon);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuponCard(Map<String, dynamic> cupon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LocaliaTheme.coppelYellow.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          // Sección izquierda (Descuento)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            decoration: const BoxDecoration(
              color: LocaliaTheme.coppelYellow,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
            ),
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                cupon['descuento'], 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.black87)
              ),
            ),
          ),
          // Sección derecha (Información)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cupon['titulo'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cupon['negocio'],
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: LocaliaTheme.coppelGreen),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cupon['descripcion'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "Expira: ${cupon['expiracion']}",
                        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
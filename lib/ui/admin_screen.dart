import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import 'add_business_screen.dart';

class AdminPortal extends StatelessWidget {
  const AdminPortal({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Gris claro Apple
      appBar: AppBar(
        title: const Text(
          "Panel Administrativo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: () => state.setRole(false),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CUADRO DE IMPACTO RESTAURADO (Degradado + Icono Finanzas)
            _buildImpactCard(state.businesses.length),

            const SizedBox(height: 35),

            const Text(
              "Mis Locales",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Lista de negocios registrados
            state.businesses.isEmpty
                ? const Center(child: Text("No hay negocios registrados aún."))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.businesses.length,
                    itemBuilder: (context, index) {
                      final biz = state.businesses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF008F39).withOpacity(0.1),
                            child: Icon(biz.icon, color: const Color(0xFF008F39)),
                          ),
                          title: Text(
                            biz.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(biz.category),
                          trailing: const Icon(Icons.edit_note),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const AddBusinessScreen()),
        ),
        label: const Text("Nuevo Negocio", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF008F39),
      ),
    );
  }

  // MÉTODO REFACTORIZADO: Estilo Premium con Degradado e Icono de Crecimiento
  Widget _buildImpactCard(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        // Degradado de Verde fuerte a Verde profundo
        gradient: const LinearGradient(
          colors: [Color(0xFF008F39), Color(0xFF004D1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D1F).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Impacto Ola México",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ALTO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              ),
              // El signo de "Finanzas/Crecimiento" que pediste
              const Icon(
                Icons.trending_up,
                color: Colors.white,
                size: 50,
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Text(
            "Tu red de $count locales está impulsando la economía de Guanajuato.",
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
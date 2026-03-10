import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import 'add_business_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Blanco hueso tipo Apple
      appBar: AppBar(
        // BOTÓN DE REGRESO PARA CAMBIAR DE ROL
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () {
            // Cambiamos el rol en el Provider y MainEntry hará el resto
            Provider.of<LocaliaProvider>(context, listen: false).setRole(false);
          },
        ),
        title: const Text("Dashboard Admin", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, letterSpacing: -1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSectionTitle("Impacto en Guanajuato"),
            const SizedBox(height: 15),
            
            // TARJETA DE IMPACTO REFINADA CON GRADIENTE
            _buildPremiumImpactCard(state.totalSocialImpact, state.businesses.length),

            const SizedBox(height: 35),
            _buildSectionTitle("Gestión de Locales"),
            const SizedBox(height: 15),

            // LISTA DE NEGOCIOS ESTILO "CLEAN"
            state.businesses.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.businesses.length,
                  itemBuilder: (context, index) => _buildBusinessItem(state.businesses[index]),
                ),
            const SizedBox(height: 100), // Espacio para el FAB
          ],
        ),
      ),
      floatingActionButton: _buildAppleFAB(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, 
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 0.5));
  }

  Widget _buildPremiumImpactCard(double impact, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        // GRADIENTE VERDE COPPEL
        gradient: const LinearGradient(
          colors: [Color(0xFF008F39), Color(0xFF00C853)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF008F39).withOpacity(0.3), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Flujo Coppel Pay", 
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Icon(Icons.trending_up, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "\$${impact.toStringAsFixed(2)}", 
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 38, 
              fontWeight: FontWeight.w900, 
              letterSpacing: -1.5
            )
          ),
          const SizedBox(height: 15),
          Text(
            "Distribuidos en $count negocios locales de GTO", 
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessItem(dynamic biz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF2F2F7),
          child: Icon(biz.icon, color: Colors.black, size: 20),
        ),
        title: Text(biz.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(biz.category, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.more_vert_rounded, color: Colors.grey),
      ),
    );
  }

  Widget _buildAppleFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddBusinessScreen())),
      backgroundColor: Colors.black,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      label: const Text("Añadir Local", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      icon: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Sin negocios aún", style: TextStyle(color: Colors.grey)));
  }
}
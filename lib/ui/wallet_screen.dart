import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import '../theme/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Coppel Pay Wallet"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // LA TARJETA PREMIUM
            _buildAppleCard(state),
            
            const SizedBox(height: 40),
            
            // ACCIONES RÁPIDAS REDONDEADAS
            _buildQuickActions(),
            
            const SizedBox(height: 40),
            
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("  Historial de Actividad", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ),
            const SizedBox(height: 15),
            
            // LISTA DE TRANSACCIONES
            ...state.history.map((item) => _buildTransactionTile(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleCard(LocaliaProvider state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF008F39), Color(0xFF004D1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(LocaliaTheme.kRadius), // 35px
        boxShadow: [
          BoxShadow(color: const Color(0xFF004D1F).withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Coppel Pay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Icon(Icons.nfc_rounded, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 50),
          const Text("Saldo Disponible", style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text("\$${state.balance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.amber, size: 16),
              const SizedBox(width: 5),
              Text("${state.coppelPoints} Coppel Points", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionItem(Icons.add_rounded, "Recargar"),
        _actionItem(Icons.qr_code_scanner_rounded, "Escanear"),
        _actionItem(Icons.send_rounded, "Enviar"),
      ],
    );
  }

  Widget _actionItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(20)),
          child: Icon(icon, color: LocaliaTheme.coppelGreen),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTransactionTile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.shopping_bag_outlined, color: Colors.black)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }
}
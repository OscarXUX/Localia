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
      backgroundColor: const Color(0xFFF8F9FA), // Fondo gris muy suave
      appBar: AppBar(
        title: const Text(
          "Coppel Pay Wallet",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      // 1. CONTROL DE ESTADO: Si el microservicio está cargando, muestra el spinner
      body: state.isLoadingBackend
          ? const Center(child: CircularProgressIndicator(color: LocaliaTheme.coppelGreen))
          : RefreshIndicator(
              color: LocaliaTheme.coppelGreen,
              // 2. REFRESH: Permite al usuario arrastrar hacia abajo para consultar el saldo real
              onRefresh: () async {
                await state.sincronizarEcosistema();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Obligatorio para el RefreshIndicator
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  children: [
                    // LA TARJETA PREMIUM
                    _buildAppleCard(state),
                    
                    const SizedBox(height: 35),
                    
                    // ACCIONES RÁPIDAS REDONDEADAS
                    _buildQuickActions(context),
                    
                    const SizedBox(height: 40),
                    
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Historial de Actividad", 
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.black87)
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // LISTA DE TRANSACCIONES
                    if (state.history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No hay movimientos recientes.", style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ...state.history.map((item) => _buildTransactionTile(item)).toList(),
                      
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAppleCard(LocaliaProvider state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF008F39), Color(0xFF005924)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D1F).withOpacity(0.4), 
            blurRadius: 25, 
            offset: const Offset(0, 12)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Coppel Pay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.0)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.contactless_rounded, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text("Saldo Disponible", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            "\$${state.balance.toStringAsFixed(2)}", 
            style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1.0)
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 6),
                    Text("${state.coppelPoints} pts", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionItem(context, Icons.add_rounded, "Recargar"),
        _actionItem(context, Icons.qr_code_scanner_rounded, "Escanear"),
        _actionItem(context, Icons.send_rounded, "Enviar"),
        _actionItem(context, Icons.receipt_long_rounded, "Recibos"),
      ],
    );
  }

  Widget _actionItem(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Función "$label" en desarrollo...'),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
          )
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Icon(icon, color: LocaliaTheme.coppelGreen, size: 28),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(String fullText) {
    // 3. INTELIGENCIA DE TEXTO: Separa "Pago en Local" de la cantidad cobrada
    final parts = fullText.split(':');
    final String title = parts.first;
    final String amount = parts.length > 1 ? parts.last.trim() : "";
    
    // Si la cadena contiene un '+', asumimos que es un ingreso (recarga), de lo contrario es un egreso (pago)
    final bool isIncome = fullText.contains("+");
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isIncome ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isIncome ? Icons.account_balance_wallet_rounded : Icons.storefront_rounded, 
              color: isIncome ? Colors.green : Colors.orange,
              size: 24
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black87)
                ),
                const SizedBox(height: 4),
                const Text(
                  "Completado exitosamente", 
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 16, 
              letterSpacing: -0.5,
              color: isIncome ? LocaliaTheme.coppelGreen : Colors.black87
            ),
          ),
        ],
      ),
    );
  }
}
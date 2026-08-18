import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import '../theme/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _mostrarModalRecarga(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => const _OpcionesRecarga(),
    );
  }

  // 🔥 NUEVO MODAL: Para transferencias a otros usuarios (P2P)
  void _mostrarModalTransferencia(BuildContext context) {
    final TextEditingController destinatarioCtrl = TextEditingController();
    final TextEditingController montoCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 25, right: 25, top: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Transferir Dinero", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            TextField(
              controller: destinatarioCtrl,
              decoration: InputDecoration(
                labelText: "Destinatario (Nombre o @Usuario)",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: montoCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monto a transferir",
                prefixIcon: const Icon(Icons.attach_money_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  final double? amount = double.tryParse(montoCtrl.text);
                  final String destinatario = destinatarioCtrl.text.isEmpty ? "Amigo" : destinatarioCtrl.text;

                  if (amount != null && amount > 0) {
                    // Reutilizamos la función de pago para enviar el dinero
                    Provider.of<LocaliaProvider>(context, listen: false).makePurchase(amount, destinatario);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Transferencia de \$${amount.toStringAsFixed(2)} enviada a $destinatario"))
                    );
                  }
                },
                child: const Text("ENVIAR TRANSFERENCIA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Coppel Pay", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TARJETA VIRTUAL DE SALDO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [LocaliaTheme.coppelGreen, Color(0xFF00C853)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: LocaliaTheme.coppelGreen.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Saldo Disponible", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("\$${state.balance.toStringAsFixed(2)}", 
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: LocaliaTheme.coppelYellow, size: 20),
                          const SizedBox(width: 5),
                          Text("${state.coppelPoints} Puntos", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Text("Localia Premium", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            // 2. BOTONES DE ACCIÓN 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BotonAccion(
                  icono: Icons.add_card_rounded, 
                  texto: "Recargar", 
                  color: LocaliaTheme.coppelYellow, 
                  onTap: () => _mostrarModalRecarga(context) 
                ),
                _BotonAccion(
                  icono: Icons.qr_code_scanner_rounded, 
                  texto: "Escanear", 
                  color: Colors.white, 
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Escáner biométrico simulado...")));
                  }
                ),
                _BotonAccion(
                  icono: Icons.swap_horiz_rounded, 
                  texto: "Transferir", 
                  color: Colors.white, 
                  onTap: () => _mostrarModalTransferencia(context) // 🔥 AHORA ABRE EL MODAL
                ),
              ],
            ),
            
            const SizedBox(height: 35),
            const Text("Movimientos Recientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 15),
            
            // 3. HISTORIAL DE TRANSACCIONES DINÁMICO
            Expanded(
              child: state.isProcessing 
                  ? const Center(child: CircularProgressIndicator(color: LocaliaTheme.coppelGreen))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.history.length,
                      itemBuilder: (context, index) {
                        final movimiento = state.history[index];
                        final esIngreso = movimiento.contains("+");
                        
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: esIngreso ? Colors.green.shade50 : Colors.red.shade50,
                            child: Icon(
                              esIngreso ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: esIngreso ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(
                            movimiento.split(':').first, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                          ),
                          trailing: Text(
                            movimiento.split(':').last,
                            style: TextStyle(
                              fontWeight: FontWeight.w900, 
                              color: esIngreso ? Colors.green : Colors.black87,
                              fontSize: 15
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback onTap;

  const _BotonAccion({required this.icono, required this.texto, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Icon(icono, color: Colors.black87, size: 28),
          ),
          const SizedBox(height: 8),
          Text(texto, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _OpcionesRecarga extends StatelessWidget {
  const _OpcionesRecarga();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("¿Cuánto deseas recargar?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BotonMontoRapido(monto: 100),
              _BotonMontoRapido(monto: 500),
              _BotonMontoRapido(monto: 1000),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LocaliaTheme.coppelGreen,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                Provider.of<LocaliaProvider>(context, listen: false).recargarCartera(5000);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Carga fuerte de \$5,000 recibida!")));
              },
              child: const Text("Recargar saldo fuerte (\$5,000)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

class _BotonMontoRapido extends StatelessWidget {
  final double monto;
  const _BotonMontoRapido({required this.monto});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Provider.of<LocaliaProvider>(context, listen: false).recargarCartera(monto);
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("¡Recarga de \$${monto.toInt()} en proceso!"), backgroundColor: LocaliaTheme.coppelGreen)
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: LocaliaTheme.coppelGreen.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(15),
          color: LocaliaTheme.coppelGreen.withOpacity(0.05),
        ),
        child: Text("\$${monto.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: LocaliaTheme.coppelGreen)),
      ),
    );
  }
}
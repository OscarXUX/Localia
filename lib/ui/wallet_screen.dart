import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import '../theme/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  // LÓGICA INTACTA: Modal de Recarga
  void _mostrarModalRecarga(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => const _OpcionesRecarga(),
    );
  }

  // LÓGICA INTACTA: Modal de Transferencia P2P
  void _mostrarModalTransferencia(BuildContext context) {
    final TextEditingController destinatarioCtrl = TextEditingController();
    final TextEditingController montoCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, // Para que el borde redondeado se vea perfecto
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 25, right: 25, top: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Transferir Dinero", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.black87)),
            const SizedBox(height: 20),
            
            // 🔥 ACTUALIZADO: TextFields estandarizados al diseño Perfil
            TextField(
              controller: destinatarioCtrl,
              decoration: InputDecoration(
                labelText: "Destinatario (Nombre o @Usuario)",
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.person_rounded, color: Colors.black54),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.08), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.black87, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: montoCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monto a transferir",
                labelStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.attach_money_rounded, color: Colors.black54),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.08), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.black87, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 25),
            
            // LÓGICA INTACTA: Botón de envío
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  final double? amount = double.tryParse(montoCtrl.text);
                  final String destinatario = destinatarioCtrl.text.isEmpty ? "Amigo" : destinatarioCtrl.text;

                  if (amount != null && amount > 0) {
                    Provider.of<LocaliaProvider>(context, listen: false).makePurchase(amount, destinatario);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Transferencia de \$${amount.toStringAsFixed(2)} enviada a $destinatario"),
                        backgroundColor: Colors.black87,
                      )
                    );
                  }
                },
                child: const Text("ENVIAR TRANSFERENCIA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
    // LÓGICA INTACTA: Lectura del estado global
    final state = Provider.of<LocaliaProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Coppel Pay", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 ACTUALIZADO: Tarjeta virtual premium oscura
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Saldo Disponible", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, fontWeight: FontWeight.w600)),
                      const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 22),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // LÓGICA INTACTA: Lectura del balance
                  Text("\$${state.balance.toStringAsFixed(2)}", 
                    style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LÓGICA INTACTA: Lectura de Puntos Coppel
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: LocaliaTheme.coppelYellow, size: 18),
                            const SizedBox(width: 6),
                            Text("${state.coppelPoints} Puntos", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Text("Localia Premium", style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            // 🔥 ACTUALIZADO: Botones de Acción estandarizados a tarjetas cuadradas
            Row(
              children: [
                Expanded(
                  child: _BotonAccion(
                    icono: Icons.add_circle_outline_rounded, 
                    texto: "Recargar", 
                    isPrimary: false,
                    onTap: () => _mostrarModalRecarga(context) 
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BotonAccion(
                    icono: Icons.qr_code_scanner_rounded, 
                    texto: "Escanear", 
                    isPrimary: false,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Escáner biométrico simulado..."), backgroundColor: Colors.black87));
                    }
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BotonAccion(
                    icono: Icons.swap_horiz_rounded, 
                    texto: "Transferir", 
                    isPrimary: true, // Resaltamos la transferencia con el color verde
                    onTap: () => _mostrarModalTransferencia(context)
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 35),
            const Text("Movimientos Recientes", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.black87)),
            const SizedBox(height: 15),
            
            // 🔥 ACTUALIZADO: Historial de transacciones con el nuevo diseño de bordes
            Expanded(
              child: state.isProcessing 
                  ? const Center(child: CircularProgressIndicator(color: Colors.black87))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.history.length,
                      itemBuilder: (context, index) {
                        // LÓGICA INTACTA: Parseo de datos del historial
                        final movimiento = state.history[index];
                        final esIngreso = movimiento.contains("+");
                        final nombreMovimiento = movimiento.split(':').first;
                        final montoMovimiento = movimiento.split(':').last;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: esIngreso ? const Color(0xFF008F39).withOpacity(0.1) : Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  esIngreso ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                  color: esIngreso ? const Color(0xFF008F39) : Colors.redAccent,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  nombreMovimiento, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                montoMovimiento,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900, 
                                  color: esIngreso ? const Color(0xFF008F39) : Colors.black87,
                                  fontSize: 16
                                ),
                              ),
                            ],
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

// 🔥 ACTUALIZADO: Botón de acción rediseñado como tarjeta
class _BotonAccion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool isPrimary;
  final VoidCallback onTap;

  const _BotonAccion({required this.icono, required this.texto, required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? LocaliaTheme.coppelGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icono, color: isPrimary ? Colors.white : Colors.black87, size: 24),
            const SizedBox(height: 8),
            Text(
              texto, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 13, 
                color: isPrimary ? Colors.white : Colors.black87
              )
            ),
          ],
        ),
      ),
    );
  }
}

// 🔥 ACTUALIZADO: Modal de recarga con estilos limpios
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
          const Text("¿Cuánto deseas recargar?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _BotonMontoRapido(monto: 100)),
              const SizedBox(width: 10),
              Expanded(child: _BotonMontoRapido(monto: 500)),
              const SizedBox(width: 10),
              Expanded(child: _BotonMontoRapido(monto: 1000)),
            ],
          ),
          const SizedBox(height: 25),
          
          // LÓGICA INTACTA: Recarga fuerte
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () {
                Provider.of<LocaliaProvider>(context, listen: false).recargarCartera(5000);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("¡Carga fuerte de \$5,000 recibida!"), backgroundColor: Colors.black87)
                );
              },
              child: const Text("Recargar saldo fuerte (\$5,000)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
          )
        ],
      ),
    );
  }
}

// 🔥 ACTUALIZADO: Botones de monto rápido estilo chip premium
class _BotonMontoRapido extends StatelessWidget {
  final double monto;
  const _BotonMontoRapido({required this.monto});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // LÓGICA INTACTA: Dispara la recarga
        Provider.of<LocaliaProvider>(context, listen: false).recargarCartera(monto);
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("¡Recarga de \$${monto.toInt()} en proceso!"), backgroundColor: Colors.black87)
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
        ),
        child: Center(
          child: Text(
            "\$${monto.toInt()}", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
          ),
        ),
      ),
    );
  }
}
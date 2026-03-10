import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/business.dart';
import '../providers/localia_provider.dart';

class BusinessDetailScreen extends StatelessWidget {
  final Business business;
  const BusinessDetailScreen({super.key, required this.business});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(business.name)),
      body: Center(child: Column(children: [
        const SizedBox(height: 50),
        Icon(business.icon, size: 100, color: Colors.green),
        const SizedBox(height: 50),
        // Busca donde dice .simulateAction y cámbialo por:
                  // Este es el botón que debes poner donde tenías el error
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008F39), // Verde Coppel
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              elevation: 5,
            ),
            onPressed: () {
              // La lógica de compra va AQUÍ adentro, no suelta en el Column
              Provider.of<LocaliaProvider>(context, listen: false)
                  .makePurchase(150.0, business.name);
                  
              // Opcional: Volver atrás después de pagar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Procesando pago con Coppel Pay...'))
              );
            },
            child: const Text(
              "Pagar con Coppel Pay",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
      ])),
    );
  }
}
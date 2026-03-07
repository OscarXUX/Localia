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
        ElevatedButton(onPressed: () => Provider.of<LocaliaProvider>(context, listen: false).simulateAction(context, "Pago exitoso con Coppel Pay"), child: const Text("Pagar con Coppel Pay")),
      ])),
    );
  }
}
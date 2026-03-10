import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/localia_provider.dart';
import '../../theme/app_theme.dart';

class SocialImpactCard extends StatelessWidget {
  const SocialImpactCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, color: Colors.blueAccent),
              const SizedBox(width: 10),
              const Text("Tu Impacto en Guanajuato", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: (state.totalSocialImpact / 5000), // Meta de 5k pesos
            backgroundColor: Colors.grey.shade100,
            color: Colors.blueAccent,
            minHeight: 12,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Has apoyado con:", style: TextStyle(color: Colors.grey.shade600)),
              Text("\$${state.totalSocialImpact.toStringAsFixed(0)} MXN", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.blueAccent)),
            ],
          ),
        ],
      ),
    );
  }
}
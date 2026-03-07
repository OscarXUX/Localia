import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/business.dart';
import '../../providers/localia_provider.dart';
import '../business_detail_screen.dart';

class BusinessCard extends StatelessWidget {
  final Business business;
  const BusinessCard({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => BusinessDetailScreen(business: business))),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 15, bottom: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35), // Máxima redondez
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(color: const Color(0xFF008F39).withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
              child: Icon(business.icon, color: const Color(0xFF008F39), size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(business.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.5)),
                  Text(business.category, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 5),
                  Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), Text(" ${business.rating}", style: const TextStyle(fontWeight: FontWeight.bold))]),
                ],
              ),
            ),
            Consumer<LocaliaProvider>(
              builder: (c, p, _) => IconButton(
                icon: Icon(p.isFavorite(business.id) ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                onPressed: () => p.toggleFavorite(business.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
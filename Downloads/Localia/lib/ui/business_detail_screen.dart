import 'package:flutter/material.dart'; import 'package:provider/provider.dart'; import '../providers/localia_provider.dart'; import '../theme/app_theme.dart';

class BusinessDetailScreen extends StatefulWidget { final dynamic business; // Recibe el objeto Business dinámico

const BusinessDetailScreen({super.key, required this.business});

@override State createState() => _BusinessDetailScreenState(); }

class _BusinessDetailScreenState extends State { final TextEditingController _reviewController = TextEditingController();

@override void dispose() { _reviewController.dispose(); super.dispose(); }

@override Widget build(BuildContext context) { final state = Provider.of(context);

// Buscamos si el negocio es favorito
final bool isFav = state.isFavorite(widget.business.id);

return Scaffold(
  backgroundColor: const Color(0xFFF2F2F7),
  appBar: AppBar(
    title: Text(widget.business.name, style: const TextStyle(fontWeight: FontWeight.bold)),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 1,
    actions: [
      IconButton(
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? Colors.red : Colors.grey,
        ),
        onPressed: () => state.toggleFavorite(widget.business.id),
      )
    ],
  ),
  body: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. BANNER O FOTO DE PRESENTACIÓN
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [LocaliaTheme.coppelGreen, Color(0xFF007A3B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(Icons.storefront_rounded, size: 80, color: Colors.white),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. CABECERA: Nombre y categoría
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.business.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: LocaliaTheme.coppelGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      widget.business.category,
                      style: const TextStyle(color: LocaliaTheme.coppelGreen, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Calificación
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.business.rating}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // 3. DESCRIPCIÓN
              const Text("Acerca del negocio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                widget.business.description,
                style: const TextStyle(color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 25),

              // 4. ACCIÓN MÓVIL: Pagar con Coppel Pay
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const Text(
                      "¿Consumiste aquí?",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Paga con tu saldo Coppel Pay y obtén 10% de puntos",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LocaliaTheme.coppelGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                        label: const Text(
                          "Pagar \$150.00 MXN",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        onPressed: () {
                          state.makePurchase(150.0, widget.business.name);
                          Navigator.pop(context); // Regresa al mapa
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // 5. CAJA DE COMENTARIOS
              const Text("Reseñas de Turistas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        hintText: "Escribe una reseña...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: LocaliaTheme.coppelGreen,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () {
                      if (_reviewController.text.trim().isNotEmpty) {
                        state.addReviewToBusiness(widget.business.id, _reviewController.text);
                        _reviewController.clear();
                      }
                    },
                  )
                ],
              ),
              const SizedBox(height: 15),

              // Lista de reseñas agregadas
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.business.reviews.length,
                itemBuilder: (context, i) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE5E5EA),
                        child: Icon(Icons.person, color: Colors.black54),
                      ),
                      title: Text(widget.business.reviews[i]),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ],
    ),
  ),
);
} }
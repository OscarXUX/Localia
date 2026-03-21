import 'dart:io'; // Necesario para cargar las fotos tomadas con la cámara
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/business.dart';
import '../providers/localia_provider.dart';
import '../theme/app_theme.dart';

/// [BusinessDetailScreen] es la pantalla donde el turista interactúa con el local.
/// Aquí puede ver fotos reales, leer reseñas, escribir su propia opinión y pagar.
class BusinessDetailScreen extends StatefulWidget {
  final Business business;
  const BusinessDetailScreen({super.key, required this.business});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  // ---------------------------------------------------------
  // 1. CONTROLADORES
  // ---------------------------------------------------------
  
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final PageController _pageController = PageController();
  
  bool _isPaymentMode = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reviewController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // CABECERA: Carrusel que soporta URLs de internet y Fotos de la Cámara
          _buildSliverCarousel(),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainHeader(),
                  const SizedBox(height: 25),
                  
                  _buildSectionTitle("Sobre este anfitrión"),
                  Text(
                    widget.business.description.isEmpty 
                        ? "Este negocio local está listo para recibirte en el Mundial 2026." 
                        : widget.business.description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: 25),

                  _buildInfoTile(Icons.access_time_filled_rounded, "Horario", widget.business.schedule),
                  _buildInfoTile(Icons.location_on_rounded, "Ubicación", widget.business.address),
                  _buildInfoTile(Icons.phone_rounded, "Contacto", widget.business.phone),
                  
                  const SizedBox(height: 40),

                  // LÓGICA DE PAGO: Botón inicial o Input de monto
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _isPaymentMode ? _buildPaymentInputArea() : _buildInitialPayButton(),
                  ),

                  const SizedBox(height: 45),

                  // NUEVA SECCIÓN: ESCRIBIR COMENTARIO
                  _buildAddReviewSection(),

                  const SizedBox(height: 30),
                  _buildSectionTitle("Lo que dicen otros turistas"),
                  const SizedBox(height: 15),
                  
                  // Lista de reseñas guardadas en el Provider
                  if (widget.business.reviews.isEmpty)
                    const Text("Aún no hay reseñas. ¡Sé el primero!", 
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                  else
                    ...widget.business.reviews.map((comment) => _buildReviewBubble(comment)).toList(),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 2. COMPONENTES DE INTERFAZ
  // ---------------------------------------------------------

  /// Widget para que el turista escriba su opinión sobre el negocio.
  Widget _buildAddReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Danos tu opinión", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          controller: _reviewController,
          decoration: InputDecoration(
            hintText: "Escribe tu reseña aquí...",
            filled: true,
            fillColor: const Color(0xFFF2F2F7),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send_rounded, color: LocaliaTheme.coppelGreen),
              onPressed: () {
                if (_reviewController.text.isNotEmpty) {
                  // Guardamos el comentario en el Provider para que sea persistente
                  Provider.of<LocaliaProvider>(context, listen: false)
                      .addReviewToBusiness(widget.business.id, _reviewController.text);
                  
                  _reviewController.clear(); // Limpiamos el campo
                  FocusScope.of(context).unfocus(); // Cerramos el teclado
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("¡Gracias por tu comentario!"))
                  );
                }
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  /// Carrusel de imágenes que detecta automáticamente si la foto es de Galería/Cámara o de Internet.
  Widget _buildSliverCarousel() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: LocaliaTheme.coppelYellow,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.business.photos.length,
              itemBuilder: (context, index) {
                String imagePath = widget.business.photos[index];
                
                // Si el path empieza con http es de internet, si no, es un archivo local del cel
                return Image(
                  image: imagePath.startsWith('http') 
                      ? NetworkImage(imagePath) 
                      : FileImage(File(imagePath)) as ImageProvider,
                  fit: BoxFit.cover,
                );
              },
            ),
            // Sombreado inferior para visibilidad
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black45],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentInputArea() {
    return Container(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: LocaliaTheme.coppelGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("¿Cuánto deseas pagar?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              IconButton(
                icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                onPressed: () => setState(() => _isPaymentMode = false),
              )
            ],
          ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
            decoration: const InputDecoration(hintText: "\$0.00", border: InputBorder.none),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LocaliaTheme.coppelGreen,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                final double? amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  Provider.of<LocaliaProvider>(context, listen: false)
                      .makePurchase(amount, widget.business.name);
                  Navigator.pop(context);
                }
              },
              child: const Text("CONFIRMAR TRANSACCIÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialPayButton() {
    return SizedBox(
      key: const ValueKey(1),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: LocaliaTheme.coppelGreen,
          padding: const EdgeInsets.symmetric(vertical: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () => setState(() => _isPaymentMode = true),
        child: const Text(
          "PAGAR CON COPPEL PAY",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildReviewBubble(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE5E5EA),
            child: Icon(Icons.person_outline_rounded, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(widget.business.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.2)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  Text(" ${widget.business.rating}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
        Text(widget.business.category.toUpperCase(), style: const TextStyle(color: LocaliaTheme.coppelGreen, fontWeight: FontWeight.w800, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5));
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.black87, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(value.isEmpty ? "No proporcionado" : value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/business.dart';
import '../providers/localia_provider.dart';
import '../theme/app_theme.dart';

class BusinessDetailScreen extends StatefulWidget {
  final Business business;
  const BusinessDetailScreen({super.key, required this.business});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
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
    // 🔥 LEER EL PROVIDER UNA SOLA VEZ AL INICIO
    final provider = Provider.of<LocaliaProvider>(context);
    final activeBusiness = provider.businesses.firstWhere(
      (b) => b.id == widget.business.id,
      orElse: () => widget.business,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverCarousel(activeBusiness),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pasamos 'provider' directamente
                  _buildMainHeader(activeBusiness, provider),
                  const SizedBox(height: 16),

                  _buildVerifiedBadge(),
                  const SizedBox(height: 25),

                  _buildSectionTitle("Sobre este anfitrión"),
                  const SizedBox(height: 8),
                  Text(
                    activeBusiness.description.isEmpty
                        ? "Este negocio local está listo para recibirte y ofrecerte la mejor atención de la región."
                        : activeBusiness.description,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 25),

                  _buildInfoTile(
                    Icons.access_time_filled_rounded,
                    "Horario de atención",
                    activeBusiness.schedule,
                  ),
                  _buildInfoTile(
                    Icons.location_on_rounded,
                    "Ubicación",
                    activeBusiness.address,
                  ),
                  _buildInfoTile(
                    Icons.phone_rounded,
                    "Contacto directo",
                    activeBusiness.phone,
                  ),

                  const SizedBox(height: 35),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: _isPaymentMode
                        ? _buildPaymentInputArea(activeBusiness)
                        : _buildInitialPayButton(),
                  ),

                  const SizedBox(height: 40),

                  _buildAddReviewSection(activeBusiness),

                  const SizedBox(height: 30),
                  _buildSectionTitle("Opiniones de la comunidad"),
                  const SizedBox(height: 15),

                  if (activeBusiness.reviews.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Text(
                        "Aún no hay reseñas registradas. ¡Sé el primer turista en opinar!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    ...activeBusiness.reviews
                        .map((comment) => _buildReviewBubble(comment))
                        .toList(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainHeader(Business activeBusiness, LocaliaProvider provider) {
    // Usamos el provider que recibimos por parámetro
    final bool esFavorito = provider.isFavorite(activeBusiness.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                activeBusiness.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 10),

            IconButton(
              icon: Icon(
                esFavorito
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: esFavorito ? Colors.redAccent : Colors.grey.shade400,
                size: 30,
              ),
              onPressed: () {
                provider.toggleFavorite(activeBusiness.id);

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      esFavorito
                          ? "Eliminado de favoritos"
                          : "¡Guardado en tus favoritos!",
                    ),
                    backgroundColor: esFavorito
                        ? Colors.grey[800]
                        : Colors.redAccent,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              activeBusiness.category.toUpperCase(),
              style: const TextStyle(
                color: LocaliaTheme.coppelGreen,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    activeBusiness.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: LocaliaTheme.coppelGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LocaliaTheme.coppelGreen.withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            color: LocaliaTheme.coppelGreen,
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            "Comercio Autorizado Coppel Pay",
            style: TextStyle(
              color: LocaliaTheme.coppelGreen,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverCarousel(Business activeBusiness) {
    final List<String> photos = activeBusiness.photos;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: LocaliaTheme.coppelYellow,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (photos.isEmpty)
              Container(
                color: LocaliaTheme.coppelYellow.withOpacity(0.3),
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 80,
                    color: LocaliaTheme.coppelGreen,
                  ),
                ),
              )
            else
              PageView.builder(
                controller: _pageController,
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  String imagePath = photos[index];
                  return Image(
                    image: imagePath.startsWith('http')
                        ? NetworkImage(imagePath)
                        : FileImage(File(imagePath)) as ImageProvider,
                    fit: BoxFit.cover,
                  );
                },
              ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black38, Colors.transparent, Colors.black54],
                  stops: [0.0, 0.5, 1.0],
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black87,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialPayButton() {
    return Container(
      key: const ValueKey(1),
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: LocaliaTheme.coppelGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: LocaliaTheme.coppelGreen,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        onPressed: () => setState(() => _isPaymentMode = true),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 22,
            ),
            SizedBox(width: 12),
            Text(
              "PAGAR CON COPPEL PAY",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInputArea(Business activeBusiness) {
    return Container(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LocaliaTheme.coppelGreen.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Monto a transferir",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.cancel_rounded,
                  color: Colors.redAccent,
                  size: 26,
                ),
                onPressed: () => setState(() => _isPaymentMode = false),
              ),
            ],
          ),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: LocaliaTheme.coppelGreen,
            ),
            decoration: const InputDecoration(
              hintText: "\$0.00",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [50, 100, 250]
                .map(
                  (quickAmount) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text("\$$quickAmount"),
                      selected: false,
                      onSelected: (_) {
                        setState(() {
                          _amountController.text = quickAmount.toString();
                        });
                      },
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LocaliaTheme.coppelGreen,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                final double? amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  Provider.of<LocaliaProvider>(
                    context,
                    listen: false,
                  ).makePurchase(amount, activeBusiness.name);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "¡Pago de \$$amount enviado a ${activeBusiness.name}!",
                      ),
                      backgroundColor: LocaliaTheme.coppelGreen,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "CONFIRMAR TRANSACCIÓN",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReviewSection(Business activeBusiness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Escribe tu experiencia"),
        const SizedBox(height: 12),
        TextField(
          controller: _reviewController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: "¿Qué tal te atendieron en este local?",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: LocaliaTheme.coppelGreen,
                ),
                onPressed: () {
                  if (_reviewController.text.trim().isNotEmpty) {
                    Provider.of<LocaliaProvider>(
                      context,
                      listen: false,
                    ).addReviewToBusiness(
                      activeBusiness.id,
                      _reviewController.text.trim(),
                    );

                    _reviewController.clear();
                    FocusScope.of(context).unfocus();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("¡Tu reseña se ha publicado con éxito!"),
                      ),
                    );
                  }
                },
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewBubble(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: LocaliaTheme.coppelYellow.withOpacity(0.4),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.black87,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Turista Localia",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(icon, color: LocaliaTheme.coppelGreen, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? "No especificado" : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

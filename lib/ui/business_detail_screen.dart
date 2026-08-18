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
    // LEER EL PROVIDER UNA SOLA VEZ AL INICIO (LÓGICA INTACTA)
    final provider = Provider.of<LocaliaProvider>(context);
    final activeBusiness = provider.businesses.firstWhere(
      (b) => b.id == widget.business.id,
      orElse: () => widget.business,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fondo gris claro y limpio
      body: CustomScrollView(
        slivers: [
          _buildSliverCarousel(activeBusiness),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 🔥 NUEVO: Tarjeta de información agrupada (Estilo Perfil)
                  _buildInfoCard(activeBusiness),

                  const SizedBox(height: 35),

                  // LÓGICA INTACTA: Animación del panel de pago
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

                  // LÓGICA INTACTA: Muestra reseñas o mensaje de vacío
                  if (activeBusiness.reviews.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
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

            // LÓGICA INTACTA: Botón de favoritos y SnackBar
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
            // 🔥 NUEVO: Diseño del Rating con borde estilizado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
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
        border: Border.all(color: LocaliaTheme.coppelGreen.withOpacity(0.3), width: 1.5),
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

  // LÓGICA INTACTA: Carrusel de imágenes web-safe
  Widget _buildSliverCarousel(Business activeBusiness) {
    final List<String> photos = activeBusiness.photos;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (photos.isEmpty)
              Container(
                color: Colors.grey.shade100,
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 80,
                    color: Colors.black12,
                  ),
                ),
              )
            else
              PageView.builder(
                controller: _pageController,
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  String imagePath = photos[index];

                  Widget imageWidget;
                  if (imagePath.startsWith('http')) {
                    imageWidget = Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _buildErrorImage(),
                    );
                  } else if (imagePath.startsWith('assets/')) {
                    imageWidget = Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _buildErrorImage(),
                    );
                  } else {
                    imageWidget = _buildErrorImage();
                  }

                  return imageWidget;
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
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
            ],
          ),
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

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_rounded,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text("Imagen no disponible", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // 🔥 NUEVO: Tarjeta agrupada para reemplazar los _buildInfoTile sueltos
  Widget _buildInfoCard(Business activeBusiness) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.access_time_filled_rounded,
            activeBusiness.schedule.isEmpty ? "9:00 AM - 6:00 PM" : activeBusiness.schedule,
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Colors.black12)),
          _buildInfoRow(
            Icons.location_on_rounded,
            activeBusiness.address.isEmpty ? "Guanajuato, México" : activeBusiness.address,
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Colors.black12)),
          _buildInfoRow(
            Icons.phone_rounded,
            activeBusiness.phone.isEmpty ? "No disponible" : activeBusiness.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // 🔥 ACTUALIZADO: Botón con estilo "Administrar Perfil"
  Widget _buildInitialPayButton() {
    return Container(
      key: const ValueKey(1),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 ACTUALIZADO: Panel de pago con bordes del nuevo diseño
  Widget _buildPaymentInputArea(Business activeBusiness) {
    return Container(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.cancel_rounded,
                  color: Colors.black26,
                  size: 24,
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
              color: LocaliaTheme.coppelGreen, // Mantenemos el verde para el dinero
            ),
            decoration: const InputDecoration(
              hintText: "\$0.00",
              hintStyle: TextStyle(color: Colors.black12),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 10),

          // LÓGICA INTACTA: Chips de montos rápidos
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [50, 100, 250]
                .map(
                  (quickAmount) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text("\$$quickAmount", style: const TextStyle(fontWeight: FontWeight.bold)),
                      selected: false,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.black.withOpacity(0.08), width: 1.5),
                      ),
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
          
          // LÓGICA INTACTA: Procesamiento de pago
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LocaliaTheme.coppelGreen, // Verde para confirmar transacción
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
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
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 ACTUALIZADO: Caja de texto rediseñada
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
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.black87,
                ),
                // LÓGICA INTACTA: Publicar reseña
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
                        backgroundColor: Colors.black87,
                      ),
                    );
                  }
                },
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.08), width: 1.5),
            ),
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
      ],
    );
  }

  // 🔥 ACTUALIZADO: Burbujas de reseña unificadas al diseño
  Widget _buildReviewBubble(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.black54,
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.4,
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
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import '../theme/app_theme.dart';
import 'widgets/business_card.dart';
import 'wallet_screen.dart';
import 'ai_chat_screen.dart';
import 'profile_screen.dart';
import 'business_detail_screen.dart';
import 'package:localia/ui/widgets/success_overlay.dart';
import './widgets/promociones_bottom_sheet.dart';

class TouristPortal extends StatefulWidget {
  const TouristPortal({super.key});

  @override
  State<TouristPortal> createState() => _TouristPortalState();
}

class _TouristPortalState extends State<TouristPortal> {
  @override
  void initState() {
    super.initState();

    // Dispara la consulta al microservicio en segundo plano al cargar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocaliaProvider>(
        context,
        listen: false,
      ).sincronizarEcosistema();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. CAPA DEL MAPA: Fondo con los marcadores interactivos
          _buildMapBackground(context, state),

          // 2. CAPA DE INTERFAZ: Elementos flotantes sobre el mapa
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildAppleHeader(context, state),
                  const SizedBox(height: 15),

                  // 🔥 NUEVO: Barra de búsqueda estandarizada con el diseño Perfil
                  _buildSearchBar(),
                  const SizedBox(height: 15),

                  _buildWorldCupTicker(state),
                  const Spacer(),
                  _buildBusinessCarousel(state),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // 3. OVERLAY DE CARGA: Se activa durante las transacciones locales
          if (state.isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  color: LocaliaTheme.coppelGreen,
                ),
              ),
            ),
          if (state.showSuccess) const SuccessOverlay(),
        ],
      ),
      // AQUÍ ESTÁ LA MAGIA: Una columna que agrupa los dos botones flotantes
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPromocionesFAB(context),
          const SizedBox(height: 15),
          _buildAppleFAB(context),
        ],
      ),
    );
  }

  // --- MÉTODOS DE CONSTRUCCIÓN DE INTERFAZ ---

  Widget _buildMapBackground(BuildContext context, LocaliaProvider state) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/mapa_gto.png'),
          fit: BoxFit.cover,
          opacity: 0.7,
        ),
      ),
      child: Stack(
        children: [
          // Si está cargando el backend y aún no hay datos, mostramos un indicador central
          if (state.isLoadingBackend && state.filteredBusinesses.isEmpty)
            const Center(
              child: CircularProgressIndicator(color: LocaliaTheme.coppelGreen),
            ),

          ...state.filteredBusinesses.map(
            (biz) => Positioned(
              left: MediaQuery.of(context).size.width * biz.mapX,
              top: MediaQuery.of(context).size.height * biz.mapY,
              child: _MapMarker(business: biz),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 ACTUALIZADO: Encabezado rediseñado con el estilo de la vista de Perfil
  Widget _buildAppleHeader(BuildContext context, LocaliaProvider state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        children: [
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Saldo Coppel Pay",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "\$${state.balance.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Botón Cartera
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const WalletScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: LocaliaTheme.coppelGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón Perfil
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const ProfileScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 NUEVO: Método integrado para la barra de búsqueda visual
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "¿Qué se te antoja buscar hoy?",
          hintStyle: const TextStyle(
            color: Colors.black38,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 ACTUALIZADO: Ticker suavizado para encajar con el nuevo estilo
  Widget _buildWorldCupTicker(LocaliaProvider state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.events[0].matchTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCarousel(LocaliaProvider state) {
    // Si la red está activa y no hay datos locales, ponemos un esqueleto visual de carga
    if (state.isLoadingBackend && state.filteredBusinesses.isEmpty) {
      return Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: LocaliaTheme.coppelGreen),
              SizedBox(height: 12),
              Text(
                "Cargando comercios de Guanajuato...",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: state.filteredBusinesses.length,
        itemBuilder: (c, i) =>
            BusinessCard(business: state.filteredBusinesses[i]),
      ),
    );
  }

  Widget _buildPromocionesFAB(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'btnPromociones',
      backgroundColor: LocaliaTheme.coppelYellow,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        PromocionesBottomSheet.mostrar(context);
      },
      label: const Text(
        "CUPONES",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.black87,
        ),
      ),
      icon: const Icon(Icons.local_offer_rounded, color: Colors.black87),
    );
  }

  Widget _buildAppleFAB(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'btnAsistente',
      backgroundColor: LocaliaTheme.coppelGreen,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const AIChatScreen()),
      ),
      label: const Text(
        "AI ASSISTANT",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.white,
        ),
      ),
      icon: const Icon(Icons.auto_awesome, color: Colors.white),
    );
  }
}

// 🔥 ACTUALIZADO: Marcador en el mapa rediseñado
class _MapMarker extends StatelessWidget {
  final dynamic business;
  const _MapMarker({required this.business});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => BusinessDetailScreen(business: business),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: LocaliaTheme.coppelGreen, width: 2.5),
        ),
        child: Icon(business.icon, color: LocaliaTheme.coppelGreen, size: 22),
      ),
    );
  }
}

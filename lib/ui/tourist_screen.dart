import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import '../theme/app_theme.dart';
import 'widgets/business_card.dart';
import 'wallet_screen.dart';
import 'ai_chat_screen.dart';
import 'profile_screen.dart';
import 'business_detail_screen.dart';

class TouristPortal extends StatelessWidget {
  const TouristPortal({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // MAPA (Tu asset mapa_gto.png)
          _buildMapBackground(context, state),

          // INTERFAZ FLOTANTE
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildAppleHeader(context, state),
                  const SizedBox(height: 15),
                  _buildWorldCupTicker(state),
                  const Spacer(),
                  _buildBusinessCarousel(state),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          
          if (state.isProcessing)
            Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: LocaliaTheme.coppelGreen))),
        ],
      ),
      floatingActionButton: _buildAppleFAB(context),
    );
  }

  Widget _buildMapBackground(BuildContext context, LocaliaProvider state) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/mapa_gto.png'), fit: BoxFit.cover, opacity: 0.7),
      ),
      child: Stack(
        children: [
          ...state.filteredBusinesses.map((biz) => Positioned(
            left: MediaQuery.of(context).size.width * biz.mapX,
            top: MediaQuery.of(context).size.height * biz.mapY,
            child: _MapMarker(business: biz),
          )),
        ],
      ),
    );
  }

  Widget _buildAppleHeader(BuildContext context, LocaliaProvider state) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: LocaliaTheme.glassStyle,
      child: Row(
        children: [
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Saldo Coppel Pay", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                Text("\$${state.balance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -1)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const WalletScreen())),
            child: const CircleAvatar(backgroundColor: LocaliaTheme.coppelGreen, child: Icon(Icons.account_balance_wallet, color: Colors.white, size: 20)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfileScreen())),
            child: const CircleAvatar(backgroundColor: Color(0xFFE5E5EA), child: Icon(Icons.person_rounded, color: Colors.black87, size: 20)),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildWorldCupTicker(LocaliaProvider state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(state.events[0].matchTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildBusinessCarousel(LocaliaProvider state) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.filteredBusinesses.length,
        itemBuilder: (c, i) => BusinessCard(business: state.filteredBusinesses[i]),
      ),
    );
  }

  Widget _buildAppleFAB(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: LocaliaTheme.coppelGreen,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AIChatScreen())),
      label: const Text("AI ASSISTANT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
      icon: const Icon(Icons.auto_awesome, color: Colors.white),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final dynamic business;
  const _MapMarker({required this.business});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => BusinessDetailScreen(business: business))),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          border: Border.all(color: LocaliaTheme.coppelGreen, width: 2),
        ),
        child: Icon(business.icon, color: LocaliaTheme.coppelGreen, size: 24),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import 'tourist_screen.dart';
import 'admin_screen.dart';
import 'login_screen.dart'; // Importa la nueva pantalla

class MainEntry extends StatelessWidget {
  const MainEntry({super.key});
  
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);
    
    // Bloqueo de seguridad: Si no hay sesión, muestra el Login
    if (!state.isAuthenticated) {
      return const LoginScreen();
    }
    
    // Si ya inició sesión, revisamos su rol para mandarlo al mapa o al dashboard
    return state.isAdmin ? const AdminScreen() : const TouristPortal();
  }
}
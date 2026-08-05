import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white, // Consistencia con el diseño Apple limpio
      appBar: AppBar(
        title: const Text(
          "Mi Perfil",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            // --- DETECTOR DE GESTOS PARA PRUEBA DE SEGURIDAD NATIVA ---
            GestureDetector(
              onTap: () {
                // Forzamos la impresión segura del estado del Sandbox en la terminal de VS Code
                // Mitiga el error de desincronización de sockets web de la extensión
                state.auditarSeguridadSandbox();
              },
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF008F39), // Verde Coppel
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Oscar Pérez", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)
            ),
            const Text(
              "Explorador en sedes del Mundial 2026", 
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)
            ),
            
            const SizedBox(height: 40),
            
            _buildProfileTile(Icons.favorite, "Mis Favoritos", "${state.favorites.length}"),
            _buildProfileTile(Icons.account_balance_wallet, "Puntos Coppel", "${state.coppelPoints}"),
            
            const Spacer(),

            // --- PANEL DE CONMUTACIÓN DE ROLES (SANDBOX COMERCIANTE) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7), // Gris claro Apple
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.black.withOpacity(0.03)),
              ),
              child: Column(
                children: [
                  const Text(
                    "¿Eres miembro de Ola México o Coppel Emprende?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Accede al dashboard de administración de tu PyME",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008F39), // Verde Coppel
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () {
                      state.setRole(true); // Cambia el rol a Administrador en el Provider
                      Navigator.pop(context); // Cierra la vista actual; MainEntry enrutará al Dashboard
                    },
                    child: const Text(
                      "Ir al Panel de Administrador",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Constructor de filas informativas Premium
  Widget _buildProfileTile(IconData icon, String title, String trailing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF008F39).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF008F39), size: 22),
        ),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87, fontSize: 15)
        ),
        trailing: Text(
          trailing, 
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)
        ),
      ),
    );
  }
}
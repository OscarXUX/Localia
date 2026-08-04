import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF008F39),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 15),
            const Text(
              "Oscar Pérez", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const Text("Explorador en Guanajuato", style: TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 40),
            
            _buildProfileTile(Icons.favorite, "Mis Favoritos", "${state.favorites.length}"),
            _buildProfileTile(Icons.account_balance_wallet, "Puntos Coppel", "${state.coppelPoints}"),
            
            const Spacer(),

            // --- ESTE ES EL BOTÓN QUE FALTABA ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  const Text(
                    "¿Tienes un negocio en Guanajuato?",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008F39),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      state.setRole(true); // Cambia el estado a Admin
                      Navigator.pop(context); // Cierra el perfil para ver el panel
                    },
                    child: const Text("Ir al Panel de Administrador"),
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

  Widget _buildProfileTile(IconData icon, String title, String trailing) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF008F39)),
      title: Text(title),
      trailing: Text(trailing, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
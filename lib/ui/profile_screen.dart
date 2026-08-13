import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import 'admin_screen.dart'; // Importante para que funcione la navegación

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Cuadro de diálogo principal
  void _mostrarSelectorDeUsuario(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Gestión de Cuenta", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.star, color: Colors.white)),
              title: const Text("Turista Premium (Admin)"),
              onTap: () {
                Provider.of<LocaliaProvider>(context, listen: false).cambiarUsuario("premium");
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
              title: const Text("Turista Básico"),
              onTap: () {
                Provider.of<LocaliaProvider>(context, listen: false).cambiarUsuario("basico");
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person_add, color: Colors.white)),
              title: const Text("Crear Nueva Cuenta"),
              onTap: () {
                Navigator.pop(context);
                _mostrarFormularioRegistro(context); // Abre el formulario
              },
            ),
          ],
        ),
      ),
    );
  }

  // Cuadro de diálogo con el formulario real
  void _mostrarFormularioRegistro(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Nueva Cuenta", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nombre completo",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008F39),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Provider.of<LocaliaProvider>(context, listen: false)
                          .registrarUsuario(_nameController.text, _emailController.text);
                      
                      _nameController.clear();
                      _emailController.clear();
                      Navigator.pop(context); // Cierra el formulario
                    }
                  },
                  child: const Text("REGISTRARSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);
    
    final String nombreReal = state.perfil.isNotEmpty ? (state.perfil['name'] ?? 'Cargando...') : 'Cargando...';
    final String bioReal = state.perfil.isNotEmpty ? (state.perfil['accountType'] ?? 'Explorador') : 'Explorador';
    final String rolReal = state.perfil.isNotEmpty ? (state.perfil['role'] ?? 'user') : 'user';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts_rounded),
            tooltip: "Gestión de Cuenta",
            onPressed: () => _mostrarSelectorDeUsuario(context),
          ),
        ],
      ),
      body: state.isLoadingBackend
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF008F39)))
          : Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: rolReal == 'admin' ? Colors.amber.shade600 : const Color(0xFF008F39),
                    child: Icon(
                      rolReal == 'admin' ? Icons.workspace_premium : Icons.person, 
                      size: 50, 
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    nombreReal, 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  Text(bioReal, style: const TextStyle(color: Colors.grey)),
                  
                  const SizedBox(height: 40),
                  
                  _buildProfileTile(Icons.favorite, "Mis Favoritos", "${state.favorites.length}"),
                  _buildProfileTile(Icons.account_balance_wallet, "Puntos Coppel", "${state.coppelPoints}"),
                  
                  const Spacer(),

                  // 🔥 LÓGICA DE SEGURIDAD: Solo si el rol es 'admin', mostramos el panel
                  if (rolReal == 'admin')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.shade400, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Acceso de Administrador",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: () {
                              state.setRole(true); 
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AdminScreen()));
                            },
                            child: const Text("Ir al Panel de Negocios"),
                          ),
                        ],
                      ),
                    )
                  else
                    // Mensaje para usuarios normales
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Text(
                          "Tu cuenta actual no tiene privilegios para administrar negocios locales.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
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
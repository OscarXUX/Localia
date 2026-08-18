import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import '../theme/app_theme.dart';
import 'admin_screen.dart'; 
import 'login_screen.dart'; // 🔥 IMPORTACIÓN NUEVA: Necesaria para redirigir al cerrar sesión

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
                _mostrarFormularioRegistro(context); 
              },
            ),
          ],
        ),
      ),
    );
  }

  // Cuadro de diálogo con el formulario real
  void _mostrarFormularioRegistro(BuildContext context) {
    final TextEditingController _passController = TextEditingController();

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
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _passController,
                obscureText: true, 
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: const Icon(Icons.lock),
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
                          .registrarUsuario(_nameController.text, _emailController.text, _passController.text, 'user'); 
                      
                      _nameController.clear();
                      _emailController.clear();
                      _passController.clear(); 
                      Navigator.pop(context); 
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
    
    final Map<String, dynamic> userData = state.perfilUsuario; 
    
    final String nombreReal = userData.isNotEmpty ? (userData['name'] ?? 'Turista Localia') : 'Cargando...';
    final String rolReal = userData.isNotEmpty ? (userData['role'] ?? 'user') : 'user';
    final String bioReal = rolReal == 'admin' ? 'Turista Premium' : 'Nuevo Turista';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA), 
      appBar: AppBar(
        title: const Text("Mi Perfil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.black54),
            tooltip: "Gestión de Cuenta",
            onPressed: () => _mostrarSelectorDeUsuario(context),
          ),
        ],
      ),
      body: state.isLoadingBackend
          ? const Center(child: CircularProgressIndicator(color: LocaliaTheme.coppelGreen))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  
                  // 1. AVATAR PREMIUM
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))
                      ]
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: rolReal == 'admin' ? LocaliaTheme.coppelYellow : LocaliaTheme.coppelGreen,
                      child: Icon(
                        rolReal == 'admin' ? Icons.workspace_premium_rounded : Icons.person_rounded, 
                        size: 55, 
                        color: rolReal == 'admin' ? Colors.black87 : Colors.white
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 2. TEXTOS DINÁMICOS
                  Text(
                    nombreReal, 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.black87)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bioReal, 
                    style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w600)
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // 3. TARJETA DE ESTADÍSTICAS
                  Container(
                    decoration: LocaliaTheme.solidCardStyle,
                    child: Column(
                      children: [
                        _buildPremiumTile(Icons.favorite_rounded, Colors.redAccent, "Mis Favoritos", "${state.favorites.length}"),
                        Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15), indent: 50),
                        _buildPremiumTile(Icons.account_balance_wallet_rounded, LocaliaTheme.coppelGreen, "Puntos Coppel", "${state.coppelPoints}"),
                      ],
                    ),
                  ),
                  
                  const Spacer(),

                  // 4. TARJETA DE SEGURIDAD Y PANELES
                  if (rolReal == 'admin')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: LocaliaTheme.solidCardStyle.copyWith(
                        border: Border.all(color: LocaliaTheme.coppelYellow.withValues(alpha: 0.6), width: 1.5),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.admin_panel_settings_rounded, color: Colors.amber),
                              SizedBox(width: 8),
                              Text("Acceso de Administrador", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              state.setRole(true); 
                              
                              // 🔥 Le quitamos el "Replacement" para que solo apile la pantalla de Admin
                              // y mantenga vivo el Perfil debajo.
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminScreen()));
                            },
                            child: const Text("Ir al Panel de Negocios", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: LocaliaTheme.solidCardStyle,
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.grey.shade400, size: 28),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              "Tu cuenta actual es de Turista Básico y no tiene privilegios administrativos.",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 15),

                  // 🔥 5. BOTÓN DE CERRAR SESIÓN (Punto 1 completado)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.1), // Fondo rojizo tenue
                      ),
                      onPressed: () {
                        // 1. Limpia los datos de la memoria
                        Provider.of<LocaliaProvider>(context, listen: false).logout();
                        
                        // 2. Navega al Login y destruye todas las pantallas anteriores por seguridad
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text("Cerrar Sesión", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // Funciones de apoyo para la UI
  Widget _buildPremiumTile(IconData icon, Color iconColor, String title, String trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          Text(trailing, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
        ],
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
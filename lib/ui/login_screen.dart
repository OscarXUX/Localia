import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import '../theme/app_theme.dart';
import 'main_entry.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Ponemos las credenciales por defecto para agilizar pruebas
  final _emailController = TextEditingController(text: 'oscar.g@localia.app');
  final _passController = TextEditingController(text: '12345');
  bool _isLoading = false;

  void _intentarLogin() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<LocaliaProvider>(context, listen: false);
    
    bool exito = await provider.login(_emailController.text, _passController.text);
    
    if (exito) {
      // Destruimos la pantalla de login y entramos a la app
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (c) => const MainEntry()), 
        (route) => false
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Credenciales incorrectas"), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.travel_explore_rounded, size: 80, color: LocaliaTheme.coppelGreen),
              const SizedBox(height: 20),
              const Text("Bienvenido a Localia", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const Text("Tu pasaporte a Guanajuato", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 50),
              
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Correo Electrónico",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 40),
              
              _isLoading
                ? const Center(child: CircularProgressIndicator(color: LocaliaTheme.coppelGreen))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LocaliaTheme.coppelGreen,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _intentarLogin,
                    child: const Text("INICIAR SESIÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
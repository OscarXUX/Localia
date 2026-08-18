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
  final _emailController = TextEditingController(text: 'oscar.g@localia.app');
  final _passController = TextEditingController(text: '12345');
  bool _isLoading = false;

  void _intentarLogin() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<LocaliaProvider>(context, listen: false);
    
    bool exito = await provider.login(_emailController.text, _passController.text);
    
    if (exito) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const MainEntry()), (route) => false);
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Credenciales incorrectas"), backgroundColor: Colors.red));
    }
  }

  // --- FORMULARIO DESLIZABLE DE REGISTRO ---
  void _mostrarFormularioRegistro() {
    final nombreRegCtrl = TextEditingController();
    final emailRegCtrl = TextEditingController();
    final passRegCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    // Variable para controlar el rol seleccionado
    String rolSeleccionado = 'user'; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      // Usamos StatefulBuilder para que el Dropdown pueda actualizarse visualmente
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 30, right: 30, top: 30,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Únete a Localia", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: LocaliaTheme.coppelGreen)),
                  const SizedBox(height: 25),
                  
                  TextFormField(
                    controller: nombreRegCtrl,
                    decoration: InputDecoration(labelText: "Nombre completo", prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 15),
                  
                  TextFormField(
                    controller: emailRegCtrl,
                    decoration: InputDecoration(labelText: "Correo Electrónico", prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 15),
                  
                  TextFormField(
                    controller: passRegCtrl,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Crea una contraseña", prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 15),
                  
                  // 🔥 NUEVO: Selector de Tipo de Cuenta
                  DropdownButtonFormField<String>(
                    value: rolSeleccionado,
                    decoration: InputDecoration(
                      labelText: "Tipo de Cuenta",
                      prefixIcon: const Icon(Icons.card_membership_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text("Turista Básico (Explorar)")),
                      DropdownMenuItem(value: 'admin', child: Text("Turista Premium (Registrar Negocios)")),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setModalState(() => rolSeleccionado = newValue);
                      }
                    },
                  ),
                  const SizedBox(height: 25),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: LocaliaTheme.coppelGreen, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          // 1. Extraemos datos
                          final nombre = nombreRegCtrl.text;
                          final email = emailRegCtrl.text;
                          final pass = passRegCtrl.text;
                          final rol = rolSeleccionado;

                          // 🔥 LA MAGIA: Capturamos el navegador, el mensajero y el provider ANTES de hacer nada
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          final provider = Provider.of<LocaliaProvider>(context, listen: false);

                          // 2. Ahora sí, cerramos el modal de forma segura
                          navigator.pop(); 
                          
                          // 3. Ruedita de carga
                          setState(() => _isLoading = true);
                          
                          // 4. Petición a Node.js
                          bool exito = await provider.registrarUsuario(nombre, email, pass, rol);
                          
                          if (!mounted) return;
                          setState(() => _isLoading = false);
                          
                          if (exito) {
                            _emailController.text = email;
                            _passController.clear();
                            // Usamos la variable capturada en lugar del context destruido
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text("¡Cuenta creada con éxito! Por favor, inicia sesión."), backgroundColor: LocaliaTheme.coppelGreen)
                            );
                          } else {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text("Ocurrió un error al registrarse."), backgroundColor: Colors.red)
                            );
                          }
                        }
                      },
                      child: const Text("CREAR CUENTA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 100,
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
                  decoration: InputDecoration(labelText: "Correo Electrónico", prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Contraseña", prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                ),
                const SizedBox(height: 40),
                
                _isLoading
                  ? const Center(child: CircularProgressIndicator(color: LocaliaTheme.coppelGreen))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: LocaliaTheme.coppelGreen, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          onPressed: _intentarLogin,
                          child: const Text("INICIAR SESIÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: _mostrarFormularioRegistro,
                          child: const Text("¿No tienes cuenta? Regístrate aquí", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15)),
                        )
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
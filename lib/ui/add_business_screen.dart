import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import '../models/business.dart';

class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key});

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // CONTROLADORES DE TEXTO (Para capturar los datos)
  final _nameController = TextEditingController();
  final _rfcController = TextEditingController();
  final _repController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();
  
  // VARIABLES DE ESTADO
  String _category = 'Comida';
  int _priceLevel = 1;
  IconData _selectedIcon = Icons.restaurant;
  
  final List<String> _categories = ['Comida', 'Tienda', 'Servicio', 'Artesanía', 'Hotel'];
  final List<Map<String, dynamic>> _icons = [
    {'name': 'Restaurante', 'icon': Icons.restaurant},
    {'name': 'Tienda', 'icon': Icons.storefront_rounded},
    {'name': 'Servicios', 'icon': Icons.construction_rounded},
    {'name': 'Hotel', 'icon': Icons.hotel_rounded},
    {'name': 'Artesanías', 'icon': Icons.palette_rounded},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _rfcController.dispose();
    _repController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Gris claro iOS
      appBar: AppBar(
        title: const Text("Registrar Nueva PyME", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("1. IDENTIFICACIÓN DEL NEGOCIO", Icons.store_rounded),
              _buildFormCard([
                _buildOutlinedField(controller: _nameController, label: "Nombre Comercial", icon: Icons.storefront_rounded, isRequired: true),
                _buildOutlinedField(controller: _rfcController, label: "R.F.C. (Opcional)", icon: Icons.description_rounded),
                _buildOutlinedField(controller: _repController, label: "Representante Legal", icon: Icons.person_rounded, isRequired: true),
                _buildCategoryDropdown(),
              ]),
              
              const SizedBox(height: 35),
              _buildSectionHeader("2. CONTACTO Y UBICACIÓN", Icons.map_rounded),
              _buildFormCard([
                _buildOutlinedField(controller: _addressController, label: "Dirección Física Completa", icon: Icons.location_on_rounded, isRequired: true),
                _buildOutlinedField(controller: _phoneController, label: "Teléfono de Negocio", icon: Icons.phone_rounded, isRequired: true, keyboardType: TextInputType.phone),
                _buildOutlinedField(controller: _descController, label: "Descripción Breve", icon: Icons.description_rounded, maxLines: 3),
              ]),

              const SizedBox(height: 35),
              _buildSectionHeader("3. DETALLES OPERATIVOS Y CLASIFICACIÓN", Icons.analytics_rounded),
              _buildFormCard([
                _buildPriceDropdown(),
                _buildIconSelector(), // El selector horizontal premium
              ]),
              
              const SizedBox(height: 35),
              _buildFormCard([
                _buildInitialRatingInfo(), // Read-only 5.0 rating
              ]),
              const SizedBox(height: 120), // Espacio para el FAB
            ],
          ),
        ),
      ),
      floatingActionButton: _buildSaveFAB(context),
    );
  }

  // WIDGET HELPER: Encabezado de sección
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600, letterSpacing: 1.0)),
        ],
      ),
    );
  }

  // WIDGET HELPER: Tarjeta contenedora de inputs
  Widget _buildFormCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(children: children),
    );
  }

  // WIDGET HELPER: Campo de texto moderno (Apple Style)
  Widget _buildOutlinedField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: isRequired ? "$label *" : label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
        ),
        validator: isRequired ? (value) => (value == null || value.isEmpty) ? "Campo requerido" : null : null,
      ),
    );
  }

  // WIDGET HELPER: Dropdowns con estilo unificado
  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _category,
        decoration: InputDecoration(
          labelText: "Giro o Categoría",
          prefixIcon: const Icon(Icons.category_rounded, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
        ),
        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => setState(() => _category = v!),
      ),
    );
  }

  Widget _buildPriceDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<int>(
        value: _priceLevel,
        decoration: InputDecoration(
          labelText: "Nivel de Precios",
          prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
        ),
        items: [
          const DropdownMenuItem(value: 1, child: Text("\$ (Económico)")),
          const DropdownMenuItem(value: 2, child: Text("\$\$ (Medio)")),
          const DropdownMenuItem(value: 3, child: Text("\$\$\$ (Premium)")),
        ],
        onChanged: (v) => setState(() => _priceLevel = v!),
      ),
    );
  }

  // WIDGET HELPER: Selector horizontal de iconos (Premium)
  Widget _buildIconSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Icono de Identidad", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _icons.length,
              itemBuilder: (context, index) {
                final iconData = _icons[index];
                bool isSelected = _selectedIcon == iconData['icon'];
                // 1. Cambia 'Container' por 'GestureDetector'
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconData['icon'];
                    });
                  },
                  child: Container( // 2. El Container se queda SOLO con el diseño
                    width: 70,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF008F39).withOpacity(0.1) : const Color(0xFFF9F9F9),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF008F39) : const Color(0xFFE5E5EA), 
                        width: 1.5
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconData['icon'], 
                          color: isSelected ? const Color(0xFF008F39) : Colors.black, 
                          size: 25
                        ),
                        Text(
                          iconData['name'], 
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF008F39) : Colors.grey, 
                            fontSize: 10, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET HELPER: Info card para el rating predeterminado (Read-only)
  Widget _buildInitialRatingInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFFFAEB), borderRadius: BorderRadius.circular(20)),
      child: const Row(
        children: [
          Icon(Icons.star_rounded, color: Color(0xFFFFB800)),
          SizedBox(width: 10),
          Text("Rating Predeterminado de Registro:", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF8B6400))),
          Spacer(),
          Text("5.0", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF8B6400))),
        ],
      ),
    );
  }

  // WIDGET HELPER: Botón de Guardar Coppel Style
  Widget _buildSaveFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // Creamos el negocio completo
          final newBiz = Business(
            id: DateTime.now().toString(), // ID automático
            name: _nameController.text,
            category: _category,
            rating: 5.0, // Puntuación inicial fija
            icon: _selectedIcon, // El icono seleccionado por el usuario
            mapX: 0.5, // Coordenadas temporales
            mapY: 0.5,
            priceLevel: _priceLevel,
          );
          
          // Agregamos al Provider
          Provider.of<LocaliaProvider>(context, listen: false).addBusiness(newBiz);
          
          // Cerramos y damos feedback
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("¡PyME registrada con éxito en Guanajuato!"), backgroundColor: Color(0xFF008F39)),
          );
        }
      },
      backgroundColor: const Color(0xFF008F39), // Verde Coppel
      icon: const Icon(Icons.check_rounded, color: Colors.white),
      label: const Text("Guardar Registro", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import '../models/business.dart';

class AddBusinessScreen extends StatefulWidget {
  // PARÁMETRO DE EDICIÓN: Si es nulo, la pantalla es para "Registrar". Si tiene datos, es para "Editar".
  final Business? businessToEdit;

  const AddBusinessScreen({super.key, this.businessToEdit});

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 1. CONTROLADORES: Usamos 'late' para inicializarlos en el initState con los datos si estamos editando.
  late TextEditingController _nameController;
  late TextEditingController _rfcController;
  late TextEditingController _repController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _descController;
  
  // 2. VARIABLES DE ESTADO: Capturan las selecciones de los Dropdowns e Iconos.
  late String _category;
  late int _priceLevel;
  late IconData _selectedIcon;
  
  final List<String> _categories = ['Comida', 'Tienda', 'Servicio', 'Artesanía', 'Hotel'];
  final List<Map<String, dynamic>> _icons = [
    {'name': 'Restaurante', 'icon': Icons.restaurant},
    {'name': 'Tienda', 'icon': Icons.storefront_rounded},
    {'name': 'Servicios', 'icon': Icons.construction_rounded},
    {'name': 'Hotel', 'icon': Icons.hotel_rounded},
    {'name': 'Artesanías', 'icon': Icons.palette_rounded},
  ];

  @override
  void initState() {
    super.initState();
    // LÓGICA DE DETECCIÓN: ¿Estamos editando?
    final isEditing = widget.businessToEdit != null;

    // Inicializamos controladores con datos existentes o vacíos
    _nameController = TextEditingController(text: isEditing ? widget.businessToEdit!.name : "");
    _rfcController = TextEditingController(); // Nota: RFC no está en el modelo Business aún
    _repController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _descController = TextEditingController();

    // Cargamos selecciones previas si es edición
    _category = isEditing ? widget.businessToEdit!.category : 'Comida';
    _priceLevel = isEditing ? widget.businessToEdit!.priceLevel : 1;
    _selectedIcon = isEditing ? widget.businessToEdit!.icon : Icons.restaurant;
  }

  @override
  void dispose() {
    // IMPORTANTE: Liberar memoria de los controladores al cerrar la pantalla
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
    final isEditing = widget.businessToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Fondo Gris claro estilo iOS
      appBar: AppBar(
        title: Text(isEditing ? "Editar PyME" : "Registrar Nueva PyME", 
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: -1)),
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
              // SECCIÓN 1: Datos legales y nombre
              _buildSectionHeader("1. IDENTIFICACIÓN DEL NEGOCIO", Icons.store_rounded),
              _buildFormCard([
                _buildOutlinedField(controller: _nameController, label: "Nombre Comercial", icon: Icons.storefront_rounded, isRequired: true),
                _buildOutlinedField(controller: _rfcController, label: "R.F.C. (Opcional)", icon: Icons.description_rounded),
                _buildOutlinedField(controller: _repController, label: "Representante Legal", icon: Icons.person_rounded, isRequired: true),
                _buildCategoryDropdown(),
              ]),
              
              const SizedBox(height: 35),
              
              // SECCIÓN 2: Datos de contacto (Los que habías diseñado)
              _buildSectionHeader("2. CONTACTO Y UBICACIÓN", Icons.map_rounded),
              _buildFormCard([
                _buildOutlinedField(controller: _addressController, label: "Dirección Física Completa", icon: Icons.location_on_rounded, isRequired: true),
                _buildOutlinedField(controller: _phoneController, label: "Teléfono de Negocio", icon: Icons.phone_rounded, isRequired: true, keyboardType: TextInputType.phone),
                _buildOutlinedField(controller: _descController, label: "Descripción Breve", icon: Icons.description_rounded, maxLines: 3),
              ]),

              const SizedBox(height: 35),

              // SECCIÓN 3: Clasificación y selector de icono
              _buildSectionHeader("3. DETALLES OPERATIVOS", Icons.analytics_rounded),
              _buildFormCard([
                _buildPriceDropdown(),
                _buildIconSelector(),
              ]),
              
              const SizedBox(height: 35),

              // SECCIÓN 4: Info de Rating (Informativo)
              _buildFormCard([
                _buildInitialRatingInfo(isEditing ? widget.businessToEdit!.rating : 5.0),
              ]),
              
              const SizedBox(height: 120), // Espacio para que el botón flotante no tape el contenido
            ],
          ),
        ),
      ),
      floatingActionButton: _buildSaveFAB(context),
    );
  }

  // --- COMPONENTES DE DISEÑO (WIDGET HELPERS) ---

  // Crea el título de cada sección con un icono pequeño
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

  // Tarjeta blanca con sombra que agrupa los inputs
  Widget _buildFormCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(children: children),
    );
  }

  // Input de texto personalizado con bordes redondeados
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
        validator: isRequired ? (value) => (value == null || value.isEmpty) ? "Requerido" : null : null,
      ),
    );
  }

  // Selector de categoría (Dropdown)
  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _category,
        decoration: InputDecoration(
          labelText: "Giro o Categoría",
          prefixIcon: const Icon(Icons.category_rounded, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => setState(() => _category = v!),
      ),
    );
  }

  // Selector de precio (Dropdown)
  Widget _buildPriceDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<int>(
        value: _priceLevel,
        decoration: InputDecoration(
          labelText: "Nivel de Precios",
          prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
        items: const [
          DropdownMenuItem(value: 1, child: Text("\$ (Económico)")),
          DropdownMenuItem(value: 2, child: Text("\$\$ (Medio)")),
          DropdownMenuItem(value: 3, child: Text("\$\$\$ (Premium)")),
        ],
        onChanged: (v) => setState(() => _priceLevel = v!),
      ),
    );
  }

  // Selector horizontal de iconos con efecto de selección verde
  Widget _buildIconSelector() {
    return Column(
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
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = iconData['icon']),
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF008F39).withOpacity(0.1) : const Color(0xFFF9F9F9),
                    border: Border.all(color: isSelected ? const Color(0xFF008F39) : const Color(0xFFE5E5EA), width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(iconData['icon'], color: isSelected ? const Color(0xFF008F39) : Colors.black),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Tarjeta que muestra el rating actual o inicial
  Widget _buildInitialRatingInfo(double rating) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFFFAEB), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFB800)),
          const SizedBox(width: 10),
          const Text("Rating del Negocio:", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF8B6400))),
          const Spacer(),
          Text("$rating", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF8B6400))),
        ],
      ),
    );
  }

  // BOTÓN GUARDAR: Decide si llamar a 'addBusiness' o 'updateBusiness'
  Widget _buildSaveFAB(BuildContext context) {
    final isEditing = widget.businessToEdit != null;

    return FloatingActionButton.extended(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          final provider = Provider.of<LocaliaProvider>(context, listen: false);
          
          final businessData = Business(
            id: isEditing ? widget.businessToEdit!.id : DateTime.now().toString(),
            name: _nameController.text,
            category: _category,
            rating: isEditing ? widget.businessToEdit!.rating : 5.0,
            icon: _selectedIcon,
            mapX: isEditing ? widget.businessToEdit!.mapX : 0.5,
            mapY: isEditing ? widget.businessToEdit!.mapY : 0.5,
            priceLevel: _priceLevel,
          );
          
          if (isEditing) {
            provider.updateBusiness(businessData);
          } else {
            provider.addBusiness(businessData);
          }
          
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? "¡Cambios guardados!" : "¡PyME registrada con éxito!"),
              backgroundColor: const Color(0xFF008F39),
            ),
          );
        }
      },
      backgroundColor: const Color(0xFF008F39),
      label: Text(isEditing ? "Actualizar PyME" : "Guardar Registro", 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      icon: const Icon(Icons.check_rounded, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
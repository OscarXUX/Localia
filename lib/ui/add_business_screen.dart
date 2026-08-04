import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/business.dart';
import '../providers/localia_provider.dart';
import '../theme/app_theme.dart';
import 'dart:io'; 
import 'package:image_picker/image_picker.dart';

/// [AddBusinessScreen] permite tanto la creación de un nuevo negocio como la edición 
/// de uno existente. Si se pasa un [businessToEdit], el formulario se auto-completa.
class AddBusinessScreen extends StatefulWidget {
  final Business? businessToEdit;

  const AddBusinessScreen({super.key, this.businessToEdit});

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // ---------------------------------------------------------
  // 1. LÓGICA DE CAPTURA DE IMAGEN
  // ---------------------------------------------------------

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          // Guardamos la ruta del archivo real en la lista
          _photoList.add(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error al capturar imagen: $e");
    }
  }

  // ---------------------------------------------------------
  // 2. CONTROLADORES Y ESTADO LOCAL
  // ---------------------------------------------------------
  
  late TextEditingController _nameController, _descController, _addressController,
      _phoneController, _repController, _rfcController, _scheduleController, _photoUrlController;

  String _category = 'Restaurante'; 
  IconData _selectedIcon = Icons.storefront_rounded; 
  List<String> _photoList = []; 

  final List<IconData> _availableIcons = [
    Icons.storefront_rounded, Icons.restaurant_rounded, Icons.hotel_rounded,
    Icons.shopping_bag_rounded, Icons.local_cafe_rounded, Icons.celebration_rounded,
    Icons.directions_bus_rounded, Icons.museum_rounded, Icons.fastfood_rounded
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.businessToEdit?.name ?? '');
    _descController = TextEditingController(text: widget.businessToEdit?.description ?? '');
    _addressController = TextEditingController(text: widget.businessToEdit?.address ?? '');
    _phoneController = TextEditingController(text: widget.businessToEdit?.phone ?? '');
    _repController = TextEditingController(text: widget.businessToEdit?.representative ?? '');
    _rfcController = TextEditingController(text: widget.businessToEdit?.rfc ?? '');
    _scheduleController = TextEditingController(text: widget.businessToEdit?.schedule ?? '09:00 - 21:00');
    _photoUrlController = TextEditingController();

    if (widget.businessToEdit != null) {
      _category = widget.businessToEdit!.category;
      _selectedIcon = widget.businessToEdit!.icon;
      _photoList = List.from(widget.businessToEdit!.photos);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _repController.dispose();
    _rfcController.dispose();
    _scheduleController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.businessToEdit == null ? 'Nuevo Local' : 'Editar Local',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Identidad Visual", Icons.palette_rounded),
              _buildIconPicker(),
              const SizedBox(height: 20),
              
              _buildSectionHeader("Información Legal y Contacto", Icons.gavel_rounded),
              _buildTextField(_nameController, "Nombre Comercial", Icons.store),
              _buildTextField(_rfcController, "RFC (Opcional)", Icons.badge_rounded, required: false),
              _buildTextField(_repController, "Nombre del Representante", Icons.person),
              _buildTextField(_phoneController, "Teléfono", Icons.phone),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              
              _buildSectionHeader("Fotos del Local", Icons.camera_alt_rounded),
              _buildPhotoUploader(), 
              const SizedBox(height: 20),
              
              _buildSectionHeader("Detalles de Operación", Icons.info_outline),
              _buildTextField(_descController, "Descripción del negocio", Icons.description_rounded, maxLines: 3),
              _buildTextField(_scheduleController, "Horario (ej: 09:00 - 20:00)", Icons.access_time_filled_rounded),
              _buildTextField(_addressController, "Dirección exacta", Icons.location_on_rounded),
              
              const SizedBox(height: 40),
              _buildSaveButton(context),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 3. WIDGETS DE COMPONENTES
  // ---------------------------------------------------------

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: LocaliaTheme.coppelGreen),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildIconPicker() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableIcons.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedIcon == _availableIcons[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedIcon = _availableIcons[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? LocaliaTheme.coppelGreen : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_availableIcons[index], color: isSelected ? Colors.white : Colors.black54),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
        validator: (value) => required && value!.isEmpty ? 'Este campo es obligatorio' : null,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          isExpanded: true,
          items: ['Restaurante', 'Artesanías', 'Hospedaje', 'Servicios', 'Tienda']
            .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => _category = val!),
        ),
      ),
    );
  }

  Widget _buildPhotoUploader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Botón de Cámara Real
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Cámara"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            ),
            // Botón de Galería Real
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Galería"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildTextField(_photoUrlController, "O pega URL", Icons.link, required: false)),
            IconButton(
              icon: const Icon(Icons.add_circle, color: LocaliaTheme.coppelGreen),
              onPressed: () {
                if (_photoUrlController.text.isNotEmpty) {
                  setState(() {
                    _photoList.add(_photoUrlController.text);
                    _photoUrlController.clear();
                  });
                }
              },
            )
          ],
        ),
        const SizedBox(height: 15),
        if (_photoList.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photoList.length,
              itemBuilder: (context, index) {
                final String path = _photoList[index];
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          // Detecta si es URL de internet o archivo local
                          image: path.startsWith('http') 
                              ? NetworkImage(path) 
                              : FileImage(File(path)) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 5, top: 5,
                      child: GestureDetector(
                        onTap: () => setState(() => _photoList.removeAt(index)),
                        child: const CircleAvatar(
                          radius: 12, 
                          backgroundColor: Colors.red, 
                          child: Icon(Icons.close, size: 14, color: Colors.white)
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: LocaliaTheme.coppelGreen, 
          padding: const EdgeInsets.symmetric(vertical: 18), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final provider = Provider.of<LocaliaProvider>(context, listen: false);
            
            final biz = Business(
              id: widget.businessToEdit?.id ?? DateTime.now().toString(),
              name: _nameController.text,
              category: _category,
              rating: widget.businessToEdit?.rating ?? 5.0,
              icon: _selectedIcon,
              mapX: widget.businessToEdit?.mapX ?? 0.5,
              mapY: widget.businessToEdit?.mapY ?? 0.5,
              description: _descController.text,
              address: _addressController.text,
              phone: _phoneController.text,
              representative: _repController.text,
              rfc: _rfcController.text,
              schedule: _scheduleController.text,
              photos: _photoList.isEmpty ? ["https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=500"] : _photoList,
              reviews: widget.businessToEdit?.reviews ?? ["¡Bienvenidos a nuestro local!"],
            );
            
            if (widget.businessToEdit == null) {
              provider.addBusiness(biz);
            } else {
              provider.updateBusiness(biz);
            }
            Navigator.pop(context);
          }
        },
        child: const Text("GUARDAR EN EL ECOSISTEMA", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
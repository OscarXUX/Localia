import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/business.dart';
import '../providers/localia_provider.dart';

/// [AddBusinessScreen] permite tanto la creación de un nuevo negocio como la edición 
/// de uno existente. Incluye validación de roles, corrección de categorías y subida de imágenes.
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
  // 1. ESTADOS DE IMAGEN Y CARGA
  // ---------------------------------------------------------
  XFile? _imagenSeleccionada;
  bool _isSaving = false;

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imagenSeleccionada = pickedFile;
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
      // 🔥 SOLUCIÓN AL CRASH DEL DROPDOWN: Traductor de categorías viejas
      String fetchedCategory = widget.businessToEdit!.category;
      if (fetchedCategory == 'Artesanía') fetchedCategory = 'Artesanías';
      
      final validCategories = ['Restaurante', 'Artesanías', 'Hospedaje', 'Servicios', 'Tienda'];
      _category = validCategories.contains(fetchedCategory) ? fetchedCategory : 'Restaurante';

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
    final provider = Provider.of<LocaliaProvider>(context);
    
    // 🔥 SOLUCIÓN A LA SEGURIDAD: Forzar que el ID sea Texto para evitar errores
    final String? userIdStr = provider.perfilUsuarioData['id']?.toString(); 
    final isAdmin = provider.isAdmin;

    if (widget.businessToEdit != null) {
      final String? ownerIdStr = widget.businessToEdit!.ownerId?.toString();
      
      // Comparamos textos con textos
      final bool isOwner = (ownerIdStr == userIdStr) && (userIdStr != null);
      
      if (!isOwner && !isAdmin) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gpp_bad_rounded, size: 80, color: Colors.redAccent),
                  SizedBox(height: 20),
                  Text("Acceso Denegado", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(
                    "Solo el usuario que registró este negocio o un Administrador del sistema pueden realizar modificaciones.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

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
              
              _buildSectionHeader("Foto Principal del Local", Icons.camera_alt_rounded),
              _buildPhotoUploader(), 
              const SizedBox(height: 20),
              
              _buildSectionHeader("Detalles de Operación", Icons.info_outline),
              _buildTextField(_descController, "Descripción del negocio", Icons.description_rounded, maxLines: 3),
              _buildTextField(_scheduleController, "Horario (ej: 09:00 - 20:00)", Icons.access_time_filled_rounded),
              _buildTextField(_addressController, "Dirección exacta", Icons.location_on_rounded),
              
              const SizedBox(height: 40),
              _buildSaveButton(context, provider),
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
           Icon(icon, size: 20, color: const Color(0xFF008F39)),
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
                color: isSelected ? const Color(0xFF008F39) : Colors.grey[100],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _seleccionarImagen(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Cámara"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            ),
            ElevatedButton.icon(
              onPressed: () => _seleccionarImagen(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Galería"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 15),
        
        if (_imagenSeleccionada == null && _photoList.isNotEmpty)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage(_photoList.first),
                fit: BoxFit.cover,
              ),
            ),
          ),

        if (_imagenSeleccionada != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Archivo listo: ${_imagenSeleccionada!.name}",
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _imagenSeleccionada = null),
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, LocaliaProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF008F39), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
        ),
        onPressed: _isSaving ? null : () async {
          if (_formKey.currentState!.validate()) {
            setState(() => _isSaving = true); 

            List<String> finalPhotos = List.from(_photoList);
            
            if (_imagenSeleccionada != null) {
              final String? uploadedUrl = await provider.subirImagenNegocio(_imagenSeleccionada);
              if (uploadedUrl != null) {
                finalPhotos = [uploadedUrl]; 
              } else {
                finalPhotos = ["https://placehold.co/600x400/008F39/FFFFFF/png?text=Nuevo+Local"];
              }
            } else if (finalPhotos.isEmpty) {
              finalPhotos = ["https://placehold.co/600x400/008F39/FFFFFF/png?text=Nuevo+Local"];
            }

            final biz = Business(
              id: widget.businessToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              ownerId: widget.businessToEdit?.ownerId?.toString() ?? provider.perfilUsuarioData['id']?.toString(), 
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
              photos: finalPhotos, 
              reviews: widget.businessToEdit?.reviews ?? ["¡Bienvenidos a nuestro local!"],
            );
            
            if (widget.businessToEdit == null) {
              await provider.addBusiness(biz);
            } else {
              await provider.updateBusiness(biz);
            }
            
            if (mounted) {
              setState(() => _isSaving = false);
              Navigator.pop(context);
            }
          }
        },
        child: _isSaving
            ? const SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : const Text("GUARDAR EN EL ECOSISTEMA", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
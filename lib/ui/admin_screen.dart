import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import 'add_business_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  
  // Controladores para el formulario de la Promoción
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descuentoController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _expiracionController = TextEditingController();
  final _formPromoKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _tituloController.dispose();
    _descuentoController.dispose();
    _descController.dispose();
    _expiracionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);
    
    // 🔥 PUNTO 2 COMPLETADO: Filtro de Seguridad para el Administrador
    final currentUserId = state.perfilUsuarioData['id']?.toString();
    
    // Creamos una lista que SOLO contiene los negocios donde el usuario actual es el dueño
    final misNegocios = state.businesses.where((biz) {
      return biz.ownerId?.toString() == currentUserId;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () {
            Provider.of<LocaliaProvider>(context, listen: false).setRole(false);
            Navigator.pop(context);
          },
        ),
        title: const Text("Dashboard Admin", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, letterSpacing: -1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSectionTitle("Impacto de mis negocios"),
            const SizedBox(height: 15),
            
            // Reflejamos solo la cantidad de negocios que le pertenecen a este usuario
            _buildPremiumImpactCard(state.totalSocialImpact, misNegocios.length),

            const SizedBox(height: 35),
            _buildSectionTitle("Gestión de Mis Locales y Cupones"),
            const SizedBox(height: 15),

            // 🔥 Usamos la lista filtrada 'misNegocios' en lugar de la global
            misNegocios.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: misNegocios.length,
                  itemBuilder: (context, index) => _buildBusinessItem(context, misNegocios[index]),                
                ),
            const SizedBox(height: 100), 
          ],
        ),
      ),
      floatingActionButton: _buildAppleFAB(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, 
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 0.5));
  }

  Widget _buildPremiumImpactCard(double impact, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF008F39), Color(0xFF00C853)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF008F39).withValues(alpha: 0.3), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Flujo Coppel Pay", 
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2), 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Icon(Icons.trending_up, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "\$${impact.toStringAsFixed(2)}", 
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 38, 
              fontWeight: FontWeight.w900, 
              letterSpacing: -1.5
            )
          ),
          const SizedBox(height: 15),
          Text(
            "Distribuidos en tus $count negocios registrados", 
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessItem(BuildContext context, dynamic biz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF2F2F7),
          child: Icon(biz.icon, color: Colors.black, size: 20),
        ),
        title: Text(biz.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(biz.category, style: const TextStyle(fontSize: 12)),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onSelected: (value) {
            if (value == 'promo') {
              _mostrarFormularioPromo(context, biz.id, biz.name);
            } else if (value == 'edit') {
              _navigateToEdit(context, biz);
            } else if (value == 'delete') {
              _confirmDelete(context, biz);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'promo', child: Row(children: [Icon(Icons.local_offer, size: 18, color: Colors.orange), SizedBox(width: 8), Text("Añadir Promo")])),
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Editar")])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text("Eliminar", style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddBusinessScreen())),
      backgroundColor: Colors.black,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      label: const Text("Añadir Local", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      icon: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: Text("Aún no tienes negocios registrados", style: TextStyle(color: Colors.grey, fontSize: 16)),
      ),
    );
  }

  // --- FORMULARIO EMERGENTE PARA CREAR PROMOCIÓN ---
  void _mostrarFormularioPromo(BuildContext context, String businessId, String businessName) {
    // Limpiamos los controladores al abrir
    _tituloController.clear();
    _descuentoController.clear();
    _descController.clear();
    _expiracionController.text = "2026-12-31"; 

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nueva Promoción", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Para: $businessName", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formPromoKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: "Título (Ej: 2x1 en Cervezas)", prefixIcon: Icon(Icons.title)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descuentoController,
                  decoration: const InputDecoration(labelText: "Descuento (Ej: 50% o \$100)", prefixIcon: Icon(Icons.percent)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "Condiciones", prefixIcon: Icon(Icons.description)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _expiracionController,
                  decoration: const InputDecoration(labelText: "Expiración (YYYY-MM-DD)", prefixIcon: Icon(Icons.calendar_today)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              if (_formPromoKey.currentState!.validate()) {
                Provider.of<LocaliaProvider>(context, listen: false).crearPromocion(
                  businessId,
                  businessName,
                  _tituloController.text,
                  _descuentoController.text,
                  _descController.text,
                  _expiracionController.text
                );
                
                Navigator.pop(context); // Cierra el modal
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Cupón creado para $businessName"), backgroundColor: Colors.orange)
                );
              }
            },
            child: const Text("Publicar Cupón", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic biz) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("¿Eliminar negocio?"),
        content: Text("Esta acción eliminará a '${biz.name}' de forma permanente."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              Provider.of<LocaliaProvider>(context, listen: false).deleteBusiness(biz.id);
              Navigator.pop(c);
            }, 
            child: const Text("Eliminar", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context, dynamic biz) {
    Navigator.push(context, MaterialPageRoute(builder: (c) => AddBusinessScreen(businessToEdit: biz)));
  }
}
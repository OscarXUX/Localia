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
  String _name = '';
  String _category = 'Comida';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar PyME")),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre Comercial', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                onSaved: (v) => _name = v!,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                value: _category,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Comida', child: Text('Alimentos')),
                  DropdownMenuItem(value: 'Artesanía', child: Text('Artesanías')),
                  DropdownMenuItem(value: 'Servicio', child: Text('Servicio')),
                ],
                onChanged: (v) => setState(() => _category = v.toString()),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008F39),
                  minimumSize: const Size(double.infinity, 60),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newBiz = Business(
                      id: DateTime.now().toString(),
                      name: _name,
                      category: _category,
                      icon: _category == 'Comida' ? Icons.restaurant : Icons.store,
                    );
                    Provider.of<LocaliaProvider>(context, listen: false).addBusiness(newBiz);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Guardar Registro", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
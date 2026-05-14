import 'package:flutter/material.dart';
import 'database_helper.dart';

class ProductForm extends StatefulWidget {
  final Map<String, dynamic>? producto;
  const ProductForm({super.key, this.producto});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();

  late TextEditingController _nombre;
  late TextEditingController _categoria;
  late TextEditingController _cantidad;
  late TextEditingController _precio;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.producto?['nombre'] ?? '');
    _categoria = TextEditingController(
      text: widget.producto?['categoria'] ?? '',
    );
    _cantidad = TextEditingController(
      text: widget.producto?['cantidad']?.toString() ?? '',
    );
    _precio = TextEditingController(
      text: widget.producto?['precio']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nombre.dispose();
    _categoria.dispose();
    _cantidad.dispose();
    _precio.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'nombre': _nombre.text.trim(),
      'categoria': _categoria.text.trim(),
      'cantidad': int.parse(_cantidad.text.trim()),
      'precio': double.parse(_precio.text.trim()),
    };
    if (_esEdicion) {
      await db.updateProducto({...data, 'id': widget.producto!['id']});
    } else {
      await db.insertProducto(data);
    }
    if (mounted) Navigator.pop(context);
  }

  Widget _campo(
    String label,
    TextEditingController ctrl, {
    TextInputType tipo = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) return 'Campo requerido';
          if (tipo == TextInputType.number) {
            if (double.tryParse(val.trim()) == null) {
              return 'Ingresa un número válido';
            }
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: Text(
          _esEdicion ? 'Editar Producto' : 'Nuevo Producto',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              _campo('Nombre', _nombre),
              _campo('Categoría', _categoria),
              _campo('Cantidad', _cantidad, tipo: TextInputType.number),
              _campo('Precio', _precio, tipo: TextInputType.number),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: Text(_esEdicion ? 'Actualizar' : 'Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

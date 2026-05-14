import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'product_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseHelper();

  List<Map<String, dynamic>> _productos = [];
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final data = await db.getProductos();

    setState(() {
      _productos = data.where((p) {
        return p['nombre'].toLowerCase().contains(_busqueda.toLowerCase());
      }).toList();
    });
  }

  Future<void> _eliminar(int id) async {
    await db.deleteProducto(id);
    _cargarProductos();
  }

  void _abrirFormulario({Map<String, dynamic>? producto}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductForm(producto: producto)),
    );

    _cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      appBar: AppBar(
        title: const Text(
          'Inventario de Productos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),

        centerTitle: true,
        elevation: 0,

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F6FB), Color(0xFFE8ECF7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),

              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar producto...',
                    prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(18),
                  ),

                  onChanged: (val) {
                    setState(() => _busqueda = val);
                    _cargarProductos();
                  },
                ),
              ),
            ),

            Expanded(
              child: _productos.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay productos registrados',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _productos.length,

                      itemBuilder: (_, i) {
                        final p = _productos[i];

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),

                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),

                          child: ListTile(
                            contentPadding: const EdgeInsets.all(18),

                            leading: Container(
                              padding: const EdgeInsets.all(12),

                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.inventory_2,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),

                            title: Text(
                              p['nombre'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),

                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),

                              child: Text(
                                'Categoría: ${p['categoria']}\nCantidad: ${p['cantidad']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ),

                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),

                              child: Text(
                                '\$${p['precio']}',
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            onTap: () => _abrirFormulario(producto: p),

                            onLongPress: () async {
                              final confirm = await showDialog<bool>(
                                context: context,

                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  title: const Text('Eliminar producto'),

                                  content: const Text(
                                    '¿Seguro que deseas eliminar este producto?',
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),

                                      child: const Text('Cancelar'),
                                    ),

                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),

                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                _eliminar(p['id']);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4A00E0),
        foregroundColor: Colors.white,
        elevation: 10,

        onPressed: () => _abrirFormulario(),

        icon: const Icon(Icons.add),

        label: const Text(
          'Agregar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

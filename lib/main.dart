import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'database_helper.dart';
import 'login_screen.dart';
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
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4FC3F7),
          secondary: Color(0xFF81D4FA),
          surface: Color(0xFF111118),
        ),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final db = DatabaseHelper();
  List<Map<String, dynamic>> _productos = [];
  String _busqueda = '';
  late AnimationController _listAnim;

  @override
  void initState() {
    super.initState();
    _listAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cargarProductos();
  }

  @override
  void dispose() {
    _listAnim.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    final data = await db.getProductos();
    setState(() {
      _productos = data.where((p) {
        return p['nombre'].toLowerCase().contains(_busqueda.toLowerCase());
      }).toList();
    });
    _listAnim.forward(from: 0);
  }

  Future<void> _eliminar(int id) async {
    await db.deleteProducto(id);
    _cargarProductos();
  }

  void _abrirFormulario({Map<String, dynamic>? producto}) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ProductForm(producto: producto),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
    _cargarProductos();
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        title: Row(children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF4FC3F7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Inventario',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Text(
                  user.nombre.split(' ').first,
                  style: const TextStyle(
                    color: Color(0xFF546E7A),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                color: Color(0xFF546E7A), size: 22),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF111118)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                      width: 28, height: 1.5, color: const Color(0xFF4FC3F7)),
                  const SizedBox(width: 10),
                  Text(
                    '${_productos.length} PRODUCTOS',
                    style: const TextStyle(
                      color: Color(0xFF4FC3F7),
                      fontSize: 11,
                      letterSpacing: 3,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                const Text(
                  'Gestión de\nproductos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111118),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E2A35), width: 1.5),
              ),
              child: TextField(
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, fontFamily: 'Roboto'),
                decoration: const InputDecoration(
                  hintText: 'Buscar producto...',
                  hintStyle: TextStyle(color: Color(0xFF37474F)),
                  prefixIcon:
                      Icon(Icons.search, color: Color(0xFF4FC3F7), size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (val) {
                  setState(() => _busqueda = val);
                  _cargarProductos();
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _productos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 56,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sin productos aún',
                          style: TextStyle(
                            color: Color(0xFF37474F),
                            fontSize: 18,
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: _productos.length,
                    itemBuilder: (_, i) {
                      final p = _productos[i];
                      return AnimatedBuilder(
                        animation: _listAnim,
                        builder: (context, child) {
                          final delay = (i * 0.1).clamp(0.0, 0.8);
                          final t = ((_listAnim.value - delay) /
                                  (1.0 - delay))
                              .clamp(0.0, 1.0);
                          return Opacity(
                            opacity: t,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - t)),
                              child: child,
                            ),
                          );
                        },
                        child: _ProductCard(
                          producto: p,
                          onTap: () => _abrirFormulario(producto: p),
                          onLongPress: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFF111118),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                      color: Color(0xFF1E2A35)),
                                ),
                                title: const Text(
                                  'Eliminar producto',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Georgia'),
                                ),
                                content: const Text(
                                  '¿Seguro que deseas eliminar este producto?',
                                  style: TextStyle(
                                      color: Color(0xFF78909C),
                                      fontFamily: 'Roboto'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar',
                                        style: TextStyle(
                                            color: Color(0xFF546E7A))),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF4FC3F7),
                                      foregroundColor:
                                          const Color(0xFF0A0A0F),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) _eliminar(p['id']);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4FC3F7).withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF4FC3F7),
          foregroundColor: const Color(0xFF0A0A0F),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          onPressed: () => _abrirFormulario(),
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            'Agregar',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRODUCT CARD
// ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> producto;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProductCard({
    required this.producto,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF111118),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1E2A35), width: 1.5),
          ),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF4FC3F7).withOpacity(0.2)),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  color: Color(0xFF4FC3F7), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto['nombre'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${producto['categoria']}  ·  Cant: ${producto['cantidad']}',
                    style: const TextStyle(
                        color: Color(0xFF546E7A),
                        fontSize: 13,
                        fontFamily: 'Roboto'),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF4FC3F7).withOpacity(0.25)),
              ),
              child: Text(
                '\$${producto['precio']}',
                style: const TextStyle(
                  color: Color(0xFF4FC3F7),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ]),
        ),
      );
}
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static const _key = 'productos';

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<List<Map<String, dynamic>>> getProductos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return List<Map<String, dynamic>>.from(
      decoded.map((item) => Map<String, dynamic>.from(item)),
    );
  }

  Future<void> _guardar(List<Map<String, dynamic>> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(lista));
  }

  Future<void> insertProducto(Map<String, dynamic> producto) async {
    final lista = await getProductos();
    final id = DateTime.now().millisecondsSinceEpoch;
    lista.add({...producto, 'id': id});
    lista.sort((a, b) => a['nombre'].compareTo(b['nombre']));
    await _guardar(lista);
  }

  Future<void> updateProducto(Map<String, dynamic> producto) async {
    final lista = await getProductos();
    final index = lista.indexWhere(
        (p) => p['id'].toString() == producto['id'].toString());
    if (index != -1) lista[index] = producto;
    await _guardar(lista);
  }

  Future<void> deleteProducto(int id) async {
    final lista = await getProductos();
    lista.removeWhere((p) => p['id'].toString() == id.toString());
    await _guardar(lista);
  }
}
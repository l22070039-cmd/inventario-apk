import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'inventario.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        categoria TEXT,
        cantidad INTEGER DEFAULT 0,
        precio REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL,
        reset_token TEXT,
        reset_token_expiry TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS usuarios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          created_at TEXT NOT NULL,
          reset_token TEXT,
          reset_token_expiry TEXT
        )
      ''');
    }
  }

  // ── Utilidad hash ──────────────────────────────────────────

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ── USUARIOS ───────────────────────────────────────────────

  /// Registra un usuario nuevo. Retorna null si el email ya existe.
  Future<Map<String, dynamic>?> registrarUsuario({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final db = await database;
    final existe = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    if (existe.isNotEmpty) return null;

    final id = await db.insert('usuarios', {
      'nombre': nombre.trim(),
      'email': email.toLowerCase().trim(),
      'password_hash': _hashPassword(password),
      'created_at': DateTime.now().toIso8601String(),
    });

    return {'id': id, 'nombre': nombre.trim(), 'email': email.toLowerCase().trim()};
  }

  /// Inicia sesión. Retorna el usuario o null si credenciales incorrectas.
  Future<Map<String, dynamic>?> loginUsuario({
    required String email,
    required String password,
  }) async {
    final db = await database;
    final rows = await db.query(
      'usuarios',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email.toLowerCase().trim(), _hashPassword(password)],
    );
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first)..remove('password_hash');
  }

  /// Genera un token de recuperación (6 dígitos) válido por 15 minutos.
  /// En una app real enviarías esto por email.
  Future<String?> generarTokenRecuperacion(String email) async {
    final db = await database;
    final rows = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    if (rows.isEmpty) return null;

    final token = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
        .toString();
    final expiry = DateTime.now().add(const Duration(minutes: 15)).toIso8601String();

    await db.update(
      'usuarios',
      {'reset_token': token, 'reset_token_expiry': expiry},
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    return token;
  }

  /// Verifica el token y cambia la contraseña si es válido y no expiró.
  Future<bool> resetPassword({
    required String email,
    required String token,
    required String nuevaPassword,
  }) async {
    final db = await database;
    final rows = await db.query(
      'usuarios',
      where: 'email = ? AND reset_token = ?',
      whereArgs: [email.toLowerCase().trim(), token],
    );
    if (rows.isEmpty) return false;

    final expiry = DateTime.parse(rows.first['reset_token_expiry'] as String);
    if (DateTime.now().isAfter(expiry)) return false;

    await db.update(
      'usuarios',
      {
        'password_hash': _hashPassword(nuevaPassword),
        'reset_token': null,
        'reset_token_expiry': null,
      },
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    return true;
  }

  // ── PRODUCTOS ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getProductos() async {
    final db = await database;
    return await db.query('productos', orderBy: 'id DESC');
  }

  Future<int> insertProducto(Map<String, dynamic> producto) async {
    final db = await database;
    return await db.insert('productos', producto);
  }

  Future<int> updateProducto(Map<String, dynamic> producto) async {
    final db = await database;
    return await db.update(
      'productos',
      producto,
      where: 'id = ?',
      whereArgs: [producto['id']],
    );
  }

  Future<int> deleteProducto(int id) async {
    final db = await database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }
}
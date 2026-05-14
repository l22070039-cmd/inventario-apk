import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, 'inventario.db'),
      version: 1,

      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE productos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            categoria TEXT,
            cantidad INTEGER,
            precio REAL
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> getProductos() async {
    final db = await database;

    return await db.query(
      'productos',
      orderBy: 'nombre ASC',
    );
  }

  Future<void> insertProducto(
    Map<String, dynamic> producto,
  ) async {
    final db = await database;

    await db.insert(
      'productos',
      producto,
    );
  }

  Future<void> updateProducto(
    Map<String, dynamic> producto,
  ) async {
    final db = await database;

    await db.update(
      'productos',
      producto,
      where: 'id = ?',
      whereArgs: [producto['id']],
    );
  }

  Future<void> deleteProducto(int id) async {
    final db = await database;

    await db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

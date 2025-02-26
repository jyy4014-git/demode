import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE posts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imageUrl TEXT,
            title TEXT,
            price TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertPost(Map<String, dynamic> post) async {
    final db = await database;
    await db.insert('posts', post);
  }

  Future<List<Map<String, dynamic>>> getPosts() async {
    final db = await database;
    return await db.query('posts');
  }
}

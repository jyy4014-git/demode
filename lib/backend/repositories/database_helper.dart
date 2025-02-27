import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:demode/config/app_config.dart';
import 'package:demode/backend/constants/query_constants.dart';
import 'package:demode/backend/mappers/data_mapper.dart';
import 'package:demode/utils/logger.dart';
import 'database_interface.dart';

class DatabaseHelper implements DatabaseInterface {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  @override
  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, AppConfig.dbName);
    
    return await openDatabase(
      path,
      version: AppConfig.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(QueryConstants.CREATE_USERS_TABLE);
    await db.execute(QueryConstants.CREATE_POSTS_TABLE);
    await db.execute(QueryConstants.CREATE_FAVORITES_TABLE);
    await db.execute(QueryConstants.CREATE_SEARCH_HISTORY_TABLE);
    await db.execute(QueryConstants.CREATE_REPORTS_TABLE);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.info('Database upgrading from $oldVersion to $newVersion');
    
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE posts ADD COLUMN viewCount INTEGER DEFAULT 0');
      await db.execute(QueryConstants.CREATE_SEARCH_HISTORY_TABLE);
      await db.execute(QueryConstants.CREATE_FAVORITES_TABLE);
    }
    
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE posts ADD COLUMN description TEXT');
      await db.execute(QueryConstants.CREATE_REPORTS_TABLE);
    }
  }

  // User Operations
  @override
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', UserMapper.toMap(user));
  }

  @override
  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    final results = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return results.isNotEmpty ? UserMapper.fromMap(results.first) : null;
  }

  @override
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
    return results.isNotEmpty ? UserMapper.fromMap(results.first) : null;
  }

  @override
  Future<int> updateUser(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  // Post Operations
  @override
  Future<int> insertPost(Map<String, dynamic> post) async {
    final db = await database;
    return await db.insert('posts', PostMapper.toMap(post));
  }

  @override
  Future<List<Map<String, dynamic>>> getPosts() async {
    final db = await database;
    final results = await db.query('posts', orderBy: 'createdAt DESC');
    return results.map((post) => PostMapper.fromMap(post)).toList();
  }

  @override
  Future<Map<String, dynamic>?> getPost(int id) async {
    final db = await database;
    final results = await db.query('posts', where: 'id = ?', whereArgs: [id], limit: 1);
    return results.isNotEmpty ? PostMapper.fromMap(results.first) : null;
  }

  @override
  Future<int> updatePost(Map<String, dynamic> post) async {
    final db = await database;
    return await db.update(
      'posts',
      PostMapper.toMap(post),
      where: 'id = ?',
      whereArgs: [post['id']],
    );
  }

  @override
  Future<int> deletePost(int id) async {
    final db = await database;
    return await db.delete('posts', where: 'id = ?', whereArgs: [id]);
  }

  // Favorite Operations
  @override
  Future<bool> checkFavorite(int postId, int userId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'postId = ? AND userId = ?',
      whereArgs: [postId, userId],
    );
    return result.isNotEmpty;
  }

  @override
  Future<void> addFavorite(int postId, int userId) async {
    final db = await database;
    await db.insert('favorites', {
      'postId': postId,
      'userId': userId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> removeFavorite(int postId, int userId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'postId = ? AND userId = ?',
      whereArgs: [postId, userId],
    );
  }

  // Report Operations
  @override
  Future<void> insertReport(Map<String, dynamic> report) async {
    final db = await database;
    await db.insert('reports', ReportMapper.toMap(report));
  }

  @override
  Future<void> incrementViewCount(int postId) async {
    final db = await database;
    await db.rawUpdate(QueryConstants.INCREMENT_VIEW_COUNT, [postId]);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String query, [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      return await db.rawQuery(query, arguments);
    } catch (e) {
      AppLogger.error('Raw query error', e);
      return [];
    }
  }
}

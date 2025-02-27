// lib/backend/repositories/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:demode/config/app_config.dart';
import '../constants/query_constants.dart';
import '../mappers/data_mapper.dart';
import '../../utils/logger.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart'; //crypto 추가

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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'app_database.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createTables(db);
      },
        onUpgrade: (db, oldVersion, newVersion) async {
        AppLogger.info('Database upgrading from $oldVersion to $newVersion');
        if (oldVersion < 2) {
          await _upgradeToVersion2(db);
        }
        if (oldVersion < 3){
          await _upgradeToVersion3(db);
        }
      },
    );
  }
    Future<void> _createTables(Database db) async {
    await db.execute(QueryConstants.CREATE_USERS_TABLE);
    await db.execute(QueryConstants.CREATE_POSTS_TABLE);
    await db.execute(QueryConstants.CREATE_FAVORITES_TABLE);
    await db.execute(QueryConstants.CREATE_SEARCH_HISTORY_TABLE);
    await db.execute(QueryConstants.CREATE_REPORTS_TABLE);

    // 테스트 데이터 추가
    //await _insertTestData(db);
  }
  Future<void> _upgradeToVersion2(Database db) async {
    await db.execute('ALTER TABLE posts ADD COLUMN createdAt TEXT');
    await db.execute('ALTER TABLE posts ADD COLUMN viewCount INTEGER DEFAULT 0');
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        keyword TEXT,
        createdAt TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER,
        userId INTEGER,
        createdAt TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER,
        reason TEXT,
        reporterId INTEGER,
        createdAt TEXT,
        status TEXT
      )
    ''');
  }
    Future<void> _upgradeToVersion3(Database db) async {
    // users 테이블 생성
    await db.execute(QueryConstants.CREATE_USERS_TABLE);
  }
    Future<List<Map<String, dynamic>>> rawQuery(String query, [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      return await db.rawQuery(query, arguments);
    } catch (e, stackTrace) {
      AppLogger.error('Raw query error', e, stackTrace);
      return [];
    }
  }
  // Create
  Future<int> insertPost(Map<String, dynamic> post) async {
    try{
      final db = await database;
      final mappedPost = PostMapper.toMap(post);
      return await db.insert('posts', mappedPost);
    } catch (e, stackTrace){
      AppLogger.error('insertPost error', e, stackTrace);
      return 0;
    }
  }

  // Read
  Future<List<Map<String, dynamic>>> getPosts() async {
    try{
      final db = await database;
      return await db.query('posts', orderBy: 'createdAt DESC');
    } catch (e, stackTrace) {
      AppLogger.error('getPosts error', e, stackTrace);
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPost(int id) async {
    try{
      final db = await database;
      List<Map<String, dynamic>> results = await db.query(
        'posts',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e, stackTrace) {
       AppLogger.error('getPost error', e, stackTrace);
      return null;
    }
  }

  // Update
  Future<int> updatePost(Map<String, dynamic> post) async {
    try{
      final db = await database;
      return await db.update(
        'posts',
        post,
        where: 'id = ?',
        whereArgs: [post['id']],
      );
    } catch (e, stackTrace) {
       AppLogger.error('updatePost error', e, stackTrace);
      return 0;
    }
  }

  // Delete
  Future<int> deletePost(int id) async {
    try{
      final db = await database;
      return await db.delete(
        'posts',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
       AppLogger.error('deletePost error', e, stackTrace);
       return 0;
    }
  }

  // 카테고리별 검색
  Future<List<Map<String, dynamic>>> getPostsByCategory(String category) async {
    try{
      final db = await database;
      return await db.query(
        'posts',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'createdAt DESC',
      );
    } catch (e, stackTrace) {
      AppLogger.error('getPostsByCategory error', e, stackTrace);
      return [];
    }
  }

  // 키워드 검색
  Future<List<Map<String, dynamic>>> searchPosts(String keyword) async {
    try{
      final db = await database;
      return await db.query(
        'posts',
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%'],
        orderBy: 'createdAt DESC',
      );
    } catch (e, stackTrace) {
      AppLogger.error('searchPosts error', e, stackTrace);
      return [];
    }
  }

  // 가격 범위 검색
  Future<List<Map<String, dynamic>>> getPostsByPriceRange(int min, int max) async {
    try{
      final db = await database;
      return await db.query(
        'posts',
        where: 'CAST(price AS INTEGER) BETWEEN ? AND ?',
        whereArgs: [min, max],
      );
    } catch (e, stackTrace) {
      AppLogger.error('getPostsByPriceRange error', e, stackTrace);
      return [];
    }
  }
}

class QueryConstants {
  // 사용자 관련 쿼리
  static const String CREATE_USERS_TABLE = '''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      salt TEXT NOT NULL,
      name TEXT NOT NULL,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // 게시글 관련 쿼리
  static const String CREATE_POSTS_TABLE = '''
    CREATE TABLE IF NOT EXISTS posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      title TEXT NOT NULL,
      price TEXT NOT NULL,
      description TEXT,
      category TEXT,
      imageUrl TEXT,
      viewCount INTEGER DEFAULT 0,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      status TEXT DEFAULT 'active',
      FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
    )
  ''';

  // 찜하기 관련 쿼리
  static const String CREATE_FAVORITES_TABLE = '''
    CREATE TABLE IF NOT EXISTS favorites (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      postId INTEGER NOT NULL,
      userId INTEGER NOT NULL,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(postId, userId),
      FOREIGN KEY (postId) REFERENCES posts(id) ON DELETE CASCADE,
      FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
    )
  ''';

  // 검색 기록 관련 쿼리
  static const String CREATE_SEARCH_HISTORY_TABLE = '''
    CREATE TABLE IF NOT EXISTS search_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      keyword TEXT NOT NULL,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
    )
  ''';

  // 신고 관련 쿼리
  static const String CREATE_REPORTS_TABLE = '''
    CREATE TABLE IF NOT EXISTS reports (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      postId INTEGER NOT NULL,
      reporterId INTEGER NOT NULL,
      reason TEXT NOT NULL,
      status TEXT DEFAULT 'pending',
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (postId) REFERENCES posts(id) ON DELETE CASCADE,
      FOREIGN KEY (reporterId) REFERENCES users(id) ON DELETE CASCADE
    )
  ''';

  // 조회수 증가 쿼리
  static const String INCREMENT_VIEW_COUNT = '''
    UPDATE posts 
    SET viewCount = viewCount + 1, 
        updatedAt = CURRENT_TIMESTAMP 
    WHERE id = ?
  ''';

  // 사용자 조회 쿼리
  static const String GET_USER_BY_EMAIL = '''
    SELECT * FROM users WHERE email = ? LIMIT 1
  ''';

  // 게시글 조회 쿼리
  static const String GET_POSTS_WITH_USER = '''
    SELECT p.*, u.name as userName 
    FROM posts p 
    LEFT JOIN users u ON p.userId = u.id 
    ORDER BY p.createdAt DESC
  ''';

  // 인기 게시글 조회 쿼리
  static const String GET_POPULAR_POSTS = '''
    SELECT p.*, u.name as userName 
    FROM posts p 
    LEFT JOIN users u ON p.userId = u.id 
    ORDER BY p.viewCount DESC 
    LIMIT ?
  ''';

  // 검색 쿼리
  static const String SEARCH_POSTS = '''
    SELECT p.*, u.name as userName 
    FROM posts p 
    LEFT JOIN users u ON p.userId = u.id 
    WHERE p.title LIKE ? OR p.description LIKE ? 
    ORDER BY p.createdAt DESC
  ''';
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:demode/config/app_config.dart';

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
    String path = join(documentsDirectory.path, AppConfig.dbName);
    return await openDatabase(
      path,
      version: AppConfig.dbVersion,
      onCreate: (db, version) async {
        // 사용자 테이블 추가
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            name TEXT,
            createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        // 테스트용 기본 사용자 추가
        await db.insert('users', {
          'email': 'test@test.com',
          'password': '1234',
          'name': '테스트 사용자'
        });

        // 게시글 테이블
        await db.execute('''
          CREATE TABLE posts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imageUrl TEXT,
            title TEXT,
            price TEXT,
            description TEXT,
            category TEXT,
            viewCount INTEGER DEFAULT 0,
            createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
            updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
            userId INTEGER,
            status TEXT DEFAULT 'active'
          )
        ''');

        // 검색 기록 테이블
        await db.execute('''
          CREATE TABLE search_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            keyword TEXT,
            createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
            userId INTEGER
          )
        ''');

        // 찜하기 테이블
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            postId INTEGER,
            userId INTEGER,
            createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(postId, userId)
          )
        ''');

        // 신고 테이블
        await db.execute('''
          CREATE TABLE reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            postId INTEGER,
            reporterId INTEGER,
            reason TEXT,
            status TEXT DEFAULT 'pending',
            createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  // Create
  Future<int> insertPost(Map<String, dynamic> post) async {
    final db = await database;
    return await db.insert(
      'posts',
      post,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read
  Future<List<Map<String, dynamic>>> getPosts() async {
    final db = await database;
    return await db.query('posts', orderBy: 'createdAt DESC');
  }

  Future<Map<String, dynamic>?> getPost(int id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Update
  Future<int> updatePost(Map<String, dynamic> post) async {
    final db = await database;
    return await db.update(
      'posts',
      post,
      where: 'id = ?',
      whereArgs: [post['id']],
    );
  }

  // Delete
  Future<int> deletePost(int id) async {
    final db = await database;
    return await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 카테고리별 검색
  Future<List<Map<String, dynamic>>> getPostsByCategory(String category) async {
    final db = await database;
    return await db.query(
      'posts',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );
  }

  // 키워드 검색
  Future<List<Map<String, dynamic>>> searchPosts(String keyword) async {
    final db = await database;
    return await db.query(
      'posts',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'createdAt DESC',
    );
  }

  // 가격 범위 검색
  Future<List<Map<String, dynamic>>> getPostsByPriceRange(int min, int max) async {
    final db = await database;
    return await db.query(
      'posts',
      where: 'CAST(price AS INTEGER) BETWEEN ? AND ?',
      whereArgs: [min, max],
      orderBy: 'createdAt DESC',
    );
  }
}

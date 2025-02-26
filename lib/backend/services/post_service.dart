import 'dart:convert';
import 'package:demode/backend/database_helper.dart';
import 'package:demode/backend/post.dart';

class PostService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final DatabaseHelper _db = DatabaseHelper();

  Future<List<Post>> getPosts() async {
    final posts = await _dbHelper.getPosts();
    return posts.map((post) => Post.fromMap(post)).toList();
  }

  Future<Post> createPost(String payload) async {
    final postMap = _parsePayload(payload);
    await _dbHelper.insertPost(postMap);
    return Post.fromMap(postMap);
  }

  Map<String, dynamic> _parsePayload(String payload) {
    return jsonDecode(payload);
  }

  // 게시글 목록 조회 (페이지네이션 적용)
  Future<List<Map<String, dynamic>>> getPostsWithPagination(int page, int limit) async {
    final offset = (page - 1) * limit;
    final db = await _db.database;
    return await db.query(
      'posts',
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
  }

  // 인기 게시글 조회 (조회수 기준)
  Future<List<Map<String, dynamic>>> getPopularPosts() async {
    final db = await _db.database;
    return await db.query(
      'posts',
      orderBy: 'viewCount DESC',
      limit: 10,
    );
  }

  // 최근 검색어 저장
  Future<void> saveSearchHistory(String keyword) async {
    final db = await _db.database;
    await db.insert(
      'search_history',
      {'keyword': keyword, 'createdAt': DateTime.now().toIso8601String()},
    );
  }

  // 최근 검색어 조회
  Future<List<String>> getSearchHistory() async {
    final db = await _db.database;
    final results = await db.query(
      'search_history',
      orderBy: 'createdAt DESC',
      limit: 10,
    );
    return results.map((row) => row['keyword'] as String).toList();
  }

  // 찜하기 기능
  Future<void> toggleFavorite(int postId, int userId) async {
    final db = await _db.database;
    final existing = await db.query(
      'favorites',
      where: 'postId = ? AND userId = ?',
      whereArgs: [postId, userId],
    );

    if (existing.isEmpty) {
      await db.insert('favorites', {
        'postId': postId,
        'userId': userId,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } else {
      await db.delete(
        'favorites',
        where: 'postId = ? AND userId = ?',
        whereArgs: [postId, userId],
      );
    }
  }

  // 찜한 상품 목록 조회
  Future<List<Map<String, dynamic>>> getFavoritePosts(int userId) async {
    final db = await _db.database;
    return await db.rawQuery('''
      SELECT p.* FROM posts p
      INNER JOIN favorites f ON p.id = f.postId
      WHERE f.userId = ?
      ORDER BY f.createdAt DESC
    ''', [userId]);
  }

  // 조회수 증가
  Future<void> incrementViewCount(int postId) async {
    final db = await _db.database;
    await db.rawUpdate('''
      UPDATE posts 
      SET viewCount = viewCount + 1 
      WHERE id = ?
    ''', [postId]);
  }

  // 게시글 신고하기
  Future<void> reportPost(int postId, String reason, int reporterId) async {
    final db = await _db.database;
    await db.insert('reports', {
      'postId': postId,
      'reason': reason,
      'reporterId': reporterId,
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'pending',
    });
  }

  // 게시글 통계 조회
  Future<Map<String, dynamic>> getPostStatistics(int postId) async {
    final db = await _db.database;
    final viewCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT viewCount FROM posts WHERE id = ?',
      [postId],
    )) ?? 0;
    
    final favoriteCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM favorites WHERE postId = ?',
      [postId],
    )) ?? 0;

    return {
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
}

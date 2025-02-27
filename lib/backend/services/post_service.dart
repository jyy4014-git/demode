import 'dart:convert';
import 'package:demode/backend/repositories/database_helper.dart';
import 'package:demode/backend/models/post.dart';
import 'package:demode/utils/logger.dart';

class PostService {
  final DatabaseHelper _db = DatabaseHelper();

  // CRUD 작업
  Future<Map<String, dynamic>?> createPost(Map<String, dynamic> postData, int userId) async {
    try {
      postData['userId'] = userId;
      postData['createdAt'] = DateTime.now().toIso8601String();
      final id = await _db.insertPost(postData);
      return await _db.getPost(id);
    } catch (e) {
      AppLogger.error('Create post error', e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getPosts({
    int? page,
    int? limit,
    String? category,
    String? searchQuery,
    String? sortBy,
    int? userId,
  }) async {
    try {
      final query = _buildPostQuery(
        page: page,
        limit: limit,
        category: category,
        searchQuery: searchQuery,
        sortBy: sortBy,
        userId: userId,
      );
      return await _db.rawQuery(query.query, query.args);
    } catch (e) {
      AppLogger.error('Get posts error', e);
      return [];
    }
  }

  // 게시글 상호작용
  Future<bool> toggleFavorite(int postId, int userId) async {
    try {
      final exists = await _db.checkFavorite(postId, userId);
      if (exists) {
        await _db.removeFavorite(postId, userId);
      } else {
        await _db.addFavorite(postId, userId);
      }
      return true;
    } catch (e) {
      AppLogger.error('Toggle favorite error', e);
      return false;
    }
  }

  Future<bool> incrementViewCount(int postId) async {
    try {
      await _db.incrementViewCount(postId);
      return true;
    } catch (e) {
      AppLogger.error('Increment view count error', e);
      return false;
    }
  }

  Future<bool> reportPost(int postId, int reporterId, String reason) async {
    try {
      await _db.insertReport({
        'postId': postId,
        'reporterId': reporterId,
        'reason': reason,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      AppLogger.error('Report post error', e);
      return false;
    }
  }

  // 유틸리티 메서드
  QueryBuilder _buildPostQuery({
    int? page,
    int? limit,
    String? category,
    String? searchQuery,
    String? sortBy,
    int? userId,
  }) {
    final conditions = <String>[];
    final args = <dynamic>[];

    if (category != null) {
      conditions.add('category = ?');
      args.add(category);
    }

    if (searchQuery != null) {
      conditions.add('(title LIKE ? OR description LIKE ?)');
      args.addAll(['%$searchQuery%', '%$searchQuery%']);
    }

    if (userId != null) {
      conditions.add('userId = ?');
      args.add(userId);
    }

    String orderBy = 'createdAt DESC';
    if (sortBy == 'popular') {
      orderBy = 'viewCount DESC';
    }

    String query = 'SELECT * FROM posts';
    if (conditions.isNotEmpty) {
      query += ' WHERE ' + conditions.join(' AND ');
    }
    query += ' ORDER BY $orderBy';

    if (page != null && limit != null) {
      final offset = (page - 1) * limit;
      query += ' LIMIT ? OFFSET ?';
      args.addAll([limit, offset]);
    }

    return QueryBuilder(query: query, args: args);
  }
}

class QueryBuilder {
  final String query;
  final List<dynamic> args;

  QueryBuilder({required this.query, required this.args});
}

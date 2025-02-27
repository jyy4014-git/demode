// lib/backend/services/post_service.dart
import 'package:demode/backend/repositories/database_helper.dart';
import 'package:demode/backend/models/post.dart';
import 'package:demode/utils/logger.dart';
import 'package:demode/backend/constants/query_constants.dart';

class PostService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Create
  Future<Post?> createPost(Map<String, dynamic> postData, int userId) async {
    try {
      postData['userId'] = userId;
      final id = await _dbHelper.insertPost(postData);
      final post = await _dbHelper.getPost(id);
      return post != null ? Post.fromMap(post) : null;
    } catch (e, stackTrace) {
      AppLogger.error('Create post error', e, stackTrace);
      return null;
    }
  }

  // Read
  Future<List<Post>> getPosts({
    int? page,
    int? limit,
    String? category,
    String? searchQuery,
    String? sortBy,
    int? userId,
  }) async {
    try {
      final queryBuilder = _buildPostQuery(
        page: page,
        limit: limit,
        category: category,
        searchQuery: searchQuery,
        sortBy: sortBy,
        userId: userId,
      );
      final results = await _dbHelper.rawQuery(queryBuilder.query, queryBuilder.args);
      return results.map((post) => Post.fromMap(post)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Get posts error', e, stackTrace);
      return [];
    }
  }

  Future<Post?> getPost(int postId) async {
    try {
      final post = await _dbHelper.getPost(postId);
      return post != null ? Post.fromMap(post) : null;
    } catch (e, stackTrace) {
      AppLogger.error('get Post error', e, stackTrace);
      return null;
    }
  }

  // Update
  Future<Post?> updatePost(int postId, Map<String, dynamic> data) async {
    try {
      await _dbHelper.updatePost(data..['id'] = postId);
      final updatedPost = await _dbHelper.getPost(postId);
      return updatedPost != null ? Post.fromMap(updatedPost) : null;
    } catch (e, stackTrace) {
      AppLogger.error('Update Post error', e, stackTrace);
      return null;
    }
  }

  // Delete
  Future<bool> deletePost(int postId) async {
    try {
      await _dbHelper.deletePost(postId);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Delete Post error', e, stackTrace);
      return false;
    }
  }

  // 게시글 상호작용
  Future<bool> toggleFavorite(int postId, int userId) async {
    try {
      final exists = await _dbHelper.checkFavorite(postId, userId);
      if (exists) {
        await _dbHelper.removeFavorite(postId, userId);
      } else {
        await _dbHelper.addFavorite(postId, userId);
      }
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Toggle favorite error', e, stackTrace);
      return false;
    }
  }

  Future<bool> incrementViewCount(int postId) async {
    try {
      await _dbHelper.incrementViewCount(postId);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Increment view count error', e, stackTrace);
      return false;
    }
  }

  Future<bool> reportPost(int postId, int reporterId, String reason) async {
    try {
      await _dbHelper.insertReport({
        'postId': postId,
        'reporterId': reporterId,
        'reason': reason,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Report post error', e, stackTrace);
      return false;
    }
  }
  //게시글 목록 조회 (페이지네이션 적용)
    Future<List<Map<String, dynamic>>> getPostsWithPagination(int page, int limit) async {
      final offset = (page - 1) * limit;
      final query = "SELECT * FROM posts ORDER BY createdAt DESC LIMIT ? OFFSET ?";
      final args = [limit, offset];
      return await _dbHelper.rawQuery(query, args);
    }

    // 인기 게시글 조회 (조회수 기준)
    Future<List<Map<String, dynamic>>> getPopularPosts() async {
      final query = "SELECT * FROM posts ORDER BY viewCount DESC LIMIT 10";
      return await _dbHelper.rawQuery(query);
    }
    // 최근 검색어 저장
    Future<void> saveSearchHistory(String keyword) async {
      final query = "INSERT INTO search_history (keyword, createdAt) VALUES (?, ?)";
      final args = [keyword, DateTime.now().toIso8601String()];
      await _dbHelper.rawQuery(query, args);
    }

    // 최근 검색어 조회
    Future<List<String>> getSearchHistory() async {
      final query = "SELECT keyword FROM search_history ORDER BY createdAt DESC LIMIT 10";
      final results = await _dbHelper.rawQuery(query);
      return results.map((row) => row['keyword'] as String).toList();
    }
      // 찜한 상품 목록 조회
    Future<List<Map<String, dynamic>>> getFavoritePosts(int userId) async {
        final query = "SELECT p.* FROM posts p INNER JOIN favorites f ON p.id = f.postId WHERE f.userId = ? ORDER BY f.createdAt DESC";
        final args = [userId];
        return await _dbHelper.rawQuery(query, args);
    }
      // 게시글 통계 조회
  Future<Map<String, dynamic>> getPostStatistics(int postId) async {
    final viewCount = (await _dbHelper.rawQuery(
      'SELECT viewCount FROM posts WHERE id = ?',
      [postId],
    )).firstOrNull?['viewCount'] as int? ?? 0;

    final favoriteCount = (await _dbHelper.rawQuery(
      'SELECT COUNT(*) as count FROM favorites WHERE postId = ?',
      [postId],
    )).firstOrNull?['count'] as int? ?? 0;

    return {
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
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

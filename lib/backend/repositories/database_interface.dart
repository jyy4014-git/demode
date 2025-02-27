import 'package:sqflite/sqflite.dart';

abstract class DatabaseInterface {
  Future<Database> get database;
  
  // User operations
  Future<int> insertUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>?> getUser(int id);
  Future<Map<String, dynamic>?> getUserByEmail(String email);
  Future<int> updateUser(int id, Map<String, dynamic> data);
  
  // Post operations
  Future<int> insertPost(Map<String, dynamic> post);
  Future<List<Map<String, dynamic>>> getPosts();
  Future<Map<String, dynamic>?> getPost(int id);
  Future<int> updatePost(Map<String, dynamic> post);
  Future<int> deletePost(int id);
  
  // Favorite operations
  Future<bool> checkFavorite(int postId, int userId);
  Future<void> addFavorite(int postId, int userId);
  Future<void> removeFavorite(int postId, int userId);
  
  // Report operations
  Future<void> insertReport(Map<String, dynamic> report);
  Future<void> incrementViewCount(int postId);
}

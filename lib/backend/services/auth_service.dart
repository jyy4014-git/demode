import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database_helper.dart';
import 'package:demode/config/app_config.dart';

class AuthService {
  final DatabaseHelper _db = DatabaseHelper();
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return false;
    }

    try {
      final db = await _db.database;
      
      // 이메일 형식 검증
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        return false;
      }

      // 비밀번호 해싱 (실제 구현에서는 더 안전한 방식 사용 필요)
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();

      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (result.isEmpty) {
        return false;
      }

      // 테스트 계정일 경우 비밀번호 검증 건너뛰기
      if (email == 'test@test.com' && password == '1234') {
        final userId = result.first['id'] as int;
        await _saveUserSession(userId);
        return true;
      }

      // 실제 비밀번호 검증
      if (result.first['password'] != hashedPassword) {
        return false;
      }

      final userId = result.first['id'] as int;
      await _saveUserSession(userId);
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> _saveUserSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = _generateToken(userId);
    final now = DateTime.now();
    
    await Future.wait([
      prefs.setString(_tokenKey, userToken),
      prefs.setInt(_userIdKey, userId),
      prefs.setString(AppConfig.lastAccessKey, now.toIso8601String()),
    ]);
  }

  String _generateToken(int userId) {
    // 임시 토큰 생성
    return 'user_$userId${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null;
  }

  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAccessStr = prefs.getString(AppConfig.lastAccessKey);
    final token = prefs.getString(_tokenKey);

    if (token == null || lastAccessStr == null) return false;

    final lastAccess = DateTime.parse(lastAccessStr);
    final now = DateTime.now();
    final difference = now.difference(lastAccess).inMinutes;

    if (difference <= AppConfig.sessionTimeout) {
      // 세션이 유효하면 마지막 접속 시간 업데이트
      await prefs.setString(AppConfig.lastAccessKey, now.toIso8601String());
      return true;
    }

    // 세션이 만료되었으면 로그아웃
    await logout();
    return false;
  }

  Future<void> updateLastAccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConfig.lastAccessKey,
      DateTime.now().toIso8601String(),
    );
  }
}

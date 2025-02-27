
class LocalStorage {
  static final Map<String, dynamic> _storage = {};

  static Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }

  static Future<void> setInt(String key, int value) async {
    _storage[key] = value;
  }

  static String? getString(String key) {
    return _storage[key] as String?;
  }

  static int? getInt(String key) {
    return _storage[key] as int?;
  }

  static Future<void> remove(String key) async {
    _storage.remove(key);
  }
}

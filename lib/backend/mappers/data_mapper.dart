class UserMapper {
  static Map<String, dynamic> toMap(Map<String, dynamic> data) {
    return {
      'email': data['email'],
      'password': data['password'],
      'name': data['name'],
      'salt': data['salt'],
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> fromMap(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'email': data['email'],
      'name': data['name'],
      'createdAt': data['createdAt'],
    };
  }
}

class PostMapper {
  static Map<String, dynamic> toMap(Map<String, dynamic> data) {
    return {
      'imageUrl': data['imageUrl'],
      'title': data['title'],
      'price': data['price'],
      'description': data['description'],
      'category': data['category'],
      'userId': data['userId'],
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'active',
    };
  }

  static Map<String, dynamic> fromMap(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'imageUrl': data['imageUrl'],
      'title': data['title'],
      'price': data['price'],
      'description': data['description'],
      'category': data['category'],
      'viewCount': data['viewCount'],
      'createdAt': data['createdAt'],
      'updatedAt': data['updatedAt'],
      'userId': data['userId'],
      'status': data['status'],
    };
  }
}

class ReportMapper {
  static Map<String, dynamic> toMap(Map<String, dynamic> data) {
    return {
      'postId': data['postId'],
      'reporterId': data['reporterId'],
      'reason': data['reason'],
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}

class Post {
  final int? id;
  final String imageUrl;
  final String title;
  final String price;
  final String description;
  final String category;
  final int viewCount;
  final DateTime createdAt;
  final int userId;

  Post({
    this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.description = '',
    this.category = '',
    this.viewCount = 0,
    DateTime? createdAt,
    required this.userId,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'viewCount': viewCount,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  static Post fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as int?,
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      price: map['price'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      viewCount: map['viewCount'] ?? 0,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : null,
      userId: map['userId'] ?? 0,
    );
  }
}

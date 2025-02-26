import 'package:demode/product_detail_screen.dart';
import 'package:flutter/material.dart';

class Post {
  final int? id;
  final String imageUrl;
  final String title;
  final String price;
  final String? description;
  final String? category;
  final int viewCount;
  final DateTime createdAt;
  final int? userId;

  Post({
    this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.description,
    this.category,
    this.viewCount = 0,
    DateTime? createdAt,
    this.userId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as int?,
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      price: map['price'] ?? '',
      description: map['description'],
      category: map['category'],
      viewCount: map['viewCount'] ?? 0,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : null,
      userId: map['userId'] as int?,
    );
  }

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
}

class PostWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;

  const PostWidget({super.key, required this.imageUrl, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              imageUrl: imageUrl,
              title: title,
              price: price,
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(imageUrl),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                price,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

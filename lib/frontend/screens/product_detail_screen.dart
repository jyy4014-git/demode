import 'package:flutter/material.dart';
import 'package:demode/backend/repositories/database_helper.dart';
import 'package:demode/backend/models/post.dart';
import 'package:demode/utils/logger.dart';

class ProductDetailScreen extends StatelessWidget {
  final int id;
  
  const ProductDetailScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('상품 상세')),
      body: FutureBuilder(
        future: DatabaseHelper().getPost(id),
        builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            AppLogger.error('Product detail error', snapshot.error);
            return const Center(child: Text('오류가 발생했습니다'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('상품을 찾을 수 없습니다'));
          }

          final post = Post.fromMap(snapshot.data!);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.imageUrl.isNotEmpty)
                  Image.network(
                    post.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 16),
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  post.price,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(post.description),
              ],
            ),
          );
        },
      ),
    );
  }
}

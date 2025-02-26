import 'package:flutter/material.dart';
import 'package:demode/backend/database_helper.dart';
import 'package:demode/backend/post.dart';
import 'package:demode/frontend/widgets/header.dart';
import 'package:demode/backend/services/auth_service.dart';

// 인스타그램 화면 클래스
class InstagramScreen extends StatefulWidget {
  final List<Post> posts;

  const InstagramScreen({super.key, this.posts = const []});

  @override
  _InstagramScreenState createState() => _InstagramScreenState();
}

class _InstagramScreenState extends State<InstagramScreen> {
  List<Post> _posts = [];
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _updateSession();
  }

  Future<void> _loadPosts() async {
    final dbHelper = DatabaseHelper();
    final posts = await dbHelper.getPosts();
    setState(() {
      _posts = posts.map((post) => Post.fromMap(post)).toList();
    });
  }

  Future<void> _updateSession() async {
    await _authService.updateLastAccess();
  }

  void _addPost(Post post) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertPost(post.toMap());
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: '인스타그램'),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return PostWidget(
            imageUrl: post.imageUrl,
            title: post.title,
            price: post.price,
          );
        },
      ),
    );
  }
}

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:demode/backend/services/post_service.dart';

class PostController {
  final PostService _postService = PostService();

  Router get router {
    final router = Router();

    router.get('/posts', (Request request) async {
      try {
        final posts = await _postService.getPosts();
        return Response.ok(posts.toString());
      } catch (e) {
        return Response.internalServerError(body: 'Error fetching posts');
      }
    });

    router.post('/posts', (Request request) async {
      try {
        final payload = await request.readAsString();
        final post = await _postService.createPost(payload);
        return Response.ok(post.toString());
      } catch (e) {
        return Response.internalServerError(body: 'Error creating post');
      }
    });

    return router;
  }
}

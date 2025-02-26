import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:demode/backend/controllers/post_controller.dart';

void main() async {
  final router = Router();

  // PostController 라우트 추가
  final postController = PostController();
  router.mount('/api/', postController.router.call);

  // 서버 실행
  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router.call);
  final server = await io.serve(handler, 'localhost', 8080);

  print('Server listening on port ${server.port}');
}

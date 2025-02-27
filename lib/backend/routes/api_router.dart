import 'package:shelf/shelf_router.dart';
import 'package:shel
import 'package:demode/backend
import 'package:demode/backend/controllers/post_controller.dart';

class ApiRouter {
  Router get router {
    final router = Router();

    // 인증 관련 라우트
    router.mount('/auth/', AuthController().router);
    
    // 게시글 관련 라우트
    router.mount('/posts/', PostController().router);

    // 기본 에러 핸들러
    router.all('/<ignored|.*>', (Request request) {
      return Response.notFound('Route not found');
    });

    return router;
  }
}

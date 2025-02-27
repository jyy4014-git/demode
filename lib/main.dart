import 'package:flutter/material.dart';
import 'frontend/widgets/header.dart';
import 'frontend/widgets/footer.dart';
import 'frontend/screens/instagram_screen.dart';
import 'frontend/screens/sell_item_screen.dart';
import 'frontend/screens/chat_screen.dart';
import 'backend/post.dart';
import 'package:demode/frontend/screens/login_screen.dart';
import 'package:demode/utils/logger.dart';
import 'package:demode/config/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demode',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Routes.login,
      routes: Routes.getRoutes(),
    );
  }
}

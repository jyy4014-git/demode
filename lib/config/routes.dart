import 'package:flutter/material.dart';
import 'package:demode/frontend/screens/login_screen.dart';
import 'package:demode/frontend/screens/instagram_screen.dart';
import 'package:demode/frontend/screens/product_detail_screen.dart';
import 'package:demode/frontend/screens/sell_item_screen.dart';
import 'package:demode/frontend/screens/chat_screen.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/';
  static const String productDetail = '/product_detail';
  static const String sellItem = '/sell_item';
  static const String chat = '/chat';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      home: (context) => const InstagramScreen(),
      sellItem: (context) => const SellItemScreen(),
      chat: (context) => const ChatScreen(),
      productDetail: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ProductDetailScreen(id: args['id']);
      },
    };
  }
}

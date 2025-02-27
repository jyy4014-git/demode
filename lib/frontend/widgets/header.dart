import 'package:flutter/material.dart';

// 헤더 클래스
class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const Header({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // 검색 기능 구현
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            // 알림 기능 구현
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

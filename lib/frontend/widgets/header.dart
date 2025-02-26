import 'package:flutter/material.dart';

// 헤더 클래스
class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const Header({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(
        title,
        style: TextStyle(fontSize: 20),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            // 알림창 로직 추가
          },
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // 찾기 로직 추가
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

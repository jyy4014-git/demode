import 'package:flutter/material.dart';

// 홈 페이지 클래스
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: title),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 상품 목록 표시
            Expanded(
              child: ListView.builder(
                itemCount: 1, // 등록된 상품 개수
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('상품 제목'),
                    subtitle: Text('상품 설명'),
                    trailing: Text('₩1000'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: '증가',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Footer(),
    );
  }
}

// 헤더 클래스
class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const Header({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(title),
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

// 푸터 클래스
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: '채팅',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '프로필',
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

// 채팅 화면 클래스
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text('판매자 1'),
            subtitle: Text('안녕하세요, 상품에 관심 있습니다.'),
            onTap: () {
              // 채팅 상세 화면으로 이동
            },
          ),
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text('판매자 2'),
            subtitle: Text('상품 가격을 조정할 수 있나요?'),
            onTap: () {
              // 채팅 상세 화면으로 이동
            },
          ),
          // 추가 채팅 목록
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text('판매자 3'),
            subtitle: Text('상품에 대해 더 알고 싶습니다.'),
            onTap: () {
              // 채팅 상세 화면으로 이동
            },
          ),
        ],
      ),
    );
  }
}

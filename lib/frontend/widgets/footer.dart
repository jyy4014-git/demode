import 'package:flutter/material.dart';

// 푸터 클래스
class Footer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddButtonPressed;

  const Footer({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FloatingActionButton(
              onPressed: onAddButtonPressed,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

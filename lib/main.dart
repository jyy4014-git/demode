import 'package:flutter/material.dart';
import 'frontend/widgets/header.dart';
import 'frontend/widgets/footer.dart';
import 'frontend/screens/instagram_screen.dart';
import 'frontend/screens/sell_item_screen.dart';
import 'frontend/screens/chat_screen.dart';
import 'backend/post.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    InstagramScreen(),
    ChatScreen(),
    Text('My Records Screen'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddButtonPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SellItemScreen()),
    );
    if (result != null && result is Post) {
      setState(() {
        _widgetOptions[0] = InstagramScreen(posts: [result]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: Header(title: 'Flutter Demo'),
        body: _widgetOptions.elementAt(_selectedIndex),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Footer(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            onAddButtonPressed: _onAddButtonPressed,
          ),
        ),
      ),
    );
  }
}

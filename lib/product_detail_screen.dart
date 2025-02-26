import 'package:demode/frontend/screens/chat_screen.dart';
import 'package:flutter/material.dart';

// 상품 상세 페이지 클래스
class ProductDetailScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String price;

  const ProductDetailScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedCategory;
  final List<String> _categories = ['전자제품', '책', '의류', '가정용품', '장난감'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.imageUrl),
            SizedBox(height: 16),
            Text(
              widget.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.price,
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              hint: Text('카테고리 선택'),
              value: _selectedCategory,
              onChanged: (String? newValue) {
                try {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                } catch (e) {
                  ErrorDialog.show(context, '카테고리를 선택하는 중 오류가 발생했습니다.');
                }
              },
              items: _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              '상품 설명을 여기에 추가하세요.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // 채팅 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
                );
              },
              child: Text('판매자에게 채팅하기'),
            ),
          ],
        ),
      ),
    );
  }
}

// 오류 다이얼로그 클래스
class ErrorDialog {
  static void show(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

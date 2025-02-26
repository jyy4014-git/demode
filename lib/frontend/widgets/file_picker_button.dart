import 'package:flutter/material.dart';

// 파일 선택 버튼 클래스
class FilePickerButton extends StatelessWidget {
  final Future<void> Function() onFilesPicked;

  const FilePickerButton({super.key, required this.onFilesPicked});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onFilesPicked,
      child: Text('파일 선택 (최대 5개)'),
    );
  }
}

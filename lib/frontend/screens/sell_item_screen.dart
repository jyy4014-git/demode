import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:demode/frontend/widgets/file_picker_button.dart';
import 'package:demode/frontend/widgets/error_dialog.dart';
import 'package:demode/backend/post.dart';
import 'package:demode/frontend/widgets/header.dart';
import 'package:demode/backend/repositories/database_helper.dart';
import 'package:demode/utils/logger.dart';

// 판매 아이템 화면 클래스
class SellItemScreen extends StatelessWidget {
  const SellItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: '상품 등록'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SellItemForm(),
      ),
    );
  }
}

// 판매 아이템 폼 클래스
class SellItemForm extends StatefulWidget {
  const SellItemForm({super.key});

  @override
  _SellItemFormState createState() => _SellItemFormState();
}

class _SellItemFormState extends State<SellItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<PlatformFile> _files = [];
  String? _selectedCategory;
  final List<String> _categories = ['전자제품', '책', '의류', '가정용품', '장난감'];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  // 파일 선택 함수
  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );
      if (result != null && result.files.length <= 5) {
        setState(() {
          _files = result.files;
        });
      } else {
        ErrorDialog.show(context, '파일은 최대 5개까지 선택할 수 있습니다.');
      }
    } catch (e) {
      ErrorDialog.show(context, '파일을 선택하는 중 오류가 발생했습니다.');
    }
  }

  // 이미지 선택 함수
  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> selectedImages = await picker.pickMultiImage(imageQuality: 50);
      if (selectedImages.length <= 5) {
        setState(() {
          _files.addAll(selectedImages.map((image) => PlatformFile(
            name: image.name,
            path: image.path,
            size: File(image.path).lengthSync(),
          )));
        });
      } else {
        ErrorDialog.show(context, '이미지는 최대 5개까지 선택할 수 있습니다.');
      }
    } catch (e) {
      ErrorDialog.show(context, '이미지를 선택하는 중 오류가 발생했습니다.');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final post = {
        'title': _titleController.text,
        'price': _priceController.text,
        'description': _descriptionController.text,
        'imageUrl': _files.isNotEmpty ? _files.first.path! : '',
        'category': _selectedCategory ?? '기타',
      };

      final id = await _dbHelper.insertPost(post);
      
      if (!mounted) return;
      
      if (id > 0) {
        Navigator.of(context).pop(true); // 성공 시 true 반환
      } else {
        _showError('게시물 등록에 실패했습니다');
      }
    } catch (e) {
      AppLogger.error('Submit form error', e);
      if (!mounted) return;
      _showError('오류가 발생했습니다');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ErrorDialog.show(context, message);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          // 제목 입력 필드
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(labelText: '제목'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '제목을 입력하세요';
              }
              return null;
            },
          ),
          // 가격 입력 필드
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(labelText: '가격'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '가격을 입력하세요';
              }
              return null;
            },
          ),
          // 카테고리 선택 드롭다운
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: '카테고리'),
            value: _selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            items: _categories.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '카테고리를 선택하세요';
              }
              return null;
            },
          ),
          // 설명 입력 필드
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: '설명'),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '설명을 입력하세요';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          // 파일 선택 버튼
          FilePickerButton(onFilesPicked: _pickFiles),
          SizedBox(height: 10),
          // 이미지 선택 버튼
          ElevatedButton(
            onPressed: _pickImages,
            child: Text('이미지 선택 (최대 5개)'),
          ),
          SizedBox(height: 10),
          // 선택된 파일 표시
          _files.isNotEmpty
              ? Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _files.map((file) {
                    if (file.path == null) return Container();
                    return Column(
                      children: [
                        if (file.extension == 'jpg' || file.extension == 'png')
                          Image.file(
                            File(file.path!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        else if (file.extension == 'pdf')
                          Icon(Icons.picture_as_pdf, size: 100),
                        Text(file.name),
                      ],
                    );
                  }).toList(),
                )
              : Text('선택된 파일이 없습니다'),
          SizedBox(height: 20),
          // 등록 버튼
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            child: _isLoading ? CircularProgressIndicator() : Text('등록'),
          ),
        ],
      ),
    );
  }
}

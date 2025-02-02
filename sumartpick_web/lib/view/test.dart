import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
    final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  
  int? _selectedCategory;
  Uint8List? _imageBytes;
  String? _base64Image;

  final Map<int, String> categoryMap = {
    4: "가구",
    5: "기타",
    6: "도서",
    7: "미디어",
    8: "뷰티",
    9: "스포츠",
    10: "식품_음료",
    11: "유아_애완",
    12: "전자제품",
    13: "패션"
  };

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _imageBytes = result.files.first.bytes;
        _base64Image = base64Encode(_imageBytes!);
      });
    }
  }

  Future<void> _uploadProduct() async {
    print(_selectedCategory);
    if (_base64Image == null ||
        _selectedCategory == null ||
        _nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _detailController.text.isEmpty ||
        _manufacturerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("모든 필드를 입력해주세요.")));
      return;
    }

    final Map<String, dynamic> productData = {
      "Category_ID": _selectedCategory,
      "name": _nameController.text,
      "base64_image": _base64Image,
      "price": int.parse(_priceController.text),
      "detail": _detailController.text,
      "manufacturer": _manufacturerController.text
    };

    final response = await http.post(
      Uri.parse("https://fastapi.sumartpick.shop/insert_products"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(productData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("상품이 성공적으로 등록되었습니다.")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("상품 등록 실패")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("상품 등록")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _selectedCategory,
              hint: Text("카테고리 선택"),
              items: categoryMap.keys.map((int key) {
                return DropdownMenuItem<int>(
                  value: key,
                  child: Text(categoryMap[key]!)
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "상품명")),
            TextField(controller: _priceController, decoration: InputDecoration(labelText: "가격"), keyboardType: TextInputType.number),
            TextField(controller: _detailController, decoration: InputDecoration(labelText: "상품 상세")),
            TextField(controller: _manufacturerController, decoration: InputDecoration(labelText: "제조사")),
            SizedBox(height: 10),
            _imageBytes == null
                ? Text("이미지를 선택하세요")
                : Image.memory(_imageBytes!, height: 100),
            ElevatedButton(onPressed: _pickImage, child: Text("이미지 선택")),
            ElevatedButton(onPressed: _uploadProduct, child: Text("상품 등록")),
          ],
        ),
      ),
    );
  }
}
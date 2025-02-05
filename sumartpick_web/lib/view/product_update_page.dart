import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProductUpdatePage extends StatefulWidget {
  const ProductUpdatePage({super.key});

  @override
  State<ProductUpdatePage> createState() => _ProductUpdatePageState();
}

class _ProductUpdatePageState extends State<ProductUpdatePage> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late int? selectedCategory;
  Uint8List? imageBytes;
  String? base64Image;
  // arguments: [product['이미지'], product['상품코드'], product['카테고리'], product['상품명'], product['판매가']

  var value = Get.arguments ?? "__";

  final Map<String, int> reversedCategoryMap = {
    "가구": 4,
    "기타": 5,
    "도서": 6,
    "미디어": 7,
    "뷰티": 8,
    "스포츠": 9,
    "식품_음료": 10,
    "유아_애완": 11,
    "전자제품": 12,
    "패션": 13
  };

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
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.first.bytes != null) {
      setState(() {
        imageBytes = result.files.first.bytes;
        base64Image = base64Encode(imageBytes!);
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("카테고리를 선택하세요.")));
      return;
    }

    if (base64Image == null || base64Image!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("이미지를 선택하세요.")));
      return;
    }

    if (nameController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("모든 필드를 입력해주세요.")));
      return;
    }

    final Map<String, dynamic> productData = {
      "Product_ID" : value[1],
      "Category_ID": selectedCategory!,
      "name": nameController.text,
      "base64_image": base64Image ?? "", // ✅ Firebase Storage 업로드용 Base64 이미지
      "price": int.tryParse(priceController.text) ?? 0,
    };

    // print("📤 Sending Product Data: ${jsonEncode(productData)}");

    final response = await http.post(
      Uri.parse("https://fastapi.sumartpick.shop/update_all_products"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(productData),
    );

    // print("📥 Response status: ${response.statusCode}");
    // print("📥 Response body: ${response.body}");
    if (mounted) {
          if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("상품이 성공적으로 등록되었습니다.")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("상품 등록 실패: ${response.body}")));
    }
    }

  }
  // arguments: [product['이미지'], product['상품코드'], product['카테고리'], product['상품명'], product['판매가']
  @override
  void initState() {
    super.initState();
    selectedCategory = reversedCategoryMap[value[2]];
    nameController = TextEditingController(text: value[3]);
    priceController = TextEditingController(text: value[4].toString());
    // print(selectedCategory);
    
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
        child: Center(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: Row(
                  children: [
                    Text(
                      '상품 추가',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              DropdownButtonFormField<int>(
                dropdownColor: Colors.white,
              value: selectedCategory ?? 4,
              hint: const Text("카테고리 선택"),
              items: categoryMap.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value)
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 450,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 380, 20),
                              child: Text(
                                '상품이름',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17
                                ),
                                ),
                            ),
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                  hintText: '상품 이름을 입력하세요',
                                  border: OutlineInputBorder()),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(150, 0, 0, 0),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 380, 20),
                              child: Text(
                                '가격입력',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17
                                ),
                                ),
                            ),
                            SizedBox(
                              width: 450,
                              child: TextField(
                                controller: priceController,
                                decoration: const InputDecoration(
                                    hintText: '가격을 입력하세요', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                          const SizedBox(height: 10),
            imageBytes == null ? Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Image.network(
                              Uri.decodeFull(value[0]), // URL 디코딩
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error, color: Colors.red, size: 50);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
            )
            : Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Container(
                decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0), // 검은색 테두리, 두께 2
                ),
                child: Image.memory(imageBytes!, height: 100)
                ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: ElevatedButton(
                onPressed: _pickImage, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                  )
                ),
                child: const Text(
                  "이미지 선택"
                  )),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: ElevatedButton(
                onPressed: () async{
                  imageBytes == null 
                  ? await updateJSONData()
                  : await _uploadProduct();
                  Get.back();
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                  )
                ),
                child: const Text("상품 등록")),
            ),
            ],
          ),
        ),
      ),
    );
  }

  updateJSONData() async{
    // "update Products set Category_ID = %s, name = %s, price = %s where Product_ID = %s"
    var url = Uri.parse(
      "https://fastapi.sumartpick.shop/product_update?Category_ID=$selectedCategory&name=${nameController.text}&price=${double.parse(priceController.text)}&Product_ID=${value[1]}");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];

    setState(() {});
  }
}
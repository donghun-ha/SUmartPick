import 'dart:convert';

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
  late String selectedDropdown;
  late int selectedCategoryId;
  late List<String> categoryList;
  late List<int> categoryId;
  var value = Get.arguments ?? "__";

  @override
  void initState() {
    super.initState();
    selectedCategoryId = 4;
    nameController = TextEditingController(text: value[1]);
    priceController = TextEditingController(text: value[2].toString());
    selectedDropdown = '가구';
    categoryList = ['가구', '기타', '도서', '미디어', '뷰티', '스포츠', '식품_음료', '유아_애완', '전자제품', '패션'];
    categoryId = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
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
                    '상품 수정',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(175, 30, 0, 0),
                  child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: Colors.white,
                            value: selectedDropdown, // 현재 선택된 값
                            items: ['가구', '기타', '도서', '미디어', '뷰티', '스포츠', '식품_음료', '유아_애완', '전자제품', '패션']
                                .map((String option) => DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(option),
                                    ))
                                .toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedDropdown = value!; // 선택된 값 업데이트
                                selectedCategoryId = categoryId[categoryList.indexOf(value)];
                                // print(selectedCategoryId);
                              });
                            },
                          ),
                        ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(175, 40, 0, 0),
                  child: SizedBox(
                    width: 600,
                    child: Text(
                      '상품명',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(100, 40, 0, 0),
                  child: SizedBox(
                    width: 600,
                    child: Text(
                      '상품 가격',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(175, 40, 0, 0),
                  child: SizedBox(
                    width: 600,
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: '상품명을 입력하세요',
                        border: OutlineInputBorder()
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(100, 40, 0, 0),
                  child: SizedBox(
                    width: 600,
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        hintText: '상품 가격을 입력하세요',
                        border: OutlineInputBorder()
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: ElevatedButton(
                onPressed: () {
                  updateJSONData();
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white
                ),
                child: const Text('수정')
                ),
            )
            ],
          ),
        ),
      ),
    );
  }

  updateJSONData() async{
    // "update Products set Category_ID = %s, name = %s, price = %s where Product_ID = %s"
    var url = Uri.parse(
      "https://fastapi.sumartpick.shop/products/product_update?Category_ID=$selectedCategoryId&name=${nameController.text}&price=${double.parse(priceController.text)}&Product_ID=${value[0]}");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];

    setState(() {});

    if(result == 'OK'){
      _showDialog();
    }else{
      errorSnackBar();
    }
  }
  _showDialog(){
    print("Completed");
    Get.back();
  }

  errorSnackBar(){
    print("Error");
  }
}
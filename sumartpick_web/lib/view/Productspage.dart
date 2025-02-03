import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumatpick_web/view/Userpage.dart';
import 'package:sumatpick_web/view/product_insert_page.dart';
import 'package:sumatpick_web/view/product_update_page.dart';

import 'Dashboard.dart';
import 'Inventorypage.dart';
import 'Orderpage.dart';
import 'package:http/http.dart' as http;

class Productspage extends StatefulWidget {
  const Productspage({super.key});

  @override
  State<Productspage> createState() => _ProductspageState();
}

class _ProductspageState extends State<Productspage> {
  late String selectedFilter;
  late List data;
  late List<String> keys;
  late TextEditingController searchController;
  // 임시 데이터 선언
  late List<Map<String, dynamic>> products;
  // 검색 데이터 선언
  late List<Map<String, dynamic>> filteredProducts;

  @override
  void initState() {
    super.initState();
    data = [];
    filteredProducts = [];
    selectedFilter = "상품코드";
    searchController = TextEditingController();
    keys = ["이미지", "상품코드", "상품명", "카테고리", "등록일", "판매가"];
    getJSONData();
  }
    getJSONData() async{
    var url = Uri.parse('https://fastapi.sumartpick.shop/product_select_all');
    var response = await http.get(url);
    // print(response.body);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data.addAll(result);
    // map 형식으로 변환 후 저장
    products = data.map((entry) {
    return Map.fromIterables(keys, entry);
  }).toList();
  // 변환한 데이터를 화면에 보여줄 변수에 저장
  filteredProducts = products;

  if (mounted) {
  setState(() {
    filteredProducts = products;
  });
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
        child: Column(
          children: [
            // 위의 탭 부분
            Row(
              children: [
                // 대시보드
                InkWell(
                  onTap: () {
                    Get.to(const Dashboard());
                  },
                  child: Container(
                      width: 80,
                      height: 30,
                      alignment: Alignment.center,
                      color: const Color(0xffF9FAFB),
                      child: const Text(
                        '대시보드',
                      )),
                ),
                // 회원관리
                InkWell(
                  onTap: () {
                    Get.to(const Userpage());
                  },
                  child: Container(
                      width: 80,
                      height: 30,
                      alignment: Alignment.center,
                      color: const Color(0xffF9FAFB),
                      child: const Text(
                        '회원관리',
                      )),
                ),
                //상품관리
                Container(
                    width: 80,
                    height: 30,
                    alignment: Alignment.center,
                    color: const Color(0xffD9D9D9),
                    child: const Text(
                      '상품관리',
                    )),
                //주문관리
                InkWell(
                  onTap: () {
                    Get.to(const Orderpage());
                  },
                  child: Container(
                      width: 80,
                      height: 30,
                      alignment: Alignment.center,
                      color: const Color(0xffF9FAFB),
                      child: const Text(
                        '주문관리',
                      )),
                ),
                // 재고관리
                InkWell(
                  onTap: () {
                    Get.to(const Inventorypage());
                  },
                  child: Container(
                      width: 80,
                      height: 30,
                      alignment: Alignment.center,
                      color: const Color(0xffF9FAFB),
                      child: const Text(
                        '재고관리',
                      )),
                ),
              ],
            ),
            const Divider(
              height: 1,
              thickness: 2,
              color: Color(0xffD9D9D9),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: Row(
                children: [
                  Text(
                    '상품 정보관리',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  // 검색창 밑 그림자 설정
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // 드롭다운 버튼
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: selectedFilter, // 현재 선택된 값
                        items: ['상품코드', '상품명']
                            .map((String option) => DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedFilter = value!; // 선택된 값 업데이트
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 검색 입력 창
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: "검색어를 입력하세요",
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          filterproducts();
                        },
                      ),
                    ),
                    // 검색 버튼
                    ElevatedButton.icon(
                      onPressed: filterproducts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text(
                        "검색",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: TextButton(
                        onPressed: resetFilter,
                        child: const Text(
                          '초기화',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          "총 상품 수 : ${filteredProducts.length}개",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                      // 상품 추가 버튼
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
                        child: SizedBox(
                                    width: 100,
                                    height: 40,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Get.to(const ProductInsertPage())!.then((value) => reloadData(),);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5), // 모서리 둥글게
                                          ),
                                        ),
                                        child: const Text(
                                          '상품추가',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold
                                            ),
                                        )),
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '이미지',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '상품코드',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '상품명',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '카테고리',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '등록일',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '판매가',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      ' ',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      ' ',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // 유저 관리 리스트
            Expanded(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index]; // 검색결과 product에 저장
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Image.network(
                              Uri.decodeFull(product['이미지']), // URL 디코딩
                              width: 200,
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
                          ),
                          Expanded(
                            child: Text(
                              "${product['상품코드']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['상품명']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['카테고리']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['등록일']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['판매가']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // 상품 수정 버튼
                          Expanded(
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 66,
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 20,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Get.to(const ProductUpdatePage(), arguments: [product['상품코드'], product['상품명'], product['판매가']])!.then((value) => reloadData(),);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5), // 모서리 둥글게
                                        ),
                                      ),
                                      child: const Text(
                                        '수정',
                                        style: TextStyle(fontSize: 11),
                                      )),
                                ),
                              ],
                            ),
                          ),
                          // 상품 삭제 버튼
                          Expanded(
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 66,
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 20,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        deleteDialog(product['상품코드']);
                                        
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5), // 모서리 둥글게
                                        ),
                                      ),
                                      child: const Text(
                                        '삭제',
                                        style: TextStyle(fontSize: 11),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
  // -----Function-----

  // dropdown에서 선택한 검색어로 검색
  filterproducts() {
    String query = searchController.text.trim();
    if (query.isEmpty) {
      filteredProducts = products; // 검색어 없으면 전체 표시
    } else {
      filteredProducts = products.where((product) {
        return product[selectedFilter].toString().contains(query);
      }).toList();
    }
    setState(() {});
  }

  // 검색창 초기화
  resetFilter() {
    searchController.clear();
    filteredProducts =
        products; // 지금은 초기화 하면 임시데이터를 넣지만 DB가 있을땐 초기 DB데이터를 넣어야 함
    setState(() {});
  }
  
  reloadData(){
    getJSONData();
  }

  deleteDialog(proID){
    Get.defaultDialog(
      title: '삭제',
      middleText: '정말로 해당 상품을 삭제하시겠습니까?',
      backgroundColor: Colors.white,
      barrierDismissible: false,
      actions: [
        ElevatedButton(
          onPressed: () {
            productDelete(proID);
          }, 
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 244, 107, 97),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
            )
          ),
          child: const Text(
            '삭제'
            )
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: ElevatedButton(
            onPressed: () {
              Get.back();
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 32, 32, 32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
              )
            ),
            child: const Text(
              '아니오'
              )
            ),
          ),
      ]
    );
  }
  // SQL에서 상품 삭제 기능
  productDelete(proID) async{
    var url = Uri.parse(
      "https://fastapi.sumartpick.shop/delete?Product_ID=$proID");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];

    setState(() {});
    searchController.text = '';
    reloadData();
    Get.back();
  }
}
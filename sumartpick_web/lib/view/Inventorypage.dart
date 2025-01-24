import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumatpick_web/view/Orderpage.dart';

import 'Dashboard.dart';
import 'Productspage.dart';
import 'Userpage.dart';
import 'package:http/http.dart' as http;

class Inventorypage extends StatefulWidget {
  const Inventorypage({super.key});

  @override
  State<Inventorypage> createState() => _InventorypageState();
}

class _InventorypageState extends State<Inventorypage> {
  late String selectedFilter;
  late List data;
  late List totaldata;
  late TextEditingController searchController;
  late String selectedHubFilter;
  late List<String> hubList;
  late List<int> hubId;
  late int selectHubId;
  late List<String> summationKeys;
  late List<String> mainKeys;
  // 임시 데이터 선언
  late List<Map<String, dynamic>> inventorys;
  late List<Map<String, dynamic>> totalInventorys;
  // 검색 데이터 선언
  late List<Map<String, dynamic>> filteredInventorys;
  late List<Map<String, dynamic>> filteredtotalInventorys;

  @override
  void initState() {
    super.initState();
    data = [];
    totaldata = [];
    selectHubId = 1;
    hubList = ['Central Hub_1', 'North Hub_2', 'South Hub_3'];
    hubId = [1, 2, 3];
    summationKeys = ['상품코드', '상품명', '상품재고'];
    mainKeys = ['변동시간', '상품코드', '상품명', '재고량', '재고이동'];
    filteredInventorys = [];
    filteredtotalInventorys = [];
    selectedFilter = "상품코드";
    selectedHubFilter = "Central Hub_1";
    searchController = TextEditingController();
    inventorys = [];
    totalInventorys = [];
    getJSONTotalData();
    getJSONData();
  }

  getJSONTotalData() async {
    var url =
        Uri.parse('http://127.0.0.1:8000/inventories/inventory_total_${selectHubId}_select');
    var response = await http.get(url);

    // 데이터를 클리어
    totaldata.clear();

    // JSON 데이터를 디코딩
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    totaldata.addAll(result);

    // null 값을 빈 문자열로 변환하며 map 형식으로 변환
    totalInventorys = totaldata.map((entry) {
      return Map.fromIterables(
        summationKeys,
        entry.map((value) => value ?? ''), // null 값을 빈 문자열로 변환
      );
    }).toList();

    // 변환한 데이터를 화면에 보여줄 변수에 저장
    filteredtotalInventorys = totalInventorys;

    if (mounted) {
      setState(() {
        // 상태 업데이트
      });
    }
  }

  getJSONData() async {
    var url = Uri.parse('http://127.0.0.1:8000/inventories/inventory_${selectHubId}_select');
    var response = await http.get(url);

    // 데이터를 클리어
    data.clear();

    // JSON 데이터를 디코딩
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data.addAll(result);

    // null 값을 빈 문자열로 변환하며 map 형식으로 변환
    inventorys = data.map((entry) {
      return Map.fromIterables(
        mainKeys,
        entry.map((value) => value ?? ''), // null 값을 빈 문자열로 변환
      );
    }).toList();

    // 변환한 데이터를 화면에 보여줄 변수에 저장
    filteredInventorys = inventorys;

    if (mounted) {
      setState(() {
        // 상태 업데이트
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
        child: SingleChildScrollView(
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
                  InkWell(
                    onTap: () {
                      Get.to(const Productspage());
                    },
                    child: Container(
                        width: 80,
                        height: 30,
                        alignment: Alignment.center,
                        color: const Color(0xffF9FAFB),
                        child: const Text(
                          '상품관리',
                        )),
                  ),
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
                  Container(
                      width: 80,
                      height: 30,
                      alignment: Alignment.center,
                      color: const Color(0xffD9D9D9),
                      child: const Text(
                        '재고관리',
                      )),
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
                      '재고관리',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          items: ['상품코드', '상품명', '재고이동']
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
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: Colors.white,
                              value: selectedHubFilter, // 현재 선택된 값
                              items: hubList
                                  .map((String option) =>
                                      DropdownMenuItem<String>(
                                        value: option,
                                        child: Text(option),
                                      ))
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedHubFilter = value!; // 선택된 값 업데이트
                                  selectHubId = hubId[hubList.indexOf(value)];
                                  reloadData();
                                });
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                          child: TextButton(
                              onPressed: () {
                                //
                              },
                              child: const Text(
                                '재고등록',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // 재고 요약
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '상품코드',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '상품명',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '상품재고',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // 재고 요약 ListviewBuild
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListView.builder(
                    itemCount: filteredtotalInventorys.length,
                    itemBuilder: (context, index) {
                      final product =
                          filteredtotalInventorys[index]; // 검색결과 product에 저장
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                "${product['상품재고']}",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1650,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(85, 0, 0, 0),
                          child: SizedBox(
                            width: 100,
                            child: Text(
                              '변동시간',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(175, 0, 0, 0),
                          child: SizedBox(
                            width: 100,
                            child: Text(
                              '상품코드',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(175, 0, 0, 0),
                          child: SizedBox(
                            width: 100,
                            child: Text(
                              '상품명',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(175, 0, 0, 0),
                          child: SizedBox(
                            width: 100,
                            child: Text(
                              '재고량',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(175, 0, 0, 0),
                          child: SizedBox(
                            width: 100,
                            child: Text(
                              '재고이동',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        // Expanded(
                        //   child: Text(
                        //     ' ', // 관리 버튼 칸
                        //     style: TextStyle(
                        //         fontSize: 15, fontWeight: FontWeight.bold),
                        //     textAlign: TextAlign.center,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              // 유저 관리 리스트
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Container(
                  width: 1650,
                  height: 500, // 높이 지정
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListView.builder(
                    itemCount: filteredInventorys.length,
                    itemBuilder: (context, index) {
                      final product =
                          filteredInventorys[index]; // 검색결과 product에 저장
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10), // 적절한 간격 추가
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // 변동시간
                              Padding(
                                padding: const EdgeInsets.fromLTRB(85, 0, 0, 0),
                                child: SizedBox(
                                  width: 100, // 고정된 너비 설정
                                  child: Text(
                                    "${product['변동시간']}",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 상품코드
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(175, 0, 0, 0),
                                child: SizedBox(
                                  width: 100, // 고정된 너비 설정
                                  child: Text(
                                    "${product['상품코드']}",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 상품명
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(150, 0, 0, 0),
                                child: SizedBox(
                                  width: 150, // 고정된 너비 설정
                                  child: Text(
                                    "${product['상품명']}",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 재고량
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(150, 0, 0, 0),
                                child: SizedBox(
                                  width: 100, // 고정된 너비 설정
                                  child: Text(
                                    "${product['재고량']}",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 재고이동
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(175, 0, 0, 0),
                                child: SizedBox(
                                  width: 100, // 고정된 너비 설정
                                  child: Text(
                                    "${product['재고이동']}",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 관리 버튼
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(150, 0, 0, 0),
                                child: SizedBox(
                                  width: 70,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // 버튼 동작 추가
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
                                      '관리',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  // -----Function-----

  // dropdown에서 선택한 검색어로 검색
  filterproducts() {
    String query = searchController.text.trim();
    if (query.isEmpty) {
      filteredInventorys = inventorys; // 검색어 없으면 전체 표시
    } else {
      filteredInventorys = inventorys.where((product) {
        return product[selectedFilter].toString().contains(query);
      }).toList();
    }
    setState(() {});
  }

  // 검색창 초기화
  resetFilter() {
    searchController.clear();
    filteredInventorys =
        inventorys; // 지금은 초기화 하면 임시데이터를 넣지만 DB가 있을땐 초기 DB데이터를 넣어야 함
    setState(() {});
  }

  reloadData(){
    getJSONTotalData();
    getJSONData();
  }
}

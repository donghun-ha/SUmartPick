import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart' as toget;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sumatpick_web/view/Order_update.dart';
import 'package:sumatpick_web/view/Userpage.dart';

import 'Dashboard.dart';
import 'Inventorypage.dart';
import 'Productspage.dart';
import 'package:http/http.dart' as http;

class Orderpage extends StatefulWidget {
  const Orderpage({super.key});

  @override
  State<Orderpage> createState() => _OrderpageState();
}

class _OrderpageState extends State<Orderpage> {
  late String selectedFilter;
  late TextEditingController searchController;
  late List data;
  late List<String> keys;
  // 임시 데이터 선언
  late List<Map<String, dynamic>> orders;
  // 검색 데이터 선언
  late List<Map<String, dynamic>> filteredOrders;

  late DateTime? startDate; // 시작 날짜
  late DateTime? endDate; // 종료 날짜

  @override
  void initState() {
    super.initState();
    data = [];
    filteredOrders = [];
    keys = ["주문번호", "주문상세번호", "주문ID", "상품명", "상품금액", "주문일시", "배송주소", "환불요청시간", "환불시간", "결제방법", "배송도착시간", "배송상태", "상품ID"];
    selectedFilter = "주문번호";
    searchController = TextEditingController();
    startDate = null; // 초기값 null
    endDate = null; // 초기값 null
    getJSONData();
  }

  getJSONData() async {
  var url = Uri.parse('https://fastapi.sumartpick.shop/orders/order_select');
  var response = await http.get(url);

  // 데이터를 클리어
  data.clear();

  // JSON 데이터를 디코딩
  var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
  List result = dataConvertedJSON['results'];
  data.addAll(result);

  // null 값을 빈 문자열로 변환하며 map 형식으로 변환
  orders = data.map((entry) {
    return Map.fromIterables(
      keys,
      entry.map((value) => value ?? ''), // null 값을 빈 문자열로 변환
    );
  }).toList();

  // 변환한 데이터를 화면에 보여줄 변수에 저장
  filteredOrders = orders;

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
          child: Column(
            children: [
              // 위의 탭 부분
              Row(
                children: [
                  // 대시보드
                  InkWell(
                    onTap: () {
                      toget.Get.to(const Dashboard());
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
                      toget.Get.to(const Userpage());
                    },
                    child: Container(
                        width: 80,
                        height: 30,
                        alignment: Alignment.center,
                        color: const Color(0xffF9FAFB),
                        child: const Text(
                          '회원검색',
                        )),
                  ),
                  //상품관리
                  InkWell(
                    onTap: () {
                      toget.Get.to(const Productspage());
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
                  Container(
                      width: 80,
                      height: 30,
                      alignment: Alignment.center,
                      color: const Color(0xffD9D9D9),
                      child: const Text(
                        '주문관리',
                      )),
                  // 재고관리
                  InkWell(
                    onTap: () {
                      toget.Get.to(const Inventorypage());
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
                      '주문리스트(전체)',
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
                          items: ['주문번호', '주문ID', '배송상태']
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
                            filterorders();
                          },
                        ),
                      ),
                      // 시작 날짜 선택 버튼
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              startDate = picked;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                          )
                        ),
                        child: Text(startDate == null
                            ? "시작 날짜 선택"
                            : "${startDate!.toLocal()}".split(' ')[0]),
                      ),
                      const SizedBox(width: 10),

                      // 종료 날짜 선택 버튼
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              endDate = picked;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                          )
                        ),
                        child: Text(endDate == null
                            ? "종료 날짜 선택"
                            : "${endDate!.toLocal()}".split(' ')[0]),
                      ),
                      const SizedBox(width: 10),
                      // 검색 버튼
                      ElevatedButton.icon(
                        onPressed: filterorders,
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
                            "총 주문 수 : ${filteredOrders.length}건",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
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
                        '주문번호',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '주문상세번호',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '주문ID',
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
                        '상품금액',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '주문일시',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '배송주소',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '환불요청시간',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '환불시간',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '결제방법',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '배송도착시간',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '배송상태',
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
              Padding(
                            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: Container(
                              height: 600,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15)),
              child: ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final product = filteredOrders[index]; // 검색결과 product에 저장
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${product['주문번호']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['주문상세번호']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['주문ID']}",
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
                              "${product['상품금액']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['주문일시']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['배송주소']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['환불요청시간']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['환불시간']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['결제방법']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['배송도착시간']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${product['배송상태']}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // 상품 수정 버튼
                          Expanded(
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 47,
                                  height: 20,
                                ),
                                SizedBox(
                                  width: ResponsiveValue(
                                    defaultValue: 70.0,
                                    context, 
                                    conditionalValues: [
                                      const Condition.smallerThan(
                                        value: 40.0, name: MOBILE
                                      ),
                                      const Condition.largerThan(
                                        value: 70.0, name: TABLET
                                      )
                                    ]
                                    ).value,
                                  height: ResponsiveValue(
                                    defaultValue: 20.0,
                                    context, 
                                    conditionalValues: [
                                      const Condition.smallerThan(
                                        value: 10.0, name: MOBILE
                                      ),
                                      const Condition.largerThan(
                                        value: 20.0, name: TABLET
                                      )
                                    ]
                                    ).value,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        toget.Get.to(const OrderUpdate(), arguments: [
                                          product['주문번호'],
                                          product['주문상세번호'],
                                          product['환불요청시간'],
                                          product['배송도착시간'],
                                          product['배송상태'],
                                          product['상품ID']
                                          ]
                                          )!.then((value) => getJSONData(),);
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
                        ],
                      ),
                    ),
                  );
                },
              ),
                            ),
                          ),
            ],
          ),
        ),
      ),
    );
  }
  // -----Function-----

  // dropdown에서 선택한 검색어로 검색
  // filterorders() {
  //   String query = searchController.text.trim();
  //   if (query.isEmpty) {
  //     filteredOrders = orders; // 검색어 없으면 전체 표시
  //   } else {
  //     filteredOrders = orders.where((product) {
  //       return product[selectedFilter].toString().contains(query);
  //     }).toList();
  //   }
  //   setState(() {});
  // }

  filterorders() {
    String query = searchController.text.trim();

    filteredOrders = orders.where((order) {
      bool matchesQuery =
          query.isEmpty || order[selectedFilter].toString().contains(query);

      // ✅ 주문일시 필터 적용 (날짜가 `startDate` ~ `endDate` 범위 내에 있는지 확인)
      bool matchesDateRange = true;
      if (startDate != null && endDate != null && order['주문일시'] != "") {
        DateTime ordersDate =
            DateTime.tryParse(order['주문일시']) ?? DateTime(1900); // 변환 오류 방지
        matchesDateRange = (ordersDate.isAfter(startDate!) ||
                ordersDate.isAtSameMomentAs(startDate!)) &&
            (ordersDate.isBefore(endDate!) ||
                ordersDate.isAtSameMomentAs(endDate!));
      }

      return matchesQuery && matchesDateRange;
    }).toList();

    setState(() {});
  }

  // 검색창 초기화
  resetFilter() {
    searchController.clear();
    filteredOrders =
        orders; // 지금은 초기화 하면 임시데이터를 넣지만 DB가 있을땐 초기 DB데이터를 넣어야 함
    setState(() {});
  }
}
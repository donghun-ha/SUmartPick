import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumatpick_web/view/Inventorypage.dart';
import 'package:sumatpick_web/view/Orderpage.dart';
import 'package:sumatpick_web/view/Productspage.dart';
import 'package:sumatpick_web/view/Userpage.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // 전체 주문현황
  late int totalOrders; // 총 주문건수
  late int totalsales; // 총 주문액
  // 주문상태 현황
  late int completedPayment; // 결제완료
  late int readyDelivery; // 배송준비
  late int inDelivery; // 배송중
  late int completedDelivery; // 배송완료
  // 클래임 현황
  late int refundStatus; // 환불
  late int returnStatus; // 반품
  late int exchangeStatus; // 교환
  // 최근 주문내역
  late List<List<dynamic>> recentOrders; // 최근 주문내역 리스트
  // 최근 회원가입
  late List<List<dynamic>> recentlyRegistered; // 최근 회원가입 리스트



  @override
  void initState() {
    super.initState();
    // 전체 주문현황
    totalOrders = 0;
    totalsales = 0;
    // 주문상태 현황
    completedPayment = 0;
    readyDelivery = 0;
    inDelivery = 0;
    completedDelivery = 0;
    // 클래임 현황
    refundStatus = 0;
    returnStatus = 0;
    exchangeStatus = 0;
    // 최근 주문내역(예시데이터)
    recentOrders = [
  ["25010716241290", "관리자", "관리자", "010-0000-0000", "무통장", "89,000", "2025-01-07 16:25 (화)"],
  ["24122316544816", "관리자", "관리자", "010-0000-0000", "무통장", "89,000", "2024-12-23 16:57 (월)"],
  ["24120419364235", "세글만", "세글만", "010-3333-3333", "무통장", "615,600", "2024-12-04 19:36 (수)"],
];
    // 최근 회원가입(예시데이터)
    recentlyRegistered = [
  ["가맹점몰", "submall", "가맹점", "서울", "2024-12-16 06:14 (월)"],
  ["세글만", "test3", "일반회원", "충주", "2020-10-04 18:05 (일)"],
  ["두글만", "test2", "일반회원", "판교", "2020-10-04 18:05 (일)"],
  ["한글만", "test1", "가맹점", "인천", "2020-10-04 18:04 (일)"],
];
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
                  Container(
                    width: 80,
                    height: 30,
                    alignment: Alignment.center,
                    color: const Color(0xffD9D9D9),
                    child: const Text(
                      '대시보드',
                      )
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
                      )
                    ),
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
                      )
                    ),
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
                      )
                    ),
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
                      )
                    ),
                    ),
                ],
              ),
              const Divider(
                height: 1,
                thickness: 2,
                color: Color(0xffD9D9D9),
              ),
              // ------------------통계 부분--------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Container(
                            width: 5,
                            height: 18,
                            color: const Color.fromARGB(255, 14, 101, 171),
                          ),
                        ),
                        const Text(
                          "전체 주문통계",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(const Orderpage());
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // 모서리 둥글기 설정
                  ),
                        ),
                        
                        child: const Text(
                          '주문내역 바로가기',
                          style: TextStyle(
                            fontSize: 12,
                            
                          ),
                          )
                        )
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 전체 주문 현황
                    Container(
                      width: 300,
                      height: 150,
                      decoration: BoxDecoration(
                      color: Colors.white, // 배경색
                      border: Border.all(
                        color: const Color.fromARGB(255, 199, 199, 199), // 외곽선 색상
                        width: 1.0, // 외곽선 두께
                      ),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(13.0),
                              child: Text(
                                '전체 주문현황',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18
                                ),
                                ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 35,
                                    color: const Color.fromARGB(255, 232, 232, 232),
                                    child: const Center(
                                      child: Text(
                                        '총 주문건수',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold
                                        ),
                                        ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                    child: Container(
                                      width: 170,
                                      height: 35,
                                      color: const Color.fromARGB(255, 232, 232, 232),
                                      child: const Center(
                                        child: Text(
                                          '총 주문액',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold
                                          ),
                                          ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 55,
                                    color: const Color.fromARGB(255, 243, 243, 243),
                                  child: Center(
                                    child: Text(
                                      '$totalOrders',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                      ),
                                      ),
                                  ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                    child: Container(
                                      width: 170,
                                      height: 55,
                                      color: const Color.fromARGB(255, 243, 243, 243),
                                      child: Center(
                                        child: Text(
                                          '$totalsales',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                          ),
                                          ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 주문상태 현황
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                      child: Container(
                        width: 437,
                        height: 150,
                        decoration: BoxDecoration(
                        color: Colors.white, // 배경색
                        border: Border.all(
                          color: const Color.fromARGB(255, 199, 199, 199), // 외곽선 색상
                          width: 1.0, // 외곽선 두께
                        ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(13.0),
                                child: Text(
                                  '주문상태 현황',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                  ),
                                  ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 35,
                                      color: const Color.fromARGB(255, 232, 232, 232),
                                      child: const Center(
                                        child: Text(
                                          '결제완료',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold
                                          ),
                                          ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 35,
                                        color: const Color.fromARGB(255, 232, 232, 232),
                                        child: const Center(
                                          child: Text(
                                            '배송준비',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold
                                            ),
                                            ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 35,
                                        color: const Color.fromARGB(255, 232, 232, 232),
                                        child: const Center(
                                          child: Text(
                                            '배송중',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold
                                            ),
                                            ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 35,
                                        color: const Color.fromARGB(255, 232, 232, 232),
                                        child: const Center(
                                          child: Text(
                                            '배송완료',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold
                                            ),
                                            ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 55,
                                      color: const Color.fromARGB(255, 243, 243, 243),
                                    child: Center(
                                      child: Text(
                                        '$completedPayment',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold
                                        ),
                                        ),
                                    ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 55,
                                        color: const Color.fromARGB(255, 243, 243, 243),
                                        child: Center(
                                          child: Text(
                                            '$readyDelivery',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold
                                            ),
                                            ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 55,
                                        color: const Color.fromARGB(255, 243, 243, 243),
                                        child: Center(
                                          child: Text(
                                            '$inDelivery',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold
                                            ),
                                            ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 55,
                                        color: const Color.fromARGB(255, 243, 243, 243),
                                        child: Center(
                                          child: Text(
                                            '$completedDelivery',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold
                                            ),
                                            ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 환불, 반품, 교환
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                      child: Container(
                        width: 335,
                        height: 150,
                        decoration: BoxDecoration(
                        color: Colors.white, // 배경색
                        border: Border.all(
                          color: const Color.fromARGB(255, 199, 199, 199), // 외곽선 색상
                          width: 1.0, // 외곽선 두께
                        ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(13.0),
                                child: Text(
                                  '클래임 현황',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                  ),
                                  ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 35,
                                      color: const Color.fromARGB(255, 232, 232, 232),
                                      child: const Center(
                                        child: Text(
                                          '환불',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold
                                          ),
                                          ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 35,
                                        color: const Color.fromARGB(255, 232, 232, 232),
                                        child: const Center(
                                          child: Text(
                                            '반품',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold
                                            ),
                                            ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 35,
                                        color: const Color.fromARGB(255, 232, 232, 232),
                                        child: const Center(
                                          child: Text(
                                            '교환',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold
                                            ),
                                            ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 55,
                                      color: const Color.fromARGB(255, 243, 243, 243),
                                    child: Center(
                                      child: Text(
                                        '$refundStatus',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold
                                        ),
                                        ),
                                    ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 55,
                                        color: const Color.fromARGB(255, 243, 243, 243),
                                        child: Center(
                                          child: Text(
                                            '$returnStatus',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold
                                            ),
                                            ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 55,
                                        color: const Color.fromARGB(255, 243, 243, 243),
                                        child: Center(
                                          child: Text(
                                            '$exchangeStatus',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold
                                            ),
                                            ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Container(
                            width: 5,
                            height: 18,
                            color: const Color.fromARGB(255, 14, 101, 171),
                          ),
                        ),
                        const Text(
                          "최근 주문내역",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(const Orderpage());
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // 모서리 둥글기 설정
                  ),
                        ),
                        
                        child: const Text(
                          '주문내역 바로가기',
                          style: TextStyle(
                            fontSize: 12,
                            
                          ),
                          )
                        )
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 200,
                  columns: const [
                    DataColumn(label: Text('주문번호')),
                    DataColumn(label: Text('주문자명')),
                    DataColumn(label: Text('수령자명')),
                    DataColumn(label: Text('전화번호')),
                    DataColumn(label: Text('결제방법')),
                    DataColumn(label: Text('총주문액')),
                    DataColumn(label: Text('주문일시')),
                  ], 
                  rows: recentOrders.map((row) {
                  return DataRow(
                    cells: row.map((cell) {
                      return DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            cell.toString(),
                            softWrap: false,
                            ),
                        )
                        );
                    }).toList(),
                  );
                }).toList(),
                  ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Container(
                            width: 5,
                            height: 18,
                            color: const Color.fromARGB(255, 14, 101, 171),
                          ),
                        ),
                        const Text(
                          "최근 회원가입",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(const Userpage());
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // 모서리 둥글기 설정
                  ),
                        ),
                        
                        child: const Text(
                          '회원관리 바로가기',
                          style: TextStyle(
                            fontSize: 12,
                            
                          ),
                          )
                        )
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 200,
                  columns: const [
                    DataColumn(label: Text('이름')),
                    DataColumn(label: Text('아이디')),
                    DataColumn(label: Text('회원유형')),
                    DataColumn(label: Text('주소')),
                    DataColumn(label: Text('가입일시')),
                  ], 
                  rows: recentlyRegistered.map((row) {
                  return DataRow(
                    cells: row.map((cell) {
                      return DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            cell.toString(),
                            softWrap: false,
                            ),
                        )
                        );
                    }).toList(),
                  );
                }).toList(),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
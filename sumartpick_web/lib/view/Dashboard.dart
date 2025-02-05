import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sumatpick_web/model/chart_hub_data.dart';
import 'package:sumatpick_web/view/Inventorypage.dart';
import 'package:sumatpick_web/view/Orderpage.dart';
import 'package:sumatpick_web/view/Productspage.dart';
import 'package:sumatpick_web/view/Userpage.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
import '../model/chart_data.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // 전체 주문현황
  late List totalOrders; // 총 주문건수
  late List totalsales; // 총 주문액
  // 주문상태 현황
  late List completedPayment; // 결제완료
  late List readyDelivery; // 배송준비
  late List inDelivery; // 배송중
  late List completedDelivery; // 배송완료
  // 클래임 현황
  late List refundStatus; // 환불
  late List returnStatus; // 반품
  late List exchangeStatus; // 교환
  // 최근 주문내역
  late List<dynamic> recentOrders; // 최근 주문내역 리스트
  // 최근 회원가입
  late List<dynamic> recentlyRegistered; // 최근 회원가입 리스트
  late List orderChart;
  late List hubChart;
  late List<ChartData> chartData;
  late List<ChartHubData> hubData;

  @override
  void initState() {
    super.initState();

    // 전체 주문현황
    totalOrders = [];
    totalsales = [];

    // 주문상태 현황
    completedPayment = [];
    readyDelivery = [];
    inDelivery = [];
    completedDelivery = [];

    // 클래임 현황
    refundStatus = [];

    orderChart = [];
    hubChart = [];

    // 클레임 현황 미적용 부분
    returnStatus = [0];
    exchangeStatus = [0];

    // 최근 주문내역(예시데이터)
    recentOrders = [
      // ["25010716241290", "관리자", "관리자", "010-0000-0000", "무통장", "89,000", "2025-01-07 16:25 (화)"],
      // ["24122316544816", "관리자", "관리자", "010-0000-0000", "무통장", "89,000", "2024-12-23 16:57 (월)"],
      // ["24120419364235", "세글만", "세글만", "010-3333-3333", "무통장", "615,600", "2024-12-04 19:36 (수)"],
    ];
    // 최근 회원가입(예시데이터)
    recentlyRegistered = [
      // ["가맹점몰", "submall", "가맹점", "서울", "2024-12-16 06:14 (월)"],
      // ["세글만", "test3", "일반회원", "충주", "2020-10-04 18:05 (일)"],
      // ["두글만", "test2", "일반회원", "판교", "2020-10-04 18:05 (일)"],
      // ["한글만", "test1", "가맹점", "인천", "2020-10-04 18:04 (일)"],
    ];
    chartData = [];
    hubData = [];
    getJSONDashboardData();
    getJSONUserData();
    getJSONOrderData();
    getJSONOrderchartData();
    getJSONHubchartData();
  }

  Future getJSONDashboardData() async {
    Map<String, dynamic> apiEndpoints = {
      'https://fastapi.sumartpick.shop/dashboard/total_orders': (List result) {
        totalOrders.clear();
        totalOrders.addAll(result);
      },
      'https://fastapi.sumartpick.shop/dashboard/total_orders_amount':
          (List result) {
        totalsales.clear();
        totalsales.addAll(result);
      },
      'https://fastapi.sumartpick.shop/dashboard/order_payment_completed':
          (List result) {
        completedPayment.clear();
        completedPayment.addAll(result);
      },
      'https://fastapi.sumartpick.shop/dashboard/order_preparing_for_delivery':
          (List result) {
        readyDelivery.clear();
        readyDelivery.addAll(result);
      },
      'https://fastapi.sumartpick.shop/dashboard/order_in_delivery':
          (List result) {
        inDelivery.clear();
        inDelivery.addAll(result);
      },
      'https://fastapi.sumartpick.shop/dashboard/order_delivered':
          (List result) {
        completedDelivery.clear();
        completedDelivery.addAll(result);
      },
      'https://fastapi.sumartpick.shop/dashboard/order_refund': (List result) {
        refundStatus.clear();
        refundStatus.addAll(result);
      },
    };

    for (var entry in apiEndpoints.entries) {
      var url = Uri.parse(entry.key);
      try {
        var response = await http.get(url);

        // 🚨 응답이 200(정상)인지 확인
        if (response.statusCode != 200) {
          print("❌ API 요청 실패: ${entry.key} - 상태코드: ${response.statusCode}");
          continue;
        }

        // 🚨 API 응답 출력 (디버깅용)
        print("🔍 API 응답 (${entry.key}): ${response.body}");

        var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));

        // 🚨 JSON 구조 확인
        if (!dataConvertedJSON.containsKey('results')) {
          print("❌ 'results' 키 없음 (${entry.key}): $dataConvertedJSON");
          continue;
        }

        List result = dataConvertedJSON['results'];
        entry.value(result); // 변수에 데이터 추가
      } catch (e) {
        print("❌ API 요청 중 오류 발생 (${entry.key}): $e");
      }
    }

    setState(() {}); // UI 업데이트
  }

  // 최근 회원가입 유저
  getJSONUserData() async {
    var url = Uri.parse(
        'https://fastapi.sumartpick.shop/dashboard/user_recent_select');
    var response = await http.get(url);
    // print(response.body);
    recentlyRegistered.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    recentlyRegistered.addAll(result);

    setState(() {});
  }

  // 최근 주문내역
  getJSONOrderData() async {
    var url = Uri.parse(
        'https://fastapi.sumartpick.shop/dashboard/order_recent_select');
    var response = await http.get(url);
    // print(response.body);
    recentOrders.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    recentOrders.addAll(result);
    setState(() {});
  }

  getJSONOrderchartData() async {
    var url =
        Uri.parse('https://fastapi.sumartpick.shop/dashboard/orders_chart');
    var response = await http.get(url);
    // print(response.body);
    orderChart.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    orderChart.addAll(result);
    chartData =
        orderChart.map((row) => ChartData(row[0], row[1] as int)).toList();
    setState(() {});
  }

  getJSONHubchartData() async {
    var url = Uri.parse('https://fastapi.sumartpick.shop/dashboard/hub_chart');
    var response = await http.get(url);
    // print(response.body);
    hubChart.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    hubChart.addAll(result);
    hubData = hubChart
        .map((row) => ChartHubData(row[0] as String, row[1] as int))
        .toList();
    setState(() {});
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
                  Container(
                      width: 80,
                      height: 30,
                      alignment: Alignment.center,
                      color: const Color(0xffD9D9D9),
                      child: const Text(
                        '대시보드',
                      )),
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
                          '회원검색',
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
                            borderRadius:
                                BorderRadius.circular(5), // 모서리 둥글기 설정
                          ),
                        ),
                        child: const Text(
                          '주문내역 바로가기',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ))
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
                          color: const Color.fromARGB(
                              255, 199, 199, 199), // 외곽선 색상
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
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 35,
                                    color: const Color.fromARGB(
                                        255, 232, 232, 232),
                                    child: const Center(
                                      child: Text(
                                        '총 주문건수',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                    child: Container(
                                      width: 170,
                                      height: 35,
                                      color: const Color.fromARGB(
                                          255, 232, 232, 232),
                                      child: const Center(
                                        child: Text(
                                          '총 주문액',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
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
                                    color: const Color.fromARGB(
                                        255, 243, 243, 243),
                                    child: Center(
                                      child: Text(
                                        totalOrders.isNotEmpty
                                            ? '${totalOrders[0][0]}'
                                            : '0',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                    child: Container(
                                      width: 170,
                                      height: 55,
                                      color: const Color.fromARGB(
                                          255, 243, 243, 243),
                                      child: Center(
                                        child: Text(
                                          totalsales.isNotEmpty
                                              ? '${totalsales[0][0]}'
                                              : '0',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
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
                            color: const Color.fromARGB(
                                255, 199, 199, 199), // 외곽선 색상
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
                                      fontSize: 18),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 35,
                                      color: const Color.fromARGB(
                                          255, 232, 232, 232),
                                      child: const Center(
                                        child: Text(
                                          '결제완료',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 35,
                                        color: const Color.fromARGB(
                                            255, 232, 232, 232),
                                        child: const Center(
                                          child: Text(
                                            '배송준비',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 35,
                                        color: const Color.fromARGB(
                                            255, 232, 232, 232),
                                        child: const Center(
                                          child: Text(
                                            '배송중',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 35,
                                        color: const Color.fromARGB(
                                            255, 232, 232, 232),
                                        child: const Center(
                                          child: Text(
                                            '배송완료',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
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
                                      color: const Color.fromARGB(
                                          255, 243, 243, 243),
                                      child: Center(
                                        child: Text(
                                          completedPayment.isNotEmpty
                                              ? '${completedPayment[0][0]}'
                                              : '0',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 55,
                                        color: const Color.fromARGB(
                                            255, 243, 243, 243),
                                        child: Center(
                                          child: Text(
                                            readyDelivery.isNotEmpty
                                                ? '${readyDelivery[0][0]}'
                                                : '0',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 55,
                                        color: const Color.fromARGB(
                                            255, 243, 243, 243),
                                        child: Center(
                                          child: Text(
                                            inDelivery.isNotEmpty
                                                ? '${inDelivery[0][0]}'
                                                : '0',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 55,
                                        color: const Color.fromARGB(
                                            255, 243, 243, 243),
                                        child: Center(
                                          child: Text(
                                            completedDelivery.isNotEmpty
                                                ? '${completedDelivery[0][0]}'
                                                : '0',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
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
                            color: const Color.fromARGB(
                                255, 199, 199, 199), // 외곽선 색상
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
                                      fontSize: 18),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 35,
                                      color: const Color.fromARGB(
                                          255, 232, 232, 232),
                                      child: const Center(
                                        child: Text(
                                          '환불',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 35,
                                        color: const Color.fromARGB(
                                            255, 232, 232, 232),
                                        child: const Center(
                                          child: Text(
                                            '반품',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 35,
                                        color: const Color.fromARGB(
                                            255, 232, 232, 232),
                                        child: const Center(
                                          child: Text(
                                            '교환',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
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
                                      color: const Color.fromARGB(
                                          255, 243, 243, 243),
                                      child: Center(
                                        child: Text(
                                          refundStatus.isNotEmpty
                                              ? '${refundStatus[0][0]}'
                                              : '0',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 55,
                                        color: const Color.fromARGB(
                                            255, 243, 243, 243),
                                        child: Center(
                                          child: Text(
                                            '${returnStatus[0]}',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                      child: Container(
                                        width: 100,
                                        height: 55,
                                        color: const Color.fromARGB(
                                            255, 243, 243, 243),
                                        child: Center(
                                          child: Text(
                                            '${exchangeStatus[0]}',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
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
                        // -------------Chart---------------
                        const Text(
                          "차트",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ------------------차트 그리는 부분--------------------
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 710, 10),
                          child: Text(
                            '날짜별 주문량',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                            ),
                            ),
                        ),
                        Container(
                            width: 800,
                            height: 600,
                            decoration: BoxDecoration(
                              color: Colors.white, // 배경색
                              border: Border.all(
                                color: const Color.fromARGB(
                                    255, 199, 199, 199), // 외곽선 색상
                                width: 1.0, // 외곽선 두께
                              ),
                            ),
                            child: chartData.isEmpty
                                ? const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator()
                                  )
                                : SfCartesianChart(
                                    primaryXAxis: const CategoryAxis(),
                                    primaryYAxis: const NumericAxis(),
                                    series: <CartesianSeries<ChartData, String>>[
                                      LineSeries<ChartData, String>(
                                        dataSource: chartData,
                                        xValueMapper: (ChartData data, _) =>
                                            data.date,
                                        yValueMapper: (ChartData data, _) =>
                                            data.value,
                                        color: Colors.blue,
                                        markerSettings:
                                            const MarkerSettings(isVisible: true),
                                        dataLabelSettings: const DataLabelSettings(
                                            isVisible: true,
                                            labelAlignment:
                                                ChartDataLabelAlignment.auto,
                                            textStyle: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  )),
                      ],
                    ),
                    // -----------hub-------------
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Column(
                        children: [
                          const Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 710, 10),
                          child: Text(
                            '허브별 재고량',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                            ),
                            ),
                        ),
                          Container(
                              width: 800,
                              height: 600,
                              decoration: BoxDecoration(
                                color: Colors.white, // 배경색
                                border: Border.all(
                                  color: const Color.fromARGB(
                                      255, 199, 199, 199), // 외곽선 색상
                                  width: 1.0, // 외곽선 두께
                                ),
                              ),
                              child: hubData.isEmpty
                                  ? const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator()
                                  )
                                  : SfCartesianChart(
                                      primaryXAxis:
                                          const CategoryAxis(), // ✅ X축: Hub 이름 (문자열)
                                      primaryYAxis:
                                          const NumericAxis(), // ✅ Y축: Hub별 수량
                                      series: <CartesianSeries<ChartHubData,
                                          String>>[
                                        ColumnSeries<ChartHubData, String>(
                                          // ✅ LineSeries → ColumnSeries로 변경
                                          dataSource: hubData,
                                          xValueMapper: (ChartHubData data, _) =>
                                              data.name, // ✅ X축에 Hub 이름 (문자열)
                                          yValueMapper: (ChartHubData data, _) =>
                                              data.value, // ✅ Y축에 수량 값
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(
                                              6), // ✅ 막대 모서리 둥글게 설정
                                          dataLabelSettings:
                                              const DataLabelSettings(
                                            isVisible: true,
                                            labelAlignment:
                                                ChartDataLabelAlignment.auto,
                                            textStyle: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                        ],
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
                            borderRadius:
                                BorderRadius.circular(5), // 모서리 둥글기 설정
                          ),
                        ),
                        child: const Text(
                          '주문내역 바로가기',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ))
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 85,
                  columns: const [
                    DataColumn(label: Text('주문번호')),
                    DataColumn(label: Text('상세번호')),
                    DataColumn(label: Text('상품명')),
                    DataColumn(label: Text('주문가격')),
                    DataColumn(label: Text('주문일시')),
                    DataColumn(label: Text('결제방법')),
                    DataColumn(label: Text('배송상태')),
                  ],
                  rows: recentOrders.map((row) {
                    return DataRow(
                      cells: row.map<DataCell>((cell) {
                        // ✅ `map<DataCell>`을 명시적으로 사용
                        return DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              cell.toString(),
                              softWrap: false,
                            ),
                          ),
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
                            borderRadius:
                                BorderRadius.circular(5), // 모서리 둥글기 설정
                          ),
                        ),
                        child: const Text(
                          '회원검색 바로가기',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ))
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 200,
                  columns: const [
                    DataColumn(label: Text('아이디')),
                    DataColumn(label: Text('가입유형')),
                    DataColumn(label: Text('이름')),
                    DataColumn(label: Text('이메일')),
                    DataColumn(label: Text('가입일시')),
                    DataColumn(label: Text('등록주소')),
                  ],
                  rows: recentlyRegistered.map((row) {
                    return DataRow(
                      cells: row.map<DataCell>((cell) {
                        // ✅ `map<DataCell>`을 명시적으로 사용
                        return DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              cell.toString(),
                              softWrap: false,
                            ),
                          ),
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

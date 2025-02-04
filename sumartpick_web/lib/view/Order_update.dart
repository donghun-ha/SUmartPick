import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrderUpdate extends StatefulWidget {
  const OrderUpdate({super.key});

  @override
  State<OrderUpdate> createState() => _OrderUpdateState();
}

class _OrderUpdateState extends State<OrderUpdate> {
  late TextEditingController refundRequesttime;
  late TextEditingController refuntFinishtime;
  late TextEditingController deliveryFinishtime;
  late String selectedFilter;
  late List<String> orderState;
  late String selectedOrderstate;
  // product['주문번호'],product['주문상세번호'],product['환불요청시간'],product['배송도착시간'],product['배송상태']

  // argument
  var value = Get.arguments ?? "__";

  @override
  void initState() {
    super.initState();
    refundRequesttime = TextEditingController(text: value[2]);
    refuntFinishtime = TextEditingController();
    deliveryFinishtime = TextEditingController(text: value[3]);
    selectedFilter = '취소';
    selectedOrderstate = value[4];
    orderState = [
      'Payment_completed',
      'Preparing_for_delivery',
      'In_delivery',
      'Delivered',
      'Refund'
    ];
    print(value);
  }

  @override
  void dispose() {
    refundRequesttime.dispose();
    refuntFinishtime.dispose();
    deliveryFinishtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: Row(
                  children: [
                    const Text(
                      '주문 수정',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 0, 0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Container(
                        width: 5,
                        height: 18,
                        color: const Color.fromARGB(255, 214, 111, 111),
                      ),
                    ),
                    const Text(
                      '환불',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 450,
                        child: TextField(
                          controller: refundRequesttime,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                          readOnly: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(230, 0, 0, 0),
                        child: refundRequesttime.text.trim() == ''
                            ? DropdownButton<String>(
                                dropdownColor: Colors.white,
                                value: selectedFilter, // 현재 선택된 값
                                items: ['수락', '취소']
                                    .map((String option) =>
                                        DropdownMenuItem<String>(
                                          value: option,
                                          child: Text(option),
                                        ))
                                    .toList(),
                                onChanged: null)
                            : DropdownButton<String>(
                                dropdownColor: Colors.white,
                                value: selectedFilter, // 현재 선택된 값
                                items: ['수락', '취소']
                                    .map((String option) =>
                                        DropdownMenuItem<String>(
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
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Divider(
                  thickness: 1,
                  color: Color(0xffD9D9D9),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 0, 0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Container(
                        width: 5,
                        height: 18,
                        color: const Color.fromARGB(255, 214, 111, 111),
                      ),
                    ),
                    const Text(
                      '주문 상태',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 450,
                        child: TextField(
                          controller: deliveryFinishtime,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                          readOnly: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(100, 0, 0, 0),
                        child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          value: selectedOrderstate, // 현재 선택된 값
                          items: orderState
                              .map((String option) => DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedOrderstate = value!; // 선택된 값 업데이트
                              DateTime now = DateTime.now();
                              value == 'Delivered'
                                  ? deliveryFinishtime.text =
                                      DateFormat('yyyy-MM-dd HH:mm:ss').format(now)
                                  : deliveryFinishtime.text = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: ElevatedButton(
                    onPressed: () {
                      updateJSONData();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: const Text('주문상태 수정')),
              )
            ],
          ),
        ),
      ),
    );
  }
  // "update orders set Arrival_Time = %s, Order_state = %s where Order_ID = %s and Product_seq = %s"
  updateJSONData() async{
    // "update Products set Category_ID = %s, name = %s, price = %s where Product_ID = %s"
    var url = Uri.parse(
      "https://fastapi.sumartpick.shop/orders/norefund_orders_update?Arrival_Time=${deliveryFinishtime.text}&Order_state=$selectedOrderstate&Order_ID=${(value[0])}&Product_ID=${value[1]}");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];

    setState(() {});
  }
}

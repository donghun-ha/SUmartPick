import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class InventoryUpdate extends StatefulWidget {
  const InventoryUpdate({super.key});

  @override
  State<InventoryUpdate> createState() => _InventoryUpdateState();
}

class _InventoryUpdateState extends State<InventoryUpdate> {
  late TextEditingController nameController;
  late TextEditingController hubController;
  late TextEditingController qtyController;
  late List hubList;
  late int qty;
  //[selectHubId, product['상품코드'], product['상품명'], product['재고량']]
  // argument
  var value = Get.arguments ?? "__";

  @override
  void initState() {
    super.initState();
    hubList = ['Central Hub_1', 'North Hub_2', 'South Hub_3'];
    qty = value[3];
    nameController = TextEditingController(text: value[2]);
    hubController = TextEditingController(text: hubList[value[0] - 1]);
    qtyController = TextEditingController(text: qty.toString());
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
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: Row(
                  children: [
                    Text(
                      '재고량 수정',
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
                      '수정',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 130, 10),
                          child: Text(
                            'Hub이름',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17
                            ),
                            ),
                        ),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: hubController,
                            readOnly: true,
                            decoration: const InputDecoration(
                                hintText: 'Hub이름이 비어있습니다.',
                                border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 330, 10),
                            child: Text(
                              '상품이름',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17
                              ),
                              ),
                          ),
                          SizedBox(
                            width: 400,
                            child: TextField(
                              controller: nameController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                  hintText: '상품 이름이 비어있습니다.',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 33, 10, 0),
                      child: IconButton(
                        onPressed: () {
                          qty -= 1;
                          qtyController.text = qty.toString();
                          setState(() {});
                        }, 
                        icon: const Icon(Icons.remove)
                        ),
                    ),
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 150, 10),
                          child: Text(
                            '재고량',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17
                            ),
                            ),
                        ),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: qtyController,
                            readOnly: true,
                            decoration: const InputDecoration(
                                hintText: '재고량이 비어있습니다.',
                                border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 33, 0, 0),
                      child: IconButton(
                        onPressed: () {
                          qty += 1;
                          qtyController.text = qty.toString();
                          setState(() {});
                        }, 
                        style: IconButton.styleFrom(

                        ),
                        icon: const Icon(Icons.add)
                        ),
                    ),
                  ],
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
                      borderRadius: BorderRadius.circular(5)
                    )
                  ),
                  child: const Text('재고량 수정')
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
      "https://fastapi.sumartpick.shop/inventories/hub_qty_update?Product_ID=${value[1]}&QTY=$qty");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];

    setState(() {});
  }
}

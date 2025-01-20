import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumatpick_web/view/Orderpage.dart';

import 'Dashboard.dart';
import 'Productspage.dart';
import 'Userpage.dart';

class Inventorypage extends StatefulWidget {
  const Inventorypage({super.key});

  @override
  State<Inventorypage> createState() => _InventorypageState();
}

class _InventorypageState extends State<Inventorypage> {
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
            )
          ],
        ),
      ),
    );
  }
}

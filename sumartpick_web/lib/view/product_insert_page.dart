import 'package:flutter/material.dart';

class ProductInsertPage extends StatefulWidget {
  const ProductInsertPage({super.key});

  @override
  State<ProductInsertPage> createState() => _ProductInsertPageState();
}

class _ProductInsertPageState extends State<ProductInsertPage> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: '상품 이름을 입력하세요',
                      border: OutlineInputBorder()
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: '상품 이름을 입력하세요',
                      border: OutlineInputBorder()
                    ),
                  ),
                ),
              ],
            )
            ],
          ),
        ),
      ),
    );
  }
}
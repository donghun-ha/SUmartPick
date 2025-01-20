import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumatpick_web/view/Dashboard.dart';
import 'package:sumatpick_web/view/Home.dart';
import 'package:sumatpick_web/view/Userpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Userpage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumatpick_web/firebase_options.dart';
import 'package:sumatpick_web/view/Dashboard.dart';
import 'package:sumatpick_web/view/Home.dart';
import 'package:sumatpick_web/view/Inventorypage.dart';
import 'package:sumatpick_web/view/Orderpage.dart';
import 'package:sumatpick_web/view/Productspage.dart';
import 'package:sumatpick_web/view/Userpage.dart';
import 'package:sumatpick_web/view/product_insert_page.dart';
import 'package:sumatpick_web/view/product_update_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const Productspage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumatpick_web/view/Dashboard.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late TextEditingController idController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    passwordController = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "SUMartpick",
              style: TextStyle(
                fontSize: 110,
              ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(500, 70, 500, 50),
                child: TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    hintText: '아이디를 입력하세요'
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(500, 0, 500, 0),
                child: TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    hintText: '비밀번호를 입력하세요'
                  ),
                  obscureText: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if(idController.text.trim().isEmpty||passwordController.text.trim().isEmpty){
                        Get.snackbar(
                          '경고', 
                          '아이디나 비밀번호를 입력하세요',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.red,
                          colorText: Colors.white
                          );
                      }else if(idController.text.trim() == 'test' && passwordController.text.trim() == 'qwer1234'){
                        idController.text = '';
                        passwordController.text = '';
                        Get.to(const Dashboard());
                      }else{
                        Get.snackbar(
                          '경고', 
                          '아이디나 비밀번호가 일치하지 않습니다.',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.red,
                          colorText: Colors.white
                          );
                      }
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 모서리 둥글기 설정
                  ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20
                      ),
                      )
                    ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumatpick_web/view/Dashboard.dart';

import 'Inventorypage.dart';
import 'Orderpage.dart';
import 'Productspage.dart';
import 'package:http/http.dart' as http;

class Userpage extends StatefulWidget {
  const Userpage({super.key});

  @override
  State<Userpage> createState() => _UserpageState();
}

class _UserpageState extends State<Userpage> {
  late String selectedFilter;
  late TextEditingController searchController;
  late List<String> keys;
  late List data;
  // 임시 데이터 선언
  late List<Map<String, dynamic>> members;
  // 검색 데이터 선언
  late List<Map<String, dynamic>> filteredMembers;

  @override
  void initState() {
    super.initState();
    data = [];
    members = [];
    filteredMembers = [];
    // key
    keys = ["아이디", "로그인방법", "회원명", "이메일", "가입일시"];

    selectedFilter = "아이디";
    searchController = TextEditingController();
  getJSONData();
  }

  getJSONData() async{
    var url = Uri.parse('http://127.0.0.1:8000/users/user_select');
    var response = await http.get(url);
    // print(response.body);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data.addAll(result);
    members = data.map((entry) {
    return Map.fromIterables(keys, entry);
  }).toList();
  filteredMembers = members;
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
                Container(
                    width: 80,
                    height: 30,
                    alignment: Alignment.center,
                    color: const Color(0xffD9D9D9),
                    child: const Text(
                      '회원관리',
                    )),
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
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: Row(
                children: [
                  Text(
                    '회원 정보관리',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // 드롭다운 버튼
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: selectedFilter, // 현재 선택된 값
                        items: ['아이디', '회원명', '로그인방법']
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
                          filterMembers();
                        },
                      ),
                    ),
                    // 검색 버튼
                    ElevatedButton.icon(
                      onPressed: filterMembers,
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
          borderRadius: BorderRadius.circular(15)
          ),
        child: Center(
          child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Text(
            "총 회원 수 : ${filteredMembers.length}명",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17
            ),
            ),
        )
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
                      '회원명',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                      '아이디',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                      '로그인방법',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                      '이메일',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                      '가입일시',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            // 유저 관리 리스트
            Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Container(
                            decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)
                            ),
                            child: ListView.builder(
                              itemCount: filteredMembers.length,
                              itemBuilder: (context, index) {
                                final member = filteredMembers[index]; // 검색결과 member에 저장
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${member['회원명']}",
                                          textAlign: TextAlign.center,
                                          ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${member['아이디']}",
                                          textAlign: TextAlign.center,
                                          ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${member['로그인방법']}",
                                          textAlign: TextAlign.center,
                                          ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${member['이메일']}",
                                          textAlign: TextAlign.center,
                                          ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${member['가입일시']}",
                                          textAlign: TextAlign.center,
                                          ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              ),
                          ),
                        )
                        ),
          ],
        ),
      ),
    );
  }
  // -----Function-----

  // dropdown에서 선택한 검색어로 검색
  filterMembers(){
    String query = searchController.text.trim();
    if (query.isEmpty){
      filteredMembers = members; // 검색어 없으면 전체 표시
    } else {
      filteredMembers = members.where((member) {
        return member[selectedFilter].toString().contains(query);
      }).toList();
    }
    setState(() {});
  }
  // 검색창 초기화
  resetFilter(){
    searchController.clear();
    filteredMembers = members; // 지금은 초기화 하면 임시데이터를 넣지만 DB가 있을땐 초기 DB데이터를 넣어야 함
    setState(() {});
  }
}

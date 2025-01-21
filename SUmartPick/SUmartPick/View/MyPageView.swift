//
//  MyPageView.swift
//  SUmartPick
//
//  Created by aeong on 1/20/25.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var authState: AuthenticationState // 인증 상태 관리 객체
    @State private var showLogoutConfirmation = false // 로그아웃 확인 Alert 표시 여부

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // 유저 이름 영역
                HStack {
                    Text(authState.userFullName ?? "UserFullName")
                        .font(.title)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 12)

                Divider()

                // 아이콘 3개 (주문목록 / 찜한상품 / 최근본상품)
                HStack {
                    Spacer()

                    // 주문목록 버튼
                    NavigationLink(destination: Text("주문목록 뷰")) {
                        VStack {
                            Image(systemName: "doc.text.fill")
                                .font(.title)
                                .foregroundColor(.indigo)
                                .padding(.bottom, 4)
                            Text("주문목록")
                                .font(.caption)
                                .foregroundColor(.indigo)
                        }
                    }

                    Spacer()

                    // 찜한상품 버튼
                    NavigationLink(destination: Text("찜한상품 뷰")) {
                        VStack {
                            Image(systemName: "heart.fill")
                                .font(.title)
                                .foregroundColor(.indigo)
                                .padding(.bottom, 4)
                            Text("찜한상품")
                                .font(.caption)
                                .foregroundColor(.indigo)
                        }
                    }

                    Spacer()

                    // 최근본상품 버튼
                    NavigationLink(destination: Text("최근본상품 뷰")) {
                        VStack {
                            Image(systemName: "clock.fill")
                                .font(.title)
                                .foregroundColor(.indigo)
                                .padding(.bottom, 4)
                            Text("최근본상품")
                                .font(.caption)
                                .foregroundColor(.indigo)
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, 16)

                Divider()

                // 목록 영역 (주문목록 / 취소·반품·교환목록 / 리뷰 관리)
                NavigationLink(destination: Text("주문목록 뷰")) {
                    rowItem(title: "주문목록", icon: "doc.text.fill")
                        .padding(.vertical, 4)
                }
                Divider()

                NavigationLink(destination: Text("취소·반품·교환목록 뷰")) {
                    rowItem(title: "취소·반품·교환목록", icon: "arrow.uturn.backward.circle.fill")
                        .padding(.vertical, 4)
                }
                Divider()

                NavigationLink(destination: Text("리뷰 관리 뷰")) {
                    rowItem(title: "리뷰 관리", icon: "star.fill")
                        .padding(.vertical, 4)
                }
                Divider()

                Spacer()

                // 로그아웃 텍스트
                Text("로그아웃")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .underline()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
                    .onTapGesture {
                        showLogoutConfirmation = true // Alert 표시
                    }
                    .alert("로그아웃 하시겠습니까?", isPresented: $showLogoutConfirmation) {
                        Button("취소", role: .cancel) {}
                        Button("로그아웃", role: .destructive) {
                            authState.logout() // 로그아웃 로직 호출
                        }
                    }
            }
            .padding(.horizontal, 16)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // 각 행을 간단히 구성하는 뷰
    func rowItem(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon) // 아이콘 추가
                .font(.title3)
                .foregroundColor(.black)
                .padding(.trailing, 8) // 아이콘과 텍스트 간 간격 조정
            Text(title)
                .foregroundColor(.black) // 텍스트 색상 설정
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
    }
}

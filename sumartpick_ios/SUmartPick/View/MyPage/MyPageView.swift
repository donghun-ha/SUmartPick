//
//  MyPageView.swift
//  SUmartPick
//
//  Created by aeong on 1/20/25.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var authState: AuthenticationState
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                // SafeArea를 무시하고 화면 전체를 가로지르는 Divider
                VStack(spacing: 56) {
                    Color.clear
                        .frame(height: 24)
                    Divider()
                        .frame(height: 1)
                        .ignoresSafeArea(edges: .horizontal)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 0) {
                    // (1) 유저 이름 + 오른쪽 화살표 → 주소지 관리 화면 링크
                    NavigationLink(destination: AddressManagementView()) {
                        HStack {
                            Text(authState.userFullName ?? "UserFullName")
                                .font(.title)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 24)
                    }

                    // (2) 주문 목록
                    NavigationLink(destination: OrderListView()) {
                        rowItem(title: "주문목록", icon: "doc.text.fill")
                    }
                    Divider()

                    // (3) 최근 본 상품
                    NavigationLink(destination: Text("최근본상품 뷰")) {
                        rowItem(title: "최근본상품", icon: "clock.fill")
                    }
                    Divider()

                    // (4) 취소·반품·교환 목록
                    NavigationLink(destination: RefundExchangeListView()) {
                        rowItem(title: "취소·반품·교환목록", icon: "arrow.uturn.backward.circle.fill")
                    }
                    Divider()

                    // (5) 리뷰 관리
                    NavigationLink(destination: ReviewManagementView()) {
                        rowItem(title: "리뷰 관리", icon: "star.fill")
                    }
                    Divider()

                    Spacer()

                    // 로그아웃
                    Text("로그아웃")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .underline()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                        .onTapGesture {
                            showLogoutConfirmation = true
                        }
                        .alert("로그아웃 하시겠습니까?", isPresented: $showLogoutConfirmation) {
                            Button("취소", role: .cancel) {}
                            Button("로그아웃", role: .destructive) {
                                authState.logout()
                            }
                        }
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // 기존 rowItem 함수는 그대로 사용
    func rowItem(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.black)
                .padding(.trailing, 8)
            Text(title)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical)
    }
}

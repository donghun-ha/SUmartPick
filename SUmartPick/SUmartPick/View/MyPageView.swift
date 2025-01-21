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
            VStack(alignment: .leading, spacing: 0) {
                // 유저 이름 표시
                HStack {
                    Text(authState.userFullName ?? "UserFullName")
                        .font(.title)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 12)

                Divider()

                // 예시 버튼들
                HStack {
                    Spacer()
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

                NavigationLink(destination: Text("취소·반품·교환목록 뷰")) {
                    rowItem(title: "취소·반품·교환목록", icon: "arrow.uturn.backward.circle.fill")
                }
                Divider()

                NavigationLink(destination: Text("리뷰 관리 뷰")) {
                    rowItem(title: "리뷰 관리", icon: "star.fill")
                }
                Divider()

                // 간편 로그인 등록 버튼
                NavigationLink(destination: EasyLoginRegisterView()) {
                    rowItem(title: "간편 로그인 등록", icon: "person.badge.plus")
                }
                Divider()

                Spacer()

                // 로그아웃
                Text("로그아웃")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .underline()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
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
            .padding(.horizontal, 16)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // 공용 행 레이아웃
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
        .padding(.vertical, 12)
    }
}

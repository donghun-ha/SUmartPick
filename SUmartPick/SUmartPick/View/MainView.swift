//
//  MainView.swift
//  SUmartPick
//
//  Created by aeong on 1/10/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authState: AuthenticationState // 인증 상태 공유 객체
    @State private var showLogoutAlert = false // 로그아웃 확인 경고창 상태

    var body: some View {
        VStack {
            Text("환영합니다!")
                .font(.largeTitle)
                .padding()

            Button(action: {
                showLogoutAlert = true // 로그아웃 경고창 표시
            }) {
                Text("로그아웃")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .alert("로그아웃", isPresented: $showLogoutAlert) {
                Button("취소", role: .cancel) {}
                Button("로그아웃", role: .destructive) {
                    performLogout()
                }
            } message: {
                Text("정말로 로그아웃 하시겠습니까?")
            }
        }
        .padding()
    }

    func performLogout() {
        withAnimation {
            authState.isAuthenticated = false // 인증 상태 변경
            authState.userIdentifier = nil
        }
        print("로그아웃 완료")
    }
}

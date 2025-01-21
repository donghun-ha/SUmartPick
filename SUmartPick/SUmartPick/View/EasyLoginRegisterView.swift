//
//  EasyLoginRegisterView.swift
//  SUmartPick
//
//  Created by aeong on 1/21/25.
//

import SwiftUI

struct EasyLoginRegisterView: View {
    @EnvironmentObject var authState: AuthenticationState
    @Environment(\.dismiss) private var dismiss // 뒤로 이동(dismiss) 기능
    @State private var showSuccessMessage = false         // 등록 성공시 메시지
    @State private var showRegisterConfirmation = false   // 등록 전 확인 다이얼로그

    var body: some View {
        VStack {
            Text("간편 로그인 등록하기")
                .font(.headline)
                .padding()

            Text("""
            지금 로그인 중인 계정을 간편 로그인으로 등록합니다.
            Face ID 또는 비밀번호로 빠른 로그인을 할 수 있게 됩니다.
            """)
            .multilineTextAlignment(.center)
            .padding()

            Button {
                // 1) 등록 버튼을 누르면, 먼저 확인 다이얼로그를 띄움
                showRegisterConfirmation = true
            } label: {
                Text("등록하기")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .padding()
        .confirmationDialog(
            "간편 로그인 등록", // 다이얼로그 제목
            isPresented: $showRegisterConfirmation,
            titleVisibility: .visible
        ) {
            Button("등록") {
                // 2) 사용자가 "등록"을 선택하면 실제 등록 로직 수행
                Task {
                    do {
                        try await authState.registerEasyLogin()
                        showSuccessMessage = true
                    } catch {
                        authState.showError(message: error.localizedDescription)
                    }
                }
            }
            Button("취소", role: .cancel) { /* 아무것도 하지 않음 */ }
        } message: {
            Text("정말 간편 로그인으로 등록하시겠습니까?")
        }
        .alert("등록 성공", isPresented: $showSuccessMessage) {
            // 3) 등록 성공 메시지 → "확인"을 누르면 뷰 닫기(dismiss)
            Button("확인") {
                dismiss() // 네비게이션 뒤로 이동
            }
        } message: {
            Text("간편 로그인이 성공적으로 등록되었습니다.")
        }
        .alert("오류 발생", isPresented: $authState.showingErrorAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(authState.errorMessage)
        }
    }
}

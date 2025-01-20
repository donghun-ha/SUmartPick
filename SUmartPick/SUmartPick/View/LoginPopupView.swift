//
//  LoginPopupView.swift
//  SUmartPick
//
//  Created by aeong on 1/14/25.
//

import AuthenticationServices
import GoogleSignInSwift
import SwiftUI

struct LoginPopupView: View {
    @EnvironmentObject var authState: AuthenticationState

    var body: some View {
        VStack {
            Text("로그인을 진행하세요")
                .font(.headline)
                .padding()

            // Apple 로그인 버튼
            SignInWithAppleButton(
                onRequest: authState.configureSignInWithApple, // ViewModel 메서드
                onCompletion: authState.handleSignInWithAppleCompletionForPopup
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(10)
            .padding()

            // Google 로그인 버튼
            GoogleSignInButton {
                authState.handleGoogleSignInForPopup() // ViewModel 메서드
            }
            .frame(height: 50)
            .cornerRadius(10)
            .padding()

            Spacer()
        }
        .padding()
        .alert("오류 발생", isPresented: $authState.showingErrorAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(authState.errorMessage)
        }
    }
}

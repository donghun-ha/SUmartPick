//
//  ContentView.swift
//  SUmartPick
//
//  Created by aeong on 1/10/25.
//

import AuthenticationServices
import GoogleSignInSwift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authState: AuthenticationState

    var body: some View {
        Group {
            if authState.isAuthenticated {
                // 이미 로그인된 상태 → 메인 화면
                MainView()
                    .transition(.slide)
            } else {
                // 미로그인 상태 → 로그인 화면
                NavigationStack {
                    VStack {
                        Text("로그인")
                            .font(.headline)
                            .padding()

                        // Apple 로그인
                        SignInWithAppleButton(
                            onRequest: authState.configureSignInWithApple,
                            onCompletion: { result in
                                authState.handleSignInWithAppleCompletion(result, isPopup: false)
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(10)
                        .padding()

                        // Google 로그인
                        GoogleSignInButton {
                            Task {
                                await authState.handleGoogleSignIn(isPopup: false)
                            }
                        }
                        .frame(height: 50)
                        .cornerRadius(10)
                        .padding()

                        // 간편 로그인 버튼 (이미 등록되어 있는 계정으로 Face ID/비밀번호 인증 후 로그인)
                        Button {
                            authState.performEasyLoginWithAuthentication()
                        } label: {
                            Text("간편 로그인")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()

                        if let userID = authState.userIdentifier {
                            Text("환영합니다, \(userID)!")
                                .font(.headline)
                                .padding(.top, 20)
                        }
                    }
                    .padding()
                    .alert("오류 발생", isPresented: $authState.showingErrorAlert) {
                        Button("확인", role: .cancel) {}
                    } message: {
                        Text(authState.errorMessage)
                    }
                }
                .transition(.slide)
            }
        }
        .onAppear {
            authState.autoLogin()
        }
        .animation(.easeInOut, value: authState.isAuthenticated)
    }
}

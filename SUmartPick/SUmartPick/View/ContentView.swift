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
    @State private var showingLoginPopup = false // 팝업 화면 표시 여부 (View 전용)

    var body: some View {
        Group {
            if authState.isAuthenticated {
                // 로그인 성공 시 메인 화면 이동
                MainView()
                    .onAppear {
                        showingLoginPopup = false
                    }
                    .transition(.slide) // 메인 화면 전환 애니메이션
            } else {
                NavigationStack {
                    VStack {
                        Text("로그인")
                            .font(.headline)
                            .padding()

                        // Apple 로그인 버튼
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

                        // Google 로그인 버튼
                        GoogleSignInButton {
                            Task {
                                await authState.handleGoogleSignIn(isPopup: false)
                            }
                        }
                        .frame(height: 50)
                        .cornerRadius(10)
                        .padding()

                        // 간편 로그인 등록 버튼
                        Button {
                            showingLoginPopup = true
                        } label: {
                            Text("간편 로그인 등록")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        .sheet(isPresented: $showingLoginPopup) {
                            LoginPopupView() // 팝업 표시
                        }

                        // 간편 로그인 버튼
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
        .animation(.easeInOut, value: authState.isAuthenticated)
    }
}

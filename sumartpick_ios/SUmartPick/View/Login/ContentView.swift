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

    // ✅ SwiftUI가 자동으로 View를 추론할 수 있도록 @ViewBuilder 사용
    @ViewBuilder
    var body: some View {
        if authState.isAuthenticated {
            MainView() // 🔥 Group 제거 후 바로 MainView() 반환
                .transition(.slide)
        } else {
            NavigationStack {
                VStack {
                    Spacer()
                    
                    // 📌 로고
                    Image("sumartpick_Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .padding(.bottom, 40)

                    Spacer()
                    
                    // 📌 Apple 로그인 버튼
                    SignInWithAppleButton(
                        onRequest: { request in
                            authState.configureSignInWithApple(request)
                        },
                        onCompletion: { result in
                            authState.handleSignInWithAppleCompletion(result, isPopup: false)
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)

                    // 📌 Google 로그인 버튼
                    Button(action: {
                        Task {
                            await authState.handleGoogleSignIn(isPopup: false)
                        }
                    }) {
                        HStack {
                            Image("googleLogo") // 구글 아이콘
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("구글로 로그인")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1) // 테두리 추가
                        )
                    }
                    .padding(.horizontal, 30)

                    // 📌 간편 로그인 버튼 (Face ID / 비밀번호 인증)
                    Button(action: {
                        authState.performEasyLoginWithAuthentication()
                    }) {
                        HStack {
                            Image(systemName: "lock.fill") // 자물쇠 아이콘 추가
                                .font(.title2)
                            Text("간편 로그인")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)

                    if let userID = authState.userIdentifier {
                        Text("환영합니다, \(userID)!")
                            .font(.headline)
                            .padding(.top, 20)
                    }

                    Spacer()
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
}

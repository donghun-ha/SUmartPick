//
//  ContentView.swift
//  SUmartPick
//
//  Created by aeong on 1/10/25.
//

import AuthenticationServices
import Firebase
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authState: AuthenticationState // 인증 상태 공유 객체

    var body: some View {
        if authState.isAuthenticated {
            MainView() // 로그인 후에는 MainView로 이동
        } else {
            NavigationStack {
                VStack {
                    Text("Apple 로그인 예제")
                        .font(.headline)
                        .padding()

                    SignInWithAppleButton(
                        onRequest: configureSignInWithApple,
                        onCompletion: handleSignInWithAppleCompletion
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(10)
                    .padding()

                    if let userID = authState.userIdentifier {
                        Text("환영합니다, \(userID)!")
                            .font(.headline)
                            .padding(.top, 20)
                    }
                }
                .padding()
            }
        }
    }

    func configureSignInWithApple(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
            case .success(let auth):
                if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                    authState.userIdentifier = appleIDCredential.user
                    authState.isAuthenticated = true
                    print("Apple 로그인 성공 - 사용자 ID: \(appleIDCredential.user)")

                    // 이메일과 이름 (최초 로그인 시에만 제공)
                    let email = appleIDCredential.email
                    let fullName = appleIDCredential.fullName

                    // 데이터베이스 저장
                    saveUserToDatabase(
                        userIdentifier: appleIDCredential.user,
                        email: email,
                        fullName: [
                            fullName?.givenName,
                            fullName?.familyName
                        ].compactMap { $0 }.joined(separator: " ")
                    )
                }
            case .failure(let error):
                print("Apple 로그인 실패: \(error.localizedDescription)")
        }
    }

    func saveUserToDatabase(userIdentifier: String, email: String?, fullName: String?) {
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(userIdentifier)

        userDoc.getDocument { document, error in
            if let document = document, document.exists {
                print("User already exists in database.")
            } else {
                let userData: [String: Any] = [
                    "userIdentifier": userIdentifier,
                    "email": email ?? "",
                    "fullName": fullName ?? "",
                    "createdAt": Timestamp(date: Date())
                ]

                userDoc.setData(userData) { error in
                    if let error = error {
                        print("Error saving user to database: \(error.localizedDescription)")
                    } else {
                        print("User saved successfully!")
                    }
                }
            }
        }
    }
}

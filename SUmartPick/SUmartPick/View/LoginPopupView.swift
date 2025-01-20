//
//  LoginPopupView.swift
//  SUmartPick
//
//  Created by aeong on 1/14/25.
//

import AuthenticationServices
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import RealmSwift
import SwiftUI

struct LoginPopupView: View {
    @EnvironmentObject var authState: AuthenticationState

    @State private var showingErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            Text("로그인을 진행하세요")
                .font(.headline)
                .padding()

            // Apple 로그인 버튼
            SignInWithAppleButton(
                onRequest: configureSignInWithApple,
                onCompletion: handleSignInWithAppleCompletion
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(10)
            .padding()

            // Google 로그인 버튼
            GoogleSignInButton {
                handleGoogleSignIn()
            }
            .frame(height: 50)
            .cornerRadius(10)
            .padding()

            Spacer()
        }
        .padding()
        .alert("오류 발생", isPresented: $showingErrorAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // Apple 로그인 요청 구성
    func configureSignInWithApple(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    // Apple 로그인 성공 처리
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
            case .success(let auth):
                if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                    authState.userIdentifier = appleIDCredential.user
                    print("Apple 로그인 성공 - 사용자 ID: \(appleIDCredential.user)")

                    let email = appleIDCredential.email
                    let fullName = [
                        appleIDCredential.fullName?.givenName,
                        appleIDCredential.fullName?.familyName
                    ]
                    .compactMap { $0 }
                    .joined(separator: " ")

                    saveUserToDatabase(
                        userIdentifier: appleIDCredential.user,
                        email: email,
                        fullName: fullName
                    )

                    registerEasyLogin()
                }
            case .failure(let error):
                showError(message: "Apple 로그인 실패: \(error.localizedDescription)")
        }
    }

    // Google 로그인 처리
    func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            showError(message: "Google 클라이언트 ID를 찾을 수 없습니다.")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            showError(message: "Root view controller를 찾을 수 없습니다.")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { user, error in
            if let error = error {
                showError(message: "Google 로그인 실패: \(error.localizedDescription)")
                return
            }

            guard let user = user?.user else { return }

            let userIdentifier = user.userID ?? "Unknown"
            let email = user.profile?.email
            let fullName = "\(user.profile?.givenName ?? "") \(user.profile?.familyName ?? "")"

            authState.userIdentifier = userIdentifier

            saveUserToDatabase(
                userIdentifier: userIdentifier,
                email: email,
                fullName: fullName
            )

            registerEasyLogin()
        }
    }

    // 사용자 정보를 서버(MySQL)에 저장
    func saveUserToDatabase(userIdentifier: String, email: String?, fullName: String?) {
        guard let url = URL(string: "http://127.0.0.1:8000/users") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let userData: [String: Any] = [
            "User_ID": userIdentifier,
            "auth_provider": "Google",
            "name": fullName ?? "Unknown",
            "email": email ?? "Unknown"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: [])
        } catch {
            showError(message: "데이터 직렬화 오류: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                showError(message: "사용자 저장 실패: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                showError(message: "서버에서 잘못된 응답을 받았습니다.")
                return
            }

            print("사용자 정보가 MySQL에 성공적으로 저장되었습니다.")
        }
        task.resume()
    }

    // 사용자 정보를 Realm에 저장
    func registerEasyLogin() {
        guard let userIdentifier = authState.userIdentifier else { return }

        Task {
            do {
                // 서버 요청 및 응답 처리
                guard let url = URL(string: "http://127.0.0.1:8000/users/\(userIdentifier)") else { return }
                let (data, response) = try await URLSession.shared.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    showError(message: "서버에서 잘못된 응답을 받았습니다.")
                    return
                }

                // JSON 데이터를 파싱
                if let userData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    saveAccountToRealm(userIdentifier: userIdentifier, userData: userData)
                    authState.isAuthenticated = true // 메인 스레드에서 자동 업데이트
                } else {
                    showError(message: "사용자 정보를 찾을 수 없습니다.")
                }
            } catch {
                // 오류 처리
                showError(message: "서버에서 사용자 정보를 가져오는 중 오류 발생: \(error.localizedDescription)")
            }
        }
    }

    // Realm에 사용자 계정 정보 저장
    func saveAccountToRealm(userIdentifier: String, userData: [String: Any]) {
        do {
            let realm = try Realm()
            let account = EasyLoginAccount()
            account.id = userIdentifier
            account.email = userData["email"] as? String ?? ""
            account.fullName = userData["name"] as? String ?? ""

            try realm.write {
                realm.add(account, update: .modified)
            }
            print("계정 정보를 Realm에 저장했습니다.")
        } catch {
            showError(message: "Realm에 계정 정보를 저장하는 중 오류 발생: \(error.localizedDescription)")
        }
    }

    // 오류 메시지 표시
    func showError(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showingErrorAlert = true
        }
    }
}

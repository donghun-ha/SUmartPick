//
//  AuthenticationState.swift
//  SUmartPick
//
//  Created by aeong on 1/13/25.
//  인증 관련 ViewModel
//

import AuthenticationServices
import Combine
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import LocalAuthentication
import RealmSwift
import SwiftUI

// 로그인 공급자를 구분하기 위한 enum
enum AuthProvider: String {
    case apple = "Apple"
    case google = "Google"
}

@MainActor // 모든 메서드가 메인 스레드에서 실행되도록 보장
class AuthenticationState: ObservableObject {
    @Published var isAuthenticated: Bool = false // 로그인 성공 여부
    @Published var userIdentifier: String? = nil // 로그인된 사용자 식별자
    @Published var showingErrorAlert = false // 오류 Alert 노출 여부
    @Published var errorMessage = "" // 오류 메시지

    // Apple 로그인 요청 시 설정
    func configureSignInWithApple(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    // Apple 로그인 결과 처리 (ContentView용)
    func handleSignInWithAppleCompletionForContentView(_ result: Result<ASAuthorization, Error>) {
        switch result {
            case .success(let auth):
                if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                    // 사용자 식별자 및 인증 상태 설정
                    self.userIdentifier = appleIDCredential.user
                    self.isAuthenticated = true

                    let email = appleIDCredential.email
                    let fullName = [
                        appleIDCredential.fullName?.givenName,
                        appleIDCredential.fullName?.familyName
                    ]
                    .compactMap { $0 }
                    .joined(separator: " ")

                    // 서버에 사용자 정보 저장 (로그인 공급자: Apple)
                    self.saveUserToDatabase(
                        userIdentifier: appleIDCredential.user,
                        email: email,
                        fullName: fullName,
                        provider: .apple
                    )
                }
            case .failure(let error):
                self.errorMessage = "Apple 로그인 실패: \(error.localizedDescription)"
                self.showingErrorAlert = true
        }
    }

    // Apple 로그인 결과 처리 (LoginPopupView용)
    func handleSignInWithAppleCompletionForPopup(_ result: Result<ASAuthorization, Error>) {
        switch result {
            case .success(let auth):
                if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                    // 사용자 식별자 설정
                    self.userIdentifier = appleIDCredential.user

                    let email = appleIDCredential.email
                    let fullName = [
                        appleIDCredential.fullName?.givenName,
                        appleIDCredential.fullName?.familyName
                    ]
                    .compactMap { $0 }
                    .joined(separator: " ")

                    // 서버에 사용자 정보 저장 (로그인 공급자: Apple)
                    self.saveUserToDatabase(
                        userIdentifier: appleIDCredential.user,
                        email: email,
                        fullName: fullName,
                        provider: .apple
                    )

                    // 팝업에서 Apple 로그인 시도 후 -> 간편로그인 등록
                    self.registerEasyLogin()
                }
            case .failure(let error):
                self.showError(message: "Apple 로그인 실패: \(error.localizedDescription)")
        }
    }

    // Google 로그인 진행 (ContentView용)
    func handleGoogleSignInForContentView() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.errorMessage = "Google 클라이언트 ID를 찾을 수 없습니다."
            self.showingErrorAlert = true
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            self.showError(message: "Root view controller를 찾을 수 없습니다.")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { user, error in
            if let error = error {
                self.showError(message: "Google 로그인 실패: \(error.localizedDescription)")
                return
            }

            guard let user = user?.user else { return }

            let userIdentifier = user.userID ?? "Unknown"
            let email = user.profile?.email
            let fullName = "\(user.profile?.givenName ?? "") \(user.profile?.familyName ?? "")"

            // 사용자 식별자 및 인증 상태 설정
            self.userIdentifier = userIdentifier
            self.isAuthenticated = true

            // 서버에 사용자 정보 저장 (로그인 공급자: Google)
            self.saveUserToDatabase(
                userIdentifier: userIdentifier,
                email: email,
                fullName: fullName,
                provider: .google
            )
        }
    }

    // Google 로그인 진행 (LoginPopupView용)
    func handleGoogleSignInForPopup() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.showError(message: "Google 클라이언트 ID를 찾을 수 없습니다.")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            self.showError(message: "Root view controller를 찾을 수 없습니다.")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { user, error in
            if let error = error {
                self.showError(message: "Google 로그인 실패: \(error.localizedDescription)")
                return
            }

            guard let user = user?.user else { return }

            let userIdentifier = user.userID ?? "Unknown"
            let email = user.profile?.email
            let fullName = "\(user.profile?.givenName ?? "") \(user.profile?.familyName ?? "")"

            self.userIdentifier = userIdentifier

            // 서버에 사용자 정보 저장 (로그인 공급자: Google)
            self.saveUserToDatabase(
                userIdentifier: userIdentifier,
                email: email,
                fullName: fullName,
                provider: .google
            )

            // 팝업 -> Google 로그인 후에도 간편로그인 등록
            self.registerEasyLogin()
        }
    }

    // 사용자 정보를 서버(MySQL)에 저장
    func saveUserToDatabase(
        userIdentifier: String,
        email: String?,
        fullName: String?,
        provider: AuthProvider
    ) {
        guard let url = URL(string: "http://127.0.0.1:8000/users") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let userData: [String: Any] = [
            "User_ID": userIdentifier,
            "auth_provider": provider.rawValue,
            "name": fullName ?? "Unknown",
            "email": email ?? "Unknown"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: [])
        } catch {
            Task {
                self.showError(message: "데이터 직렬화 오류: \(error.localizedDescription)")
            }
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                Task {
                    await self.showError(message: "사용자 저장 실패: \(error.localizedDescription)")
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 422 {
                    Task {
                        await self.showError(message: "서버가 요청 데이터를 처리할 수 없습니다. 입력값을 확인해주세요.")
                    }
                    return
                }

                if httpResponse.statusCode != 200 {
                    Task {
                        await self.showError(message: "서버에서 잘못된 응답을 받았습니다: \(httpResponse.statusCode)")
                    }
                    return
                }
            }

            if let data = data {
                print("서버 응답 데이터: \(String(data: data, encoding: .utf8) ?? "nil")")
            }
        }
        task.resume()
    }

    // Realm에 계정 정보 저장
    func saveAccountToRealm(userIdentifier: String, email: String?, fullName: String?) {
        do {
            let realm = try Realm()
            let account = EasyLoginAccount()
            account.id = userIdentifier
            account.email = email ?? "Unknown"
            account.fullName = fullName ?? "Unknown"

            try realm.write {
                realm.add(account, update: .modified)
            }
            print("계정 정보를 Realm에 저장했습니다.")
        } catch {
            self.showError(message: "Realm에 계정 정보를 저장하는 중 오류 발생: \(error.localizedDescription)")
        }
    }

    // 간편 로그인을 위해 시스템 인증(Face ID/비밀번호) 요청
    func performEasyLoginWithAuthentication() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "간편 로그인을 위해 인증해주세요."
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                if success {
                    self.performEasyLogin()
                } else {
                    self.showError(message: "인증 실패: \(authenticationError?.localizedDescription ?? "알 수 없는 오류")")
                }
            }
        } else {
            self.showError(message: "Face ID 또는 비밀번호를 사용할 수 없습니다.")
        }
    }

    // Face ID/비밀번호 인증 성공 시, Realm에 저장된 계정으로 간편로그인
    func performEasyLogin() {
        do {
            let realm = try Realm()
            if let account = realm.objects(EasyLoginAccount.self).first {
                print("간편 로그인 계정 불러오기 성공: \(account.email)")

                self.validateAccountWithServer(userIdentifier: account.id) { isValid in
                    if isValid {
                        self.userIdentifier = account.id
                        self.isAuthenticated = true
                    } else {
                        self.showError(message: "간편 로그인 계정이 서버에서 확인되지 않았습니다. 다시 등록해주세요.")
                    }
                }
            } else {
                self.showError(message: "저장된 간편 로그인 계정을 찾을 수 없습니다.")
            }
        } catch {
            self.showError(message: "Realm에서 계정을 불러오는 중 오류 발생: \(error.localizedDescription)")
        }
    }

    // 서버로 사용자 계정 존재 여부 대조
    func validateAccountWithServer(userIdentifier: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/users/\(userIdentifier)") else {
            print("잘못된 URL: \(userIdentifier)")
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("서버 대조 실패: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("서버 응답을 읽을 수 없습니다.")
                completion(false)
                return
            }

            if httpResponse.statusCode == 404 {
                print("서버에서 계정을 찾지 못함 (404). 사용자 ID: \(userIdentifier)")
                completion(false)
                return
            }

            if httpResponse.statusCode != 200 {
                print("서버에서 잘못된 응답을 받음. 상태 코드: \(httpResponse.statusCode)")
                completion(false)
                return
            }

            guard let data = data else {
                print("서버 응답 데이터가 없습니다.")
                completion(false)
                return
            }

            do {
                if try JSONSerialization.jsonObject(with: data, options: []) is [String: Any] {
                    print("서버에서 사용자 계정 확인 성공.")
                    completion(true)
                } else {
                    print("서버 응답 데이터를 파싱할 수 없습니다.")
                    completion(false)
                }
            } catch {
                print("데이터 처리 중 오류 발생: \(error.localizedDescription)")
                completion(false)
            }
        }
        task.resume()
    }

    // 간편 로그인 등록(서버 조회 후 Realm 저장)
    func registerEasyLogin() {
        guard let userIdentifier = self.userIdentifier else { return }

        Task {
            do {
                guard let url = URL(string: "http://127.0.0.1:8000/users/\(userIdentifier)") else { return }
                let (data, response) = try await URLSession.shared.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    self.showError(message: "서버에서 잘못된 응답을 받았습니다.")
                    return
                }

                // JSON 파싱
                if let userData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    self.saveAccountToRealm(
                        userIdentifier: userIdentifier,
                        email: userData["email"] as? String,
                        fullName: userData["name"] as? String
                    )
                    // 팝업에서의 로직상, 여기서 인증 완료 처리
                    self.isAuthenticated = true
                } else {
                    self.showError(message: "사용자 정보를 찾을 수 없습니다.")
                }
            } catch {
                self.showError(message: "서버에서 사용자 정보를 가져오는 중 오류 발생: \(error.localizedDescription)")
            }
        }
    }

    // 에러 처리
    func showError(message: String) {
        self.errorMessage = message
        self.showingErrorAlert = true
    }
}

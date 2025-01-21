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
enum AuthProvider: String, Codable {
    case apple = "Apple"
    case google = "Google"
}

// 에러 메시지 정의
enum AuthenticationError: LocalizedError {
    case missingClientID
    case rootViewControllerNotFound
    case invalidURL
    case serializationError
    case serverError(statusCode: Int)
    case noData
    case parsingError
    case realmError(Error)
    case authenticationFailed(String)

    var errorDescription: String? {
        switch self {
            case .missingClientID:
                return "Google 클라이언트 ID를 찾을 수 없습니다."
            case .rootViewControllerNotFound:
                return "Root view controller를 찾을 수 없습니다."
            case .invalidURL:
                return "잘못된 URL입니다."
            case .serializationError:
                return "데이터 직렬화 오류가 발생했습니다."
            case .serverError(let statusCode):
                return "서버에서 잘못된 응답을 받았습니다: \(statusCode)"
            case .noData:
                return "서버 응답 데이터가 없습니다."
            case .parsingError:
                return "서버 응답 데이터를 파싱할 수 없습니다."
            case .realmError(let error):
                return "Realm에 계정 정보를 저장하는 중 오류 발생: \(error.localizedDescription)"
            case .authenticationFailed(let message):
                return message
        }
    }
}

@MainActor // 모든 메서드가 메인 스레드에서 실행되도록 보장
class AuthenticationState: ObservableObject {
    @Published var isAuthenticated: Bool = false // 로그인 성공 여부
    @Published var userIdentifier: String? = nil // 로그인된 사용자 식별자
    @Published var userFullName: String? = nil // 로그인된 사용자 이름
    @Published var showingErrorAlert = false // 오류 Alert 노출 여부
    @Published var errorMessage = "" // 오류 메시지

    // Apple 로그인 요청 시 설정
    func configureSignInWithApple(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    // Apple 로그인 결과 처리
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>, isPopup: Bool = false) {
        switch result {
            case .success(let auth):
                guard let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential else {
                    self.showError(message: "Apple 로그인 인증 정보가 유효하지 않습니다.")
                    return
                }

                // 사용자 식별자 설정
                self.userIdentifier = appleIDCredential.user

                // 사용자 이름과 이메일 추출
                let email = appleIDCredential.email
                let fullName = [
                    appleIDCredential.fullName?.givenName,
                    appleIDCredential.fullName?.familyName
                ]
                .compactMap { $0 }
                .joined(separator: " ")

                // 사용자 이름 업데이트
                self.userFullName = fullName

                Task {
                    do {
                        try await self.saveUserToDatabase(
                            userIdentifier: appleIDCredential.user,
                            email: email,
                            fullName: fullName,
                            provider: .apple
                        )

                        if isPopup {
                            try await self.registerEasyLogin()
                        }

                        // 로그인 성공 상태 업데이트
                        self.isAuthenticated = true
                    } catch {
                        self.showError(message: error.localizedDescription)
                    }
                }

            case .failure(let error):
                self.showError(message: "Apple 로그인 실패: \(error.localizedDescription)")
        }
    }

    // Google 로그인 진행
    func handleGoogleSignIn(isPopup: Bool = false) async {
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw AuthenticationError.missingClientID
            }

            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController
            else {
                throw AuthenticationError.rootViewControllerNotFound
            }

            let user = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController).user

            guard let userID = user.userID else {
                throw AuthenticationError.authenticationFailed("Google 사용자 ID를 가져올 수 없습니다.")
            }

            let email = user.profile?.email
            let fullName = "\(user.profile?.givenName ?? "") \(user.profile?.familyName ?? "")"

            // 사용자 식별자, 이름 및 인증 상태 설정
            self.userIdentifier = userID
            self.userFullName = fullName
            self.isAuthenticated = true

            // 사용자 정보를 서버에 저장
            try await self.saveUserToDatabase(
                userIdentifier: userID,
                email: email,
                fullName: fullName,
                provider: .google
            )

            if isPopup {
                try await self.registerEasyLogin()
            }

        } catch {
            self.showError(message: error.localizedDescription)
        }
    }

    // 사용자 정보를 서버(MySQL)에 저장
    func saveUserToDatabase(userIdentifier: String, email: String?, fullName: String?, provider: AuthProvider) async throws {
        guard let url = URL(string: "http://127.0.0.1:8000/users") else {
            throw AuthenticationError.invalidURL
        }

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
            throw AuthenticationError.serializationError
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.serverError(statusCode: -1)
        }

        switch httpResponse.statusCode {
            case 200:
                // 성공적으로 저장됨
                if let responseData = String(data: data, encoding: .utf8) {
                    print("서버 응답 데이터: \(responseData)")
                }
            case 422:
                throw AuthenticationError.authenticationFailed("서버가 요청 데이터를 처리할 수 없습니다. 입력값을 확인해주세요.")
            default:
                throw AuthenticationError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    // Realm에 계정 정보 저장
    func saveAccountToRealm(userIdentifier: String, email: String?, fullName: String?) async throws {
        do {
            let realm = try await Realm()
            let account = EasyLoginAccount()
            account.id = userIdentifier
            account.email = email ?? "Unknown"
            account.fullName = fullName ?? "Unknown"

            try realm.write {
                realm.add(account, update: .modified)
            }
            print("계정 정보를 Realm에 저장했습니다.")
        } catch {
            throw AuthenticationError.realmError(error)
        }
    }

    // 간편 로그인을 위해 시스템 인증(Face ID/비밀번호) 요청
    func performEasyLoginWithAuthentication() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "간편 로그인을 위해 인증해주세요."
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                Task { @MainActor in
                    if success {
                        await self.performEasyLogin()
                    } else {
                        let message = authenticationError?.localizedDescription ?? "알 수 없는 오류"
                        self.showError(message: "인증 실패: \(message)")
                    }
                }
            }
        } else {
            let message = error?.localizedDescription ?? "Face ID 또는 비밀번호를 사용할 수 없습니다."
            self.showError(message: message)
        }
    }

    // Face ID/비밀번호 인증 성공 시, Realm에 저장된 계정으로 간편로그인
    func performEasyLogin() async {
        do {
            // 비동기 초기화 사용
            let realm = try await Realm()
            guard let account = realm.objects(EasyLoginAccount.self).first else {
                throw AuthenticationError.authenticationFailed("저장된 간편 로그인 계정을 찾을 수 없습니다.")
            }
            print("간편 로그인 계정 불러오기 성공: \(account.email)")

            let isValid = try await self.validateAccountWithServer(userIdentifier: account.id)
            if isValid {
                self.userIdentifier = account.id
                self.userFullName = account.fullName
                self.isAuthenticated = true
            } else {
                throw AuthenticationError.authenticationFailed("간편 로그인 계정이 서버에서 확인되지 않았습니다. 다시 등록해주세요.")
            }
        } catch {
            self.showError(message: error.localizedDescription)
        }
    }

    // 서버로 사용자 계정 존재 여부 대조
    func validateAccountWithServer(userIdentifier: String) async throws -> Bool {
        guard let url = URL(string: "http://127.0.0.1:8000/users/\(userIdentifier)") else {
            throw AuthenticationError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.serverError(statusCode: -1)
        }

        switch httpResponse.statusCode {
            case 200:
                // 사용자 계정 존재
                guard let userData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      userData.keys.contains("email")
                else {
                    throw AuthenticationError.parsingError
                }
                print("서버에서 사용자 계정 확인 성공.")
                return true
            case 404:
                print("서버에서 계정을 찾지 못함 (404). 사용자 ID: \(userIdentifier)")
                return false
            default:
                throw AuthenticationError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    // 간편 로그인 등록(서버 조회 후 Realm 저장)
    func registerEasyLogin() async throws {
        guard let userIdentifier = self.userIdentifier else {
            throw AuthenticationError.authenticationFailed("사용자 식별자가 없습니다.")
        }

        guard let url = URL(string: "http://127.0.0.1:8000/users/\(userIdentifier)") else {
            throw AuthenticationError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthenticationError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        guard let userData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let email = userData["email"] as? String,
              let fullName = userData["name"] as? String
        else {
            throw AuthenticationError.parsingError
        }

        try await self.saveAccountToRealm(userIdentifier: userIdentifier, email: email, fullName: fullName)
        self.isAuthenticated = true
    }

    // 로그아웃 메서드
    func logout() {
        // 사용자 상태 초기화
        self.isAuthenticated = false
        self.userIdentifier = nil
        self.userFullName = nil
//
//        // Realm 데이터 삭제 (옵션)
//        Task {
//            do {
//                try await self.clearAccountFromRealm()
//                print("Realm 데이터가 삭제되었습니다.")
//            } catch {
//                print("Realm 데이터 삭제 중 오류 발생: \(error.localizedDescription)")
//            }
//        }
//
//        // 추가 작업: 로그아웃 API 호출 (옵션)
//        Task {
//            do {
//                try await self.performServerLogout()
//                print("서버 로그아웃이 성공적으로 처리되었습니다.")
//            } catch {
//                print("서버 로그아웃 중 오류 발생: \(error.localizedDescription)")
//            }
//        }
    }

//    // Realm 데이터 삭제
//    private func clearAccountFromRealm() async throws {
//        let realm = try await Realm()
//        try realm.write {
//            realm.deleteAll() // 모든 데이터 삭제
//        }
//    }
//
//    // 서버 로그아웃 (옵션)
//    private func performServerLogout() async throws {
//        guard let url = URL(string: "http://127.0.0.1:8000/logout") else {
//            throw AuthenticationError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let (_, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//            throw AuthenticationError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
//        }
//    }

    // 에러 처리
    func showError(message: String) {
        self.errorMessage = message
        self.showingErrorAlert = true
    }
}

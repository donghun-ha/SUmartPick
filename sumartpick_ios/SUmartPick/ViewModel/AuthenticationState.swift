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

@MainActor
class AuthenticationState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userIdentifier: String? = nil
    @Published var userFullName: String? = nil
    @Published var userAddress: String? = nil
    @Published var showingErrorAlert = false
    @Published var errorMessage = ""

    // 초기화 시 UserDefaults에서 기존 저장된 사용자 정보를 불러옴
    init() {
        let userDefaults = UserDefaults.standard
        if let id = userDefaults.string(forKey: "user_id") {
            self.userIdentifier = id
            self.userFullName = userDefaults.string(forKey: "user_name")
            self.userAddress = userDefaults.string(forKey: "user_address")
            self.isAuthenticated = true
            print("AuthenticationState init - userAddress: \(self.userAddress ?? "nil")")
        }
    }
    
    func autoLogin() {
            do {
                let realm = try Realm()
                if let account = realm.objects(EasyLoginAccount.self).first {
                    self.userIdentifier = account.id
                    self.userFullName = account.fullName
                    self.isAuthenticated = true
                    print("✅ 자동 로그인 성공: \(account.email)")
                }
            } catch {
                print("❌ 자동 로그인 실패: \(error.localizedDescription)")
            }
        }


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
                let userID = appleIDCredential.user
                self.userIdentifier = userID

                let rawGivenName = appleIDCredential.fullName?.givenName ?? ""
                let rawFamilyName = appleIDCredential.fullName?.familyName ?? ""
                let combinedName = [rawGivenName, rawFamilyName].filter { !$0.isEmpty }.joined(separator: " ")

                Task {
                    do {
                        // 서버에서 사용자 정보를 가져올 때 address 필드도 파싱
                        let existingUser = try await fetchUserFromServer(userID: userID)
                        let finalName = combinedName.isEmpty ? (existingUser?.name ?? "Unknown") : combinedName
                        let finalEmail = appleIDCredential.email ?? (existingUser?.email ?? "Unknown")

                        // 만약 서버에 저장된 주소가 있다면 업데이트
                        if let existingAddress = existingUser?.address, !existingAddress.isEmpty {
                            self.userAddress = existingAddress
                        }

                        self.userFullName = finalName

                        try await self.saveUserToDatabase(
                            userIdentifier: userID,
                            email: finalEmail,
                            fullName: finalName,
                            provider: .apple
                        )

                        if isPopup {
                            try await self.registerEasyLogin()
                        }
                        self.isAuthenticated = true
                    } catch {
                        self.showError(message: error.localizedDescription)
                    }
                }

            case .failure(let error):
                self.showError(message: "Apple 로그인 실패: \(error.localizedDescription)")
        }
    }

    // 서버에서 사용자 정보를 가져올 때 address 필드도 파싱하여 반환
    func fetchUserFromServer(userID: String) async throws -> (name: String, email: String, address: String)? {
        guard let url = URL(string: "\(SUmartPickConfig.baseURL)/users/\(userID)") else {
            throw AuthenticationError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.serverError(statusCode: -1)
        }
        if httpResponse.statusCode == 404 { return nil }
        guard httpResponse.statusCode == 200 else {
            throw AuthenticationError.serverError(statusCode: httpResponse.statusCode)
        }
        guard let userData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let name = userData["name"] as? String,
              let email = userData["email"] as? String
        else {
            throw AuthenticationError.parsingError
        }
        let address = userData["address"] as? String ?? ""
        return (name, email, address)
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
                  let rootVC = windowScene.windows.first?.rootViewController
            else {
                throw AuthenticationError.rootViewControllerNotFound
            }

            let user = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC).user
            guard let userID = user.userID else {
                throw AuthenticationError.authenticationFailed("Google 사용자 ID를 가져올 수 없습니다.")
            }

            let email = user.profile?.email ?? "Unknown"
            let fullName = "\(user.profile?.givenName ?? "") \(user.profile?.familyName ?? "")"

            self.userIdentifier = userID
            self.userFullName = fullName
            self.isAuthenticated = true

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

    // 사용자 정보를 서버(MySQL)에 저장 (address 필드 포함)
    func saveUserToDatabase(userIdentifier: String, email: String?, fullName: String?, provider: AuthProvider) async throws {
        guard let url = URL(string: "\(SUmartPickConfig.baseURL)/users") else {
            throw AuthenticationError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // userAddress가 nil이면 빈 문자열 사용
        let addressValue = self.userAddress ?? ""

        let userData: [String: Any] = [
            "User_ID": userIdentifier,
            "auth_provider": provider.rawValue,
            "name": fullName ?? "Unknown",
            "email": email ?? "Unknown",
            "address": addressValue
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userData)
        } catch {
            throw AuthenticationError.serializationError
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.serverError(statusCode: -1)
        }

        switch httpResponse.statusCode {
            case 200:
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

    // 시스템 인증(Face ID/비밀번호) → 성공 시 performEasyLogin()
    func performEasyLoginWithAuthentication() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "간편 로그인을 위해 인증해주세요."
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authError in
                Task { @MainActor in
                    if success {
                        await self.performEasyLogin()
                    } else {
                        let message = authError?.localizedDescription ?? "알 수 없는 오류"
                        self.showError(message: "인증 실패: \(message)")
                    }
                }
            }
        } else {
            let message = error?.localizedDescription ?? "Face ID 또는 비밀번호를 사용할 수 없습니다."
            self.showError(message: message)
        }
    }

    // Face ID 인증 성공 → Realm에 저장된 계정으로 바로 로그인
    func performEasyLogin() async {
        do {
            let realm = try await Realm()
            guard let account = realm.objects(EasyLoginAccount.self).first else {
                throw AuthenticationError.authenticationFailed("저장된 간편 로그인 계정을 찾을 수 없습니다.")
            }
            print("간편 로그인 계정 불러오기 성공: \(account.email)")

            let isValid = try await validateAccountWithServer(userIdentifier: account.id)
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

    // 서버로 사용자 계정 존재 여부 확인
    func validateAccountWithServer(userIdentifier: String) async throws -> Bool {
        guard let url = URL(string: "\(SUmartPickConfig.baseURL)/users/\(userIdentifier)") else {
            throw AuthenticationError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.serverError(statusCode: -1)
        }

        switch httpResponse.statusCode {
            case 200:
                guard let userData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
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

    // 간편 로그인 등록 (서버 조회 후 Realm 저장)
    func registerEasyLogin() async throws {
        guard let userIdentifier = self.userIdentifier else {
            throw AuthenticationError.authenticationFailed("사용자 식별자가 없습니다.")
        }
        guard let url = URL(string: "\(SUmartPickConfig.baseURL)/users/\(userIdentifier)") else {
            throw AuthenticationError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthenticationError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        guard let userData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let email = userData["email"] as? String,
              let fullName = userData["name"] as? String
        else {
            throw AuthenticationError.parsingError
        }

        // 기존 Realm 데이터 삭제(중복 계정 등록 방지)
        try await self.clearAccountFromRealm()

        // 새 계정 정보 저장
        try await self.saveAccountToRealm(
            userIdentifier: userIdentifier,
            email: email,
            fullName: fullName
        )

        // 상태 갱신
        self.userFullName = fullName
        self.isAuthenticated = true
    }

    // Realm 데이터 전체 삭제
    private func clearAccountFromRealm() async throws {
        let realm = try await Realm()
        try realm.write {
            realm.deleteAll()
        }
    }

    // 로그아웃 메서드 (UserDefaults의 저장 값도 삭제)
    func logout() {
        self.isAuthenticated = false
        self.userIdentifier = nil
        self.userFullName = nil
        self.userAddress = nil
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "user_id")
        userDefaults.removeObject(forKey: "user_name")
        userDefaults.removeObject(forKey: "user_email")
        userDefaults.removeObject(forKey: "auth_provider")
        userDefaults.removeObject(forKey: "user_address")
    }

    // 에러 처리 메서드
    func showError(message: String) {
        self.errorMessage = message
        self.showingErrorAlert = true
    }
}

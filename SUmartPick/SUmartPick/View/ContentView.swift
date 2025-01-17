//
//  ContentView.swift
//  SUmartPick
//
//  Created by aeong on 1/10/25.
//

import AuthenticationServices
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import LocalAuthentication
import RealmSwift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authState: AuthenticationState
    @State private var showingLoginPopup = false // 팝업 상태
    @State private var showingErrorAlert = false // 오류 알림 상태
    @State private var errorMessage = "" // 오류 메시지

    var body: some View {
        if authState.isAuthenticated {
            MainView()
                .onAppear {
                    showingLoginPopup = false // 로그아웃 시 팝업 닫기
                }
        } else {
            NavigationStack {
                VStack {
                    Text("로그인 예제")
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

                    // 간편 로그인 등록 버튼
                    Button(action: {
                        showingLoginPopup = true
                    }) {
                        Text("간편 로그인 등록")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .sheet(isPresented: $showingLoginPopup) {
                        LoginPopupView() // 팝업에서 로그인 진행
                    }

                    // 간편 로그인 버튼
                    Button(action: {
                        performEasyLoginWithAuthentication()
                    }) {
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
                .alert("오류 발생", isPresented: $showingErrorAlert) {
                    Button("확인", role: .cancel) {}
                } message: {
                    Text(errorMessage)
                }
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

                    let email = appleIDCredential.email
                    let fullName = [
                        appleIDCredential.fullName?.givenName,
                        appleIDCredential.fullName?.familyName
                    ].compactMap { $0 }.joined(separator: " ")

                    saveUserToDatabase(userIdentifier: appleIDCredential.user, email: email, fullName: fullName)
                }
            case .failure(let error):
                errorMessage = "Apple 로그인 실패: \(error.localizedDescription)"
                showingErrorAlert = true
        }
    }

    func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Google 클라이언트 ID를 찾을 수 없습니다."
            showingErrorAlert = true
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            print("Root view controller를 찾을 수 없습니다.")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { user, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Google 로그인 실패: \(error.localizedDescription)"
                    self.showingErrorAlert = true
                }
                return
            }

            guard let user = user?.user else { return }

            let userIdentifier = user.userID ?? "Unknown"
            let email = user.profile?.email
            let fullName = "\(user.profile?.givenName ?? "") \(user.profile?.familyName ?? "")"

            DispatchQueue.main.async {
                self.authState.userIdentifier = userIdentifier
                self.authState.isAuthenticated = true
            }

            self.saveUserToDatabase(userIdentifier: userIdentifier, email: email, fullName: fullName)
        }
    }

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
            print("Sending data to server: \(userData)") // 디버깅용 로그
        } catch {
            errorMessage = "데이터 직렬화 오류: \(error.localizedDescription)"
            showingErrorAlert = true
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "사용자 저장 실패: \(error.localizedDescription)"
                    self.showingErrorAlert = true
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP 상태 코드: \(httpResponse.statusCode)")

                // 422 상태 처리
                if httpResponse.statusCode == 422 {
                    DispatchQueue.main.async {
                        self.errorMessage = "서버가 요청 데이터를 처리할 수 없습니다. 입력값을 확인해주세요."
                        self.showingErrorAlert = true
                    }
                    return
                }

                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        self.errorMessage = "서버에서 잘못된 응답을 받았습니다: \(httpResponse.statusCode)"
                        self.showingErrorAlert = true
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
            errorMessage = "Realm에 계정 정보를 저장하는 중 오류 발생: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }

    func performEasyLoginWithAuthentication() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "간편 로그인을 위해 인증해주세요."
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.performEasyLogin()
                    } else {
                        self.errorMessage = "인증 실패: \(authenticationError?.localizedDescription ?? "알 수 없는 오류")"
                        self.showingErrorAlert = true
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Face ID 또는 비밀번호를 사용할 수 없습니다."
                self.showingErrorAlert = true
            }
        }
    }

    func performEasyLogin() {
        do {
            let realm = try Realm()
            if let account = realm.objects(EasyLoginAccount.self).first {
                print("간편 로그인 계정 불러오기 성공: \(account.email)")

                validateAccountWithServer(userIdentifier: account.id) { isValid in
                    DispatchQueue.main.async {
                        if isValid {
                            self.authState.userIdentifier = account.id
                            self.authState.isAuthenticated = true
                        } else {
                            self.showError(message: "간편 로그인 계정이 서버에서 확인되지 않았습니다. 다시 등록해주세요.")
                        }
                    }
                }
            } else {
                showError(message: "저장된 간편 로그인 계정을 찾을 수 없습니다.")
            }
        } catch {
            showError(message: "Realm에서 계정을 불러오는 중 오류 발생: \(error.localizedDescription)")
        }
    }

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

            do {
                if try JSONSerialization.jsonObject(with: data!, options: []) is [String: Any] {
                    print("서버에서 사용자 계정 확인 성공.")
                    completion(true) // 정상적인 계정 확인
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

    func showError(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showingErrorAlert = true
        }
    }
}

//
//  ContentView.swift
//  SUmartPick
//
//  Created by aeong on 1/10/25.
//

import AuthenticationServices
import Firebase
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
                    print("Apple 로그인 성공 - 사용자 ID: \(appleIDCredential.user)")

                    let email = appleIDCredential.email
                    let fullName = appleIDCredential.fullName

                    saveUserToDatabase(
                        userIdentifier: appleIDCredential.user,
                        email: email,
                        fullName: [
                            fullName?.givenName,
                            fullName?.familyName
                        ].compactMap { $0 }.joined(separator: " ")
                    )

                    registerEasyLogin()
                }
            case .failure(let error):
                errorMessage = "Apple 로그인 실패: \(error.localizedDescription)"
                showingErrorAlert = true
        }
    }

    func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

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
                errorMessage = "Google 로그인 실패: \(error.localizedDescription)"
                showingErrorAlert = true
                return
            }

            guard let user = user?.user else { return }

            let userIdentifier = user.userID
            let email = user.profile?.email
            let fullName = "\(user.profile?.givenName ?? "") \(user.profile?.familyName ?? "")"

            authState.userIdentifier = userIdentifier
            authState.isAuthenticated = true

            saveUserToDatabase(
                userIdentifier: userIdentifier ?? "Unknown",
                email: email,
                fullName: fullName
            )

            registerEasyLogin()
        }
    }

    func registerEasyLogin() {
        guard let userIdentifier = authState.userIdentifier else { return }

        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(userIdentifier)

        userDoc.getDocument { document, error in
            if let error = error {
                print("Firebase에서 사용자 정보를 가져오는 중 오류 발생: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists,
                  let userData = document.data()
            else {
                print("사용자 정보를 찾을 수 없습니다.")
                return
            }

            saveAccountToRealm(userIdentifier: userIdentifier, userData: userData)
        }
    }

    func saveUserToDatabase(userIdentifier: String, email: String?, fullName: String?) {
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(userIdentifier)

        userDoc.getDocument { document, error in
            if let document = document, document.exists {
                print("User already exists in the database.")
            } else {
                let userData: [String: Any] = [
                    "userIdentifier": userIdentifier,
                    "email": email ?? "",
                    "fullName": fullName ?? "",
                    "createdAt": Timestamp(date: Date())
                ]

                userDoc.setData(userData) { error in
                    if let error = error {
                        print("Error saving user to the database: \(error.localizedDescription)")
                    } else {
                        print("User successfully saved to the database!")
                    }
                }
            }
        }
    }

    func saveAccountToRealm(userIdentifier: String, userData: [String: Any]) {
        do {
            let realm = try Realm()
            let account = EasyLoginAccount()
            account.id = userIdentifier
            account.email = userData["email"] as? String ?? ""
            account.fullName = userData["fullName"] as? String ?? ""

            try realm.write {
                realm.add(account)
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

        // Face ID 또는 Touch ID 사용 가능 여부 확인
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "간편 로그인을 위해 인증해주세요."
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // 인증 성공 시 간편 로그인 수행
                        self.performEasyLogin()
                    } else {
                        // 인증 실패 시 오류 메시지 표시
                        self.errorMessage = "인증 실패: \(authenticationError?.localizedDescription ?? "알 수 없는 오류")"
                        self.showingErrorAlert = true
                    }
                }
            }
        } else {
            // Face ID 또는 비밀번호 사용 불가 시 오류 메시지 표시
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
                authState.userIdentifier = account.id
                authState.isAuthenticated = true
            } else {
                errorMessage = "저장된 간편 로그인 계정을 찾을 수 없습니다."
                showingErrorAlert = true
            }
        } catch {
            errorMessage = "Realm에서 계정을 불러오는 중 오류 발생: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
}

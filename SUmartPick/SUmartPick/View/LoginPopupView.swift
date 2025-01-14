//
//  LoginPopupView.swift
//  SUmartPick
//
//  Created by aeong on 1/14/25.
//

import AuthenticationServices
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import RealmSwift
import SwiftUI

struct LoginPopupView: View {
    @EnvironmentObject var authState: AuthenticationState

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
                print("Apple 로그인 실패: \(error.localizedDescription)")
        }
    }

    // Google 로그인 처리
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
                print("Google 로그인 실패: \(error.localizedDescription)")
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

    // 사용자 정보 Firebase에 저장
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

    // 사용자 정보 Realm에 저장
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

    // Realm에 사용자 계정 정보 저장
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
            print("Realm에 계정 정보를 저장하는 중 오류 발생: \(error.localizedDescription)")
        }
    }
}

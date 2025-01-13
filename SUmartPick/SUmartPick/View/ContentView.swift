//
//  ContentView.swift
//  SUmartPick
//
//  Created by aeong on 1/10/25.
//

import LocalAuthentication
import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false // 인증 상태 관리

    var body: some View {
        NavigationStack {
            VStack {
                Text("Face ID 인증 예제")
                    .font(.headline)
                    .padding()

                Button(action: {
                    authenticateWithFaceID()
                }) {
                    Text("Face ID로 인증")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationDestination(isPresented: $isAuthenticated) {
                MainView()
            }
        }
    }

    func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        // Face ID 또는 Touch ID 사용 가능 여부 확인
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Face ID를 사용하여 앱에 로그인하세요."

            // Face ID 인증 시작
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // 인증 성공 - 인증 상태 업데이트
                        isAuthenticated = true
                        print("Face ID 인증 성공")
                    } else {
                        // 인증 실패
                        print("Face ID 인증 실패: \(authenticationError?.localizedDescription ?? "알 수 없는 오류")")
                    }
                }
            }
        } else {
            // Face ID 사용 불가능
            print("Face ID를 사용할 수 없습니다: \(error?.localizedDescription ?? "알 수 없는 오류")")
        }
    }
}

// #Preview {
//    ContentView()
// }

//
//  FaceIDAuthentication.swift
//  SUmartPick
//
//  Created by aeong on 1/14/25.
//

import LocalAuthentication

class FaceIDAuthentication {
    static func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        // Face ID 사용 가능 여부 확인
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Face ID를 사용하여 간편 로그인하세요."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluationError in
                DispatchQueue.main.async {
                    if success {
                        print("Face ID 인증 성공")
                        completion(true)
                    } else {
                        print("Face ID 인증 실패: \(evaluationError?.localizedDescription ?? "알 수 없는 오류")")
                        completion(false)
                    }
                }
            }
        } else {
            print("Face ID를 사용할 수 없습니다: \(error?.localizedDescription ?? "알 수 없는 오류")")
            completion(false)
        }
    }
}

//
//  AuthenticationService.swift
//  SUmartPick
//
//  Created by aeong on 2/5/25.
//

import AuthenticationServices
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

class AuthenticationService {
    static let shared = AuthenticationService()

    let baseURL = "https://fastapi.sumartpick.shop" // ✅ FastAPI 주소

    func login(email: String, name: String, provider: AuthProvider, completion: @escaping (Result<UserData, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/login") else {
            completion(.failure(AuthenticationError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginData: [String: Any] = [
            "email": email,
            "name": name,
            "login_type": provider.rawValue.lowercased()
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData)
        } catch {
            completion(.failure(AuthenticationError.serializationError))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(AuthenticationError.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                // 로그인 성공 후 사용자 정보를 UserDefaults에 저장 (address 추가)
                let userData = decodedResponse.userData
                let userDefaults = UserDefaults.standard
                userDefaults.set(userData.User_Id, forKey: "user_id")
                userDefaults.set(userData.name, forKey: "user_name")
                userDefaults.set(userData.email, forKey: "user_email")
                userDefaults.set(userData.auth_provider, forKey: "auth_provider")
                userDefaults.set(userData.address, forKey: "user_address")

                completion(.success(userData))
            } catch {
                completion(.failure(AuthenticationError.parsingError))
            }
        }.resume()
    }
}

// MARK: - 로그인 응답 데이터 모델 (수정)

struct LoginResponse: Codable {
    let source: String
    let userData: UserData
}

struct UserData: Codable {
    let User_Id: Int
    let email: String
    let name: String
    let auth_provider: String
    let address: String // 추가: 서버에서 받은 address 값
}

enum AuthProvider: String, Codable {
    case apple = "Apple"
    case google = "Google"
}

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

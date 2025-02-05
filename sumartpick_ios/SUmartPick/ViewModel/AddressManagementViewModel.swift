//
//  AddressManagementViewModel.swift
//  SUmartPick
//
//  Created by aeong on 2/5/25.
//

import Foundation

@MainActor
final class AddressManagementViewModel: ObservableObject {
    @Published var address = ""
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    @Published var isLoading = false // 로딩 상태 추가

    // 주소 업데이트 API 호출
    func updateAddress(userID: String) async {
        guard let url = URL(string: "https://fastapi.sumartpick.shop/update_address") else {
            errorMessage = "유효하지 않은 URL입니다."
            showErrorAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "user_id": userID, // AuthenticationState의 userIdentifier 사용
            "address": address
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                errorMessage = "서버 응답 오류"
                showErrorAlert = true
                return
            }
            // 성공적으로 업데이트되었음을 로그로 확인
            print("주소 업데이트 성공: \(String(data: data, encoding: .utf8) ?? "")")
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

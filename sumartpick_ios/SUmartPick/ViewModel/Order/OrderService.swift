//
//  OrderService.swift
//  SUmartPick
//
//  Created by 하동훈 on 3/2/2025.
//

import Foundation

class OrderService {
    static let shared = OrderService()
    private let baseURL = "https://fastapi.sumartpick.shop"
    
    // 주문 생성 API 호출
    func createOrder(order: OrderRequest) async throws -> String {
        guard let url = URL(string: "\(baseURL)/orders/create_order") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let jsonData = try JSONEncoder().encode(order)
            print("📌 JSON Body:", String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("📌 응답 상태 코드: \(httpResponse.statusCode)")
            }
            
            let responseBody = String(data: data, encoding: .utf8) ?? "Invalid Response Data"
            print("📌 서버 응답 본문: \(responseBody)")

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "Invalid Response", code: 1)
            }

            return responseBody
        } catch {
            throw error
        }
    }
}

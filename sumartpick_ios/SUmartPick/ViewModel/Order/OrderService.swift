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
        guard let url = URL(string: "\(baseURL)/create_order") else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(order)
            request.httpBody = jsonData
            
            let(data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "Invalid Response", code: 1)
            }
            
            return String(data: data, encoding: .utf8) ??
            "Successfully created order!"
        } catch {
            throw error
        }
    }
}

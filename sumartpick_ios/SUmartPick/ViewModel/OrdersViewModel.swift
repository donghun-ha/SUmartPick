//
//  OrdersViewModel.swift
//  SUmartPick
//
//  Created by aeong on 1/21/25.
//

import SwiftUI

@MainActor
class OrdersViewModel: ObservableObject {
    @Published var orders: [OrderItem] = []

    // 검색어 저장
    @Published var searchText: String = ""

    // 에러 알림
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    // 각 주문별 ML 테스트 결과 저장 (주문 ID → 예상 도착 시간)
    @Published var mlTestResults: [Int: Date] = [:]

    // 기본 서버 URL
    let baseURL = "\(SUmartPickConfig.baseURL)"

    // ============== 1) 주문 목록 조회 ==============
    func fetchOrders(for userID: String) async {
        guard let url = URL(string: "\(baseURL)/orders/\(userID)") else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("서버 응답 raw JSON:\n\(rawJSON)")
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                print("Server error or invalid response.")
                return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            let fetchedOrders = try decoder.decode([OrderItem].self, from: data)
            orders = fetchedOrders
        } catch {
            print("Failed to fetch orders:", error.localizedDescription)
        }
    }

    // ============== 2) 반품 신청 ==============
    func requestRefund(orderID: Int) async {
        guard let url = URL(string: "\(baseURL)/orders/\(orderID)/requestRefund") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                throw URLError(.badServerResponse)
            }
            print("반품 신청이 성공적으로 처리되었습니다.")
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    // ============== 3) 머신러닝 테스트 데이터 가져오기 ==============
    func fetchMLTest(for order_id: Int) async {
        // URL: /mlplus?order_id=...
        guard let url = URL(string: "\(baseURL)/mlplus?order_id=\(order_id)") else {
            print("잘못된 URL")
            return
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                print("ML Test: Server error or invalid response.")
                return
            }
            let decoder = JSONDecoder()
            // 서버가 "2025-02-05T00:00:00" 형식의 문자열을 반환한다고 가정
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            decoder.dateDecodingStrategy = .formatted(formatter)
            struct MLTestResponse: Decodable {
                let results: Date
            }
            let decodedResponse = try decoder.decode(MLTestResponse.self, from: data)
            mlTestResults[order_id] = decodedResponse.results
            print("ML Test result for order \(order_id): \(decodedResponse.results)")
        } catch {
            print("Error fetching ML test data for order \(order_id): \(error.localizedDescription)")
        }
    }

    // (옵션) 검색 로직
    var filteredOrders: [OrderItem] {
        if searchText.isEmpty {
            return orders
        } else {
            return orders.filter { order in
                order.productName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // (옵션) 날짜별 그룹핑
    var groupedByDate: [String: [OrderItem]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d"
        return Dictionary(grouping: filteredOrders, by: { order in
            formatter.string(from: order.orderDate)
        })
    }

    var sortedDateKeys: [String] {
        Array(groupedByDate.keys).sorted {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy. M. d"
            guard let d1 = formatter.date(from: $0), let d2 = formatter.date(from: $1) else {
                return false
            }
            return d1 > d2
        }
    }
}

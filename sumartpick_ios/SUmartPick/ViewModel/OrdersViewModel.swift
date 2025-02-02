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

    // 검색어를 저장
    @Published var searchText: String = ""

    // 기본 서버 URL
    let baseURL = "\(SUmartPickConfig.baseURL)"

    // 서버로부터 특정 사용자(User_ID)의 주문 목록을 가져옴
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

    // 검색어를 기준으로 필터링된 주문 목록
    var filteredOrders: [OrderItem] {
        if searchText.isEmpty {
            return orders
        } else {
            return orders.filter { order in
                order.productName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var groupedByDate: [String: [OrderItem]] {
        // 예: "yyyy. M. d" 형식으로 문자열 변환
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d"

        // [날짜문자열: [OrderItem]] 으로 그룹핑
        return Dictionary(grouping: filteredOrders, by: { order in
            formatter.string(from: order.orderDate)
        })
    }

    // 날짜 문자열을 내림차순 정렬한 키
    var sortedDateKeys: [String] {
        Array(groupedByDate.keys)
            .sorted {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy. M. d"
                guard let date1 = formatter.date(from: $0),
                      let date2 = formatter.date(from: $1)
                else {
                    return false
                }
                // 최신 날짜가 먼저 오도록 내림차순
                return date1 > date2
            }
    }
}

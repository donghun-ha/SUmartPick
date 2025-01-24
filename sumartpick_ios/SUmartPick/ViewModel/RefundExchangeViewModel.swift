//
//  RefundExchangeViewModel.swift
//  SUmartPick
//
//  Created by aeong on 1/23/25.
//

import SwiftUI

@MainActor
class RefundExchangeViewModel: ObservableObject {
    @Published var orders: [OrderItem] = []
    @Published var searchText: String = ""

    let baseURL = SUmartPickConfig.baseURL

    func fetchRefundExchangeOrders(for userID: String) async {
        guard let url = URL(string: "\(baseURL)/orders/refunds/\(userID)") else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            // Debug: raw JSON 찍어보기
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("Refund Exchange Orders JSON:\n\(rawJSON)")
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                print("서버 에러 또는 응답이 유효하지 않습니다.")
                return
            }

            // 날짜 디코딩
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)

            let fetchedOrders = try decoder.decode([OrderItem].self, from: data)
            orders = fetchedOrders
        } catch {
            print("취소·반품·교환 주문 목록 조회 실패:", error.localizedDescription)
        }
    }

    // 검색어로 필터링
    var filteredOrders: [OrderItem] {
        if searchText.isEmpty {
            return orders
        } else {
            return orders.filter { $0.productName.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // 날짜별 그룹핑
    var groupedByDate: [String: [OrderItem]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d"

        // orderDate 기준으로 그룹핑
        return Dictionary(grouping: filteredOrders, by: { order in
            formatter.string(from: order.orderDate)
        })
    }

    var sortedDateKeys: [String] {
        Array(groupedByDate.keys)
            .sorted {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy. M. d"
                guard let d1 = formatter.date(from: $0),
                      let d2 = formatter.date(from: $1)
                else { return false }
                return d1 > d2
            }
    }
}

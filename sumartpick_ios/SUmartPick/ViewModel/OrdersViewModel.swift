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

    // 에러 알림
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    // 배송 조회 정보를 화면에 표시하기 위해 사용
    @Published var selectedTrackingInfo: TrackingInfo? = nil

    // 기본 서버 URL
    let baseURL = "\(SUmartPickConfig.baseURL)"

    // ============== 1) 주문 목록 조회 (기존) ==============
    func fetchOrders(for userID: String) async {
        guard let url = URL(string: "\(baseURL)/orders/\(userID)") else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let rawJSON = String(data: data, encoding: .utf8) {
                print("서버 응답 raw JSON:\n\(rawJSON)")
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
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
    // 서버 측 가정: PUT /orders/{order_id}/requestRefund
    // refund_demands_time = NOW(), Order_state = 'Return_Requested' 등
    func requestRefund(orderID: Int) async {
        guard let url = URL(string: "\(baseURL)/orders/\(orderID)/requestRefund") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            print("반품 신청이 성공적으로 처리되었습니다.")
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    // ============== 3) 배송조회 정보 요청 ==============
    // 서버 측 가정: GET /orders/{order_id}/track
    func fetchTrackingInfo(orderID: Int) async -> TrackingInfo? {
        guard let url = URL(string: "\(baseURL)/orders/\(orderID)/track") else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            let decoder = JSONDecoder()
            let tracking = try decoder.decode(TrackingInfo.self, from: data)
            return tracking
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            return nil
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
            return d1 > d2 // 최신 날짜가 먼저 오도록
        }
    }
}

// ============== 4) 배송조회 결과 모델 (TrackingInfo) ==============
struct TrackingInfo: Codable {
    let orderID: Int
    let trackingNumber: String?
    let carrier: String?
    let shippingStatus: String?

    enum CodingKeys: String, CodingKey {
        case orderID = "Order_ID"
        case trackingNumber = "TrackingNumber"
        case carrier = "Carrier"
        case shippingStatus = "ShippingStatus"
    }
}

//
//  OrderListView.swift
//  SUmartPick
//
//  Created by aeong on 1/21/25.
//

import SwiftUI

struct OrderListView: View {
    @EnvironmentObject var authState: AuthenticationState
    @StateObject var viewModel = OrdersViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // (A) 검색 영역
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    TextField("주문 검색", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()

                // (B) 주문 목록 리스트
                List {
                    ForEach(viewModel.sortedDateKeys, id: \.self) { dateKey in
                        // 날짜별 구역
                        Section {
                            // 실제 주문 목록
                            if let items = viewModel.groupedByDate[dateKey] {
                                ForEach(items) { order in
                                    OrderRow(order: order)
                                }
                            }
                        } header: {
                            // 날짜 표시를 커스텀 헤더로 만듦
                            HStack {
                                Text(dateKey)
                                    .font(.headline)
                                    .textCase(nil)
                                Spacer()
                            }
                            .padding(.vertical, 4)
//                            .background(Color(.systemGray6))
                        }
                    }
                }
            }
            .navigationTitle("주문목록")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if let userID = authState.userIdentifier {
                    await viewModel.fetchOrders(for: userID)
                }
            }
        }
    }
}

// 주문 하나를 표시하는 Row
struct OrderRow: View {
    let order: OrderItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 배송 완료 vs 미완료 구분
            if let arrival = order.arrivalTime {
                Text("\(formatDate(arrival)) 도착")
                    .font(.subheadline)
            } else {
                Text("\(formatDate(order.orderDate)) 주문")
                    .font(.subheadline)
            }

            // 상품명 및 수량
            Text("\(order.productName)")
                .font(.headline)

            // 가격
            Text("\(Int(order.productPrice))원 · 1개")
                .font(.subheadline)

            // 교환/반품, 배송조회 버튼
            HStack {
                Button("교환, 반품 신청") {}
                    .buttonStyle(.bordered)

                Button("배송조회") {}
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 6)
    }

    // 날짜를 간단히 "M/d(EEE)" 형식으로 표시
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d(EEE)" // 예: "1/23(Thu)"
        return formatter.string(from: date)
    }
}

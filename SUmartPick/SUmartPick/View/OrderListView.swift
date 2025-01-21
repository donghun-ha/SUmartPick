//
//  OrderListView.swift
//  SUmartPick
//
//  Created by aeong on 1/21/25.
//

import SwiftUI

struct OrderListView: View {
    // 로그인 정보 (현재 로그인한 userID 등)를 참조
    @EnvironmentObject var authState: AuthenticationState

    @StateObject var viewModel = OrdersViewModel()

    var body: some View {
        NavigationStack {
            // 날짜별 섹션 예시
            List {
                ForEach(viewModel.sortedDateKeys, id: \.self) { dateKey in
                    Section(header: Text(dateKey)) {
                        if let items = viewModel.groupedByDate[dateKey] {
                            ForEach(items) { order in
                                // 주문 1건에 대한 Row
                                OrderRow(order: order)
                            }
                        }
                    }
                }
            }
            // iOS 15+에서 사용할 수 있는 검색어 바
            .searchable(text: $viewModel.searchText, prompt: "주문한 상품을 검색할 수 있어요!")
            .navigationTitle("주문목록")
            .toolbar {
                // 우측 상단 등에 버튼 배치도 가능
            }
            // 뷰가 나타날 때(또는 리프레시 시점)에 주문 데이터 불러오기
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
            // 도착(또는 주문) 날짜 표시: 여기서는 arrivalTime이 있다면 표시
            if let arrival = order.arrivalTime {
                Text("\(formatDate(arrival)) 도착 예정")
                    .font(.subheadline)
            }

            // 상품명 및 수량
            Text("\(order.productName)")
                .font(.headline)

            // 가격
            Text("\(Int(order.productPrice))원 · 1개")
                .font(.subheadline)

            // 교환/반품, 배송조회 버튼 등 (UI 예시)
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

    // 간단히 날짜만 "M/d(EEE)" 형식 등으로 표시
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d(EEE)"
        return formatter.string(from: date)
    }
}

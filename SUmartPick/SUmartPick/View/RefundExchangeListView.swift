//
//  RefundExchangeListView.swift
//  SUmartPick
//
//  Created by aeong on 1/23/25.
//

import SwiftUI

struct RefundExchangeListView: View {
    @EnvironmentObject var authState: AuthenticationState
    @StateObject var viewModel = RefundExchangeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 검색 영역
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    TextField("검색어 입력", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()

                // 목록
                List {
                    ForEach(viewModel.sortedDateKeys, id: \.self) { dateKey in
                        Section(header: sectionHeader(for: dateKey)) {
                            if let items = viewModel.groupedByDate[dateKey] {
                                ForEach(items) { order in
                                    refundOrderRow(for: order)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("취소·반품·교환 목록")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if let userID = authState.userIdentifier {
                    await viewModel.fetchRefundExchangeOrders(for: userID)
                }
            }
        }
    }

    // 섹션 헤더를 구성하는 뷰
    @ViewBuilder
    private func sectionHeader(for dateKey: String) -> some View {
        HStack {
            Text(dateKey)
                .font(.headline)
                .textCase(nil)
            Spacer()
        }
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
    }

    // 각 주문 항목을 표시하는 행
    @ViewBuilder
    private func refundOrderRow(for order: OrderItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 1) 반품 완료/신청 날짜 표시
            if let refundTime = order.refundTime {
                // 실제 반품이 완료되었을 때
                Text("\(formatDate(refundTime)) 반품 완료")
                    .font(.subheadline)
                    .foregroundColor(.green)
            } else if let demandsTime = order.refundDemandsTime {
                // 반품 신청만 했을 때
                Text("\(formatDate(demandsTime)) 반품 신청")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }

            // 2) 상품명 및 수량/가격
            Text(order.productName)
                .font(.headline)
                .foregroundColor(.primary)

            Text("\(Int(order.productPrice))원 · 1개")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // 3) 추가 기능이나 상태 표시가 필요할 경우 여기에 추가
        }
        .padding(.vertical, 6)
    }

    // 날짜를 "M/d(EEE)" 형식으로 포맷하는 함수
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d(EEE)"
        return formatter.string(from: date)
    }
}

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
            switch order.orderState {
                case "Cancelled":
                    // 1) 취소인 경우
                    Text("\(formatDate(order.orderDate)) 취소 완료")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                case "Returned":
                    // 2) 반품이 실제 완료된 경우
                    //   -> refund_time이 있을 것이므로 해당 날짜 등 표시
                    if let refundTime = order.refundTime {
                        Text("\(formatDate(refundTime)) 반품 완료")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    } else {
                        // refund_time이 없는데 상태만 Returned로 되어 있다면
                        Text("반품 완료")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }

                case "Exchanged":
                    // 3) 교환 완료된 경우
                    Text("\(formatDate(order.orderDate)) 교환 완료")
                        .font(.subheadline)
                        .foregroundColor(.blue)

                case "Return_Requested":
                    // 4) 반품 신청
                    if let demandsTime = order.refundDemandsTime {
                        Text("\(formatDate(demandsTime)) 반품 신청")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    } else {
                        // refund_demands_time이 없는데 상태만 Return_Requested라면
                        Text("반품 신청")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }

                default:
                    // 그 외 상태(혹은 에러)
                    Text("알 수 없는 상태: \(order.orderState)")
                        .font(.subheadline)
                        .foregroundColor(.red)
            }

            // 공통: 상품명 및 가격
            Text(order.productName)
                .font(.headline)
            Text("\(Int(order.productPrice))원 · 1개")
                .font(.subheadline)
                .foregroundColor(.secondary)
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

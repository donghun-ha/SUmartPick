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

    // 리뷰 작성 sheet 상태
    @State private var showReviewWriteSheet: Bool = false
    // 선택된 주문 (리뷰 작성용)
    @State private var selectedOrderForReview: OrderItem? = nil
    // 반품 관련 Alert 상태
    @State private var selectedOrderForRefund: OrderItem? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBarView
                orderListView
            }
            .navigationTitle("주문목록")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if let userID = authState.userIdentifier {
                    await viewModel.fetchOrders(for: userID)
                }
            }
            .alert("오류 발생", isPresented: $viewModel.showErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert(item: $selectedOrderForRefund) { order in
                Alert(
                    title: Text("반품 신청"),
                    message: Text("정말 “\(order.productName)” 상품을 반품 신청하시겠습니까?"),
                    primaryButton: .destructive(Text("확인")) {
                        Task {
                            await viewModel.requestRefund(orderID: order.id)
                            if let userID = authState.userIdentifier {
                                await viewModel.fetchOrders(for: userID)
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
        .sheet(isPresented: $showReviewWriteSheet) {
            if let order = selectedOrderForReview {
                ReviewWriteView(order: order)
                    .environmentObject(authState)
            } else {
                Text("리뷰 작성할 주문이 없습니다.")
            }
        }
    }

    // MARK: - Subviews

    private var searchBarView: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
            TextField("주문 검색", text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }

    private var orderListView: some View {
        List {
            ForEach(viewModel.sortedDateKeys, id: \.self) { dateKey in
                if let orders = viewModel.groupedByDate[dateKey] {
                    OrderSectionView(
                        dateKey: dateKey,
                        orders: orders,
                        mlTestResults: viewModel.mlTestResults,
                        onRequestRefund: { selectedOrderForRefund = $0 },
                        onWriteReview: { order in
                            if order.orderState == "Delivered" {
                                selectedOrderForReview = order
                                showReviewWriteSheet = true
                            }
                        },
                        onFetchMLTest: { orderId in
                            Task {
                                await viewModel.fetchMLTest(for: orderId)
                            }
                        }
                    )
                }
            }
        }
    }
}

struct OrderSectionView: View {
    let dateKey: String
    let orders: [OrderItem]
    let mlTestResults: [Int: Date] // 각 주문별 ML 결과
    let onRequestRefund: (OrderItem) -> Void
    let onWriteReview: (OrderItem) -> Void
    let onFetchMLTest: (Int) -> Void

    var body: some View {
        Section(header: sectionHeader) {
            ForEach(orders) { order in
                OrderRow(
                    order: order,
                    mlTestResult: mlTestResults[order.id],
                    onFetchMLTest: { onFetchMLTest(order.id) },
                    onRequestRefund: { onRequestRefund(order) },
                    onWriteReview: { onWriteReview(order) }
                )
            }
        }
    }

    private var sectionHeader: some View {
        HStack {
            Text(dateKey)
                .font(.headline)
                .textCase(nil)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

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

    // 리뷰 작성 sheet (예: 리뷰 작성 화면으로 이동)
    @State private var showReviewWriteSheet: Bool = false
    // 사용자가 리뷰 작성을 위한 주문 선택
    @State private var selectedOrderForReview: OrderItem? = nil

    // 반품 관련 Alert 변수 (원한다면 유지)
    @State private var selectedOrderForRefund: OrderItem? = nil

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
                        Section {
                            if let items = viewModel.groupedByDate[dateKey] {
                                ForEach(items) { order in
                                    OrderRow(
                                        order: order,
                                        mlTestResult: viewModel.mlTestResult, // 추가된 부분
                                        // 반품 신청 버튼 액션
                                        onRequestRefund: {
                                            selectedOrderForRefund = order
                                        },
                                        // 리뷰 작성 버튼 액션: 주문 상태가 Delivered일 때만 활성화
                                        onWriteReview: {
                                            if order.orderState == "Delivered" {
                                                selectedOrderForReview = order
                                                showReviewWriteSheet = true
                                            }
                                        }
                                    )
                                }
                            }
                        } header: {
                            HStack {
                                Text(dateKey)
                                    .font(.headline)
                                    .textCase(nil)
                                Spacer()
                            }
                            .padding(.vertical, 4)
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
        // (E) 리뷰 작성 Sheet
        .sheet(isPresented: $showReviewWriteSheet) {
            if let order = selectedOrderForReview {
                ReviewWriteView(order: order)
                    .environmentObject(authState)
            } else {
                Text("리뷰 작성할 주문이 없습니다.")
            }
        }
    }
}

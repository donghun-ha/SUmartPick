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

    // 리뷰 작성 sheet (예시: 새로운 화면으로 이동)
    @State private var showReviewWriteSheet: Bool = false
    // 사용자가 리뷰 작성을 위한 주문 선택
    @State private var selectedOrderForReview: OrderItem? = nil

    // 반품 관련 Alert 변수는 그대로 유지 (원한다면 제거 가능)
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
                                        // 반품 신청 버튼은 기존대로 사용
                                        onRequestRefund: {
                                            selectedOrderForRefund = order
                                        },
                                        // 리뷰 작성 버튼 액션: 주문 상태가 Delivered일 때만 활성화
                                        onWriteReview: {
                                            // 리뷰 작성 가능한 주문인지 확인
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
            // 화면 표시되면 주문 목록 가져오기
            .task {
                if let userID = authState.userIdentifier {
                    await viewModel.fetchOrders(for: userID)
                }
            }
            // (C) 에러 처리 Alert
            .alert("오류 발생", isPresented: $viewModel.showErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            // (D) 반품 신청 확인 Alert (필요 시 유지)
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
            // (E) 리뷰 작성 Sheet
            .sheet(isPresented: $showReviewWriteSheet) {
                // 예시: 리뷰 작성 화면으로 이동 (예: ReviewWriteView)
                if let order = selectedOrderForReview {
                    ReviewWriteView(order: order)
                }
            }
        }
    }
}

// MARK: - OrderRow

struct OrderRow: View {
    let order: OrderItem
    // 기존 반품 신청 액션
    let onRequestRefund: () -> Void
    // 새롭게 추가한 리뷰 작성 액션
    let onWriteReview: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 배송 완료 vs 미완료
            if let arrival = order.arrivalTime {
                Text("\(formatDate(arrival)) 도착")
                    .font(.subheadline)
            } else {
                Text("\(formatDate(order.orderDate)) 주문")
                    .font(.subheadline)
            }

            // 상품명
            Text(order.productName)
                .font(.headline)

            // 가격
            Text("\(Int(order.productPrice))원 · 1개")
                .font(.subheadline)

            // 버튼 영역: 반품 신청과 리뷰 작성
            HStack {
                if order.orderState == "Return_Requested" {
                    Label("반품 신청됨", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .padding(.trailing, 8)
                    Button("반품 신청") { onRequestRefund() }
                        .buttonStyle(.bordered)
                        .disabled(true)
                        .opacity(0.3)
                } else {
                    Button("반품 신청") {
                        onRequestRefund()
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                // 리뷰 작성 버튼: 주문 상태가 Delivered일 때만 활성화
                if order.orderState == "Delivered" {
                    Button("리뷰 작성") {
                        onWriteReview()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("리뷰 작성") {
                        // 배송 완료되지 않은 주문은 아무 동작도 하지 않음
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(true)
                    .opacity(0.5)
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 6)
    }

    // 날짜 포맷 함수
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d(EEE)"
        return formatter.string(from: date)
    }
}

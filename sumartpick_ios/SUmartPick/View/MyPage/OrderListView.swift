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

    // 배송조회 sheet 제어
    @State private var showTrackingSheet: Bool = false

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
                                        onRequestRefund: {
                                            Task {
                                                // 반품 신청 API 호출
                                                await viewModel.requestRefund(orderID: order.id)
                                                // 완료 후 목록 재갱신 (옵션)
                                                if let userID = authState.userIdentifier {
                                                    await viewModel.fetchOrders(for: userID)
                                                }
                                            }
                                        },
                                        onTracking: {
                                            Task {
                                                if let info = await viewModel.fetchTrackingInfo(orderID: order.id) {
                                                    // 성공적으로 받아오면 ViewModel에 저장
                                                    viewModel.selectedTrackingInfo = info
                                                    showTrackingSheet = true
                                                }
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
            // 에러 처리
            .alert("오류 발생", isPresented: $viewModel.showErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            // 배송 조회 Sheet
            .sheet(isPresented: $showTrackingSheet) {
                if let trackingInfo = viewModel.selectedTrackingInfo {
                    TrackingView(trackingInfo: trackingInfo)
                }
            }
        }
    }
}

// 수정된 OrderRow
struct OrderRow: View {
    let order: OrderItem
    // 클로저 파라미터로 버튼 액션을 부모에게 위임
    let onRequestRefund: () -> Void
    let onTracking: () -> Void

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

            // (C) 교환/반품 신청, 배송조회 버튼
            HStack {
                Button("교환, 반품 신청") {
                    onRequestRefund()
                }
                .buttonStyle(.bordered)

                Button("배송조회") {
                    onTracking()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 6)
    }

    // 날짜 포맷
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d(EEE)"
        return formatter.string(from: date)
    }
}

// (D) 배송조회 결과를 보여주는 임시 뷰
struct TrackingView: View {
    let trackingInfo: TrackingInfo

    var body: some View {
        VStack(spacing: 16) {
            Text("주문번호: \(trackingInfo.orderID)")
                .font(.headline)

            if let c = trackingInfo.carrier {
                Text("택배사: \(c)")
            }
            if let tn = trackingInfo.trackingNumber {
                Text("송장번호: \(tn)")
            }
            if let status = trackingInfo.shippingStatus {
                Text("배송상태: \(status)")
            }
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}

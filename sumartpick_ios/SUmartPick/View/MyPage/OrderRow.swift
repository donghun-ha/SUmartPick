//
//  OrderRow.swift
//  SUmartPick
//
//  Created by aeong on 1/21/25.
//

import SwiftUI

struct OrderRow: View {
    let order: OrderItem
    // 해당 주문의 ML 테스트 결과 (예상 도착 시간)
    let mlTestResult: Date?
    // ML 데이터를 가져오기 위한 클로저
    let onFetchMLTest: () -> Void
    // 반품 신청 액션
    let onRequestRefund: () -> Void
    // 리뷰 작성 액션
    let onWriteReview: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let arrival = order.arrivalTime {
                Text("\(formatDate(arrival)) 도착")
                    .font(.subheadline)
            } else {
                Text("\(formatDate(order.orderDate)) 주문")
                    .font(.subheadline)
            }

            Text("도착 예정 : \(mlTestResult?.formatted(date: .abbreviated, time: .shortened) ?? "없음")")
                .font(.subheadline)
                .onAppear {
                    if mlTestResult == nil {
                        onFetchMLTest()
                    }
                }

            Text(order.productName)
                .font(.headline)
            Text("\(Int(order.productPrice))원 · 1개")
                .font(.subheadline)

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

                if order.orderState == "Delivered" {
                    Button("리뷰 작성") {
                        onWriteReview()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("리뷰 작성") {
                        // 배송 완료되지 않은 주문은 동작 없음
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

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d(EEE)"
        return formatter.string(from: date)
    }
}

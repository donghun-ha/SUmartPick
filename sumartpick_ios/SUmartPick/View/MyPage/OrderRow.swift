//
//  OrderRow.swift
//  SUmartPick
//
//  Created by aeong on 1/21/25.
//

import SwiftUI

struct OrderRow: View {
    let order: OrderItem
    // 추가: 머신러닝 테스트 결과 값을 전달받습니다.
    let mlTestResult: Date?
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

            // 도착 예정 시간: mlTestResult 값을 포맷하여 표시 (값이 없으면 "없음" 출력)
            Text("도착 예정 : \(mlTestResult?.formatted(date: .abbreviated, time: .shortened) ?? "없음")")
                .font(.subheadline)

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

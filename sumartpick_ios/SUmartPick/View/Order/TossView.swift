//
//  TossView.swift
//  SUmartPick
//
//  Created by 하동훈 on 3/2/2025.
//

import SwiftUI
import TossPayments

struct TossView: View {
    @State private var isShow: Bool = true
    @State private var orderCompleted: Bool = false
    let userId: String
    let address: String
    let products: [OrderModels]
    
    var totalPrice: Int {
        return products.reduce(0) { $0 + $1.total_price }
    }

    var body: some View {
        VStack {
        }
        .onAppear {
            isShow = true
        }
        .sheet(isPresented: $isShow) {
            TossPaymentsView(
                clientKey: "test_ck_nRQoOaPz8L4dWb1vZJqW8y47BMw6",
                paymentMethod: .CARD,
                paymentInfo: DefaultPaymentInfo(
                    amount: Double(totalPrice),
                    orderId: UUID().uuidString,
                    orderName: "SUmartPick 결제"
                ),
                isPresented: $isShow
            )
            .onSuccess { _, _, _ in
                Task { await processOrder() }
            }
            .onFail { _, errorMessage, _ in
                print("❌ 결제 실패: \(errorMessage)")
            }
        }
        .alert(isPresented: $orderCompleted) {
            Alert(title: Text("결제 완료"), message: Text("주문이 성공적으로 완료되었습니다!"), dismissButton: .default(Text("확인")))
        }
    }

    private func processOrder() async {
        let order = OrderRequest(
            User_ID: userId,
            Order_Date: ISO8601DateFormatter().string(from: Date()),
            Address: address,
            payment_method: "Toss Payments",
            Order_state: "Preparing_for_delivery",
            products: products
        )

        do {
            let response = try await OrderService.shared.createOrder(order: order)
            print("✅ 서버 응답: \(response)")
            DispatchQueue.main.async { orderCompleted = true }
        } catch {
            print("❌ 주문 실패: \(error.localizedDescription)")
        }
    }
}

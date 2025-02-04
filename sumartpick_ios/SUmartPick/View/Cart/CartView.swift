//
//  CartView.swift
//  SUmartPick
//
//  Created by 이종남 on 2/3/25.
//

import SwiftUI
import RealmSwift

struct CartView: View {
    @ObservedResults(CartItem.self) var cartItems
    @StateObject private var cartViewModel = CartViewModel()

    var totalPrice: Double {
        cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(cartItems) { item in
                        HStack {
                            AsyncImage(url: URL(string: item.productImage)) { image in
                                image.resizable().frame(width: 60, height: 60)
                            } placeholder: {
                                ProgressView()
                            }

                            VStack(alignment: .leading) {
                                Text(item.productName)
                                    .font(.headline)
                                Text("\(Int(item.price))원")
                                    .foregroundColor(.gray)

                                // 수량 조절
                                HStack {
                                    Button(action: {
                                        if item.quantity > 1 {
                                            try! item.realm?.write {
                                                item.quantity -= 1
                                            }
                                        }
                                    }) {
                                        Image(systemName: "minus.circle")
                                    }

                                    Text("\(item.quantity)")
                                        .padding(.horizontal, 5)

                                    Button(action: {
                                        try! item.realm?.write {
                                            item.quantity += 1
                                        }
                                    }) {
                                        Image(systemName: "plus.circle")
                                    }
                                }
                            }
                            Spacer()

                            // 삭제 버튼
                            Button(action: {
                                cartViewModel.removeFromCart(userId: item.userId, productId: item.productId)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }

                // ✅ 총 금액 & 결제 버튼
                HStack {
                    Text("총 금액: \(Int(totalPrice))원")
                        .font(.headline)
                    Spacer()
                    Button("구매하기") {
                        print("✅ 결제 진행 중...")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("장바구니")
        }
    }
}

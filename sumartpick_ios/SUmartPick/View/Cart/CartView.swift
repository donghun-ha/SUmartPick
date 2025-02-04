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
            VStack(spacing: 0) {
                // ✅ 상단 타이틀
                HStack {
                    Text("장바구니")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .background(Color.white)
                .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)

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

                                // ✅ 수량 조절
                                HStack {
                                    Button(action: {
                                        if item.quantity > 1 && !item.isInvalidated {
                                            cartViewModel.updateQuantity(item: item, newQuantity: item.quantity - 1)
                                        }
                                    }) {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(item.quantity > 1 ? .blue : .gray)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // ✅ 버튼 스타일 적용 (이벤트 전파 방지)

                                    Text("\(item.quantity)")
                                        .padding(.horizontal, 5)

                                    Button(action: {
                                        if !item.isInvalidated {
                                            cartViewModel.updateQuantity(item: item, newQuantity: item.quantity + 1)
                                        }
                                    }) {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // ✅ 버튼 스타일 적용 (이벤트 전파 방지)
                                }
                            }
                            Spacer()

                            // ✅ 삭제 버튼
                            Button(action: {
                                if !item.isInvalidated {
                                    cartViewModel.removeFromCart(userId: item.userId, productId: item.productId)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle()) // ✅ 버튼 스타일 적용 (이벤트 전파 방지)
                        }
                        .padding(.vertical, 5)
                        .contentShape(Rectangle()) // ✅ 터치 가능한 영역을 명확하게 설정
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.bottom, 70)

                // ✅ 총 금액 & 구매하기 버튼
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
                    .buttonStyle(PlainButtonStyle()) // ✅ 구매 버튼도 이벤트 전파 방지
                }
                .padding()
                .background(Color.white)
                .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: -2)
            }
            .navigationBarHidden(true)
        }
    }
}

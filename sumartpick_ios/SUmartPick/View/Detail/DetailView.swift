//  최근본 상품 5개 productID -> 5개 realm
//  DetailView.swift
//  SUmartPick
//
//  Created by 이종남 on 1/23/25.
//

import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel = ProductDetailViewModel()
    let productID: Int
    @State private var quantity: Int = 1

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .font(.title)
                    .foregroundColor(.gray)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if let product = viewModel.product {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // 상품 이미지
                        HStack {
                            AsyncImage(url: URL(string: product.previewImage)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(12)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 300)
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity) // ✅ 이미지 가운데 정렬
                        
                        // 🔹 카테고리명 > 별점(리뷰)
                        HStack {
                            Text(product.category)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)

                        // 상품 이름
                        Text(product.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        // 상품 가격
                        HStack {
                            Text("\(Int(product.price) * quantity)원")
                                .font(.title)
                                .foregroundColor(.black)

                            Spacer()

                            HStack(spacing: 10) {
                                Button(action: {
                                    if quantity > 1 {
                                        quantity -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                }

                                Text("\(quantity)")
                                    .font(.title3)

                                Button(action: {
                                    quantity += 1
                                }) {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        /// 🔹 장바구니 & 바로구매 버튼
                        HStack(spacing: 16) {
                            Button(action: {
                                print("장바구니 버튼 클릭")
                            }) {
                                Text("장바구니 담기")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                            }

                            Button(action: {
                                print("바로구매 버튼 클릭")
                            }) {
                                Text("바로구매")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)

                        // 구분선
                        Divider()
                            .padding(.horizontal)

                    }
                }
            } else {
                Text("상품 정보를 불러올 수 없습니다.")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            viewModel.fetchProductDetails(productID: productID)
        }
    }
}

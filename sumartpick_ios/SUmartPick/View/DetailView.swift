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

                        // 상품 이름
                        Text(product.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        // 상품 가격
                        Text("\(Int(product.price))원")
                            .font(.title)
                            .foregroundColor(.blue)
                            .padding(.horizontal)

                        // 상품 상세 설명
                        Text(product.detail ?? "상세 설명이 없습니다.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        // 구분선
                        Divider()
                            .padding(.horizontal)

                        // 구매 버튼
                        Button(action: {
                            print("구매하기 버튼 클릭")
                        }) {
                            Text("구매하기")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
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

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
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if let product = viewModel.product {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        AsyncImage(url: URL(string: product.preview_image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)

                        Text(product.name)
                            .font(.title)
                            .bold()

                        Text(product.detail!)
                            .font(.body)

                        Text("Price: $\(product.price, specifier: "%.2f")원")
                            .font(.headline)

                        Text("Category: \(product.category)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            } else {
                Text("Product not found")
            }
        }
        .onAppear {
            viewModel.fetchProductDetails(productID: productID)
        }
    }
}

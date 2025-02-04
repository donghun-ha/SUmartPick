//  최근본 상품 5개 productID -> 5개 realm
//  DetailView.swift
//  SUmartPick
//
//  Created by 이종남 on 1/23/25.
//

import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel = ProductDetailViewModel()
    @StateObject private var cartViewModel = CartViewModel()
    @EnvironmentObject var authState: AuthenticationState
    
    let productID: Int
    @State private var quantity: Int = 1
    
    // alert 상태관리
    @State private var showAlert = false
    @State private var navigateToCart = false

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

                        // 카테고리명 + 별점 + 리뷰 개수
                        HStack {
                            Text(product.category)
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Spacer()

                            HStack(spacing: 4) {
                                StarRatingView(rating: Int(viewModel.averageRating))
                                Text(String(format: "%.1f", viewModel.averageRating))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("(\(viewModel.reviews.count))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)

                        // 상품 이름
                        Text(product.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        // 상품 가격 & 수량 조절
                        HStack {
                            Text("\(Int(product.price) * quantity)원")
                                .font(.title)
                                .foregroundColor(.black)

                            Spacer()

                            HStack(spacing: 10) {
                                Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                }

                                Text("\(quantity)")
                                    .font(.title3)

                                Button(action: { quantity += 1 }) {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // 장바구니 & 바로구매 버튼
                        HStack(spacing: 16) {
                            Button("장바구니 담기") {
                                if let userId = authState.userIdentifier {
                                    cartViewModel.addToCart(userId: userId, product: product, quantity: quantity)
                                    showAlert = true
                                }else{
                                    print("로그인 후 이용해주세요.")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 2)
                            )

                            Button("바로구매") {
                                print("바로구매 버튼 클릭")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)

                        Divider().padding(.horizontal)
                        
                        // 장바구니로 이동
                        NavigationLink(destination: CartView(), isActive: $navigateToCart) {
                            EmptyView()
                        }

                        // ✅ 리뷰 섹션
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("리뷰 (\(viewModel.reviews.count))")
                                    .font(.headline)
                                Spacer()
                                NavigationLink(destination: ReviewListView(reviews: viewModel.reviews)) {
                                    Text("리뷰 전체보기 >")
                                        .foregroundColor(.blue)
                                        .font(.subheadline)
                                }
                            }
                            .padding(.horizontal)

                            ForEach(viewModel.reviews.prefix(3)) { review in
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text(maskUserID(review.userId))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Spacer()
                                        StarRatingView(rating: review.star ?? 0)
                                    }
                                    if let content = review.reviewContent {
                                        Text(content)
                                            .font(.body)
                                            .lineLimit(2)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchProductDetails(productID: productID)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("상품이 장바구니에 담겼습니다"),
                message: Text("장바구니로 이동하시겠습니까?"),
                primaryButton: .default(Text("장바구니로 이동"), action: {
                    navigateToCart = true
                }),
                secondaryButton: .cancel(Text("쇼핑 계속하기"))
            )
        }
    }

    // ✅ 사용자 ID 마스킹 처리
    func maskUserID(_ userID: String) -> String {
        let prefix = userID.prefix(2)
        let suffix = userID.suffix(2)
        let masked = String(repeating: "*", count: max(0, userID.count - 4))
        return "\(prefix)\(masked)\(suffix)"
    }
}

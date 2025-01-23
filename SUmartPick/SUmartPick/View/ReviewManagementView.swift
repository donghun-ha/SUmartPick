//
//  ReviewManagementView.swift
//  SUmartPick
//
//  Created by aeong on 1/23/25.
//

import SwiftUI

struct ReviewManagementView: View {
    @EnvironmentObject var authState: AuthenticationState
    @StateObject var viewModel = ReviewsViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.reviews) { review in
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.productName ?? "상품명없음")
                        .font(.headline)

                    if let star = review.star {
                        Text("별점: \(star)/5")
                            .font(.subheadline)
                    }

                    Text(review.reviewContent ?? "")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("리뷰 관리")
            .task {
                // 로그인된 유저를 바탕으로 리뷰 목록 로딩
                if let userID = authState.userIdentifier {
                    await viewModel.fetchReviews(for: userID)
                }
            }
            .alert("오류 발생", isPresented: $viewModel.showErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

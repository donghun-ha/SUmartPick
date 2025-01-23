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
                VStack(alignment: .leading, spacing: 8) { // spacing을 8로 조정
                    Text(review.productName ?? "상품명 없음")
                        .font(.headline)

                    // 별점 아이콘으로 표시
                    if let star = review.star {
                        HStack(spacing: 4) {
                            StarRatingView(rating: Int(star))
                        }
                    }

                    Text(review.reviewContent ?? "")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4) // 각 리뷰 항목의 세로 패딩 추가
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

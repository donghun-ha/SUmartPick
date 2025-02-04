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

    // (A) 수정 시트 제어
    @State private var showEditSheet = false
    @State private var editingReview: ReviewItem? = nil

    // (B) 삭제 확인 대화상자 제어
    @State private var showDeleteConfirm = false
    @State private var reviewToDelete: ReviewItem? = nil

    var body: some View {
        NavigationStack {
            List(viewModel.reviews) { review in
                VStack(alignment: .leading, spacing: 8) {
                    // 1) 상품명
                    Text(review.productName ?? "상품명 없음")
                        .font(.headline)

                    // 2) 별점
                    if let star = review.star {
                        HStack(spacing: 4) {
                            StarRatingView(rating: star)
                        }
                    }

                    // 3) 리뷰 내용
                    Text(review.reviewContent ?? "")
                        .font(.body)
                        .foregroundColor(.secondary)

                    // 4) 수정 / 삭제 버튼
                    HStack {
                        Spacer()
                        Button("수정") {
                            // 시트 열기
                            editingReview = review
                            showEditSheet = true
                        }
                        .buttonStyle(.bordered)

                        Button("삭제") {
                            // 삭제 확인
                            reviewToDelete = review
                            showDeleteConfirm = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("리뷰 관리")
            // 화면 뜨면 리뷰 목록 조회
            .task {
                if let userID = authState.userIdentifier {
                    await viewModel.fetchReviews(for: userID)
                }
            }
            // 에러 알림
            .alert("오류 발생", isPresented: $viewModel.showErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            // (C) 수정 시트
            .sheet(isPresented: $showEditSheet) {
                if let editReview = editingReview {
                    ReviewEditSheet(
                        review: editReview,
                        viewModel: viewModel,
                        isPresented: $showEditSheet
                    )
                }
            }
            // (D) 삭제 확인 (confirmationDialog or alert)
            .confirmationDialog("리뷰를 삭제하시겠습니까?",
                                isPresented: $showDeleteConfirm,
                                titleVisibility: .visible)
            {
                Button("삭제", role: .destructive) {
                    Task {
                        if let userID = authState.userIdentifier,
                           let delReview = reviewToDelete
                        {
                            await viewModel.deleteReview(reviewID: delReview.id, userID: userID)
                        }
                    }
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("삭제하면 복구할 수 없습니다.")
            }
        }
    }
}

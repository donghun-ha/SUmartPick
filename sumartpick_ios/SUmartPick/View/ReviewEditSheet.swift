//
//  ReviewEditSheet.swift
//  SUmartPick
//
//  Created by aeong on 2/3/25.
//

import SwiftUI

struct ReviewEditSheet: View {
    let review: ReviewItem
    @ObservedObject var viewModel: ReviewsViewModel
    @Binding var isPresented: Bool

    // 새 리뷰 내용과 별점을 입력받는 State
    @State private var newContent: String = ""
    @State private var newStar: Int = 5

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("리뷰 수정")) {
                    TextField("리뷰 내용을 입력하세요", text: $newContent)
                    Stepper("별점: \(newStar)", value: $newStar, in: 1 ... 5)
                }
            }
            .navigationTitle("리뷰 수정")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        Task {
                            // 서버로 수정 요청
                            await viewModel.updateReview(
                                reviewID: review.id,
                                newContent: newContent,
                                star: newStar,
                                userID: review.userId
                            )
                            // 시트 닫기
                            isPresented = false
                        }
                    }
                }
            }
            .onAppear {
                // 시트 열릴 때 기존 리뷰 내용 불러옴
                newContent = review.reviewContent ?? ""
                newStar = review.star ?? 5
            }
        }
    }
}

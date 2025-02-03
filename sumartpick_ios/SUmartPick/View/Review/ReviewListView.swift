//
//  ReviewListView.swift
//  SUmartPick
//
//  Created by 이종남 on 2/3/25.
//

import SwiftUI

struct ReviewListView: View {
    let reviews: [ReviewItem]  

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("상품 리뷰 (\(reviews.count))")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                ForEach(reviews) { review in
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
                                .padding(.top, 2)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("리뷰 전체보기")
    }

    func maskUserID(_ userID: String) -> String {
        let prefix = userID.prefix(2)
        let suffix = userID.suffix(2)
        let masked = String(repeating: "*", count: max(0, userID.count - 4))
        return "\(prefix)\(masked)\(suffix)"
    }
}

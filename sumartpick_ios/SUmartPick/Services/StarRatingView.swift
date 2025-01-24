//
//  StarRatingView.swift
//  SUmartPick
//
//  Created by aeong on 1/23/25.
//

import SwiftUI

struct StarRatingView: View {
    let rating: Int
    let maxRating: Int = 5
    let filledColor: Color = .yellow
    let emptyColor: Color = .gray

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1 ... maxRating, id: \.self) { index in
                let starType = starTypeFor(index: index)
                Image(systemName: starType)
                    .foregroundColor(starType == "star.fill" || starType == "star.leadinghalf.filled" ? filledColor : emptyColor)
            }
        }
        .font(.subheadline)
    }

    // 별의 타입을 결정하는 함수
    private func starTypeFor(index: Int) -> String {
        if rating >= Int(index) {
            return "star.fill"
        } else {
            return "star"
        }
    }
}

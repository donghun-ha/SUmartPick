//
//  ProductCardView.swift
//  SUmartPick
//
//  Created by 하동훈 on 3/2/2025.
//

import SwiftUI

struct ProductCardView: View {
    let product: SearchProduct

    var body: some View {
        HStack(spacing: 12) {
            // 상품 이미지
            AsyncImage(url: URL(string: product.preview_image ?? "")) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3) // 로딩 중 기본 배경
            }
            .frame(width: 100, height: 100)
            .cornerRadius(10) // 이미지 둥글게

            VStack(alignment: .leading, spacing: 8) {
                // 상품명
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2) // 긴 제목 줄이기
                
                // 가격 (.뒤 소수점 제거)
                Text("\(Int(product.price))원") // 소수점 제거
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12) // 카드 둥글게
        .shadow(radius: 3) // 그림자 효과
    }
}

//
//  ReviewItem.swift
//  SUmartPick
//
//  Created by aeong on 1/23/25.
//

import Foundation

struct ReviewItem: Codable, Identifiable {
    // PrimaryKey를 id로 사용 -> ReviewSeq
    let id: Int
    let userId: String
    let productId: Int
    let reviewContent: String?
    let star: Int?
    let productName: String? // join한 상품명

    enum CodingKeys: String, CodingKey {
        case id = "ReviewSeq"
        case userId = "User_ID"
        case productId = "Product_ID"
        case reviewContent = "Review_Content"
        case star = "Star"
        case productName = "product_name"
    }
}

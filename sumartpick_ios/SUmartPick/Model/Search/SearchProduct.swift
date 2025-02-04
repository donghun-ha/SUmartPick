//
//  SearchProduct.swift
//  SUmartPick
//
//  Created by 하동훈 on 3/2/2025.
//

import Foundation

struct SearchProduct: Identifiable, Codable {
    let id: Int
    let category: Int
    let name: String
    let preview_image: String?
    let price: Double
    let detail: String?
    let manufacturer: String?
    let created: String?

    enum CodingKeys: String, CodingKey {
        case id = "Product_ID"
        case category = "Category_ID"
        case name, preview_image, price, detail, manufacturer, created
    }
}

//
//  Product.swift
//  SUmartPick
//
//  Created by 이종남 on 1/23/25.
//

import Foundation

struct Product: Codable {
    let productID: Int
    let name: String
    let previewImage: String
    let price: Double
    let detail: String
    let category: Category
}

struct Category: Codable {
    let categoryID: Int
    let name: String
}

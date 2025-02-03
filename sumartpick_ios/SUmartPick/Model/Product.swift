//
//  Product.swift
//  SUmartPick
//
//  Created by 이종남 on 1/23/25.
//

import Foundation

struct Product: Codable, Identifiable {
    let productID: Int
    let name: String
    let previewImage: String
    let price: Double
    let detail: String?
    let category: String
    
    var id: Int { productID }
    
    enum CodingKeys: String, CodingKey {
        case productID = "Product_ID"         // JSON의 Product_ID와 매핑
        case name
        case previewImage = "preview_image"   // JSON의 preview_image와 매핑
        case price
        case detail
        case category
    }
}


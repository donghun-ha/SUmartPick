//
//  Product.swift
//  SUmartPick
//
//  Created by 이종남 on 1/23/25.
//

import Foundation

struct Product: Codable, Identifiable {
    let productID: Int        // ✅ 변수명 수정
    let name: String
    let previewImage: String  // ✅ 변수명 수정
    let price: Double
    let detail: String?
    let category: String
    
    var id: Int { productID } // ✅ Identifiable을 위한 프로퍼티

    // ✅ JSON 키와 Swift 프로퍼티를 매핑하는 CodingKeys 추가
    enum CodingKeys: String, CodingKey {
        case productID = "Product_ID"
        case name
        case previewImage = "preview_image"
        case price
        case detail
        case category
    }
}


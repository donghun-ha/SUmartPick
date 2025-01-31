//
//  Product.swift
//  SUmartPick
//
//  Created by 이종남 on 1/23/25.
//

import Foundation

struct Product: Codable , Identifiable{
    let id: Int // Identifiable을 준수하기 위해 'id' 필드 추가
    let name: String
    let previewImage: String
    let price: Double
    let detail: String
    let category: Category
    
    var productID: Int {id} // 기존 코드 호환성을 유지하기 위해 추가
}

struct Category: Codable {
    let categoryID: Int
    let name: String
}

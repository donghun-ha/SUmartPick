//
//  Product.swift
//  SUmartPick
//
//  Created by 이종남 on 1/23/25.
//

import Foundation

struct Product: Codable , Identifiable{
    let Product_ID: Int
    let name: String
    let preview_image: String
    let price: Double
    let detail: String? // 필수 값 옵셔널로 변경
    let category: String
    
    var id: Int { Product_ID } // Identifiable을 위한 프로퍼티
}

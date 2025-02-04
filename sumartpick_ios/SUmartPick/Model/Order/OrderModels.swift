//
//  OrderModels.swift
//  SUmartPick
//
//  Created by 하동훈 on 3/2/2025.
//

import Foundation

struct OrderModels: Codable {
    let Product_ID: Int
    let quantity: Int
    let total_price: Int
}

struct OrderRequest: Codable {
    let User_ID: String
    let Order_Date: String
    let Address: String
    let payment_method: String
    let Order_state: String
    let products: [OrderModels]
}

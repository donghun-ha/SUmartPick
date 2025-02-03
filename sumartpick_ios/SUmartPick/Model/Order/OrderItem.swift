//
//  OrderItem.swift
//  SUmartPick
//
//  Created by aeong on 1/21/25.
//

import Foundation

struct OrderItem: Codable, Identifiable {
    let id: Int // Order_ID
    let productSeq: Int
    let userId: String
    let productId: Int
    let orderDate: Date // 서버에서 날짜를 ISO8601 등으로 준다면 Date로 파싱
    let address: String
    let refundDemandsTime: Date?
    let refundTime: Date?
    let paymentMethod: String?
    let arrivalTime: Date?
    let orderState: String
    let productName: String
    let productImage: String?
    let productPrice: Double

    enum CodingKeys: String, CodingKey {
        case id = "Order_ID"
        case productSeq = "Product_seq"
        case userId = "User_ID"
        case productId = "Product_ID"
        case orderDate = "Order_Date"
        case address = "Address"
        case refundDemandsTime = "refund_demands_time"
        case refundTime = "refund_time"
        case paymentMethod = "payment_method"
        case arrivalTime = "Arrival_Time"
        case orderState = "Order_state"
        case productName = "product_name"
        case productImage = "product_image"
        case productPrice = "product_price"
    }
}
